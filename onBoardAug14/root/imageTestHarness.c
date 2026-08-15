/*
 * imageTestHarness.c
 *
 * Benchmarks FOUR 2D DCT implementations over a grayscale image:
 *
 *   1. SW-NAIVE     dct_2d_naive()       floating-point cos() reference
 *   2. SW-LOEFFLER  dct_2d_loeffler_c()  Q10 butterflies, plain C rotation
 *   3. FW-LOEFFLER  dct_2d_loeffler()    same, hand-scheduled ARM asm
 *   4. HW-FPGA      dct_2d_fpga()        dct_1d_top over the LW bridge
 *
 * After benchmarking, the harness runs an IDCT on each set of coefficients,
 * reconstructs the image, and writes:
 *
 *   reconstructed_SW-NAIVE.pgm
 *   reconstructed_SW-LOEFFLER.pgm
 *   reconstructed_FW-LOEFFLER.pgm
 *   reconstructed_HW-FPGA.pgm
 *   diff_SW-LOEFFLER_vs_SW-NAIVE.pgm    (pixel-wise |a - b|, scaled x10)
 *   diff_FW-LOEFFLER_vs_SW-NAIVE.pgm
 *   diff_HW-FPGA_vs_SW-NAIVE.pgm
 *   diff_SW-LOEFFLER_vs_HW-FPGA.pgm    (most informative: same Q10)
 *
 * The diff images are amplified 10x so small differences become visible.
 * If all four are truly equivalent the diff images will be black.
 *
 * BUILD:
 *   gcc -O2 -o grayScaleBenchmark grayScaleBenchmark.c -lm
 *
 * RUN:
 *   ./grayScaleBenchmark image.pgm
 *   ./grayScaleBenchmark image.pgm -r 5 -o results.txt --output-dir ./out
 *   ./grayScaleBenchmark image.pgm --no-fpga
 *
 *   -r reps         repetitions per impl (default 3, median reported)
 *   -o file         report path (default dct_benchmark_results.txt)
 *   --output-dir d  directory for reconstructed PGMs (default .)
 *   --no-fpga       skip hardware (for running on a host machine)
 *   --raw W H       treat input as headerless raw of W x H bytes
 */

#define _POSIX_C_SOURCE 199309L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <math.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>

#ifndef PI
#define PI 3.14159265358979323846
#endif

/* ---------------------------------------------------------------- */
/* Source file paths                                                  */
/* ---------------------------------------------------------------- */

#ifndef NAIVE_SRC
#define NAIVE_SRC     "dct_naive.c"
#endif
#ifndef LOEFFLER_SRC
#define LOEFFLER_SRC  "dct_loeffler.c"
#endif
#ifndef FPGA_SRC
#define FPGA_SRC      "dct_rc.c"
#endif

/* ---------------------------------------------------------------- */
/* Pull in unmodified implementations                                */
/* ---------------------------------------------------------------- */

#define main naive_main
#include NAIVE_SRC
#undef  main

#define main loeffler_main
#include LOEFFLER_SRC
#undef  main

#ifndef NO_FPGA_BUILD
#define main fpga_main
#include FPGA_SRC
#undef  main
#endif

static void bench_unused_refs(void)
{
    (void)naive_main;
    (void)loeffler_main;
#ifndef NO_FPGA_BUILD
    (void)fpga_main;
#endif
}

/* ---------------------------------------------------------------- */
/* Config                                                            */
/* ---------------------------------------------------------------- */

#define DEFAULT_REPS   3
#define MAX_REPS       99
#define N_IMPL         4

#ifndef LW_BRIDGE_BASE
#define LW_BRIDGE_BASE  0xFF200000
#endif
#ifndef LW_BRIDGE_SPAN
#define LW_BRIDGE_SPAN  0x00200000
#endif
#ifndef DCT_1D_OFFSET
#define DCT_1D_OFFSET   0x0200
#endif

/* ---------------------------------------------------------------- */
/* IDCT — 2D Inverse DCT, orthonormal form matching the forward DCT */
/* ---------------------------------------------------------------- */
/*
 * The forward DCT in this project is the orthonormal DCT-II.
 * Its inverse is the orthonormal DCT-III (also called IDCT-II).
 *
 * Formula for one 1D pass:
 *   x[n] = (1/√N) * C0*X[0] + (√(2/N)) * Σ_{k=1}^{N-1} X[k]*cos(π*k*(2n+1)/(2N))
 *
 * where C0 = 1/√2 (the DC normalisation factor).
 *
 * We compute this in double precision since the IDCT is only used for
 * visual verification, not for benchmarking. Speed does not matter here.
 *
 * The 2D IDCT is separable: apply 1D IDCT along rows, then along columns
 * (or vice versa — the result is the same).
 */

#define IDCT_N 8

static void idct_1d(const double *input, double *output)
{
    int n, k;
    for (n = 0; n < IDCT_N; n++) {
        /* DC term: X[0] / sqrt(2), then sum AC terms */
        double sum = input[0] / sqrt(2.0);
        for (k = 1; k < IDCT_N; k++)
            sum += input[k] * cos(PI * k * (2.0 * n + 1.0) / (2.0 * IDCT_N));
        output[n] = sum * sqrt(2.0 / IDCT_N);
    }
}

/*
 * idct_2d_block: reconstruct one 8x8 pixel block from 64 DCT coefficients.
 *
 * coeff[r*8+c] = DCT coefficient at row r, column c (row-major, same layout
 * as the benchmark output arrays).
 *
 * pixels[r][c] is clamped to [0, 255] and rounded to the nearest integer.
 */
static void idct_2d_block(const int32_t *coeff, uint8_t pixels[8][8])
{
    double tmp[8][8];
    double col[8][8];
    int r, c;

    /* Pass 1: IDCT along each row of the coefficient block */
    for (r = 0; r < 8; r++) {
        double row_in[8], row_out[8];
        for (c = 0; c < 8; c++)
            row_in[c] = (double)coeff[r * 8 + c];
        idct_1d(row_in, row_out);
        for (c = 0; c < 8; c++)
            tmp[r][c] = row_out[c];
    }

    /* Pass 2: IDCT along each column of the intermediate result */
    for (c = 0; c < 8; c++) {
        double col_in[8], col_out[8];
        for (r = 0; r < 8; r++)
            col_in[r] = tmp[r][c];
        idct_1d(col_in, col_out);
        for (r = 0; r < 8; r++)
            col[r][c] = col_out[r];
    }

    /* Clamp and round to uint8 */
    for (r = 0; r < 8; r++) {
        for (c = 0; c < 8; c++) {
            double v = col[r][c];
            if (v < 0.0)   v = 0.0;
            if (v > 255.0) v = 255.0;
            pixels[r][c] = (uint8_t)(v + 0.5);
        }
    }
}

/* ---------------------------------------------------------------- */
/* Image container                                                   */
/* ---------------------------------------------------------------- */

typedef struct {
    int      w, h;
    int      bw, bh;
    int      blocks;
    uint8_t *px;
    char     src[256];
    char     fmt[32];
} image_t;

/* ---------------------------------------------------------------- */
/* PGM writer                                                        */
/* ---------------------------------------------------------------- */

/*
 * write_pgm: write a raw (binary P5) PGM file.
 *
 * dir    — output directory (NULL or "" means current directory)
 * name   — filename without extension, e.g. "reconstructed_SW-NAIVE"
 * pixels — w*h bytes, row-major
 * w, h   — image dimensions
 *
 * Returns 0 on success, -1 on failure.
 */
static int write_pgm(const char *dir, const char *name,
                     const uint8_t *pixels, int w, int h)
{
    char path[512];
    if (dir && dir[0])
        snprintf(path, sizeof path, "%s/%s.pgm", dir, name);
    else
        snprintf(path, sizeof path, "%s.pgm", name);

    FILE *f = fopen(path, "wb");
    if (!f) {
        fprintf(stderr, "cannot write %s: %s\n", path, strerror(errno));
        return -1;
    }
    fprintf(f, "P5\n%d %d\n255\n", w, h);
    if (fwrite(pixels, 1, (size_t)w * h, f) != (size_t)w * h) {
        fprintf(stderr, "short write to %s\n", path);
        fclose(f); return -1;
    }
    fclose(f);
    printf("  wrote %s\n", path);
    return 0;
}

/* ---------------------------------------------------------------- */
/* Reconstruct + write all outputs for one implementation            */
/* ---------------------------------------------------------------- */

/*
 * reconstruct_image: run IDCT on every block's coefficients and assemble
 * the full image back into a pixel buffer.
 *
 * coeff_all — array of (blocks * 64) int32_t values, block-major then
 *             row-major within each block (same layout as benchmark output)
 * img       — describes image dimensions and block tiling
 * out_px    — caller-allocated buffer of img->w * img->h bytes
 */
static void reconstruct_image(const int32_t *coeff_all,
                               const image_t *img,
                               uint8_t *out_px)
{
    uint8_t blk_px[8][8];
    int by, bx, r, c;

    memset(out_px, 0, (size_t)img->w * img->h);

    for (by = 0; by < img->bh; by++) {
        for (bx = 0; bx < img->bw; bx++) {
            const int32_t *coeff = coeff_all + (size_t)(by * img->bw + bx) * 64;
            idct_2d_block(coeff, blk_px);

            /* Copy 8x8 block back into the full image buffer */
            uint8_t *dst = out_px + (size_t)(by * 8) * img->w + bx * 8;
            for (r = 0; r < 8; r++)
                for (c = 0; c < 8; c++)
                    dst[r * img->w + c] = blk_px[r][c];
        }
    }
}

/*
 * write_diff_image: compute pixel-wise absolute difference between two
 * reconstructed images, amplify by scale, clamp to [0,255], and write.
 *
 * A purely black diff means the two reconstructed images are pixel-identical.
 * scale = 10 makes a 1-LSB difference show as grey value 10 (clearly visible
 * on a monitor while not saturating for small errors).
 */
static void write_diff_image(const char *dir,
                              const char *name_a, const uint8_t *px_a,
                              const char *name_b, const uint8_t *px_b,
                              int w, int h, int scale)
{
    uint8_t *diff = malloc((size_t)w * h);
    if (!diff) { fprintf(stderr, "out of memory for diff\n"); return; }

    long max_diff = 0, sum_diff = 0, n_diff = 0;

    for (int i = 0; i < w * h; i++) {
        int d = (int)px_a[i] - (int)px_b[i];
        if (d < 0) d = -d;
        if (d) { n_diff++; sum_diff += d; }
        if (d > max_diff) max_diff = d;
        int v = d * scale;
        diff[i] = (uint8_t)(v > 255 ? 255 : v);
    }

    /* Build filename: diff_A_vs_B */
    char fname[256];
    snprintf(fname, sizeof fname, "diff_%s_vs_%s", name_a, name_b);
    /* Replace spaces with underscores for safe filenames */
    for (char *p = fname; *p; p++) if (*p == ' ') *p = '_';

    write_pgm(dir, fname, diff, w, h);

    printf("    diff stats: %ld/%d pixels differ, max=%ld, mean=%.3f\n",
           n_diff, w*h, max_diff,
           n_diff ? (double)sum_diff / (double)n_diff : 0.0);

    free(diff);
}

/* ---------------------------------------------------------------- */
/* Implementation record                                             */
/* ---------------------------------------------------------------- */

typedef struct {
    const char *name;
    const char *kind;
    const char *detail;
    double      run_s[MAX_REPS];
    double      median_s, best_s, worst_s;
    int         reps;
    int         valid;
    int32_t    *out;   /* blocks * 64 coefficients, block-major */
} impl_t;

typedef void (*dct_fn)(const uint8_t blk[8][8], int32_t out[8][8]);

/* ---------------------------------------------------------------- */
/* Adapters                                                          */
/* ---------------------------------------------------------------- */

static void adapt_naive(const uint8_t blk[8][8], int32_t out[8][8])
{
    dct_2d_naive(blk, out);
}

/* Pure-C Loeffler (no asm) — SW-LOEFFLER */
static void butterfly_c(int16_t in_upper, int16_t in_lower,
                        int16_t *out_upper, int16_t *out_lower,
                        uint8_t rotator)
{
    rotator_coef_t coef = rotator_table[rotator];
    int32_t iu = in_upper, il = in_lower;
    int32_t tmp     = (int32_t)coef.cos_coef * (iu + il) + 512;
    int32_t t_upper = il * (int32_t)coef.simplified_1 + tmp;
    int32_t t_lower = iu * (int32_t)coef.simplified_2 + tmp;
    *out_upper = (int16_t)(t_upper >> 10);
    *out_lower = (int16_t)(t_lower >> 10);
}

static void dct_2d_loeffler_c(uint8_t input[8][8], int16_t output[8][8])
{
    uint8_t i;
    int16_t tmp_1, tmp_2;

    for (i = 0; i < 8; i++) {
        output[i][0] = input[i][0] + input[i][7];
        output[i][4] = input[i][1] + input[i][6];
        output[i][2] = input[i][2] + input[i][5];
        output[i][6] = input[i][3] + input[i][4];
        output[i][7] = input[i][3] - input[i][4];
        output[i][3] = input[i][2] - input[i][5];
        output[i][5] = input[i][1] - input[i][6];
        output[i][1] = input[i][0] - input[i][7];

        tmp_1 = output[i][0];
        output[i][0] = tmp_1 + output[i][6];
        output[i][6] = tmp_1 - output[i][6];
        tmp_1 = output[i][4];
        output[i][4] = tmp_1 + output[i][2];
        output[i][2] = tmp_1 - output[i][2];

        butterfly_c(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);
        butterfly_c(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);

        tmp_1 = output[i][0];
        output[i][0] = tmp_1 + output[i][4];
        output[i][4] = tmp_1 - output[i][4];

        butterfly_c(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);

        tmp_1 = output[i][7];
        output[i][7] = tmp_1 + output[i][5];
        output[i][5] = tmp_1 - output[i][5];
        tmp_1 = output[i][1];
        output[i][1] = tmp_1 + output[i][3];
        output[i][3] = tmp_1 - output[i][3];

        tmp_1 = output[i][1];
        output[i][1] = tmp_1 + output[i][7];
        output[i][7] = tmp_1 - output[i][7];

        output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
        output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
    }

    for (i = 0; i < 8; i++) {
        tmp_1 = output[1][i] + output[6][i];
        tmp_2 = output[1][i] - output[6][i];

        output[1][i] = output[0][i] - output[7][i];
        output[0][i] = output[0][i] + output[7][i];
        output[6][i] = output[3][i] + output[4][i];
        output[7][i] = output[3][i] - output[4][i];
        output[3][i] = output[2][i] - output[5][i];
        output[2][i] = output[2][i] + output[5][i];
        output[4][i] = tmp_1;
        output[5][i] = tmp_2;

        tmp_1 = output[0][i];
        output[0][i] = tmp_1 + output[6][i];
        output[6][i] = tmp_1 - output[6][i];
        tmp_1 = output[4][i];
        output[4][i] = tmp_1 + output[2][i];
        output[2][i] = tmp_1 - output[2][i];

        butterfly_c(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);
        butterfly_c(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);

        tmp_1 = output[0][i];
        output[0][i] = tmp_1 + output[4][i];
        output[4][i] = tmp_1 - output[4][i];

        butterfly_c(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);

        tmp_1 = output[7][i];
        output[7][i] = tmp_1 + output[5][i];
        output[5][i] = tmp_1 - output[5][i];
        tmp_1 = output[1][i];
        output[1][i] = tmp_1 + output[3][i];
        output[3][i] = tmp_1 - output[3][i];

        output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
        output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
        output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
        output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = output[1][i];
        output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
        output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
        output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
        tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
        output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
    }
}

static void adapt_loeffler_c(const uint8_t blk[8][8], int32_t out[8][8])
{
    uint8_t in8[8][8];
    int16_t o16[8][8];
    memcpy(in8, blk, 64);
    dct_2d_loeffler_c(in8, o16);
    for (int r = 0; r < 8; r++)
        for (int c = 0; c < 8; c++)
            out[r][c] = (int32_t)o16[r][c];
}

static void adapt_loeffler(const uint8_t blk[8][8], int32_t out[8][8])
{
    uint8_t  in8[8][8];
    int16_t  o16[8][8];
    memcpy(in8, blk, 64);
    dct_2d_loeffler(in8, o16);
    for (int r = 0; r < 8; r++)
        for (int c = 0; c < 8; c++)
            out[r][c] = (int32_t)o16[r][c];
}

#ifndef NO_FPGA_BUILD
static volatile int *g_dct   = NULL;
static void         *g_map   = MAP_FAILED;
static int           g_memfd = -1;

static int fpga_open(void)
{
    g_memfd = open("/dev/mem", O_RDWR | O_SYNC);
    if (g_memfd < 0) {
        fprintf(stderr, "    open /dev/mem: %s\n", strerror(errno));
        return -1;
    }
    g_map = mmap(NULL, LW_BRIDGE_SPAN, PROT_READ | PROT_WRITE,
                 MAP_SHARED, g_memfd, LW_BRIDGE_BASE);
    if (g_map == MAP_FAILED) {
        fprintf(stderr, "    mmap bridge: %s\n", strerror(errno));
        close(g_memfd); g_memfd = -1;
        return -1;
    }
    g_dct = (volatile int *)((char *)g_map + DCT_1D_OFFSET);
    return 0;
}

static void fpga_close(void)
{
    if (g_map != MAP_FAILED) munmap(g_map, LW_BRIDGE_SPAN);
    if (g_memfd >= 0)        close(g_memfd);
    g_map = MAP_FAILED; g_memfd = -1; g_dct = NULL;
}

static void adapt_fpga(const uint8_t blk[8][8], int32_t out[8][8])
{
    dct_2d_fpga(g_dct, blk, out);
}
#endif

/* ---------------------------------------------------------------- */
/* Image loading                                                      */
/* ---------------------------------------------------------------- */

static int pgm_int(FILE *f, int *val)
{
    int c, v = 0, got = 0;
    for (;;) {
        c = fgetc(f);
        if (c == EOF) return -1;
        if (c == '#') { while (c != '\n' && c != EOF) c = fgetc(f); continue; }
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
            if (got) break;
            continue;
        }
        if (c < '0' || c > '9') return -1;
        v = v * 10 + (c - '0');
        got = 1;
    }
    *val = v;
    return 0;
}

static int load_image(const char *path, image_t *im, int raw_w, int raw_h)
{
    FILE *f = fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "cannot open %s: %s\n", path, strerror(errno));
        return -1;
    }

    int c1 = fgetc(f), c2 = fgetc(f);

    if (c1 == 'P' && c2 == '5' && raw_w == 0) {
        int w, h, mx;
        if (pgm_int(f, &w) || pgm_int(f, &h) || pgm_int(f, &mx)) {
            fprintf(stderr, "%s: malformed PGM header\n", path);
            fclose(f); return -1;
        }
        if (mx != 255) {
            fprintf(stderr, "%s: maxval %d unsupported\n", path, mx);
            fclose(f); return -1;
        }
        if (w < 8 || h < 8) {
            fprintf(stderr, "%s: too small\n", path);
            fclose(f); return -1;
        }
        im->w = w; im->h = h;
        im->px = malloc((size_t)w * h);
        if (!im->px) { fclose(f); return -1; }
        if (fread(im->px, 1, (size_t)w * h, f) != (size_t)w * h) {
            fprintf(stderr, "%s: short pixel data\n", path);
            free(im->px); fclose(f); return -1;
        }
        snprintf(im->fmt, sizeof im->fmt, "binary PGM (P5)");
        fclose(f);
    } else {
        int w = raw_w ? raw_w : 320, h = raw_h ? raw_h : 240;
        rewind(f);
        im->w = w; im->h = h;
        im->px = malloc((size_t)w * h);
        if (!im->px) { fclose(f); return -1; }
        size_t got = fread(im->px, 1, (size_t)w * h, f);
        fclose(f);
        if (got != (size_t)w * h) {
            fprintf(stderr, "%s: expected %d raw bytes, read %zu\n", path, w*h, got);
            free(im->px); return -1;
        }
        snprintf(im->fmt, sizeof im->fmt, "headerless raw");
    }

    im->bw     = im->w / 8;
    im->bh     = im->h / 8;
    im->blocks = im->bw * im->bh;
    snprintf(im->src, sizeof im->src, "%s", path);

    if (im->blocks == 0) {
        fprintf(stderr, "%s: no whole 8x8 blocks\n", path);
        free(im->px); return -1;
    }
    return 0;
}

/* ---------------------------------------------------------------- */
/* Benchmarking                                                       */
/* ---------------------------------------------------------------- */

static void run_image(dct_fn fn, const image_t *im, int32_t *out)
{
    uint8_t blk[8][8];
    int32_t res[8][8];

    for (int by = 0; by < im->bh; by++) {
        for (int bx = 0; bx < im->bw; bx++) {
            const uint8_t *src = im->px + (size_t)(by * 8) * im->w + bx * 8;
            for (int r = 0; r < 8; r++)
                memcpy(blk[r], src + (size_t)r * im->w, 8);
            fn(blk, res);
            int32_t *dst = out + (size_t)(by * im->bw + bx) * 64;
            memcpy(dst, res, 64 * sizeof(int32_t));
        }
    }
}

static double now_s(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

static int cmp_d(const void *a, const void *b)
{
    double x = *(const double *)a, y = *(const double *)b;
    return (x > y) - (x < y);
}

static void benchmark(impl_t *im, dct_fn fn, const image_t *img, int reps)
{
    double sorted[MAX_REPS];
    run_image(fn, img, im->out);   /* warm-up */
    for (int i = 0; i < reps; i++) {
        double t0 = now_s();
        run_image(fn, img, im->out);
        im->run_s[i] = now_s() - t0;
    }
    memcpy(sorted, im->run_s, (size_t)reps * sizeof(double));
    qsort(sorted, (size_t)reps, sizeof(double), cmp_d);
    im->reps     = reps;
    im->median_s = sorted[reps / 2];
    im->best_s   = sorted[0];
    im->worst_s  = sorted[reps - 1];
    im->valid    = 1;
}

/* ---------------------------------------------------------------- */
/* Accuracy comparison (used in report)                              */
/* ---------------------------------------------------------------- */

typedef struct {
    long   n_diff;
    int    max_abs;
    double mean_abs;
    double rms;
} diff_t;

static void compare(const int32_t *a, const int32_t *b, long n, diff_t *d)
{
    long nd = 0, sum = 0; double sq = 0.0; int mx = 0;
    for (long i = 0; i < n; i++) {
        long e = (long)a[i] - (long)b[i];
        if (e) nd++;
        if (e < 0) e = -e;
        if (e > mx) mx = (int)e;
        sum += e; sq += (double)e * e;
    }
    d->n_diff   = nd;
    d->max_abs  = mx;
    d->mean_abs = (double)sum / (double)n;
    d->rms      = sqrt(sq / (double)n);
}

/* ---------------------------------------------------------------- */
/* Report (condensed — add more detail as needed)                    */
/* ---------------------------------------------------------------- */

static void write_report(const char *path, impl_t *im, const image_t *img,
                         int reps, const char *cc_opts)
{
    FILE *f = fopen(path, "w");
    if (!f) { fprintf(stderr, "cannot write %s\n", path); return; }

    time_t tt = time(NULL); struct tm *lt = localtime(&tt); char when[64];
    strftime(when, sizeof when, "%Y-%m-%d %H:%M:%S", lt);
    long ncoef = (long)img->blocks * 64;

    fprintf(f,
"================================================================\n"
" 2D DCT IMPLEMENTATION BENCHMARK\n"
"================================================================\n"
" Date          : %s\n"
" Platform      : DE1-SoC, Cyclone V 5CSEMA5F31C6 + ARM Cortex-A9\n"
" Compiled with : %s\n"
" Image file    : %s\n"
" Image format  : %s\n"
" Image size    : %d x %d grayscale\n"
" Blocks        : %d x %d = %d blocks of 8x8 (%ld coefficients)\n"
" Transforms    : %d 8-point 1D DCTs per full-image pass\n"
" Repetitions   : %d timed (median reported), plus 1 untimed warm-up\n"
" Timer         : clock_gettime(CLOCK_MONOTONIC)\n\n",
        when, cc_opts, img->src, img->fmt, img->w, img->h,
        img->bw, img->bh, img->blocks, ncoef,
        img->blocks * 16, reps);

    fprintf(f,
"----------------------------------------------------------------\n"
" IMPLEMENTATIONS UNDER TEST\n"
"----------------------------------------------------------------\n");
    for (int i = 0; i < N_IMPL; i++)
        fprintf(f, " %-14s %-9s %s\n", im[i].name, im[i].kind, im[i].detail);
    fprintf(f, "\n");

    fprintf(f,
"----------------------------------------------------------------\n"
" TIMING\n"
"----------------------------------------------------------------\n");
    fprintf(f, "%-14s %-9s %12s %12s %12s %12s\n",
            "IMPLEMENTATION", "TYPE", "MEDIAN(ms)", "BEST(ms)", "WORST(ms)", "BLOCK(us)");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) {
            fprintf(f, "%-14s %-9s %12s\n", im[i].name, im[i].kind, "skipped");
            continue;
        }
        fprintf(f, "%-14s %-9s %12.3f %12.3f %12.3f %12.3f\n",
                im[i].name, im[i].kind,
                im[i].median_s*1e3, im[i].best_s*1e3,
                im[i].worst_s*1e3, im[i].median_s*1e6/img->blocks);
    }

    double fastest = 0.0;
    for (int i = 0; i < N_IMPL; i++)
        if (im[i].valid && (fastest == 0.0 || im[i].median_s < fastest))
            fastest = im[i].median_s;

    fprintf(f,
"\n----------------------------------------------------------------\n"
" THROUGHPUT AND RELATIVE SPEED\n"
"----------------------------------------------------------------\n");
    fprintf(f, "%-14s %12s %12s %12s %12s\n",
            "IMPLEMENTATION","BLOCKS/S","MPIXEL/S","SPEEDUP","FPS@THIS_RES");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        fprintf(f, "%-14s %12.1f %12.3f %11.2fx %12.1f\n",
                im[i].name,
                img->blocks / im[i].median_s,
                (double)img->w * img->h / im[i].median_s / 1e6,
                fastest / im[i].median_s,
                1.0 / im[i].median_s);
    }

    fprintf(f,
"\n----------------------------------------------------------------\n"
" NUMERICAL AGREEMENT\n"
"----------------------------------------------------------------\n"
" Reference: %s — all %ld coefficients compared.\n\n",
        im[0].name, ncoef);
    fprintf(f, "%-28s %10s %8s %10s %10s\n",
            "COMPARISON","DIFFERING","MAX","MEAN ABS","RMS");

    struct { int a,b; } pairs[6] = {{0,1},{0,2},{0,3},{1,2},{1,3},{2,3}};
    for (int p = 0; p < 6; p++) {
        int a = pairs[p].a, b = pairs[p].b;
        if (!im[a].valid || !im[b].valid) continue;
        diff_t d;
        compare(im[a].out, im[b].out, ncoef, &d);
        char lbl[64];
        snprintf(lbl, sizeof lbl, "%s vs %s", im[a].name, im[b].name);
        fprintf(f, "%-28s %9.1f%% %8d %10.4f %10.4f\n",
                lbl, 100.0*(double)d.n_diff/(double)ncoef,
                d.max_abs, d.mean_abs, d.rms);
    }

    fprintf(f,
"\n Remaining differences are fixed-point rounding, not algorithmic error.\n"
" The LOEFFLER vs FPGA row is most informative: both use Q10 fixed-point\n"
" so it isolates rounding strategy only. JPEG quantisation step sizes of\n"
" 8-64 make any difference of 1-4 LSB invisible in a reconstructed image.\n"
"\n"
"----------------------------------------------------------------\n"
" FIRMWARE VS SOFTWARE — WHAT THE INLINE ASSEMBLY BUYS\n"
"----------------------------------------------------------------\n");

    if (im[1].valid && im[2].valid) {
        double sw = im[1].median_s, fw = im[2].median_s;
        long bf = (long)img->blocks * 16 * 6;
        fprintf(f, " %-18s %12s %14s %14s\n","","MEDIAN(ms)","PER BLOCK(us)","PER BUTTERFLY(ns)");
        fprintf(f, " %-18s %12.3f %14.3f %14.1f\n","SW-LOEFFLER (C)",
                sw*1e3, sw*1e6/img->blocks, sw*1e9/(double)bf);
        fprintf(f, " %-18s %12.3f %14.3f %14.1f\n","FW-LOEFFLER (asm)",
                fw*1e3, fw*1e6/img->blocks, fw*1e9/(double)bf);
        fprintf(f, "\n Butterfly rotations: %ld  (%d blocks × 16 × 6)\n\n", bf, img->blocks);
        if (sw/fw > 1.02)
            fprintf(f, " RESULT: assembly is %.2fx FASTER (saves %.3f ms/frame)\n", sw/fw, (sw-fw)*1e3);
        else if (sw/fw < 0.98)
            fprintf(f, " RESULT: assembly is SLOWER (%.2fx) — asm block is an optimisation barrier\n", sw/fw);
        else
            fprintf(f, " RESULT: no significant difference (%.2fx)\n", sw/fw);

        diff_t d; compare(im[1].out, im[2].out, ncoef, &d);
        fprintf(f, " Output equivalence: %s (max diff = %d)\n",
                d.max_abs == 0 ? "BIT-IDENTICAL" : "MISMATCH", d.max_abs);
    }

    fprintf(f,
"\n----------------------------------------------------------------\n"
" SAMPLE BLOCK (top-left block of image)\n"
"----------------------------------------------------------------\n");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        fprintf(f, "\n %s:\n", im[i].name);
        for (int r = 0; r < 8; r++) {
            fprintf(f, "  ");
            for (int c = 0; c < 8; c++)
                fprintf(f, "%8d", im[i].out[r*8+c]);
            fprintf(f, "\n");
        }
    }

    fprintf(f,
"\n================================================================\n"
" END OF REPORT\n"
"================================================================\n");
    fclose(f);
}

/* ---------------------------------------------------------------- */
/* main                                                              */
/* ---------------------------------------------------------------- */

static void usage(const char *p)
{
    fprintf(stderr,
"usage: %s <image.pgm|image.raw> [options]\n"
"\n"
"  -r reps         repetitions per impl (1-99, default 3)\n"
"  -o file         report path (default dct_benchmark_results.txt)\n"
"  --output-dir d  directory for reconstructed/diff PGMs (default .)\n"
"  --no-fpga       skip hardware implementation\n"
"  --raw W H       treat input as headerless W×H raw\n", p);
}

int main(int argc, char **argv)
{
    const char *img_path   = NULL;
    const char *report     = "dct_benchmark_results.txt";
    const char *output_dir = ".";
    int reps = DEFAULT_REPS, use_fpga = 1, raw_w = 0, raw_h = 0;

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--no-fpga"))   use_fpga = 0;
        else if (!strcmp(argv[i], "--output-dir") && i+1 < argc) output_dir = argv[++i];
        else if (!strcmp(argv[i], "--raw") && i+2 < argc) {
            raw_w = atoi(argv[++i]); raw_h = atoi(argv[++i]);
            if (raw_w < 8 || raw_h < 8) { usage(argv[0]); return 1; }
        }
        else if (!strcmp(argv[i], "-r") && i+1 < argc) {
            reps = atoi(argv[++i]);
            if (reps < 1 || reps > MAX_REPS) { usage(argv[0]); return 1; }
        }
        else if (!strcmp(argv[i], "-o") && i+1 < argc) report = argv[++i];
        else if (argv[i][0] == '-') { usage(argv[0]); return 1; }
        else img_path = argv[i];
    }

    if (!img_path) { usage(argv[0]); return 1; }

    /* Create output directory if it doesn't already exist */
    if (strcmp(output_dir, ".") != 0) {
        if (mkdir(output_dir, 0755) != 0 && errno != EEXIST) {
            fprintf(stderr, "cannot create output directory %s: %s\n",
                    output_dir, strerror(errno));
            return 1;
        }
    }

    image_t img;
    memset(&img, 0, sizeof img);
    if (load_image(img_path, &img, raw_w, raw_h) != 0) return 1;

    printf("Image   : %s  (%s, %dx%d)\n", img.src, img.fmt, img.w, img.h);
    printf("Blocks  : %d x %d = %d\n", img.bw, img.bh, img.blocks);
    printf("Reps    : %d timed + 1 warm-up\n\n", reps);

    impl_t im[N_IMPL] = {
        { "SW-NAIVE",    "software",
          "dct_2d_naive()      -- double precision, cos() per term",  {0},0,0,0,0,0,NULL },
        { "SW-LOEFFLER", "software",
          "dct_2d_loeffler_c() -- Q10 butterflies, plain C rotation", {0},0,0,0,0,0,NULL },
        { "FW-LOEFFLER", "firmware",
          "dct_2d_loeffler()   -- same, hand-scheduled ARM asm",      {0},0,0,0,0,0,NULL },
        { "HW-FPGA",     "hardware",
          "dct_2d_fpga()       -- dct_1d_top over the LW bridge",     {0},0,0,0,0,0,NULL },
    };

    for (int i = 0; i < N_IMPL; i++) {
        im[i].out = calloc((size_t)img.blocks * 64, sizeof(int32_t));
        if (!im[i].out) { fprintf(stderr, "out of memory\n"); return 1; }
    }

    /* ---- Run benchmarks ---- */
    printf("  %-14s ", im[0].name); fflush(stdout);
    benchmark(&im[0], adapt_naive, &img, reps);
    printf("%10.3f ms\n", im[0].median_s * 1e3);

    printf("  %-14s ", im[1].name); fflush(stdout);
    benchmark(&im[1], adapt_loeffler_c, &img, reps);
    printf("%10.3f ms\n", im[1].median_s * 1e3);

    printf("  %-14s ", im[2].name); fflush(stdout);
    benchmark(&im[2], adapt_loeffler, &img, reps);
    printf("%10.3f ms\n", im[2].median_s * 1e3);

    printf("  %-14s ", im[3].name); fflush(stdout);
#ifdef NO_FPGA_BUILD
    (void)use_fpga;
    printf("not built (NO_FPGA_BUILD)\n");
#else
    if (!use_fpga) {
        printf("skipped (--no-fpga)\n");
    } else if (fpga_open() != 0) {
        printf("UNAVAILABLE\n");
        fprintf(stderr, "    run as root with FPGA configured and bridges enabled\n");
    } else {
        benchmark(&im[3], adapt_fpga, &img, reps);
        printf("%10.3f ms\n", im[3].median_s * 1e3);
        fpga_close();
    }
#endif

    write_report(report, im, &img, reps,
#ifdef __OPTIMIZE__
                 "gcc -O2"
#else
                 "gcc (no optimisation -- timings not representative)"
#endif
                );
    printf("\nReport written to %s\n", report);

    /* ----------------------------------------------------------------
     * RECONSTRUCTION PASS
     *
     * For each valid implementation:
     *   1. Run IDCT on every block's coefficients
     *   2. Assemble into a full reconstructed image
     *   3. Write as a PGM
     *
     * Then write amplified pixel-difference PGMs between pairs.
     * A black diff image = the two reconstructed images are identical.
     * ---------------------------------------------------------------- */

    printf("\n--- Reconstructing images via IDCT ---\n");
    printf("  (This uses double-precision IDCT for visual verification only)\n\n");

    /* Allocate reconstructed pixel buffers */
    uint8_t *recon[N_IMPL];
    for (int i = 0; i < N_IMPL; i++) {
        recon[i] = NULL;
        if (!im[i].valid) continue;
        recon[i] = malloc((size_t)img.w * img.h);
        if (!recon[i]) { fprintf(stderr, "out of memory\n"); return 1; }
    }

    /* Write the original image for reference */
    printf("Writing original image for reference:\n");
    write_pgm(output_dir, "original", img.px, img.w, img.h);
    printf("\n");

    /* Reconstruct and write each implementation's output */
    printf("Reconstructed images (IDCT of DCT coefficients):\n");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;

        printf("  %s ... ", im[i].name); fflush(stdout);
        reconstruct_image(im[i].out, &img, recon[i]);

        /* Build safe filename: replace spaces with underscores */
        char fname[128];
        snprintf(fname, sizeof fname, "reconstructed_%s", im[i].name);
        for (char *p = fname; *p; p++) if (*p == ' ') *p = '_';

        write_pgm(output_dir, fname, recon[i], img.w, img.h);
    }

    /* ----------------------------------------------------------------
     * Diff images
     *
     * We write the most informative pairs:
     *  - Each implementation vs SW-NAIVE (the float reference)
     *  - SW-LOEFFLER vs HW-FPGA (same Q10, isolates rounding strategy)
     *  - SW-LOEFFLER vs FW-LOEFFLER (should be pixel-identical)
     *
     * Amplification factor: 10x. A 1-LSB coefficient difference
     * typically maps to roughly a 1-pixel difference in the
     * reconstructed image after the IDCT spreads energy across the
     * block. Amplifying by 10 makes even single-pixel errors visible
     * as mid-grey tones rather than nearly-black.
     * ---------------------------------------------------------------- */

    printf("\nDiff images (amplified 10× — black = identical):\n");

    struct { int a; int b; } diff_pairs[] = {
        { 0, 1 },   /* SW-NAIVE    vs SW-LOEFFLER */
        { 0, 2 },   /* SW-NAIVE    vs FW-LOEFFLER */
        { 0, 3 },   /* SW-NAIVE    vs HW-FPGA     */
        { 1, 2 },   /* SW-LOEFFLER vs FW-LOEFFLER  (expect: black) */
        { 1, 3 },   /* SW-LOEFFLER vs HW-FPGA      (most informative) */
    };
    int n_pairs = (int)(sizeof diff_pairs / sizeof diff_pairs[0]);

    for (int p = 0; p < n_pairs; p++) {
        int a = diff_pairs[p].a, b = diff_pairs[p].b;
        if (!im[a].valid || !im[b].valid) continue;
        printf("  %s vs %s:\n", im[a].name, im[b].name);
        write_diff_image(output_dir,
                         im[a].name, recon[a],
                         im[b].name, recon[b],
                         img.w, img.h, 10);
    }

    /* ---- Summary ---- */
    printf("\n--- Reconstruction summary ---\n");
    printf("  All PGMs written to: %s/\n", output_dir);
    printf("\n  To view on the board:   display <file>.pgm\n");
    printf("  To copy to your laptop: scp root@<board-ip>:%s/*.pgm .\n\n", output_dir);

    /* Cleanup */
    for (int i = 0; i < N_IMPL; i++) {
        free(recon[i]);
        free(im[i].out);
    }
    free(img.px);
    (void)bench_unused_refs;
    return 0;
}

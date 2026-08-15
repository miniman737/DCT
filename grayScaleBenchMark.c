/*
 * grayScaleBenchmark.c
 *
 * Benchmarks THREE EXISTING, UNMODIFIED 2D DCT implementations over a
 * grayscale image supplied on the command line:
 *
 *   1. SW-NAIVE     dct_2d_naive()    floating-point cos() reference
 *   2. SW-LOEFFLER  dct_2d_loeffler() fixed-point butterfly + ARM asm
 *   3. HW-FPGA      dct_2d_fpga()     dct_1d_top peripheral, row-column
 *
 * ---------------------------------------------------------------------
 * HOW THIS COMPILES WITHOUT TOUCHING YOUR SOURCE FILES
 * ---------------------------------------------------------------------
 * Each of your files has its own main(), and two of the DCT entry points
 * are declared static (so they cannot be linked from another object).
 * Both problems are solved by #including the sources here, with main
 * macro-renamed around each include:
 *
 *     #define main loeffler_main
 *     #include "dct_loeffler.c"
 *     #undef  main
 *
 * Everything lands in one translation unit, so static functions are
 * visible, and your files stay byte-for-byte unchanged on disk.
 *
 * Override the source paths at compile time if your filenames differ:
 *     -DNAIVE_SRC='"my_naive.c"'
 *     -DLOEFFLER_SRC='"my_loeffler.c"'
 *     -DFPGA_SRC='"my_fpga.c"'
 *
 * ---------------------------------------------------------------------
 * BUILD (on the DE1-SoC)
 * ---------------------------------------------------------------------
 *     gcc -O2 -o grayScaleBenchmark grayScaleBenchmark.c -lm
 *
 * -lm is required: the naive implementation uses cos() and sqrt().
 * Use -O2, not -O0 -- at -O0 you are benchmarking unoptimised code and
 * Loeffler's advantage disappears into redundant loads and stores.
 *
 * RUN
 *     ./grayScaleBenchmark image.pgm
 *     ./grayScaleBenchmark image.pgm -r 5 -o results.txt
 *     ./grayScaleBenchmark image.raw --no-fpga
 *
 *   -r reps     repetitions per implementation (default 3, median used)
 *   -o file     report path (default dct_benchmark_results.txt)
 *   --no-fpga   skip hardware (for running on a host machine)
 *   --raw W H   treat input as headerless raw of the given dimensions
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

/* PI must exist before the naive source is pulled in. Guarded so that a
 * definition inside your own file wins if it has one. */
#ifndef PI
#define PI 3.14159265358979323846
#endif

/* ---------------------------------------------------------------- */
/* Source file paths -- override with -D at compile time             */
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
/* Pull in the three unmodified implementations                      */
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

/* Keep the renamed mains referenced so -Wall stays quiet about them.
 * Never called. */
static void bench_unused_refs(void)
{
    (void)naive_main;
    (void)loeffler_main;
#ifndef NO_FPGA_BUILD
    (void)fpga_main;
#endif
}

/* ---------------------------------------------------------------- */
/* Benchmark configuration                                           */
/* ---------------------------------------------------------------- */

#define DEFAULT_REPS   3
#define MAX_REPS       99
#define N_IMPL         3

/* Your dct_rc.c defines these; repeat defensively in case the FPGA
 * source is excluded from the build. */
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
/* Image container                                                   */
/* ---------------------------------------------------------------- */

typedef struct {
    int      w, h;           /* full image dimensions                */
    int      bw, bh;         /* whole 8x8 blocks in x and y          */
    int      blocks;         /* bw * bh                              */
    uint8_t *px;             /* w * h bytes                          */
    char     src[256];
    char     fmt[32];
} image_t;

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
    int32_t    *out;         /* blocks * 64 coefficients, block-major */
} impl_t;

/* ---------------------------------------------------------------- */
/* Adapters                                                          */
/*                                                                   */
/* Each implementation has a different signature and output width.   */
/* These thin wrappers give them a common interface. The conversion  */
/* cost is a 64-element copy, identical for all three, so it does    */
/* not bias the comparison.                                          */
/* ---------------------------------------------------------------- */

typedef void (*dct_fn)(const uint8_t blk[8][8], int32_t out[8][8]);

static void adapt_naive(const uint8_t blk[8][8], int32_t out[8][8])
{
    dct_2d_naive(blk, out);
}

static void adapt_loeffler(const uint8_t blk[8][8], int32_t out[8][8])
{
    uint8_t  in16[8][8];
    int16_t  o16[8][8];

    /* dct_2d_loeffler takes a non-const uint8_t[8][8] */
    memcpy(in16, blk, 64);
    dct_2d_loeffler(in16, o16);

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
        close(g_memfd);
        g_memfd = -1;
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
/* Image loading                                                     */
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
            fprintf(stderr, "%s: maxval %d unsupported (need 255)\n", path, mx);
            fclose(f); return -1;
        }
        if (w < 8 || h < 8) {
            fprintf(stderr, "%s: %dx%d too small (need at least 8x8)\n", path, w, h);
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
        /* headerless raw */
        int w = raw_w ? raw_w : 320;
        int h = raw_h ? raw_h : 240;
        rewind(f);
        im->w = w; im->h = h;
        im->px = malloc((size_t)w * h);
        if (!im->px) { fclose(f); return -1; }
        size_t got = fread(im->px, 1, (size_t)w * h, f);
        fclose(f);
        if (got != (size_t)w * h) {
            fprintf(stderr, "%s: expected %d raw bytes for %dx%d, read %zu\n"
                            "  (use --raw W H if the dimensions differ)\n",
                    path, w * h, w, h, got);
            free(im->px);
            return -1;
        }
        snprintf(im->fmt, sizeof im->fmt, "headerless raw");
    }

    im->bw     = im->w / 8;
    im->bh     = im->h / 8;
    im->blocks = im->bw * im->bh;
    snprintf(im->src, sizeof im->src, "%s", path);

    if (im->blocks == 0) {
        fprintf(stderr, "%s: no whole 8x8 blocks in a %dx%d image\n",
                path, im->w, im->h);
        free(im->px);
        return -1;
    }
    return 0;
}

/* ---------------------------------------------------------------- */
/* Whole-image pass                                                  */
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

/* ---------------------------------------------------------------- */
/* Timing                                                            */
/* ---------------------------------------------------------------- */

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

    /* Untimed warm-up: faults pages in and primes caches, so run 1 is
     * not unfairly penalised. */
    run_image(fn, img, im->out);

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
/* Accuracy                                                          */
/* ---------------------------------------------------------------- */

typedef struct {
    long   n_diff;
    int    max_abs;
    double mean_abs;
    double rms;
    int    worst_block, worst_idx;
} diff_t;

/* Compare with b optionally read transposed within each 8x8 block. */
static void compare_xp(const int32_t *a, const int32_t *b, long nblk,
                       int xpose, diff_t *d)
{
    long   nd = 0, sum = 0;
    double sq = 0.0;
    int    mx = 0;
    long   mxi = 0;

    for (long blk = 0; blk < nblk; blk++) {
        const int32_t *pa = a + blk * 64;
        const int32_t *pb = b + blk * 64;
        for (int r = 0; r < 8; r++) {
            for (int c = 0; c < 8; c++) {
                long i  = r * 8 + c;
                long j  = xpose ? (c * 8 + r) : i;
                long e  = (long)pa[i] - (long)pb[j];
                if (e) nd++;
                if (e < 0) e = -e;
                if (e > mx) { mx = (int)e; mxi = blk * 64 + i; }
                sum += e;
                sq  += (double)e * (double)e;
            }
        }
    }
    long n = nblk * 64;
    d->n_diff      = nd;
    d->max_abs     = mx;
    d->mean_abs    = (double)sum / (double)n;
    d->rms         = sqrt(sq / (double)n);
    d->worst_block = (int)(mxi / 64);
    d->worst_idx   = (int)(mxi % 64);
}

/*
 * Try both orientations and keep whichever agrees better.
 *
 * This is not cosmetic. dct_2d_naive() performs row-DCT, transpose,
 * row-DCT and never transposes back, so it returns the transpose of
 * the true 2D DCT. Comparing it position-by-position against a
 * correctly-oriented result would report a large bogus error and
 * bury the genuine rounding differences.
 */
static int compare_best(const int32_t *a, const int32_t *b, long nblk, diff_t *d)
{
    diff_t straight, flipped;
    compare_xp(a, b, nblk, 0, &straight);
    compare_xp(a, b, nblk, 1, &flipped);

    if (flipped.rms < straight.rms) { *d = flipped;  return 1; }
    *d = straight;
    return 0;
}

/* ---------------------------------------------------------------- */
/* Report                                                            */
/* ---------------------------------------------------------------- */

static void bar(FILE *f, double frac, int width)
{
    int fill = (int)(frac * width + 0.5);
    if (fill < 0) fill = 0;
    if (fill > width) fill = width;
    fputc('[', f);
    for (int i = 0; i < width; i++) fputc(i < fill ? '#' : '.', f);
    fputc(']', f);
}

static void write_report(const char *path, impl_t *im, const image_t *img,
                         int reps, const char *cc_opts)
{
    FILE *f = fopen(path, "w");
    if (!f) {
        fprintf(stderr, "cannot write %s: %s\n", path, strerror(errno));
        return;
    }

    time_t     tt = time(NULL);
    struct tm *lt = localtime(&tt);
    char       when[64];
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
" Timer         : clock_gettime(CLOCK_MONOTONIC)\n"
"\n",
        when, cc_opts, img->src, img->fmt, img->w, img->h,
        img->bw, img->bh, img->blocks, ncoef,
        img->blocks * 16, reps);

    fprintf(f,
"----------------------------------------------------------------\n"
" IMPLEMENTATIONS UNDER TEST\n"
"----------------------------------------------------------------\n");
    for (int i = 0; i < N_IMPL; i++)
        fprintf(f, " %-14s %-9s %s\n", im[i].name, im[i].kind, im[i].detail);
    fprintf(f, "\n Sources are compiled unmodified; the harness includes them\n"
               " directly and renames each main() at preprocessing time.\n\n");

    /* ---- timing ---- */
    fprintf(f,
"----------------------------------------------------------------\n"
" TIMING\n"
"----------------------------------------------------------------\n");
    fprintf(f, "%-14s %-9s %12s %12s %12s %12s\n",
            "IMPLEMENTATION", "TYPE", "MEDIAN(ms)", "BEST(ms)", "WORST(ms)",
            "BLOCK(us)");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) {
            fprintf(f, "%-14s %-9s %12s %12s %12s %12s\n",
                    im[i].name, im[i].kind, "skipped", "-", "-", "-");
            continue;
        }
        fprintf(f, "%-14s %-9s %12.3f %12.3f %12.3f %12.3f\n",
                im[i].name, im[i].kind,
                im[i].median_s * 1e3, im[i].best_s * 1e3, im[i].worst_s * 1e3,
                im[i].median_s * 1e6 / img->blocks);
    }
    fprintf(f, "\n");

    /* ---- throughput ---- */
    double fastest = 0.0, slowest = 0.0;
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        if (fastest == 0.0 || im[i].median_s < fastest) fastest = im[i].median_s;
        if (im[i].median_s > slowest) slowest = im[i].median_s;
    }

    fprintf(f,
"----------------------------------------------------------------\n"
" THROUGHPUT AND RELATIVE SPEED\n"
"----------------------------------------------------------------\n");
    fprintf(f, "%-14s %12s %12s %12s %12s\n",
            "IMPLEMENTATION", "BLOCKS/S", "MPIXEL/S", "SPEEDUP", "FPS@THIS_RES");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        double bps = img->blocks / im[i].median_s;
        double mps = (double)img->w * img->h / im[i].median_s / 1e6;
        fprintf(f, "%-14s %12.1f %12.3f %11.2fx %12.1f\n",
                im[i].name, bps, mps, fastest / im[i].median_s,
                1.0 / im[i].median_s);
    }
    fprintf(f,
"\n SPEEDUP is normalised to the fastest implementation (1.00x =\n"
" fastest). FPS@THIS_RES is how many full frames of this size each\n"
" implementation could transform per second, DCT time only.\n\n");

    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        fprintf(f, "  %-14s ", im[i].name);
        bar(f, slowest > 0.0 ? im[i].median_s / slowest : 0.0, 44);
        fprintf(f, " %10.3f ms\n", im[i].median_s * 1e3);
    }
    fprintf(f, "  %-14s (longer bar = slower)\n\n", "");

    /* ---- per-run ---- */
    fprintf(f,
"----------------------------------------------------------------\n"
" PER-RUN TIMINGS (ms)\n"
"----------------------------------------------------------------\n");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        fprintf(f, " %-14s", im[i].name);
        for (int r = 0; r < im[i].reps; r++)
            fprintf(f, " %10.3f", im[i].run_s[r] * 1e3);
        fprintf(f, "\n");
    }
    fprintf(f,
"\n Spread between best and worst is scheduler and cache noise; the\n"
" median is reported to suppress it. A wide spread on HW-FPGA can\n"
" also indicate bus contention with other bridge traffic.\n\n");

    /* ---- accuracy ---- */
    fprintf(f,
"----------------------------------------------------------------\n"
" NUMERICAL AGREEMENT\n"
"----------------------------------------------------------------\n"
" Reference: %s -- floating-point cos(), the most accurate of the\n"
" three. All %ld coefficients compared.\n\n", im[0].name, ncoef);

    fprintf(f, "%-28s %10s %8s %10s %10s %12s\n",
            "COMPARISON", "DIFFERING", "MAX", "MEAN ABS", "RMS", "ORIENTATION");

    int any_xp = 0;
    struct { int a, b; } pairs[3] = { {0,1}, {0,2}, {1,2} };
    for (int p = 0; p < 3; p++) {
        int a = pairs[p].a, b = pairs[p].b;
        if (!im[a].valid || !im[b].valid) continue;
        diff_t d;
        int xp = compare_best(im[a].out, im[b].out, img->blocks, &d);
        if (xp) any_xp = 1;
        char lbl[64];
        snprintf(lbl, sizeof lbl, "%s vs %s", im[a].name, im[b].name);
        fprintf(f, "%-28s %9.1f%% %8d %10.4f %10.4f %12s\n",
                lbl, 100.0 * (double)d.n_diff / (double)ncoef,
                d.max_abs, d.mean_abs, d.rms,
                xp ? "TRANSPOSED" : "matching");
    }

    if (any_xp) {
        fprintf(f,
"\n *** ORIENTATION MISMATCH DETECTED ***\n"
"\n"
" A comparison above agreed far better with one operand's 8x8 blocks\n"
" read transposed. That is a real difference in output convention,\n"
" not a rounding effect, and the figures on that row are computed\n"
" after compensating for it -- otherwise they would be meaningless.\n"
"\n"
" Cause: dct_2d_naive() performs row-DCT, transpose(), row-DCT, and\n"
" never transposes back, so it returns the transpose of the true 2D\n"
" DCT. The separable 2D DCT needs three transposes in that structure\n"
" (or two, folded into the indexing) and this one has a single one.\n"
"\n"
" dct_2d_fpga() gets this right: its column pass writes\n"
"     output[r][c] = row_out[r]\n"
" which folds the second transpose into the store. dct_2d_loeffler()\n"
" also gets it right, indexing output[r][i] directly in its column\n"
" loop rather than transposing the buffer.\n"
"\n"
" Consequence if left uncorrected: F(0,1) and F(1,0) are swapped\n"
" throughout, along with every other off-diagonal pair. For a JPEG\n"
" pipeline that scrambles the zig-zag order and the quantisation\n"
" table alignment. The DC term and the main diagonal are unaffected,\n"
" which is exactly why a DC-only spot check would not have caught it.\n"
"\n"
" Fix: run the second pass into a scratch buffer and transpose that\n"
" into out, replacing the final loop of dct_2d_naive() with\n"
"\n"
"     int32_t t3[N][N];\n"
"     for (int k = 0; k < N; k++) dct_1d(t2[k], t3[k]);\n"
"     transpose(t3, out);\n"
"\n"
" Note that transpose(out, out) will NOT work -- transpose() writes\n"
" out[y][x] = in[x][y] element by element, so with in and out aliased\n"
" it overwrites entries it has not read yet and corrupts the block.\n"
" A separate destination is required.\n"
"\n");
    }

    fprintf(f,
"\n Remaining differences are fixed-point rounding, not algorithmic\n"
" error. The naive version keeps full double precision but truncates\n"
" rather than rounds at each cast to int32 -- note the cast is\n"
" (int32_t)(sum * ...) with no +0.5, so it biases toward zero and\n"
" costs roughly half an LSB per pass. Loeffler rounds at every\n"
" butterfly stage and defers its gain shift to after the column pass.\n"
" The hardware rounds once per pass at its >>> 11 output stage.\n"
"\n"
" The LOEFFLER vs FPGA row is the most informative for your report:\n"
" both are fixed-point with the same Q10 coefficients, so it isolates\n"
" rounding strategy from the float-versus-fixed gap. They should agree\n"
" to within a few LSB. JPEG quantisation divisors of 8-64 make that\n"
" invisible in a reconstructed image.\n\n");

    /* ---- sample block ---- */
    fprintf(f,
"----------------------------------------------------------------\n"
" SAMPLE BLOCK (top-left block of the image)\n"
"----------------------------------------------------------------\n");
    for (int i = 0; i < N_IMPL; i++) {
        if (!im[i].valid) continue;
        fprintf(f, "\n %s:\n", im[i].name);
        for (int r = 0; r < 8; r++) {
            fprintf(f, "   ");
            for (int c = 0; c < 8; c++)
                fprintf(f, "%8d", im[i].out[r * 8 + c]);
            fprintf(f, "\n");
        }
    }
    fprintf(f, "\n");

    /* ---- interpretation ---- */
    fprintf(f,
"----------------------------------------------------------------\n"
" INTERPRETATION\n"
"----------------------------------------------------------------\n"
" Cost per 8-point 1D DCT:\n"
"\n"
"   SW-NAIVE      64 cos() calls, 64 double multiply-accumulates\n"
"   SW-LOEFFLER   11 integer multiplies, 29 adds (butterfly form)\n"
"   HW-FPGA       64 parallel MACs in fabric, 0 CPU multiplies,\n"
"                 but 16 bridge transactions of interface overhead\n"
"\n"
" SW-NAIVE should be far and away the slowest, and the reason is not\n"
" the transform -- it is that cos() is recomputed from scratch inside\n"
" the inner loop on every call. That is one libm call per coefficient\n"
" per input sample, on a core with no fast transcendental unit. It is\n"
" a correctness reference, not a serious contender; quote it as the\n"
" baseline the other two are measured against.\n"
"\n"
" SW-LOEFFLER should beat it by two to three orders of magnitude:\n"
" the butterfly factorisation removes the multiplies, fixed point\n"
" removes the FPU, and the 3-multiply rotation with pre-computed\n"
" simplified coefficients removes a third of what remains. The inline\n"
" ARM assembly schedules the two independent multiplies into adjacent\n"
" issue slots, so the rotation is limited by multiplier latency rather\n"
" than by instruction count.\n"
"\n"
" HW-FPGA is the one to be careful about. Per 8x8 block it performs:\n"
"\n"
"   16 one-dimensional transforms x (8 writes + 8 reads)\n"
"     = 256 lightweight-bridge transactions per block\n"
"     = %ld transactions for this image\n"
"\n"
" Each read is an uncached round trip that stalls the CPU, while the\n"
" transform itself completes in 3 clocks at 50 MHz (60 ns). The\n"
" accelerator is therefore latency-bound on the interface, not\n"
" compute-bound. If it loses to Loeffler, that is why -- it is not\n"
" evidence that the DCT logic is slow, and the report should say so\n"
" explicitly rather than presenting the number bare.\n"
"\n"
" This is the classic accelerator-granularity result: offload a unit\n"
" of work this small and the interface cost exceeds the compute saved.\n"
" The fix is a wider interface, not a faster transform -- DMA a whole\n"
" 64-pixel block across the bridge, run both passes in fabric with an\n"
" on-chip transpose buffer, and read 64 coefficients back. That turns\n"
" 256 transactions into 2 bursts and lets the fabric's parallelism\n"
" actually show. The 2D peripheral was the intended route to this.\n"
"\n"
" Caveat to state when quoting these figures: this measures a\n"
" memory-mapped register interface driven from a user-space process,\n"
" not the DCT core in isolation. Report it as end-to-end offload cost,\n"
" which is both the honest framing and the more useful one.\n"
"\n"
"================================================================\n"
" END OF REPORT\n"
"================================================================\n",
        (long)img->blocks * 256);

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
"  -r reps      repetitions per implementation (1-%d, default %d)\n"
"  -o file      report path (default dct_benchmark_results.txt)\n"
"  --raw W H    treat input as headerless raw of W x H bytes\n"
"  --no-fpga    skip the hardware implementation\n",
            p, MAX_REPS, DEFAULT_REPS);
}

int main(int argc, char **argv)
{
    const char *img_path = NULL;
    const char *report   = "dct_benchmark_results.txt";
    int reps = DEFAULT_REPS, use_fpga = 1, raw_w = 0, raw_h = 0;

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--no-fpga")) use_fpga = 0;
        else if (!strcmp(argv[i], "--raw") && i + 2 < argc) {
            raw_w = atoi(argv[++i]);
            raw_h = atoi(argv[++i]);
            if (raw_w < 8 || raw_h < 8) { usage(argv[0]); return 1; }
        }
        else if (!strcmp(argv[i], "-r") && i + 1 < argc) {
            reps = atoi(argv[++i]);
            if (reps < 1 || reps > MAX_REPS) { usage(argv[0]); return 1; }
        }
        else if (!strcmp(argv[i], "-o") && i + 1 < argc) report = argv[++i];
        else if (argv[i][0] == '-') { usage(argv[0]); return 1; }
        else img_path = argv[i];
    }

    if (!img_path) { usage(argv[0]); return 1; }

    image_t img;
    memset(&img, 0, sizeof img);
    if (load_image(img_path, &img, raw_w, raw_h) != 0) return 1;

    printf("Image   : %s  (%s, %dx%d)\n", img.src, img.fmt, img.w, img.h);
    printf("Blocks  : %d x %d = %d\n", img.bw, img.bh, img.blocks);
    if (img.w % 8 || img.h % 8)
        printf("Note    : %d x %d is not a multiple of 8; edge pixels ignored\n",
               img.w, img.h);
    printf("Reps    : %d timed + 1 warm-up\n\n", reps);

    impl_t im[N_IMPL] = {
        { "SW-NAIVE",    "software",
          "dct_2d_naive()    -- double precision, cos() per term", {0},0,0,0,0,0,NULL },
        { "SW-LOEFFLER", "software",
          "dct_2d_loeffler() -- Q10 butterflies, inline ARM asm",  {0},0,0,0,0,0,NULL },
        { "HW-FPGA",     "hardware",
          "dct_2d_fpga()     -- dct_1d_top over the LW bridge",    {0},0,0,0,0,0,NULL }
    };

    for (int i = 0; i < N_IMPL; i++) {
        im[i].out = calloc((size_t)img.blocks * 64, sizeof(int32_t));
        if (!im[i].out) { fprintf(stderr, "out of memory\n"); return 1; }
    }

    printf("  %-14s ", im[0].name); fflush(stdout);
    benchmark(&im[0], adapt_naive, &img, reps);
    printf("%10.3f ms\n", im[0].median_s * 1e3);

    printf("  %-14s ", im[1].name); fflush(stdout);
    benchmark(&im[1], adapt_loeffler, &img, reps);
    printf("%10.3f ms\n", im[1].median_s * 1e3);

    printf("  %-14s ", im[2].name); fflush(stdout);
#ifdef NO_FPGA_BUILD
    (void)use_fpga;
    printf("not built (NO_FPGA_BUILD)\n");
#else
    if (!use_fpga) {
        printf("skipped (--no-fpga)\n");
    } else if (fpga_open() != 0) {
        printf("UNAVAILABLE\n");
        fprintf(stderr, "    run as root with the FPGA configured and bridges enabled\n");
    } else {
        benchmark(&im[2], adapt_fpga, &img, reps);
        printf("%10.3f ms\n", im[2].median_s * 1e3);
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
    printf("Copy it to your ThinkPad with:\n");
    printf("  scp root@<board-ip>:~/%s .\n", report);

#ifndef __OPTIMIZE__
    printf("\nWARNING: built without -O2. Rebuild with -O2 before quoting\n"
           "         any of these numbers.\n");
#endif

    for (int i = 0; i < N_IMPL; i++) free(im[i].out);
    free(img.px);
    (void)bench_unused_refs;
    return 0;
}

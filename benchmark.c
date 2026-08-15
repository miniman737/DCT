/*mark.c
 *
 * 4-way 2D-DCT comparison over a synthetic IMAGE_W × IMAGE_H image:
 *   1. Naive C          — direct cos() matrix multiply, orthonormal scaling
 *   2. Loeffler C       — fixed-point butterfly algorithm (8 muls per 1D pass)
 *   3. Loeffler NEON    — same algorithm, butterfly via ARM NEON SIMD intrinsics
 *   4. FPGA hardware    — memory-mapped 1D DCT core via /dev/mem
 *
 * Compile:   gcc -O2 -mfpu=neon -mfloat-abi=hard -o benchmark benchmark.c -lm
 * Run:       sudo ./benchmark
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <arm_neon.h>

/* ── FPGA memory map ──────────────────────────────────── */
#define LW_BRIDGE_BASE   0xFF200000UL
#define LW_BRIDGE_SPAN   0x00200000UL
#define DCT_1D_OFFSET    0x0200

/* ── tuneable parameters ──────────────────────────────── */
#define N             8
#define PI            3.14159265358979
#define IMAGE_W       512    /* must be a multiple of 8 */
#define IMAGE_H       512    /* must be a multiple of 8 */
#define BLOCKS        ((IMAGE_W / N) * (IMAGE_H / N))
#define FPGA_CLK_MHZ  50     /* set to your actual FPGA clock (50 or 100) */


/* ==========================================================
 * SECTION 1 — Naive software 2D-DCT
 *
 * Source: Mihai SIMA, SENG440 slide deck 4, two bugs fixed +
 *         normalization corrected (2.0/N → sqrt(2.0/N)).
 *
 * BUG 1 — transposition: y never reset to 0 per row.
 * BUG 2 — output loop:   missing inner loop left l == N.
 * NORM  — slide deck uses (2/N)*ck which is 2× too small;
 *         orthonormal DCT needs sqrt(2/N)*ck.
 * ========================================================== */

static void transpose(int32_t in[N][N], int32_t out[N][N])
{
    int x, y;
    for (x = 0; x < N; x++)
        for (y = 0; y < N; y++)
            out[y][x] = in[x][y];
}

static void dct_1d(const int32_t *input, int32_t *output)
{
    for (int k = 0; k < N; k++) {
        double sum = 0.0;
        double ck  = (k == 0) ? (1.0 / sqrt(2.0)) : 1.0;
        for (int n = 0; n < N; n++)
            sum += input[n] * cos(PI * k * (2.0 * n + 1.0) / (2.0 * N));
        output[k] = (int32_t)(sum * sqrt(2.0 / N) * ck); /* NORM fixed */
    }
}

static void dct_2d_naive(const uint8_t in[N][N], int32_t out[N][N])
{
    int32_t i_block[N][N], t1[N][N], t2[N][N];

    for (int k = 0; k < N; k++)
        for (int l = 0; l < N; l++)
            i_block[k][l] = (int32_t)in[k][l];

    for (int k = 0; k < N; k++) dct_1d(i_block[k], t1[k]);
    transpose(t1, t2);
    for (int k = 0; k < N; k++) dct_1d(t2[k], out[k]);
}


/* ==========================================================
 * SECTION 2 — Loeffler fixed-point 2D-DCT
 *
 * Source: provided dct_loeffler.c — inlined verbatim.
 * 8 multiplications per 1D pass vs 64 for naive.
 * ========================================================== */

#define dct_fp_precision  10
#define dct_fp_rounding   (1 << (dct_fp_precision - 1))
#define dct_gain_scale    3
#define dct_gain_rounding (1 << (dct_gain_scale - 1))

#define C1_cos           1004
#define C1_sin           200      /* sin(pi/16)    * 1024 — used by NEON butterfly */
#define C1_simplified_1  (-805)
#define C1_simplified_2  (-1204)

#define C3_cos           851
#define C3_sin           569      /* sin(3pi/16)   * 1024 — used by NEON butterfly */
#define C3_simplified_1  (-283)
#define C3_simplified_2  (-1420)

#define sqrt2_fp         1448
#define C6_cos           554
#define C6_sin           1338     /* sqrt2*sin(6pi/16)*1024 — used by NEON butterfly */
#define C6_simplified_1  784
#define C6_simplified_2  (-1892)

typedef struct {
    int16_t cos_coef;
    int16_t simplified_1;
    int16_t simplified_2;
} rotator_coef_t;

static const rotator_coef_t rotator_table[] = {
    [1] = { C1_cos, C1_simplified_1, C1_simplified_2 },
    [2] = { C6_cos, C6_simplified_1, C6_simplified_2 },
    [3] = { C3_cos, C3_simplified_1, C3_simplified_2 },
};

static void butterfly_fp(int16_t in_upper, int16_t in_lower,
                         int16_t *out_upper, int16_t *out_lower,
                         uint8_t rotator)
{
    rotator_coef_t coef = rotator_table[rotator];
    int32_t tmp     = (int32_t)coef.cos_coef * (in_upper + in_lower);
    int32_t t_upper = tmp + (int32_t)in_lower  * coef.simplified_1;
    int32_t t_lower = tmp + (int32_t)in_upper  * coef.simplified_2;
    *out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);
    *out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
}

static void dct_2d_loeffler(const uint8_t input[N][N], int16_t output[N][N])
{
    uint8_t i;
    int16_t tmp_1, tmp_2;

    /* ── Row-wise 1D DCT ── */
    for (i = 0; i < N; i++) {
        /* Stage 1 */
        output[i][0] = input[i][0] + input[i][7];
        output[i][4] = input[i][1] + input[i][6];
        output[i][2] = input[i][2] + input[i][5];
        output[i][6] = input[i][3] + input[i][4];
        output[i][7] = input[i][3] - input[i][4];
        output[i][3] = input[i][2] - input[i][5];
        output[i][5] = input[i][1] - input[i][6];
        output[i][1] = input[i][0] - input[i][7];

        /* Stage 2 */
        tmp_1 = output[i][0];
        output[i][0] = tmp_1 + output[i][6];
        output[i][6] = tmp_1 - output[i][6];

        tmp_1 = output[i][4];
        output[i][4] = tmp_1 + output[i][2];
        output[i][2] = tmp_1 - output[i][2];

        butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);
        butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);

        /* Stage 3 */
        tmp_1 = output[i][0];
        output[i][0] = tmp_1 + output[i][4];
        output[i][4] = tmp_1 - output[i][4];

        butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);

        tmp_1 = output[i][7];
        output[i][7] = tmp_1 + output[i][5];
        output[i][5] = tmp_1 - output[i][5];

        tmp_1 = output[i][1];
        output[i][1] = tmp_1 + output[i][3];
        output[i][3] = tmp_1 - output[i][3];

        /* Stage 4 — odd part only; gain scaling deferred to column pass */
        tmp_1 = output[i][1];
        output[i][1] = tmp_1 + output[i][7];
        output[i][7] = tmp_1 - output[i][7];

        output[i][3] = (int16_t)(((int32_t)output[i][3] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
        output[i][5] = (int16_t)(((int32_t)output[i][5] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
    }

    /* ── Column-wise 1D DCT ── */
    for (i = 0; i < N; i++) {
        /* Stage 1 */
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

        /* Stage 2 */
        tmp_1 = output[0][i];
        output[0][i] = tmp_1 + output[6][i];
        output[6][i] = tmp_1 - output[6][i];

        tmp_1 = output[4][i];
        output[4][i] = tmp_1 + output[2][i];
        output[2][i] = tmp_1 - output[2][i];

        butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);
        butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);

        /* Stage 3 */
        tmp_1 = output[0][i];
        output[0][i] = tmp_1 + output[4][i];
        output[4][i] = tmp_1 - output[4][i];

        butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);

        tmp_1 = output[7][i];
        output[7][i] = tmp_1 + output[5][i];
        output[5][i] = tmp_1 - output[5][i];

        tmp_1 = output[1][i];
        output[1][i] = tmp_1 + output[3][i];
        output[3][i] = tmp_1 - output[3][i];

        /* Stage 4 — apply gain scaling to all outputs here */
        output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
        output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
        output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
        output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = output[1][i];
        output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
        output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = (int16_t)(((int32_t)output[3][i] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
        output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = (int16_t)(((int32_t)output[5][i] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
        output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
    }
}

/* Wrapper: uint8_t block in, int32_t flat array out — matches harness interface */
static void dct_2d_loeffler_flat(const uint8_t in[N][N], int32_t out[N][N])
{
    int16_t tmp[N][N];
    dct_2d_loeffler(in, tmp);
    for (int r = 0; r < N; r++)
        for (int c = 0; c < N; c++)
            out[r][c] = (int32_t)tmp[r][c];
}


/* ==========================================================
 * SECTION 3 — Loeffler NEON SIMD 2D-DCT
 *
 * Source: dct_loeffler_asm.c — inlined verbatim.
 *
 * The butterfly is replaced with a NEON inline asm routine.
 * Instead of the 3-multiply form used in the plain C version,
 * this packs both inputs into one 32-bit register (I' in the
 * upper 16 bits, I" in the lower 16 bits) and computes:
 *
 *   [O']   [cos  -sin] [I']       via vmull.s16 (4 muls in 1 instruction)
 *   [O"] = [sin   cos] [I"]            + vpadd   (pairwise add)
 *                                      + vrshr   (rounded right shift)
 *
 * 4 multiplications + 2 additions in a single SIMD instruction,
 * vs the plain C version's 3 multiplications + 2 additions spread
 * across several scalar instructions.  The win comes from SIMD
 * throughput and the rounded shift (vrshr) replacing a separate add.
 * ========================================================== */

typedef struct {
    int16_t cos_coef;
    int16_t sin_coef;
} rotator_neon_t;

static const rotator_neon_t neon_rotator_table[] = {
    [1] = { C1_cos, C1_sin },
    [2] = { C6_cos, C6_sin },
    [3] = { C3_cos, C3_sin },
};

/*
 * butterfly_neon: 32-bit packed rotation using NEON
 *
 * Rs = (I' << 16) | (I" & 0xFFFF)
 * Returns Rt = (O' << 16) | (O" & 0xFFFF)
 *
 * NEON layout:
 *   coef_vec = { cos, -sin, sin, cos }   (int16x4)
 *   data_vec = { I',   I',  I",  I" }   (int16x4, duped from Rs)
 *   vmull produces int32x4: { cos*I', -sin*I', sin*I", cos*I" }
 *   vpadd pairs:            { cos*I' + (-sin*I'), sin*I" + cos*I" }
 *                         = { O',                 O" }
 */
static int32_t butterfly_neon(int32_t Rs, uint8_t rotator)
{
    rotator_neon_t coef = neon_rotator_table[rotator];
    int16x4_t coef_vec  = { coef.cos_coef, -coef.sin_coef,
                             coef.sin_coef,  coef.cos_coef };
    int16x4_t data_vec;
    int32x2_t presult;
    int32_t   Rt, tmp0, tmp1;

    __asm__(
        "vdup.32    %P[data], %[Rs]               \n\t"
        "vmull.s16  q2, %P[data], %P[coef]        \n\t"
        "vpadd.i32  %P[presult], d4, d5           \n\t"
        "vrshr.s32  %P[presult], %P[presult], #10 \n\t"
        "vmov.32    %[tmp0], %P[presult][0]       \n\t"
        "vmov.32    %[tmp1], %P[presult][1]       \n\t"
        "lsl        %[tmp1], %[tmp1], #16         \n\t"
        "uxth       %[tmp0], %[tmp0]              \n\t"
        "orr        %[Rt], %[tmp0], %[tmp1]       \n\t"
        : [data]    "=&w" (data_vec),
          [presult] "=&w" (presult),
          [tmp0]    "=&r" (tmp0),
          [tmp1]    "=&r" (tmp1),
          [Rt]      "=r"  (Rt)
        : [Rs]   "r"  (Rs),
          [coef] "w"  (coef_vec)
        : "q2"
    );
    return Rt;
}

/* Pack two int16_t into one int32_t, call butterfly, unpack */
#define BUTTERFLY_NEON(upper, lower, rot)                               \
    do {                                                                 \
        uint32_t _Rs = ((uint32_t)(uint16_t)(upper) << 16)             \
                      | (uint16_t)(lower);                              \
        uint32_t _Rt = (uint32_t)butterfly_neon((int32_t)_Rs, (rot));  \
        (upper) = (int16_t)(_Rt >> 16);                                 \
        (lower) = (int16_t)(_Rt & 0xFFFF);                             \
    } while (0)

static void dct_2d_loeffler_neon(const uint8_t input[N][N],
                                  int16_t output[N][N])
{
    uint8_t  i;
    int16_t  tmp_1, tmp_2;

    /* ── Row-wise 1D DCT ── */
    for (i = 0; i < N; i++) {
        /* Stage 1 */
        output[i][0] = input[i][0] + input[i][7];
        output[i][4] = input[i][1] + input[i][6];
        output[i][2] = input[i][2] + input[i][5];
        output[i][6] = input[i][3] + input[i][4];
        output[i][7] = input[i][3] - input[i][4];
        output[i][3] = input[i][2] - input[i][5];
        output[i][5] = input[i][1] - input[i][6];
        output[i][1] = input[i][0] - input[i][7];

        /* Stage 2 */
        tmp_1 = output[i][0];
        output[i][0] = tmp_1 + output[i][6];
        output[i][6] = tmp_1 - output[i][6];
        tmp_1 = output[i][4];
        output[i][4] = tmp_1 + output[i][2];
        output[i][2] = tmp_1 - output[i][2];

        BUTTERFLY_NEON(output[i][7], output[i][1], 3);
        BUTTERFLY_NEON(output[i][3], output[i][5], 1);

        /* Stage 3 */
        tmp_1 = output[i][0];
        output[i][0] = tmp_1 + output[i][4];
        output[i][4] = tmp_1 - output[i][4];

        BUTTERFLY_NEON(output[i][2], output[i][6], 2);

        tmp_1 = output[i][7];
        output[i][7] = tmp_1 + output[i][5];
        output[i][5] = tmp_1 - output[i][5];
        tmp_1 = output[i][1];
        output[i][1] = tmp_1 + output[i][3];
        output[i][3] = tmp_1 - output[i][3];

        /* Stage 4 — gain scaling deferred to column pass */
        tmp_1 = output[i][1];
        output[i][1] = tmp_1 + output[i][7];
        output[i][7] = tmp_1 - output[i][7];
        output[i][3] = (int16_t)(((int32_t)output[i][3] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
        output[i][5] = (int16_t)(((int32_t)output[i][5] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
    }

    /* ── Column-wise 1D DCT ── */
    for (i = 0; i < N; i++) {
        /* Stage 1 */
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

        /* Stage 2 */
        tmp_1 = output[0][i];
        output[0][i] = tmp_1 + output[6][i];
        output[6][i] = tmp_1 - output[6][i];
        tmp_1 = output[4][i];
        output[4][i] = tmp_1 + output[2][i];
        output[2][i] = tmp_1 - output[2][i];

        BUTTERFLY_NEON(output[7][i], output[1][i], 3);
        BUTTERFLY_NEON(output[3][i], output[5][i], 1);

        /* Stage 3 */
        tmp_1 = output[0][i];
        output[0][i] = tmp_1 + output[4][i];
        output[4][i] = tmp_1 - output[4][i];

        BUTTERFLY_NEON(output[2][i], output[6][i], 2);

        tmp_1 = output[7][i];
        output[7][i] = tmp_1 + output[5][i];
        output[5][i] = tmp_1 - output[5][i];
        tmp_1 = output[1][i];
        output[1][i] = tmp_1 + output[3][i];
        output[3][i] = tmp_1 - output[3][i];

        /* Stage 4 — apply gain scaling */
        output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
        output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
        output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
        output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = output[1][i];
        output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
        output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = (int16_t)(((int32_t)output[3][i] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
        output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;

        tmp_1 = (int16_t)(((int32_t)output[5][i] * sqrt2_fp + dct_fp_rounding) >> dct_fp_precision);
        output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
    }
}

static void dct_2d_loeffler_neon_flat(const uint8_t in[N][N], int32_t out[N][N])
{
    int16_t tmp[N][N];
    dct_2d_loeffler_neon(in, tmp);
    for (int r = 0; r < N; r++)
        for (int c = 0; c < N; c++)
            out[r][c] = (int32_t)tmp[r][c];
}


/* ==========================================================
 * SECTION 5 — FPGA 2D-DCT
 *
 * Copied verbatim from dct_rc.c — no changes.
 * ========================================================== */

static void fpga_dct_1d(volatile int *dct,
                        const int16_t in[N], int16_t out[N])
{
    for (int i = 0; i < N; i++) dct[i] = (int)in[i];
    for (int i = 0; i < N; i++) out[i]  = (int16_t)(dct[i] & 0xFFFF);
}

static void dct_2d_fpga(volatile int *dct,
                        const uint8_t input[N][N],
                        int32_t output[N][N])
{
    int16_t row_in[N], row_out[N];
    int32_t intermediate[N][N];

    for (int r = 0; r < N; r++) {
        for (int c = 0; c < N; c++) row_in[c] = (int16_t)input[r][c];
        fpga_dct_1d(dct, row_in, row_out);
        for (int c = 0; c < N; c++) intermediate[r][c] = (int32_t)row_out[c];
    }
    for (int c = 0; c < N; c++) {
        for (int r = 0; r < N; r++) row_in[r] = (int16_t)intermediate[r][c];
        fpga_dct_1d(dct, row_in, row_out);
        for (int r = 0; r < N; r++) output[r][c] = (int32_t)row_out[r];
    }
}


/* ==========================================================
 * SECTION 6 — Benchmark harness
 * ========================================================== */

static double now_ms(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * 1000.0 + t.tv_nsec / 1.0e6;
}

static void extract_block(const uint8_t *img, int bx, int by,
                          uint8_t block[N][N])
{
    for (int r = 0; r < N; r++)
        for (int c = 0; c < N; c++)
            block[r][c] = img[(by * N + r) * IMAGE_W + (bx * N + c)];
}

static void store_block(const int32_t blk[N][N], int bx, int by,
                        int32_t *out_img)
{
    for (int r = 0; r < N; r++)
        for (int c = 0; c < N; c++)
            out_img[(by * N + r) * IMAGE_W + (bx * N + c)] = blk[r][c];
}

typedef struct {
    int mismatches;
    int max_diff;
} diff_t;

/* Compare two int32_t flat images, tolerance ±tol */
static diff_t compare(const int32_t *a, const int32_t *b, int n, int tol)
{
    diff_t d = {0, 0};
    for (int i = 0; i < n; i++) {
        int diff = abs((int)a[i] - (int)b[i]);
        if (diff > tol) d.mismatches++;
        if (diff > d.max_diff) d.max_diff = diff;
    }
    return d;
}

static void print_block(const char *label, const int32_t *img, int bx, int by)
{
    printf("\n%s [block (0,0)]:\n", label);
    for (int r = 0; r < N; r++) {
        for (int c = 0; c < N; c++)
            printf("%7d", img[(by * N + r) * IMAGE_W + (bx * N + c)]);
        printf("\n");
    }
}

int main(void)
{
    const int pixels = IMAGE_W * IMAGE_H;

    uint8_t *img_in       = malloc(pixels * sizeof(uint8_t));
    int32_t *out_naive    = malloc(pixels * sizeof(int32_t));
    int32_t *out_loeffler = malloc(pixels * sizeof(int32_t));
    int32_t *out_neon     = malloc(pixels * sizeof(int32_t));
    int32_t *out_fpga     = malloc(pixels * sizeof(int32_t));

    if (!img_in || !out_naive || !out_loeffler || !out_neon || !out_fpga) {
        fprintf(stderr, "malloc failed\n");
        return 1;
    }

    srand(42);
    for (int i = 0; i < pixels; i++)
        img_in[i] = (uint8_t)(rand() % 256);

    /* ── open /dev/mem and map the LW bridge ── */
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return 1; }

    void *lw = mmap(NULL, LW_BRIDGE_SPAN,
                    PROT_READ | PROT_WRITE, MAP_SHARED, fd, LW_BRIDGE_BASE);
    if (lw == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

    volatile int *dct_hw = (volatile int *)((char *)lw + DCT_1D_OFFSET);

    uint8_t blk_in[N][N];
    int32_t blk_out[N][N];
    double  t0, t1;
    int     bx, by;

    /* ── Naive C pass ── */
    printf("Running naive C DCT      ...  (%d x %d, %d blocks)\n",
           IMAGE_W, IMAGE_H, BLOCKS);
    fflush(stdout);
    t0 = now_ms();
    for (by = 0; by < IMAGE_H / N; by++)
        for (bx = 0; bx < IMAGE_W / N; bx++) {
            extract_block(img_in, bx, by, blk_in);
            dct_2d_naive(blk_in, blk_out);
            store_block(blk_out, bx, by, out_naive);
        }
    t1 = now_ms();
    double naive_ms = t1 - t0;

    /* ── Loeffler pass ── */
    printf("Running Loeffler DCT     ...  (%d x %d, %d blocks)\n",
           IMAGE_W, IMAGE_H, BLOCKS);
    fflush(stdout);
    t0 = now_ms();
    for (by = 0; by < IMAGE_H / N; by++)
        for (bx = 0; bx < IMAGE_W / N; bx++) {
            extract_block(img_in, bx, by, blk_in);
            dct_2d_loeffler_flat(blk_in, blk_out);
            store_block(blk_out, bx, by, out_loeffler);
        }
    t1 = now_ms();
    double loeffler_ms = t1 - t0;

    /* ── Loeffler NEON pass ── */
    printf("Running Loeffler NEON    ...  (%d x %d, %d blocks)\n",
           IMAGE_W, IMAGE_H, BLOCKS);
    fflush(stdout);
    t0 = now_ms();
    for (by = 0; by < IMAGE_H / N; by++)
        for (bx = 0; bx < IMAGE_W / N; bx++) {
            extract_block(img_in, bx, by, blk_in);
            dct_2d_loeffler_neon_flat(blk_in, blk_out);
            store_block(blk_out, bx, by, out_neon);
        }
    t1 = now_ms();
    double neon_ms = t1 - t0;

    /* ── FPGA pass ── */
    printf("Running FPGA DCT         ...  (%d x %d, %d blocks)\n",
           IMAGE_W, IMAGE_H, BLOCKS);
    fflush(stdout);
    t0 = now_ms();
    for (by = 0; by < IMAGE_H / N; by++)
        for (bx = 0; bx < IMAGE_W / N; bx++) {
            extract_block(img_in, bx, by, blk_in);
            dct_2d_fpga(dct_hw, blk_in, blk_out);
            store_block(blk_out, bx, by, out_fpga);
        }
    t1 = now_ms();
    double fpga_ms = t1 - t0;

    /* ── Correctness ── */
    /*
     * ±1 tolerance is expected throughout:
     *   Naive     uses double cos() — reference
     *   Loeffler  uses fixed-point butterflies — should match FPGA very closely
     *   FPGA      uses Q10 coefficients + >>11 rounding
     * All three implement the same orthonormal DCT so should agree to ±1 LSB.
     * If Loeffler vs FPGA shows max_diff > 2, the normalization scales differ.
     */
    diff_t naive_vs_fpga        = compare(out_naive,    out_fpga,     pixels, 1);
    diff_t naive_vs_loeffler    = compare(out_naive,    out_loeffler, pixels, 1);
    diff_t naive_vs_neon        = compare(out_naive,    out_neon,     pixels, 1);
    diff_t loeffler_vs_neon     = compare(out_loeffler, out_neon,     pixels, 1);
    diff_t loeffler_vs_fpga     = compare(out_loeffler, out_fpga,     pixels, 1);

    /* ── Spot-check: print block (0,0) from all four ── */
    print_block("Naive         ", out_naive,    0, 0);
    print_block("Loeffler C    ", out_loeffler, 0, 0);
    print_block("Loeffler NEON ", out_neon,     0, 0);
    print_block("FPGA          ", out_fpga,     0, 0);

    /* ── Timing report ── */
    printf("\n");
    printf("=== Benchmark: %dx%d image, %d blocks of %dx%d ===\n\n",
           IMAGE_W, IMAGE_H, BLOCKS, N, N);

    printf("  %-16s %8s   %12s   %9s   %9s\n",
           "Method", "Time(ms)", "Blocks/sec", "vs Naive", "vs Loeffler C");
    printf("  %-16s %8.2f   %12.0f   %9s   %9s\n",
           "Naive C",
           naive_ms, BLOCKS/(naive_ms/1000.0), "1.00x", "-");
    printf("  %-16s %8.2f   %12.0f   %9.2fx   %9s\n",
           "Loeffler C",
           loeffler_ms, BLOCKS/(loeffler_ms/1000.0), naive_ms/loeffler_ms, "1.00x");
    printf("  %-16s %8.2f   %12.0f   %9.2fx   %9.2fx\n",
           "Loeffler NEON",
           neon_ms, BLOCKS/(neon_ms/1000.0), naive_ms/neon_ms, loeffler_ms/neon_ms);
    printf("  %-16s %8.2f   %12.0f   %9.2fx   %9s\n",
           "FPGA",
           fpga_ms, BLOCKS/(fpga_ms/1000.0), naive_ms/fpga_ms, "-");

    printf("\n  Accuracy (±1 tolerance):\n");
    printf("    Naive vs FPGA          : %6d mismatches, max diff = %d\n",
           naive_vs_fpga.mismatches,     naive_vs_fpga.max_diff);
    printf("    Naive vs Loeffler C    : %6d mismatches, max diff = %d\n",
           naive_vs_loeffler.mismatches, naive_vs_loeffler.max_diff);
    printf("    Naive vs Loeffler NEON : %6d mismatches, max diff = %d\n",
           naive_vs_neon.mismatches,     naive_vs_neon.max_diff);
    printf("    Loeffler C vs NEON     : %6d mismatches, max diff = %d\n",
           loeffler_vs_neon.mismatches,  loeffler_vs_neon.max_diff);
    printf("    Loeffler C vs FPGA     : %6d mismatches, max diff = %d\n",
           loeffler_vs_fpga.mismatches,  loeffler_vs_fpga.max_diff);

    /* ── MMIO breakdown ── */
    long total_mmio = (long)BLOCKS * 16L * 16L;
    double ns_per_txn = (fpga_ms * 1e6) / total_mmio;
    printf("\n  FPGA MMIO: %ld transactions, %.1f ns each, %.1f M/sec\n",
           total_mmio, ns_per_txn,
           total_mmio / (fpga_ms / 1000.0) / 1e6);

    /*
     * Estimate pure FPGA compute time by subtracting bus overhead.
     *
     * Each 2D block needs 16 × 1D DCT passes (8 rows + 8 cols).
     * Each 1D DCT takes 3 clock cycles on the FPGA:
     *   cycle 1: IDLE detects written_mask==0xFF → COMPUTE
     *   cycle 2: COMPUTE fires all 64 MACs       → OUTPUT
     *   cycle 3: OUTPUT rounds/shifts results     → IDLE
     *
     * Bus overhead per 1D DCT = 16 transactions × ns_per_txn
     * Compute time per 1D DCT = 3 cycles × (1000 / FPGA_CLK_MHZ) ns
     *
     * Total bus time   = total_mmio × ns_per_txn   (already measured)
     * Total compute    = total_time − total_bus_time
     */
    long   total_1d_dcts    = (long)BLOCKS * 16L;
    double cycles_per_1d    = 3.0;
    double ns_per_cycle     = 1000.0 / FPGA_CLK_MHZ;
    double compute_only_ms  = total_1d_dcts * cycles_per_1d * ns_per_cycle / 1e6;
    double bus_only_ms      = fpga_ms - compute_only_ms;

    printf("\n  FPGA time breakdown (estimated @ %d MHz):\n", FPGA_CLK_MHZ);
    printf("    Total measured      : %8.2f ms\n",  fpga_ms);
    printf("    Bus overhead (est.) : %8.2f ms  (%.1f%%)\n",
           bus_only_ms,   bus_only_ms   / fpga_ms * 100.0);
    printf("    Compute only (est.) : %8.2f ms  (%.1f%%)\n",
           compute_only_ms, compute_only_ms / fpga_ms * 100.0);
    printf("    Compute vs Loeffler C    : %8.2fx\n", loeffler_ms  / compute_only_ms);
    printf("    Compute vs Loeffler NEON : %8.2fx\n", neon_ms      / compute_only_ms);

    munmap(lw, LW_BRIDGE_SPAN);
    close(fd);
    free(img_in);
    free(out_naive);
    free(out_loeffler);
    free(out_neon);
    free(out_fpga);
    return 0;
}

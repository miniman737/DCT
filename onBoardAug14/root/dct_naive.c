/* ==========================================================
 * dct_naive.c -- Naive software 2D-DCT
 *
 * Source: Mihai SIMA, SENG440 slide deck 4, with four fixes.
 *
 * BUG 1 -- transposition(): y was never reset to 0 between rows,
 *          so only row 0 was ever transposed and the remaining 56
 *          elements were uninitialised stack garbage. Rewritten as
 *          nested for loops, which cannot exhibit the fault.
 *
 * BUG 2 -- output copy loop: the inner loop over l was missing, so
 *          the copy read o_block[k][N] (one past the row) and wrote
 *          output_stream[N*(k+1)]. Out of bounds on both sides.
 *          Removed entirely -- dct_1d() now writes straight into out.
 *
 * BUG 3 -- normalisation: the deck uses (2.0/N)*ck, which is 2x too
 *          small per pass and 4x too small for the 2D transform.
 *          The orthonormal DCT-II needs sqrt(2.0/N)*ck.
 *
 * BUG 4 -- missing transpose back: row-DCT, transpose, row-DCT
 *          returns the TRANSPOSE of the 2D DCT. A separable 2D DCT
 *          in this form needs three transposes, not one. Without the
 *          third, F(u,v) and F(v,u) are swapped throughout -- the DC
 *          term and main diagonal are unaffected, which is why a
 *          spot check of F(0,0) does not catch it.
 *
 * Scaling now matches dct_2d_loeffler() and the FPGA dct_1d_top
 * peripheral: all three produce the orthonormal DCT-II, equal to
 * MATLAB's  dct(dct(A,[],2)',[],2)'  -- F(0,0) = 1258..1260 on the
 * standard JPEG test block.
 *
 * Build standalone:  gcc -O2 -o dct_naive dct_naive.c -lm
 * ========================================================== */

#include <stdio.h>
#include <stdint.h>
#include <math.h>

#ifndef N
#define N 8
#endif

#ifndef PI
#define PI 3.14159265358979323846
#endif

/* ----------------------------------------------------------
 * transpose
 *
 * out and in MUST NOT alias. Elements are written one at a
 * time, so an in-place call would overwrite entries that have
 * not been read yet.
 * ---------------------------------------------------------- */
static void transpose(int32_t in[N][N], int32_t out[N][N])
{
    int x, y;
    for (x = 0; x < N; x++)
        for (y = 0; y < N; y++)
            out[y][x] = in[x][y];
}

/* ----------------------------------------------------------
 * dct_1d -- 8-point orthonormal DCT-II, double precision
 *
 * cos() is evaluated inside the inner loop, 64 times per call.
 * That is deliberately unoptimised: this is the correctness
 * reference the fixed-point versions are measured against, not
 * a competitive implementation.
 *
 * The cast to int32_t truncates rather than rounds, biasing
 * results toward zero by up to 1 LSB per pass. Left as-is to
 * stay faithful to the reference; add 0.5 with copysign if an
 * exact match to MATLAB's rounding is wanted.
 * ---------------------------------------------------------- */
static void dct_1d(const int32_t *input, int32_t *output)
{
    for (int k = 0; k < N; k++) {
        double sum = 0.0;
        double ck  = (k == 0) ? (1.0 / sqrt(2.0)) : 1.0;
        for (int n = 0; n < N; n++)
            sum += input[n] * cos(PI * k * (2.0 * n + 1.0) / (2.0 * N));
        output[k] = (int32_t)(sum * sqrt(2.0 / N) * ck);   /* BUG 3 fixed */
    }
}

/* ----------------------------------------------------------
 * dct_2d_naive -- separable 2D DCT by row-column decomposition
 *
 * in  : 8x8 block of raw pixels, 0-255, no level shift
 * out : 8x8 orthonormal DCT-II coefficients, row-major
 * ---------------------------------------------------------- */
static void dct_2d_naive(const uint8_t in[N][N], int32_t out[N][N])
{
    int32_t i_block[N][N], t1[N][N], t2[N][N], t3[N][N];

    for (int k = 0; k < N; k++)
        for (int l = 0; l < N; l++)
            i_block[k][l] = (int32_t)in[k][l];

    /* Pass 1: transform each row */
    for (int k = 0; k < N; k++)
        dct_1d(i_block[k], t1[k]);

    /* Transpose so the columns become rows */
    transpose(t1, t2);

    /* Pass 2: transform each row of the transposed block, which is
     * a column of the original */
    for (int k = 0; k < N; k++)
        dct_1d(t2[k], t3[k]);

    /* BUG 4 fixed -- restore row-major orientation. Separate
     * destination required; transpose(t3, t3) would corrupt. */
    transpose(t3, out);
}

/* ----------------------------------------------------------
 * Standalone test. The benchmark harness renames this main via
 * -Dmain=naive_main at include time, so it is never called there.
 *
 * Note: the original used an all-zero input block, which printed
 * all zeros and concealed every bug above. Use a real block.
 * ---------------------------------------------------------- */
int main(void)
{
    const uint8_t input[N][N] = {
        {139, 144, 149, 153, 155, 155, 155, 155},
        {144, 151, 153, 156, 159, 156, 156, 156},
        {150, 155, 160, 163, 158, 156, 156, 156},
        {159, 161, 162, 160, 160, 159, 159, 159},
        {159, 160, 161, 162, 162, 155, 155, 155},
        {161, 161, 161, 161, 160, 157, 157, 157},
        {162, 162, 161, 163, 162, 157, 157, 157},
        {162, 162, 161, 161, 163, 158, 158, 158}
    };

    int32_t output[N][N] = {{0}};

    dct_2d_naive(input, output);

    printf("Naive 2D DCT coefficients:\n");
    for (int x = 0; x < N; x++) {
        printf("  ");
        for (int y = 0; y < N; y++)
            printf("%8d", output[x][y]);
        printf("\n");
    }
    printf("\nExpected F(0,0) ~ 1258 (FPGA and Loeffler give 1260;\n");
    printf("the 2 LSB gap is the truncating cast, not an error).\n");

    return 0;
}

/*
 * dct_rc.c
 *
 * 2D DCT via row-column separation using the FPGA 1D DCT.
 * With the uniform >>> 11 OUTPUT stage, each pass is an exact
 * orthonormal DCT identical to MATLAB's dct().
 *
 * No level shift, no scaling corrections needed.
 *
 * Build:  gcc -O0 -o dct_rc dct_rc.c
 * Run:    ./dct_rc
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define LW_BRIDGE_BASE   0xFF200000
#define LW_BRIDGE_SPAN   0x00200000
#define DCT_1D_OFFSET    0x0200

#define N 8

static void fpga_dct_1d(volatile int *dct, const int16_t in[N], int16_t out[N])
{
    for (int i = 0; i < N; i++)
        dct[i] = (int)in[i];

    for (int i = 0; i < N; i++)
        out[i] = (int16_t)(dct[i] & 0xFFFF);
}

static void dct_2d_fpga(volatile int *dct,
                        const uint8_t input[N][N],
                        int32_t output[N][N])
{
    int16_t row_in[N], row_out[N];
    int32_t intermediate[N][N];

    /* Pass 1: row-wise */
    for (int r = 0; r < N; r++) {
        for (int c = 0; c < N; c++)
            row_in[c] = (int16_t)input[r][c];

        fpga_dct_1d(dct, row_in, row_out);

        for (int c = 0; c < N; c++)
            intermediate[r][c] = (int32_t)row_out[c];
    }

    /* Pass 2: column-wise */
    for (int c = 0; c < N; c++) {
        for (int r = 0; r < N; r++)
            row_in[r] = (int16_t)intermediate[r][c];

        fpga_dct_1d(dct, row_in, row_out);

        for (int r = 0; r < N; r++)
            output[r][c] = (int32_t)row_out[r];
    }
}

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

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return 1; }

    void *lw = mmap(NULL, LW_BRIDGE_SPAN,
                    PROT_READ | PROT_WRITE, MAP_SHARED,
                    fd, LW_BRIDGE_BASE);
    if (lw == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

    volatile int *dct = (volatile int *)((char *)lw + DCT_1D_OFFSET);

    dct_2d_fpga(dct, input, output);

    printf("2D DCT output (MATLAB-compatible):\n");
    for (int r = 0; r < N; r++) {
        printf("  ");
        for (int c = 0; c < N; c++)
            printf("%7d", output[r][c]);
        printf("\n");
    }

    munmap(lw, LW_BRIDGE_SPAN);
    close(fd);
    return 0;
}

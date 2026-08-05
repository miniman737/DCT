// Fixed-point arithmetic DCT implementation 
// Utilises row-column seperation and the 1D DCT Loeffler algorithm

// Input: 8x8 block of pixels, 320 x 240 grayscale image

// Dependencies: stdio.h, stdint.h

#include <stdio.h>
#include <stdint.h>

#define public		// dummy public declaration

/* Calculated constants for the Loeffler algorithm */ 
#define dct_fp_precision 10 							// precision for fixed-point arithmetic
#define dct_fp_rounding (1 << (dct_fp_precision - 1))	// rounding constant for fixed-point arithmetic

/* Butterfly coeffecients - scaled using DCT fixed-point arithmetic precision of 10*/
// Butterfly coefficients C1
#define C1_cos 1004
#define C1_sin 200



#define N 8		// Define the size of the NxN block

/*------------------------------------------------------------------------*/

/*DCT Functions*/
static void butterfly_fp();													// butterfly - Software implementation of the butterfly operation
public void dct_2d_loeffler(uint8_t input[N][N], int16_t output[N][N]);		// 2D DCT using Loeffler algorithm, row-column separation

/*------------------------------------------------------------------------*/

// Butterfly software routine implementation
static void butterfly_fp() 
{
	
}


/*------------------------------------------------------------------------*/

// 2D DCT using Loeffler algorithm, row-column separation
// Input: 8x8 block of pixels, 320 x 240 grayscale image (each pixel is 8 bits, 0-255) --> uint8_t input[N][N]
// Output: 8x8 block of DCT coefficients (each coefficient is 16 bits, -32768 to 32767) --> int16_t output[N][N]
public void dct_2d_loeffler(uint8_t input[N][N], int16_t output[N][N]) 
{
	// row-column separation: first perform 1D DCT on rows, then on columns

	uint8_t i;
	int16_t tmp;		// tmp variable to hold results

	// Row-wise 1D DCT
	for (i = 0; i < N; i++) 
	{
		// Stage 1
		// Even part
		output[i][0] = input[i][0] + input[i][7];
		output[i][4] = input[i][1] + input[i][6];
		output[i][2] = input[i][2] + input[i][5];
		output[i][6] = input[i][3] + input[i][4];

		// Odd part
		output[i][7] = input[i][3] - input[i][4];
		output[i][3] = input[i][2] - input[i][5];
		output[i][5] = input[i][1] - input[i][6];
		output[i][1] = input[i][0] - input[i][7];

		// Stage 2
		// Even part
	}
}

int main() 
{
	// Classic JPEG sample 8x8 pixel block (0-255 grayscale), commonly used as a DCT test vector
	uint8_t input[N][N] = {
		{139, 144, 149, 153, 155, 155, 155, 155},
		{144, 151, 153, 156, 159, 156, 156, 156},
		{150, 155, 160, 163, 158, 156, 156, 156},
		{159, 161, 162, 160, 160, 159, 159, 159},
		{159, 160, 161, 162, 162, 155, 155, 155},
		{161, 161, 161, 161, 160, 157, 157, 157},
		{162, 162, 161, 163, 162, 157, 157, 157},
		{162, 162, 161, 161, 163, 158, 158, 158}
	};
	int16_t output[N][N] = {0};

	dct_2d_loeffler(input, output);
	for(int x = 0; x < N; x++)
	{
		for(int y = 0; y < N; y++)
		{
			printf("%d\n", output[x][y]);
		}
	} 
	
 	return 0; 
}

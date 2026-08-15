#include <stdio.h>
#include <stdint.h>

#define public		// dummy public declaration

#define N 8		// Define the size of the NxN block


/* Calculated constants for the Loeffler algorithm */
#define dct_fp_precision 10 							// precision for fixed-point arithmetic
#define dct_fp_rounding (1 << (dct_fp_precision - 1))	// rounding constant for fixed-point arithmetic

#define dct_gain_scale 3								// scaling factor for gain scaling in DCT
#define dct_gain_rounding (1 << (dct_gain_scale - 1))	// rounding constant for gain scaling

/* Butterfly coeffecients - scaled using DCT fixed-point arithmetic precision of 10*/
// Butterfly coefficients C1
#define C1_cos 1004					// cos(pi/16) * 1024
#define C1_sin 200					// sin(pi/16) * 1024
#define C1_simplified_1 (-805)		// (sin(pi/16) - cos(pi/16)) * 1024
#define C1_simplified_2 (-1204)		// (-sin(pi/16) - cos(pi/16)) * 1024

// Butterfly coefficients C3
#define C3_cos 851					// cos(3pi/16) * 1024
#define C3_sin 569					// sin(3pi/16) * 1024
#define C3_simplified_1 (-283)		// (sin(3pi/16) - cos(3pi/16)) * 1024
#define C3_simplified_2 (-1420)		// (-sin(3pi/16) - cos(3pi/16)) * 1024

// Butterfly coefficients sqrt(2) * C6
#define sqrt2 1448					// sqrt(2) * 1024 --> used in scale-up in stage 4
#define C6_cos 554					// (sqrt(2) * cos(6pi/16)) * 1024
#define C6_sin 1338					// (sqrt(2) * sin(6pi/16)) * 1024
#define C6_simplified_1 784			// (sqrt(2) * sin(6pi/16) - sqrt(2) * cos(6pi/16)) * 1024
#define C6_simplified_2 (-1892)		// (-sqrt(2) * sin(6pi/16) - sqrt(2) * cos(6pi/16)) * 1024


/*------------------------------------------------------------------------*/

// Butterfly rotation coefficients, indexed by rotator (1 = C1, 2 = sqrt(2)*C6, 3 = C3)
// simplified_1 = sin - cos, simplified_2 = -(sin + cos) --> enables 3-multiply rotation
typedef struct {
	int16_t cos_coef;
	int16_t simplified_1;
	int16_t simplified_2;
} rotator_coef_t;

// Lookup table for butterfly rotation coefficients
static const rotator_coef_t rotator_table[] = {
	[1] = { C1_cos, C1_simplified_1, C1_simplified_2 },
	[2] = { C6_cos, C6_simplified_1, C6_simplified_2 },
	[3] = { C3_cos, C3_simplified_1, C3_simplified_2 },
};

/*DCT Functions*/
static void butterfly_fp(int16_t upper, int16_t lower, int16_t *out_upper, int16_t *out_lower, uint8_t rotator);		// butterfly - Software implementation of the butterfly operation
public void dct_2d_loeffler(uint8_t input[N][N], int16_t output[N][N]);													// 2D DCT using Loeffler algorithm, row-column separation

/*------------------------------------------------------------------------*/

// Butterfly software routine implementation
// Input: upper = I', lower = I" - input values to be rotated
// Output: out_upper = O', out_lower = O" - rotated values
static void butterfly_fp(int16_t in_upper, int16_t in_lower, int16_t *out_upper, int16_t *out_lower, uint8_t rotator)
{
	rotator_coef_t coef = rotator_table[rotator];								// Lookup the rotation coefficients for the specified rotator

	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication

	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication

	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
}


/*------------------------------------------------------------------------*/

// 2D DCT using Loeffler algorithm, row-column separation
// Input: 8x8 block of pixels, 320 x 240 grayscale image (each pixel is 8 bits, 0-255) --> uint8_t input[N][N]
// Output: 8x8 block of DCT coefficients (each coefficient is 16 bits, -32768 to 32767) --> int16_t output[N][N]
public void dct_2d_loeffler(uint8_t input[N][N], int16_t output[N][N])
{
	// row-column separation: first perform 1D DCT on rows, then on columns

	uint8_t i; //counter for the initial loop, instead of setting it in the loop, also this follows the Barr-C coding style
	int16_t tmp_1, tmp_2;		// tmp variables to hold results --> second tmp is only used in stage 1 of column-wise DCT

	// Row-wise 1D DCT
	// N is a macro that is Set to 8 unless the user sets anything
	for (i = 0; i < N; i++)
	{
		// Stage 1
		// Even part all addition
		// exactly as listed in the DCT slides from SIMA
		// stage 1 is just addition of certain matrix values
		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4

		// Odd part all subtraction
		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
		// just the reflector portion

		// Stage 2
		// Even part is reflectors again
		// could be swapped in order, but this prevents aliasing from occuring
		tmp_1 = output[i][0];
		output[i][0] = tmp_1 + output[i][6];
		output[i][6] = tmp_1 - output[i][6];

		tmp_1 = output[i][4];
		output[i][4] = tmp_1 + output[i][2];
		output[i][2] = tmp_1 - output[i][2];


		// Odd part is all butterfly operations
		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1

		// Stage 3
		// Even part
		tmp_1 = output[i][0];
		output[i][0] = tmp_1 + output[i][4];
		output[i][4] = tmp_1 - output[i][4];

		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6

		// Odd part
		tmp_1 = output[i][7];
		output[i][7] = tmp_1 + output[i][5];
		output[i][5] = tmp_1 - output[i][5];

		tmp_1 = output[i][1];
		output[i][1] = tmp_1 + output[i][3];
		output[i][3] = tmp_1 - output[i][3];


		// Stage 4
		// Rounding point for fixed-point arithmetic, to round to nearest integer (1 << 2) for right shift of 3 bits
		// Even part --> NOP
		// Scale by a 3 shift right to account for the 3 stages of scaling in DCT --> 11 bits = 8 bits for input + 3 bits for scaling
		// ONLY APPLY GAIN SCALING AFTER THE COLUMN-WISE DCT, NOT AFTER THE ROW-WISE DCT, AS THIS WILL CAUSE LOSS OF PRECISION AND INCREASED QUANTISATION ERROR

		// Odd part
		tmp_1 = output[i][1];
		output[i][1] = tmp_1 + output[i][7];
		output[i][7] = tmp_1 - output[i][7];

		/* Scale up units */
		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	}

	// Column-wise 1D DCT - takes resulting output from row-wise DCT as input
	for (i = 0; i < N; i++)
	{
		// Stage 1
		// Utilise tmp_1 and tmp_2 ordering to prevent aliasing of output values
		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
		tmp_2 = output[1][i] - output[6][i];

		output[1][i] = output[0][i] - output[7][i];
		output[0][i] = output[0][i] + output[7][i];


		output[6][i] = output[3][i] + output[4][i];
		output[7][i] = output[3][i] - output[4][i];

		output[3][i] = output[2][i] - output[5][i];
		output[2][i] = output[2][i] + output[5][i];

		output[4][i] = tmp_1;
		output[5][i] = tmp_2;

		// Stage 2
		// Even part
		tmp_1 = output[0][i];
		output[0][i] = tmp_1 + output[6][i];
		output[6][i] = tmp_1 - output[6][i];

		tmp_1 = output[4][i];
		output[4][i] = tmp_1 + output[2][i];
		output[2][i] = tmp_1 - output[2][i];


		// Odd part
butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1

		// Stage 3
		// Even part
		tmp_1 = output[0][i];
		output[0][i] = tmp_1 + output[4][i];
		output[4][i] = tmp_1 - output[4][i];

		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6

		// Odd part
		tmp_1 = output[7][i];
		output[7][i] = tmp_1 + output[5][i];
		output[5][i] = tmp_1 - output[5][i];

		tmp_1 = output[1][i];

		output[1][i] = tmp_1 + output[3][i];
		output[3][i] = tmp_1 - output[3][i];

		// Stage 4
		// Rounding point for fixed-point arithmetic, to round to nearest integer (1 << 2) for right shift of 3 bits
		// Even part --> NOP
		// Scale by a 3 shift right to account for the 3 stages of scaling in DCT --> 11 bits = 8 bits for input + 3 bits for scaling
		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;

		// Odd part
		// Scale by a 3 shift right to account for the 3 stages of scaling DCT
		tmp_1 = output[1][i];
		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;

		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;

		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
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

	printf("DCT Coefficients:\n");
	for(int x = 0; x < N; x++)
	{
		for(int y = 0; y < N; y++)
		{
			printf("%6d", output[x][y]);
		}
		printf("\n");
	}

 	return 0;
}


// Fixed-point arithmetic DCT implementation 
// Utilises row-column seperation and the 1D DCT Loeffler algorithm
// Firmware assembly implementation of the Butterfly operation for the 1D DCT Loeffler algorithm
// Butterfly operation utilises SIMD NEON instruction to perform 4-multiply and 2-add operations in parallel

// Input: 8x8 block of pixels, 320 x 240 grayscale image

// Dependencies: stdio.h, stdint.h, arm_neon.h

#include <stdio.h>
#include <stdint.h>
#include <arm_neon.h>
#include <arm_vector_types.h>

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

// Butterfly coefficients C3
#define C3_cos 851					// cos(3pi/16) * 1024
#define C3_sin 569					// sin(3pi/16) * 1024

// Butterfly coefficients sqrt(2) * C6
#define sqrt2 1448					// sqrt(2) * 1024 --> used in scale-up in stage 4
#define C6_cos 554					// (sqrt(2) * cos(6pi/16)) * 1024
#define C6_sin 1338					// (sqrt(2) * sin(6pi/16)) * 1024


/*------------------------------------------------------------------------*/

// Butterfly rotation coefficients, indexed by rotator (1 = C1, 2 = sqrt(2)*C6, 3 = C3)
typedef struct {
	int16_t cos_coef;
	int16_t sin_coef;
} rotator_coef_t;

// Lookup table for butterfly rotation coefficients - 4 MULTIPLY, 2 ADD SIMD NEON INSTRUCTION IMPLEMENTATION
static const rotator_coef_t rotator_table[] = {
	[1] = { C1_cos, C1_sin },
	[2] = { C6_cos, C6_sin },
	[3] = { C3_cos, C3_sin },
};

/*DCT Functions*/
static uint32_t butterfly_fw(int32_t Rs, uint8_t rotator);		                    // butterfly - Firmware implementation of the butterfly operation
public void dct_2d_loeffler(uint8_t input[N][N], int16_t output[N][N]);		// 2D DCT using Loeffler algorithm, row-column separation

/*------------------------------------------------------------------------*/

// Butterfly firmware implementation - utilises SIMD NEON instruction to perform 4-multiply and 2-add operations in parallel
// Input: 32-bit packed Rs (16-bit upper = I', lower = I"), uint8_t rotator = 1, 2, 3 for each rotator
// Output: 32-bit packed Rt (16-bit out_upper = O', out_lower = O")
static uint32_t butterfly_fw(int32_t Rs, uint8_t rotator)
{
	rotator_coef_t coef = rotator_table[rotator];								        // Lookup the rotation coefficients for the specified rotator

    int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
    int16x4_t data_vec;                                                                 // Load the input data into a NEON vector
    int32x2_t presult;                                                                  // NEON vector to hold the intermediate results
    int32_t Rt;                                                                         // Variable to hold the final result
    int32_t tmp0, tmp1;                                                                 // Temporary variables for intermediate calculations

	__asm__(
        "vdup.32   %P[data], %[Rs]              \n\t"                                   // Duplicate the input Rs into a NEON vector
        "vmull.s16 q2, %P[data], %P[coef]       \n\t"                                   // Multiply the input data by the rotation coefficients (4 MULTIPLY, 2 ADD SIMD NEON INSTRUCTION)
        "vpadd.i32 %P[presult], d4, d5          \n\t"                                   // Pairwise add the adjacent results to get the final rotated values
        "vrshr.s32 %P[presult], %P[presult], #10 \n\t"                                  // Right shift the results by 10 bits to account for the fixed-point precision
        "vmov.32   %[tmp0], %P[presult][0]      \n\t"                                   // Move the first result to tmp0
        "vmov.32   %[tmp1], %P[presult][1]      \n\t"                                   // Move the second result to tmp1
        "lsl       %[tmp1], %[tmp1], #16        \n\t"                                   // Left shift tmp1 by 16 bits to prepare for packing
        "uxth      %[tmp0], %[tmp0]             \n\t"                                   // Extract the lower 16 bits of tmp0        
        "orr       %[Rt], %[tmp0], %[tmp1]      \n\t"                                   // Combine tmp0 and tmp1 to form the final 32-bit result Rt    
        : [data] "=&w" (data_vec), [presult] "=&w" (presult),
          [tmp0] "=&r" (tmp0), [tmp1] "=&r" (tmp1), [Rt] "=r" (Rt)
        : [Rs] "r" (Rs), [coef] "w" (coef_vec)
        : "q2"                                                                          // clobber list for NEON registers q2 = d4, d5
    );
    return Rt;
}


/*------------------------------------------------------------------------*/

// 2D DCT using Loeffler algorithm, row-column separation
// Input: 8x8 block of pixels, 320 x 240 grayscale image (each pixel is 8 bits, 0-255) --> uint8_t input[N][N]
// Output: 8x8 block of DCT coefficients (each coefficient is 16 bits, -32768 to 32767) --> int16_t output[N][N]
public void dct_2d_loeffler(uint8_t input[N][N], int16_t output[N][N]) 
{
	// row-column separation: first perform 1D DCT on rows, then on columns

	uint8_t i;
	int16_t tmp_1, tmp_2;		// tmp variables to hold results --> second tmp is only used in stage 1 of column-wise DCT

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
		tmp_1 = output[i][0];
		output[i][0] = tmp_1 + output[i][6];
		output[i][6] = tmp_1 - output[i][6];

		tmp_1 = output[i][4];
		output[i][4] = tmp_1 + output[i][2];
		output[i][2] = tmp_1 - output[i][2];
		

		// Odd part

        // Pack the odd part inputs into a 32-bit integer for the butterfly operation
        // C3 butterfly operation
        uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
        uint32_t Rt = butterfly_fw(Rs, 3); // Call butterfly function C
        // Unpack the results back into the output array
        output[i][7] = (int16_t)(Rt >> 16);
        output[i][1] = (int16_t)(Rt & 0xFFFF);

        // C1 butterfly operation
        Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
        Rt = butterfly_fw(Rs, 1); // Call butterfly function C1
        // Unpack the results back into the output array
        output[i][3] = (int16_t)(Rt >> 16);
        output[i][5] = (int16_t)(Rt & 0xFFFF);

		// Stage 3
		// Even part
		tmp_1 = output[i][0];
		output[i][0] = tmp_1 + output[i][4];
		output[i][4] = tmp_1 - output[i][4];

        // sqrt(2) * C6 butterfly operation
        Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
        Rt = butterfly_fw(Rs, 2); // Call butterfly function sqrt(2) * C6
        // Unpack the results back into the output array
        output[i][2] = (int16_t)(Rt >> 16);
        output[i][6] = (int16_t)(Rt & 0xFFFF);

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
        // C3 butterfly operation
        uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
        uint32_t Rt = butterfly_fw(Rs, 3); // Call butterfly function C3
        // Unpack the results back into the output array
        output[7][i] = (int16_t)(Rt >> 16);
        output[1][i] = (int16_t)(Rt & 0xFFFF);

        // C1 butterfly operation
        Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
        Rt = butterfly_fw(Rs, 1); // Call butterfly function C1
        // Unpack the results back into the output array
        output[3][i] = (int16_t)(Rt >> 16);
        output[5][i] = (int16_t)(Rt & 0xFFFF);

		// Stage 3
		// Even part
		tmp_1 = output[0][i];
		output[0][i] = tmp_1 + output[4][i];
		output[4][i] = tmp_1 - output[4][i];

        // sqrt(2) * C6 butterfly operation
        Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
        Rt = butterfly_fw(Rs, 2); // Call butterfly function sqrt(2) * C6
        // Unpack the results back into the output array
        output[2][i] = (int16_t)(Rt >> 16);
        output[6][i] = (int16_t)(Rt & 0xFFFF);

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
		

	.cpu arm10e
	.arch armv5te
	.fpu vfp
	.eabi_attribute 28, 1	@ Tag_ABI_VFP_args
	.eabi_attribute 20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute 21, 1	@ Tag_ABI_FP_exceptions
	.eabi_attribute 23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute 24, 1	@ Tag_ABI_align8_needed
	.eabi_attribute 25, 1	@ Tag_ABI_align8_preserved
	.eabi_attribute 26, 2	@ Tag_ABI_enum_size
	.eabi_attribute 30, 2	@ Tag_ABI_optimization_goals
	.eabi_attribute 34, 0	@ Tag_CPU_unaligned_access
	.eabi_attribute 18, 4	@ Tag_ABI_PCS_wchar_t
	.file	"dct_loeffler.c"
@ GNU C17 (GCC) version 11.2.1 20211120 (arm-linux-musleabihf)
@	compiled by GNU C version 11.2.1 20211120, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version none
@ GGC heuristics: --param ggc-min-expand=98 --param ggc-min-heapsize=128978
@ options passed: -mcpu=arm10e -mfloat-abi=hard -mtls-dialect=gnu -marm -march=armv5te+fp -O2
	.text
	.align	2
	.global	dct_2d_loeffler
	.syntax unified
	.arm
	.type	dct_2d_loeffler, %function
dct_2d_loeffler:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}	@
	add	r3, r1, #128	@ _503, output,
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldr	r10, .L8	@ tmp539,
@ dct_loeffler.c:83: {
	sub	sp, sp, #12	@,,
@ dct_loeffler.c:83: {
	mov	lr, r1	@ output, tmp725
	str	r1, [sp, #4]	@ output, %sfp
	str	r3, [sp]	@ _503, %sfp
.L2:
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r3, [r0, #7]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 7B], MEM[(unsigned char *)_471 + 7B]
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r8, [r0]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471], MEM[(unsigned char *)_471]
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	add	lr, lr, #16	@ ivtmp.49, ivtmp.49,
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	add	r8, r8, r3	@ _8, MEM[(unsigned char *)_471], MEM[(unsigned char *)_471 + 7B]
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	strh	r8, [lr, #-16]	@ movhi	@ _8, MEM[(short int *)_487]
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r3, [r0, #6]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 6B], MEM[(unsigned char *)_471 + 6B]
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r9, [r0, #1]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 1B], MEM[(unsigned char *)_471 + 1B]
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	add	r0, r0, #8	@ ivtmp.48, ivtmp.48,
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	add	r9, r9, r3	@ _16, MEM[(unsigned char *)_471 + 1B], MEM[(unsigned char *)_471 + 6B]
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	strh	r9, [lr, #-8]	@ movhi	@ _16, MEM[(short int *)_487 + 8B]
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r3, [r0, #-3]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 5B], MEM[(unsigned char *)_471 + 5B]
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r7, [r0, #-6]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 2B], MEM[(unsigned char *)_471 + 2B]
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	add	r7, r7, r3	@ _22, MEM[(unsigned char *)_471 + 2B], MEM[(unsigned char *)_471 + 5B]
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	strh	r7, [lr, #-12]	@ movhi	@ _22, MEM[(short int *)_487 + 4B]
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r3, [r0, #-4]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 4B], MEM[(unsigned char *)_471 + 4B]
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r6, [r0, #-5]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 3B], MEM[(unsigned char *)_471 + 3B]
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	add	r6, r6, r3	@ _28, MEM[(unsigned char *)_471 + 3B], MEM[(unsigned char *)_471 + 4B]
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	strh	r6, [lr, #-4]	@ movhi	@ _28, MEM[(short int *)_487 + 12B]
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r3, [r0, #-4]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 4B], MEM[(unsigned char *)_471 + 4B]
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r5, [r0, #-5]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 3B], MEM[(unsigned char *)_471 + 3B]
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	sub	r5, r5, r3	@ _35, MEM[(unsigned char *)_471 + 3B], MEM[(unsigned char *)_471 + 4B]
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	strh	r5, [lr, #-2]	@ movhi	@ _35, MEM[(short int *)_487 + 14B]
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r3, [r0, #-3]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 5B], MEM[(unsigned char *)_471 + 5B]
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r1, [r0, #-6]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 2B], MEM[(unsigned char *)_471 + 2B]
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	sub	r1, r1, r3	@ _41, MEM[(unsigned char *)_471 + 2B], MEM[(unsigned char *)_471 + 5B]
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	strh	r1, [lr, #-10]	@ movhi	@ _41, MEM[(short int *)_487 + 6B]
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r3, [r0, #-2]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 6B], MEM[(unsigned char *)_471 + 6B]
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r4, [r0, #-7]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 1B], MEM[(unsigned char *)_471 + 1B]
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	sub	r4, r4, r3	@ _47, MEM[(unsigned char *)_471 + 1B], MEM[(unsigned char *)_471 + 6B]
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	strh	r4, [lr, #-6]	@ movhi	@ _47, MEM[(short int *)_487 + 10B]
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r2, [r0, #-1]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471 + 7B], MEM[(unsigned char *)_471 + 7B]
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r3, [r0, #-8]	@ zero_extendqisi2	@ MEM[(unsigned char *)_471], MEM[(unsigned char *)_471]
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	ip, r4, r4, lsl #22	@ tmp506, _47, _47,
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	sub	r3, r3, r2	@ _53, MEM[(unsigned char *)_471], MEM[(unsigned char *)_471 + 7B]
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r2, r5, r3	@ tmp426, _35, _53
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	fp, r2, r2, lsl #2	@ tmp429, tmp426, tmp426,
	add	fp, fp, fp, lsl #2	@ tmp431, tmp429, tmp429,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	ip, r4, ip, lsl #2	@ tmp508, _47, tmp506,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	fp, fp, fp, lsl #4	@ tmp433, tmp431, tmp431,
	add	r2, r2, fp, lsl #1	@ tmp435, tmp426, tmp433,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	ip, r4, ip, lsl #3	@ tmp510, _47, tmp508,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	fp, r1, r1, lsl #2	@ tmp478, _41, _41,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	ip, r4, ip, lsl #3	@ tmp512, _47, tmp510,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	fp, fp, fp, lsl #4	@ tmp480, tmp478, tmp478,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	ip, r4, ip, lsl #2	@ tmp514, _47, tmp512,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r4, r1, r4	@ tmp436, _41, _47
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r1, r1, fp, lsl #2	@ tmp482, _41, tmp480,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	fp, r3, r3, lsl #24	@ tmp491, _53, _53,
	rsb	fp, r3, fp, lsl #3	@ tmp493, _53, tmp491,
	add	fp, r3, fp, lsl #3	@ tmp495, _53, tmp493,
	add	r3, r3, fp, lsl #2	@ tmp497, _53, tmp495,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	fp, r5, r5, lsl #3	@ tmp521, _35, _35,
	rsb	r5, r5, fp, lsl #3	@ tmp523, _35, tmp521,
	add	r5, r5, r5, lsl #2	@ tmp525, tmp523, tmp523,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r3, r3, r2	@ t_upper, tmp497, tmp435
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	sub	r2, r2, r5, lsl #2	@ t_lower, tmp435, tmp525,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	rsb	r5, r4, r4, lsl #6	@ tmp439, tmp436, tmp436,
	rsb	r4, r4, r5, lsl #2	@ tmp441, tmp436, tmp439,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	lsl	r1, r1, #2	@ tmp483, tmp482,
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	sub	r5, r9, r7	@ _61, _16, _22
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r1, r1, r4, lsl #2	@ t_lower, tmp483, tmp441,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	ip, ip, r4, lsl #2	@ t_upper, tmp514, tmp441,
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	sub	r4, r8, r6	@ _57, _8, _28
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	add	r6, r8, r6	@ _54, _8, _28
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r8, r5, r5, lsl #21	@ tmp465, _61, _61,
	add	r8, r5, r8, lsl #4	@ tmp467, _61, tmp465,
	add	r8, r5, r8, lsl #2	@ tmp469, _61, tmp467,
	rsb	r8, r5, r8, lsl #3	@ tmp471, _61, tmp469,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r5, r5, r4	@ tmp445, _61, _57
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	add	r7, r9, r7	@ _58, _16, _22
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r4, r4, r4, lsl #3	@ tmp456, _57, _57,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r9, r5, r5, lsl #4	@ tmp448, tmp445, tmp445,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r4, r4, r4, lsl #3	@ tmp458, tmp456, tmp456,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r9, r5, r9, lsl #2	@ tmp450, tmp445, tmp448,
	add	r5, r5, r9, lsl #2	@ tmp452, tmp445, tmp450,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	add	r3, r3, #512	@ tmp499, t_upper,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	add	r1, r1, #512	@ tmp486, t_lower,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	lsl	r4, r4, #4	@ tmp459, tmp458,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r4, r4, r5, lsl #1	@ t_upper, tmp459, tmp452,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	r3, r3, #10	@ tmp500, tmp499,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	asr	r1, r1, #10	@ tmp487, tmp486,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsl	r3, r3, #16	@ tmp_1.6_81, tmp500,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsl	r1, r1, #16	@ _80, tmp487,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	add	r4, r4, #512	@ tmp461, t_upper,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsr	r1, r1, #16	@ _80, _80,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsr	r3, r3, #16	@ tmp_1.6_81, tmp_1.6_81,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	r4, r4, #10	@ tmp462, tmp461,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	lsl	r8, r8, #2	@ tmp472, tmp471,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	strh	r4, [lr, #-12]	@ movhi	@ tmp462, MEM[(int16_t *)_487 + 4B]
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r8, r8, r5, lsl #1	@ t_lower, tmp472, tmp452,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	add	r4, r1, r3	@ tmp502, _80, tmp_1.6_81
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	mov	r5, #512	@ tmp732,
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	sub	r3, r3, r1	@ tmp542, tmp_1.6_81, _80
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	add	r2, r2, #512	@ tmp529, t_lower,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	add	ip, ip, #512	@ tmp516, t_upper,
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	smlabb	r3, r3, r10, r5	@ tmp543, tmp542, tmp539, tmp732
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	asr	r2, r2, #10	@ tmp530, tmp529,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	ip, ip, #10	@ tmp517, tmp516,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	lsl	r2, r2, #16	@ tmp_1.8_87, tmp530,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	lsl	ip, ip, #16	@ _86, tmp517,
	lsr	ip, ip, #16	@ _86, _86,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	lsr	r2, r2, #16	@ tmp_1.8_87, tmp_1.8_87,
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r3, r3, #10	@ tmp547, tmp543,
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	strh	r3, [lr, #-6]	@ movhi	@ tmp547, MEM[(short int *)_487 + 10B]
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	add	r3, ip, r2	@ tmp532, _86, tmp_1.8_87
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	add	r8, r8, #512	@ tmp474, t_lower,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsl	r1, r4, #16	@ _82, tmp502,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	lsl	r3, r3, #16	@ _88, tmp532,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsr	r1, r1, #16	@ _82, _82,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	lsr	r3, r3, #16	@ _88, _88,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	asr	r8, r8, #10	@ tmp475, tmp474,
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	sub	r2, r2, ip	@ tmp536, tmp_1.8_87, _86
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	add	ip, r1, r3	@ tmp534, _82, _88
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	sub	r3, r3, r1	@ tmp535, _88, _82
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	strh	r8, [lr, #-4]	@ movhi	@ tmp475, MEM[(int16_t *)_487 + 12B]
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	strh	r3, [lr, #-2]	@ movhi	@ tmp535, MEM[(short int *)_487 + 14B]
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	add	r3, r6, r7	@ tmp443, _54, _58
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	smlabb	r2, r2, r10, r5	@ tmp537, tmp536, tmp539, tmp733
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	strh	r3, [lr, #-16]	@ movhi	@ tmp443, MEM[(short int *)_487]
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	ldr	r3, [sp]	@ _503, %sfp
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r2, r2, #10	@ tmp541, tmp537,
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	sub	r6, r6, r7	@ tmp444, _54, _58
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	cmp	lr, r3	@ ivtmp.49, _503
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	strh	ip, [lr, #-14]	@ movhi	@ tmp534, MEM[(short int *)_487 + 2B]
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	strh	r2, [lr, #-10]	@ movhi	@ tmp541, MEM[(short int *)_487 + 6B]
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	strh	r6, [lr, #-8]	@ movhi	@ tmp444, MEM[(short int *)_487 + 8B]
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	bne	.L2		@,
	ldr	r3, [sp, #4]	@ output, %sfp
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldr	r10, .L8	@ tmp705,
	sub	r5, r3, #2	@ ivtmp.39, output,
	mov	r9, #512	@ tmp706,
	add	r3, r3, #14	@ _316, output,
	str	r3, [sp]	@ _316, %sfp
.L3:
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldrh	r6, [r5, #98]	@ _109, MEM[(short int *)_321 + 98B]
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldrh	r0, [r5, #18]	@ _107, MEM[(short int *)_321 + 18B]
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldrh	r3, [r5, #2]!	@ _113, MEM[(short int *)_435]
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	sub	r4, r0, r6	@ tmp550, _107, _109
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldrh	r1, [r5, #112]	@ _115, MEM[(short int *)_435 + 112B]
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldrh	r2, [r5, #64]	@ _127, MEM[(short int *)_435 + 64B]
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldrh	lr, [r5, #48]	@ _125, MEM[(short int *)_435 + 48B]
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	sub	ip, r3, r1	@ tmp552, _113, _115
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	sub	r7, lr, r2	@ tmp558, _125, _127
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	add	r0, r0, r6	@ tmp548, _107, _109
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	add	r3, r3, r1	@ tmp554, _113, _115
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldrh	r6, [r5, #80]	@ _139, MEM[(short int *)_435 + 80B]
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldrh	r1, [r5, #32]	@ _137, MEM[(short int *)_435 + 32B]
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	add	lr, lr, r2	@ tmp556, _125, _127
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	ldr	r2, [sp]	@ _316, %sfp
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	lsl	ip, ip, #16	@ _117, tmp552,
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	cmp	r2, r5	@ _316, ivtmp.39
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	sub	r2, r1, r6	@ tmp560, _137, _139
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	add	r1, r1, r6	@ tmp562, _137, _139
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	lsl	r0, r0, #16	@ _110, tmp548,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	lsl	r7, r7, #16	@ _135, tmp558,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	lsl	r1, r1, #16	@ _146, tmp562,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	asr	ip, ip, #16	@ _117, _117,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	asr	r7, r7, #16	@ _135, _135,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	lsr	r1, r1, #16	@ _146, _146,
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	lsr	r0, r0, #16	@ _110, _110,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	add	r8, r0, r1	@ tmp568, _110, _146
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	lsl	r4, r4, #16	@ tmp_2, tmp550,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	sub	r0, r0, r1	@ tmp570, _110, _146
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	lsl	r3, r3, #16	@ _122, tmp554,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r1, r7, ip	@ tmp572, _135, _117
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	lsl	lr, lr, #16	@ _128, tmp556,
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	asr	r4, r4, #16	@ tmp_2, tmp_2,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	lsr	lr, lr, #16	@ _128, _128,
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	lsr	r3, r3, #16	@ _122, _122,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	fp, r1, r1, lsl #2	@ tmp575, tmp572, tmp572,
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	add	r6, r3, lr	@ tmp564, _122, _128
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	lsl	r2, r2, #16	@ _141, tmp560,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	sub	r3, r3, lr	@ tmp566, _122, _128
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	fp, fp, fp, lsl #2	@ tmp577, tmp575, tmp575,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	lr, r4, r4, lsl #22	@ tmp626, tmp_2, tmp_2,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	asr	r2, r2, #16	@ _141, _141,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	lr, r4, lr, lsl #2	@ tmp628, tmp_2, tmp626,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	fp, fp, fp, lsl #4	@ tmp579, tmp577, tmp577,
	add	r1, r1, fp, lsl #1	@ tmp581, tmp572, tmp579,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	lr, r4, lr, lsl #3	@ tmp630, tmp_2, tmp628,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	fp, r2, r2, lsl #2	@ tmp600, _141, _141,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	lr, r4, lr, lsl #3	@ tmp632, tmp_2, tmp630,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	fp, fp, fp, lsl #4	@ tmp602, tmp600, tmp600,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	lr, r4, lr, lsl #2	@ tmp634, tmp_2, tmp632,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r4, r2, r4	@ tmp582, _141, tmp_2
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r2, r2, fp, lsl #2	@ tmp604, _141, tmp602,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	fp, ip, ip, lsl #24	@ tmp613, _117, _117,
	rsb	fp, ip, fp, lsl #3	@ tmp615, _117, tmp613,
	add	fp, ip, fp, lsl #3	@ tmp617, _117, tmp615,
	add	ip, ip, fp, lsl #2	@ tmp619, _117, tmp617,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	fp, r7, r7, lsl #3	@ tmp641, _135, _135,
	rsb	r7, r7, fp, lsl #3	@ tmp643, _135, tmp641,
	add	r7, r7, r7, lsl #2	@ tmp645, tmp643, tmp643,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	ip, ip, r1	@ t_upper, tmp619, tmp581
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	lsl	r0, r0, #16	@ _165, tmp570,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	sub	r1, r1, r7, lsl #2	@ t_lower, tmp581, tmp645,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	rsb	r7, r4, r4, lsl #6	@ tmp585, tmp582, tmp582,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	asr	r0, r0, #16	@ _165, _165,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	rsb	r4, r4, r7, lsl #2	@ tmp587, tmp582, tmp585,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	lsl	r2, r2, #2	@ tmp605, tmp604,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r2, r2, r4, lsl #2	@ t_lower, tmp605, tmp587,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	lr, lr, r4, lsl #2	@ t_upper, tmp634, tmp587,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r4, r0, r0, lsl #21	@ tmp677, _165, _165,
	add	r4, r0, r4, lsl #4	@ tmp679, _165, tmp677,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	lsl	r3, r3, #16	@ _156, tmp566,
	asr	r3, r3, #16	@ _156, _156,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r4, r0, r4, lsl #2	@ tmp681, _165, tmp679,
	rsb	r4, r0, r4, lsl #3	@ tmp683, _165, tmp681,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r0, r0, r3	@ tmp589, _165, _156
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r7, r0, r0, lsl #4	@ tmp592, tmp589, tmp589,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	rsb	r3, r3, r3, lsl #3	@ tmp664, _156, _156,
	rsb	r3, r3, r3, lsl #3	@ tmp666, tmp664, tmp664,
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	add	r7, r0, r7, lsl #2	@ tmp594, tmp589, tmp592,
	add	r0, r0, r7, lsl #2	@ tmp596, tmp589, tmp594,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	lsl	r3, r3, #4	@ tmp667, tmp666,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	lsl	r4, r4, #2	@ tmp684, tmp683,
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r4, r4, r0, lsl #1	@ t_lower, tmp684, tmp596,
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	add	r3, r3, r0, lsl #1	@ t_upper, tmp667, tmp596,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	add	ip, ip, #512	@ tmp621, t_upper,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	add	r1, r1, #512	@ tmp649, t_lower,
	add	r2, r2, #512	@ tmp608, t_lower,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	add	lr, lr, #512	@ tmp636, t_upper,
	add	r0, r3, #512	@ tmp669, t_upper,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	ip, ip, #10	@ tmp622, tmp621,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	add	r3, r4, #512	@ tmp686, t_lower,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	asr	r1, r1, #10	@ tmp650, tmp649,
	asr	r2, r2, #10	@ tmp609, tmp608,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	lr, lr, #10	@ tmp637, tmp636,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	lsl	ip, ip, #16	@ tmp_1.19_189, tmp622,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	lsl	r1, r1, #16	@ tmp_1.21_198, tmp650,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	lsl	r2, r2, #16	@ _188, tmp609,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	lsl	lr, lr, #16	@ _197, tmp637,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	asr	r3, r3, #10	@ tmp687, tmp686,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	lsr	ip, ip, #16	@ tmp_1.19_189, tmp_1.19_189,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	lsr	lr, lr, #16	@ _197, _197,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	lsr	r1, r1, #16	@ tmp_1.21_198, tmp_1.21_198,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	lsr	r2, r2, #16	@ _188, _188,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r3, r3, #16	@ tmp688, tmp687,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	add	r4, lr, r1	@ tmp692, _197, tmp_1.21_198
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r3, r3, #16	@ tmp688, tmp688,
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	sub	r1, r1, lr	@ tmp702, tmp_1.21_198, _197
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	sub	lr, ip, r2	@ tmp712, tmp_1.19_189, _188
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	smlabb	r1, r1, r10, r9	@ tmp703, tmp702, tmp705, tmp706
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	smlabb	lr, lr, r10, r9	@ tmp713, tmp712, tmp705, tmp706
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	lsl	r6, r6, #16	@ _151, tmp564,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	lsl	r8, r8, #16	@ _160, tmp568,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ tmp690, tmp688,
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	lsr	r6, r6, #16	@ _151, _151,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	lsr	r8, r8, #16	@ _160, _160,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	add	r2, r2, ip	@ tmp694, _188, tmp_1.19_189
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r3, r3, #3	@ tmp691, tmp690,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	r0, r0, #10	@ tmp670, tmp669,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	lsl	r4, r4, #16	@ _225, tmp692,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ _227, tmp694,
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r1, r1, #10	@ tmp707, tmp703,
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	lr, lr, #10	@ tmp717, tmp713,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	strh	r3, [r5, #96]	@ movhi	@ tmp691, MEM[(short int *)_435 + 96B]
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	add	r3, r6, r8	@ tmp652, _151, _160
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	sub	r6, r6, r8	@ tmp657, _151, _160
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r4, r4, #16	@ _225, _225,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r2, #16	@ _227, _227,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r0, r0, #16	@ tmp671, tmp670,
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	lsl	r1, r1, #16	@ tmp708, tmp707,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	lsl	lr, lr, #16	@ tmp718, tmp717,
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r3, r3, #16	@ tmp653, tmp652,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r6, r6, #16	@ tmp658, tmp657,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	ip, r4, r2	@ tmp696, _225, _227
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r0, r0, #16	@ tmp671, tmp671,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	sub	r2, r4, r2	@ tmp699, _225, _227
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	r1, r1, #16	@ tmp708, tmp708,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	lr, lr, #16	@ tmp718, tmp718,
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r3, r3, #16	@ tmp653, tmp653,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r6, r6, #16	@ tmp658, tmp658,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r0, r0, #4	@ tmp673, tmp671,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	ip, ip, #4	@ tmp697, tmp696,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r2, r2, #4	@ tmp700, tmp699,
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	add	r1, r1, #4	@ tmp710, tmp708,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	add	lr, lr, #4	@ tmp720, tmp718,
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ tmp655, tmp653,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r6, r6, #4	@ tmp660, tmp658,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r0, r0, #3	@ tmp674, tmp673,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	ip, ip, #3	@ tmp698, tmp697,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r2, #3	@ tmp701, tmp700,
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	r1, r1, #3	@ tmp711, tmp710,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	lr, lr, #3	@ tmp721, tmp720,
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r3, r3, #3	@ tmp656, tmp655,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r6, r6, #3	@ tmp661, tmp660,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	strh	r0, [r5, #32]	@ movhi	@ tmp674, MEM[(short int *)_435 + 32B]
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	strh	ip, [r5, #16]	@ movhi	@ tmp698, MEM[(short int *)_435 + 16B]
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	strh	r2, [r5, #112]	@ movhi	@ tmp701, MEM[(short int *)_435 + 112B]
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	strh	r1, [r5, #48]	@ movhi	@ tmp711, MEM[(short int *)_435 + 48B]
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	strh	lr, [r5, #80]	@ movhi	@ tmp721, MEM[(short int *)_435 + 80B]
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	strh	r3, [r5]	@ movhi	@ tmp656, MEM[(short int *)_435]
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	strh	r6, [r5, #64]	@ movhi	@ tmp661, MEM[(short int *)_435 + 64B]
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	bne	.L3		@,
@ dct_loeffler.c:234: }
	add	sp, sp, #12	@,,
	@ sp needed	@
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, pc}	@
.L9:
	.align	2
.L8:
	.word	1448
	.size	dct_2d_loeffler, .-dct_2d_loeffler
	.section	.rodata.str1.4,"aMS",%progbits,1
	.align	2
.LC1:
	.ascii	"DCT Coefficients:\000"
	.align	2
.LC2:
	.ascii	"%6d\000"
	.section	.text.startup,"ax",%progbits
	.align	2
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 192
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, lr}	@
	sub	sp, sp, #196	@,,
@ dct_loeffler.c:239: 	uint8_t input[N][N] = {
	ldr	lr, .L16	@ tmp124,
	mov	ip, sp	@ tmp123,
.LPIC0:
	add	lr, pc, lr	@ tmp124, tmp124
	ldmia	lr!, {r0, r1, r2, r3}	@ tmp124,,,,
	add	r5, sp, #80	@ ivtmp.67,,
@ dct_loeffler.c:258: 			printf("%6d", output[x][y]);
	ldr	r6, .L16+4	@ tmp133,
@ dct_loeffler.c:239: 	uint8_t input[N][N] = {
	stmia	ip!, {r0, r1, r2, r3}	@ tmp123,,,,
@ dct_loeffler.c:258: 			printf("%6d", output[x][y]);
.LPIC2:
	add	r6, pc, r6	@ tmp133, tmp133
@ dct_loeffler.c:239: 	uint8_t input[N][N] = {
	ldmia	lr!, {r0, r1, r2, r3}	@ tmp124,,,,
	add	r7, sp, #208	@ _39,,
	stmia	ip!, {r0, r1, r2, r3}	@ tmp123,,,,
	ldmia	lr!, {r0, r1, r2, r3}	@ tmp124,,,,
	stmia	ip!, {r0, r1, r2, r3}	@ tmp123,,,,
	ldm	lr, {r0, r1, r2, r3}	@ tmp124,,,,
	stm	ip, {r0, r1, r2, r3}	@ tmp123,,,,
@ dct_loeffler.c:249: 	int16_t output[N][N] = {0};
	add	r3, sp, #64	@ tmp125,,
	mov	r2, #128	@,
	mov	r0, r3	@, tmp125
	mov	r1, #0	@,
	bl	memset(PLT)	@
@ dct_loeffler.c:251: 	dct_2d_loeffler(input, output);
	mov	r1, r0	@, tmp125
	mov	r0, sp	@,
	bl	dct_2d_loeffler(PLT)	@
@ dct_loeffler.c:253: 	printf("DCT Coefficients:\n");
	ldr	r0, .L16+8	@,
.LPIC1:
	add	r0, pc, r0	@,
	bl	puts(PLT)	@
.L11:
	sub	r4, r5, #16	@ ivtmp.60, ivtmp.67,
.L12:
@ dct_loeffler.c:258: 			printf("%6d", output[x][y]);
	ldrsh	r1, [r4], #2	@, MEM[(short int *)_28]
	mov	r0, r6	@, tmp133
	bl	printf(PLT)	@
@ dct_loeffler.c:256: 		for(int y = 0; y < N; y++)
	cmp	r4, r5	@ ivtmp.60, ivtmp.67
	bne	.L12		@,
@ dct_loeffler.c:260: 		printf("\n");
	mov	r0, #10	@,
@ dct_loeffler.c:254: 	for(int x = 0; x < N; x++)
	add	r5, r4, #16	@ ivtmp.67, ivtmp.60,
@ dct_loeffler.c:260: 		printf("\n");
	bl	putchar(PLT)	@
@ dct_loeffler.c:254: 	for(int x = 0; x < N; x++)
	cmp	r5, r7	@ ivtmp.67, _39
	bne	.L11		@,
@ dct_loeffler.c:264: }
	mov	r0, #0	@,
	add	sp, sp, #196	@,,
	@ sp needed	@
	pop	{r4, r5, r6, r7, pc}	@
.L17:
	.align	2
.L16:
	.word	.LANCHOR0-(.LPIC0+8)
	.word	.LC2-(.LPIC2+8)
	.word	.LC1-(.LPIC1+8)
	.size	main, .-main
	.section	.rodata
	.align	2
	.set	.LANCHOR0,. + 0
.LC0:
	.ascii	"\213\220\225\231\233\233\233\233"
	.ascii	"\220\227\231\234\237\234\234\234"
	.ascii	"\226\233\240\243\236\234\234\234"
	.ascii	"\237\241\242\240\240\237\237\237"
	.ascii	"\237\240\241\242\242\233\233\233"
	.ascii	"\241\241\241\241\240\235\235\235"
	.ascii	"\242\242\241\243\242\235\235\235"
	.ascii	"\242\242\241\241\243\236\236\236"
	.ident	"GCC: (GNU) 11.2.1 20211120"
	.section	.note.GNU-stack,"",%progbits

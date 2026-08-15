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
	.eabi_attribute 30, 6	@ Tag_ABI_optimization_goals
	.eabi_attribute 34, 0	@ Tag_CPU_unaligned_access
	.eabi_attribute 18, 4	@ Tag_ABI_PCS_wchar_t
	.file	"dct_loeffler.c"
@ GNU C17 (GCC) version 11.2.1 20211120 (arm-linux-musleabihf)
@	compiled by GNU C version 11.2.1 20211120, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version none
@ GGC heuristics: --param ggc-min-expand=98 --param ggc-min-heapsize=128978
@ options passed: -mcpu=arm10e -mfloat-abi=hard -mtls-dialect=gnu -marm -march=armv5te+fp -O0
	.text
	.section	.rodata
	.align	2
	.type	rotator_table, %object
	.size	rotator_table, 24
rotator_table:
	.space	6
@ cos_coef:
	.short	1004
@ simplified_1:
	.short	-805
@ simplified_2:
	.short	-1204
@ cos_coef:
	.short	554
@ simplified_1:
	.short	784
@ simplified_2:
	.short	-1892
@ cos_coef:
	.short	851
@ simplified_1:
	.short	-283
@ simplified_2:
	.short	-1420
	.text
	.align	2
	.syntax unified
	.arm
	.type	butterfly_fp, %function
butterfly_fp:
	@ args = 4, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}	@
	add	fp, sp, #4	@,,
	sub	sp, sp, #40	@,,
	str	r2, [fp, #-36]	@ out_upper, out_upper
	str	r3, [fp, #-40]	@ out_lower, out_lower
	mov	r3, r0	@ movhi	@ tmp134, tmp133
	strh	r3, [fp, #-30]	@ movhi	@ tmp134, in_upper
	mov	r3, r1	@ movhi	@ tmp136, tmp135
	strh	r3, [fp, #-32]	@ movhi	@ tmp136, in_lower
@ dct_loeffler.c:65: 	rotator_coef_t coef = rotator_table[rotator];								// Lookup the rotation coefficients for the specified rotator
	ldrb	r2, [fp, #4]	@ zero_extendqisi2	@ _1, rotator
@ dct_loeffler.c:65: 	rotator_coef_t coef = rotator_table[rotator];								// Lookup the rotation coefficients for the specified rotator
	ldr	r1, .L2	@ tmp137,
.LPIC0:
	add	r1, pc, r1	@ tmp137, tmp137
	mov	r3, r2	@ tmp138, _1
	lsl	r3, r3, #1	@ tmp138, tmp138,
	add	r3, r3, r2	@ tmp138, tmp138, _1
	lsl	r3, r3, #1	@ tmp139, tmp138,
	add	r2, r1, r3	@ tmp140, tmp137, tmp138
	sub	r3, fp, #24	@ tmp141,,
	mov	r1, r2	@ tmp142, tmp140
	mov	r2, #6	@ tmp143,
	mov	r0, r3	@, tmp141
	bl	memcpy(PLT)	@
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	ldrsh	r3, [fp, #-24]	@ _2, coef.cos_coef
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	mov	r1, r3	@ _3, _2
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	ldrsh	r2, [fp, #-30]	@ _4, in_upper
	ldrsh	r3, [fp, #-32]	@ _5, in_lower
	add	r3, r2, r3	@ _6, _4, _5
@ dct_loeffler.c:67: 	int32_t tmp = (int32_t)coef.cos_coef * (in_upper + in_lower);				// Typecast to int32_t to prevent overflow during multiplication
	mul	r3, r1, r3	@ tmp145, _3, tmp145
	str	r3, [fp, #-8]	@ tmp145, tmp
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	ldrsh	r3, [fp, #-32]	@ _7, in_lower
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	ldrsh	r2, [fp, #-22]	@ _8, coef.simplified_1
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	mul	r3, r2, r3	@ _10, _9, _10
@ dct_loeffler.c:69: 	int32_t t_upper = tmp + (int32_t)in_lower * coef.simplified_1;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	ldr	r2, [fp, #-8]	@ tmp147, tmp
	add	r3, r2, r3	@ tmp146, tmp147, _10
	str	r3, [fp, #-12]	@ tmp146, t_upper
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	ldrsh	r3, [fp, #-30]	@ _11, in_upper
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	ldrsh	r2, [fp, #-20]	@ _12, coef.simplified_2
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	mul	r3, r2, r3	@ _14, _13, _14
@ dct_loeffler.c:70: 	int32_t t_lower = tmp + (int32_t)in_upper * coef.simplified_2;				// tmp var - Typecast to int32_t to prevent overflow during multiplication
	ldr	r2, [fp, #-8]	@ tmp149, tmp
	add	r3, r2, r3	@ tmp148, tmp149, _14
	str	r3, [fp, #-16]	@ tmp148, t_lower
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	ldr	r3, [fp, #-12]	@ tmp150, t_upper
	add	r3, r3, #512	@ _15, tmp150,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	asr	r3, r3, #10	@ _16, _15,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	lsl	r3, r3, #16	@ tmp151, _16,
	asr	r2, r3, #16	@ _17, tmp151,
@ dct_loeffler.c:72: 	*out_upper = (int16_t)((t_upper + dct_fp_rounding) >> dct_fp_precision);	// Scale down the result to int16_t and round to nearest integer
	ldr	r3, [fp, #-36]	@ tmp152, out_upper
	strh	r2, [r3]	@ movhi	@ _17, *out_upper_29(D)
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	ldr	r3, [fp, #-16]	@ tmp153, t_lower
	add	r3, r3, #512	@ _18, tmp153,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	asr	r3, r3, #10	@ _19, _18,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	lsl	r3, r3, #16	@ tmp154, _19,
	asr	r2, r3, #16	@ _20, tmp154,
@ dct_loeffler.c:73: 	*out_lower = (int16_t)((t_lower + dct_fp_rounding) >> dct_fp_precision);
	ldr	r3, [fp, #-40]	@ tmp155, out_lower
	strh	r2, [r3]	@ movhi	@ _20, *out_lower_31(D)
@ dct_loeffler.c:74: }
	nop	
	sub	sp, fp, #4	@,,
	@ sp needed	@
	pop	{fp, pc}	@
.L3:
	.align	2
.L2:
	.word	rotator_table-(.LPIC0+8)
	.size	butterfly_fp, .-butterfly_fp
	.align	2
	.global	dct_2d_loeffler
	.syntax unified
	.arm
	.type	dct_2d_loeffler, %function
dct_2d_loeffler:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}	@
	add	fp, sp, #4	@,,
	sub	sp, sp, #24	@,,
	str	r0, [fp, #-16]	@ input, input
	str	r1, [fp, #-20]	@ output, output
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	mov	r3, #0	@ tmp764,
	strb	r3, [fp, #-5]	@ tmp765, i
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	b	.L5		@
.L6:
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _1, i
	lsl	r3, r3, #3	@ _2, _1,
	ldr	r2, [fp, #-16]	@ tmp766, input
	add	r3, r2, r3	@ _3, tmp766, _2
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r3, [r3]	@ zero_extendqisi2	@ _4, (*_3)[0]
	lsl	r3, r3, #16	@ tmp767, _4,
	lsr	r2, r3, #16	@ _5, tmp767,
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _6, i
	lsl	r3, r3, #3	@ _7, _6,
	ldr	r1, [fp, #-16]	@ tmp768, input
	add	r3, r1, r3	@ _8, tmp768, _7
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r3, [r3, #7]	@ zero_extendqisi2	@ _9, (*_8)[7]
	lsl	r3, r3, #16	@ tmp769, _9,
	lsr	r3, r3, #16	@ _10, tmp769,
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	add	r3, r2, r3	@ tmp770, _5, _10
	lsl	r3, r3, #16	@ tmp771, tmp770,
	lsr	r2, r3, #16	@ _11, tmp771,
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _12, i
	lsl	r3, r3, #4	@ _13, _12,
	ldr	r1, [fp, #-20]	@ tmp772, output
	add	r3, r1, r3	@ _14, tmp772, _13
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	lsl	r2, r2, #16	@ tmp773, _11,
	asr	r2, r2, #16	@ _15, tmp773,
@ dct_loeffler.c:97: 		output[i][0] = input[i][0] + input[i][7]; // 0 = 0 + 7
	strh	r2, [r3]	@ movhi	@ _15, (*_14)[0]
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _16, i
	lsl	r3, r3, #3	@ _17, _16,
	ldr	r2, [fp, #-16]	@ tmp774, input
	add	r3, r2, r3	@ _18, tmp774, _17
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r3, [r3, #1]	@ zero_extendqisi2	@ _19, (*_18)[1]
	lsl	r3, r3, #16	@ tmp775, _19,
	lsr	r2, r3, #16	@ _20, tmp775,
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _21, i
	lsl	r3, r3, #3	@ _22, _21,
	ldr	r1, [fp, #-16]	@ tmp776, input
	add	r3, r1, r3	@ _23, tmp776, _22
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r3, [r3, #6]	@ zero_extendqisi2	@ _24, (*_23)[6]
	lsl	r3, r3, #16	@ tmp777, _24,
	lsr	r3, r3, #16	@ _25, tmp777,
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	add	r3, r2, r3	@ tmp778, _20, _25
	lsl	r3, r3, #16	@ tmp779, tmp778,
	lsr	r2, r3, #16	@ _26, tmp779,
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _27, i
	lsl	r3, r3, #4	@ _28, _27,
	ldr	r1, [fp, #-20]	@ tmp780, output
	add	r3, r1, r3	@ _29, tmp780, _28
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	lsl	r2, r2, #16	@ tmp781, _26,
	asr	r2, r2, #16	@ _30, tmp781,
@ dct_loeffler.c:98: 		output[i][4] = input[i][1] + input[i][6]; // index 4 = index 1 + index 6
	strh	r2, [r3, #8]	@ movhi	@ _30, (*_29)[4]
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _31, i
	lsl	r3, r3, #3	@ _32, _31,
	ldr	r2, [fp, #-16]	@ tmp782, input
	add	r3, r2, r3	@ _33, tmp782, _32
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r3, [r3, #2]	@ zero_extendqisi2	@ _34, (*_33)[2]
	lsl	r3, r3, #16	@ tmp783, _34,
	lsr	r2, r3, #16	@ _35, tmp783,
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _36, i
	lsl	r3, r3, #3	@ _37, _36,
	ldr	r1, [fp, #-16]	@ tmp784, input
	add	r3, r1, r3	@ _38, tmp784, _37
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r3, [r3, #5]	@ zero_extendqisi2	@ _39, (*_38)[5]
	lsl	r3, r3, #16	@ tmp785, _39,
	lsr	r3, r3, #16	@ _40, tmp785,
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	add	r3, r2, r3	@ tmp786, _35, _40
	lsl	r3, r3, #16	@ tmp787, tmp786,
	lsr	r2, r3, #16	@ _41, tmp787,
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _42, i
	lsl	r3, r3, #4	@ _43, _42,
	ldr	r1, [fp, #-20]	@ tmp788, output
	add	r3, r1, r3	@ _44, tmp788, _43
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	lsl	r2, r2, #16	@ tmp789, _41,
	asr	r2, r2, #16	@ _45, tmp789,
@ dct_loeffler.c:99: 		output[i][2] = input[i][2] + input[i][5]; // index 2 = index 2 + index 5
	strh	r2, [r3, #4]	@ movhi	@ _45, (*_44)[2]
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _46, i
	lsl	r3, r3, #3	@ _47, _46,
	ldr	r2, [fp, #-16]	@ tmp790, input
	add	r3, r2, r3	@ _48, tmp790, _47
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r3, [r3, #3]	@ zero_extendqisi2	@ _49, (*_48)[3]
	lsl	r3, r3, #16	@ tmp791, _49,
	lsr	r2, r3, #16	@ _50, tmp791,
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _51, i
	lsl	r3, r3, #3	@ _52, _51,
	ldr	r1, [fp, #-16]	@ tmp792, input
	add	r3, r1, r3	@ _53, tmp792, _52
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r3, [r3, #4]	@ zero_extendqisi2	@ _54, (*_53)[4]
	lsl	r3, r3, #16	@ tmp793, _54,
	lsr	r3, r3, #16	@ _55, tmp793,
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	add	r3, r2, r3	@ tmp794, _50, _55
	lsl	r3, r3, #16	@ tmp795, tmp794,
	lsr	r2, r3, #16	@ _56, tmp795,
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _57, i
	lsl	r3, r3, #4	@ _58, _57,
	ldr	r1, [fp, #-20]	@ tmp796, output
	add	r3, r1, r3	@ _59, tmp796, _58
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	lsl	r2, r2, #16	@ tmp797, _56,
	asr	r2, r2, #16	@ _60, tmp797,
@ dct_loeffler.c:100: 		output[i][6] = input[i][3] + input[i][4]; // index 6 = index 3 + index 4
	strh	r2, [r3, #12]	@ movhi	@ _60, (*_59)[6]
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _61, i
	lsl	r3, r3, #3	@ _62, _61,
	ldr	r2, [fp, #-16]	@ tmp798, input
	add	r3, r2, r3	@ _63, tmp798, _62
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r3, [r3, #3]	@ zero_extendqisi2	@ _64, (*_63)[3]
	lsl	r3, r3, #16	@ tmp799, _64,
	lsr	r2, r3, #16	@ _65, tmp799,
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _66, i
	lsl	r3, r3, #3	@ _67, _66,
	ldr	r1, [fp, #-16]	@ tmp800, input
	add	r3, r1, r3	@ _68, tmp800, _67
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r3, [r3, #4]	@ zero_extendqisi2	@ _69, (*_68)[4]
	lsl	r3, r3, #16	@ tmp801, _69,
	lsr	r3, r3, #16	@ _70, tmp801,
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	sub	r3, r2, r3	@ tmp802, _65, _70
	lsl	r3, r3, #16	@ tmp803, tmp802,
	lsr	r2, r3, #16	@ _71, tmp803,
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _72, i
	lsl	r3, r3, #4	@ _73, _72,
	ldr	r1, [fp, #-20]	@ tmp804, output
	add	r3, r1, r3	@ _74, tmp804, _73
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	lsl	r2, r2, #16	@ tmp805, _71,
	asr	r2, r2, #16	@ _75, tmp805,
@ dct_loeffler.c:103: 		output[i][7] = input[i][3] - input[i][4]; // index 7 = index 3 - index 4
	strh	r2, [r3, #14]	@ movhi	@ _75, (*_74)[7]
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _76, i
	lsl	r3, r3, #3	@ _77, _76,
	ldr	r2, [fp, #-16]	@ tmp806, input
	add	r3, r2, r3	@ _78, tmp806, _77
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r3, [r3, #2]	@ zero_extendqisi2	@ _79, (*_78)[2]
	lsl	r3, r3, #16	@ tmp807, _79,
	lsr	r2, r3, #16	@ _80, tmp807,
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _81, i
	lsl	r3, r3, #3	@ _82, _81,
	ldr	r1, [fp, #-16]	@ tmp808, input
	add	r3, r1, r3	@ _83, tmp808, _82
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r3, [r3, #5]	@ zero_extendqisi2	@ _84, (*_83)[5]
	lsl	r3, r3, #16	@ tmp809, _84,
	lsr	r3, r3, #16	@ _85, tmp809,
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	sub	r3, r2, r3	@ tmp810, _80, _85
	lsl	r3, r3, #16	@ tmp811, tmp810,
	lsr	r2, r3, #16	@ _86, tmp811,
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _87, i
	lsl	r3, r3, #4	@ _88, _87,
	ldr	r1, [fp, #-20]	@ tmp812, output
	add	r3, r1, r3	@ _89, tmp812, _88
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	lsl	r2, r2, #16	@ tmp813, _86,
	asr	r2, r2, #16	@ _90, tmp813,
@ dct_loeffler.c:104: 		output[i][3] = input[i][2] - input[i][5]; // index 3 = index 2 - index 5
	strh	r2, [r3, #6]	@ movhi	@ _90, (*_89)[3]
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _91, i
	lsl	r3, r3, #3	@ _92, _91,
	ldr	r2, [fp, #-16]	@ tmp814, input
	add	r3, r2, r3	@ _93, tmp814, _92
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r3, [r3, #1]	@ zero_extendqisi2	@ _94, (*_93)[1]
	lsl	r3, r3, #16	@ tmp815, _94,
	lsr	r2, r3, #16	@ _95, tmp815,
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _96, i
	lsl	r3, r3, #3	@ _97, _96,
	ldr	r1, [fp, #-16]	@ tmp816, input
	add	r3, r1, r3	@ _98, tmp816, _97
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r3, [r3, #6]	@ zero_extendqisi2	@ _99, (*_98)[6]
	lsl	r3, r3, #16	@ tmp817, _99,
	lsr	r3, r3, #16	@ _100, tmp817,
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	sub	r3, r2, r3	@ tmp818, _95, _100
	lsl	r3, r3, #16	@ tmp819, tmp818,
	lsr	r2, r3, #16	@ _101, tmp819,
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _102, i
	lsl	r3, r3, #4	@ _103, _102,
	ldr	r1, [fp, #-20]	@ tmp820, output
	add	r3, r1, r3	@ _104, tmp820, _103
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	lsl	r2, r2, #16	@ tmp821, _101,
	asr	r2, r2, #16	@ _105, tmp821,
@ dct_loeffler.c:105: 		output[i][5] = input[i][1] - input[i][6]; // index 5 = index 1 - index 6
	strh	r2, [r3, #10]	@ movhi	@ _105, (*_104)[5]
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _106, i
	lsl	r3, r3, #3	@ _107, _106,
	ldr	r2, [fp, #-16]	@ tmp822, input
	add	r3, r2, r3	@ _108, tmp822, _107
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r3, [r3]	@ zero_extendqisi2	@ _109, (*_108)[0]
	lsl	r3, r3, #16	@ tmp823, _109,
	lsr	r2, r3, #16	@ _110, tmp823,
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _111, i
	lsl	r3, r3, #3	@ _112, _111,
	ldr	r1, [fp, #-16]	@ tmp824, input
	add	r3, r1, r3	@ _113, tmp824, _112
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r3, [r3, #7]	@ zero_extendqisi2	@ _114, (*_113)[7]
	lsl	r3, r3, #16	@ tmp825, _114,
	lsr	r3, r3, #16	@ _115, tmp825,
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	sub	r3, r2, r3	@ tmp826, _110, _115
	lsl	r3, r3, #16	@ tmp827, tmp826,
	lsr	r2, r3, #16	@ _116, tmp827,
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _117, i
	lsl	r3, r3, #4	@ _118, _117,
	ldr	r1, [fp, #-20]	@ tmp828, output
	add	r3, r1, r3	@ _119, tmp828, _118
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	lsl	r2, r2, #16	@ tmp829, _116,
	asr	r2, r2, #16	@ _120, tmp829,
@ dct_loeffler.c:106: 		output[i][1] = input[i][0] - input[i][7]; // index 1 = index 0 - index 7
	strh	r2, [r3, #2]	@ movhi	@ _120, (*_119)[1]
@ dct_loeffler.c:112: 		tmp_1 = output[i][0];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _121, i
	lsl	r3, r3, #4	@ _122, _121,
	ldr	r2, [fp, #-20]	@ tmp830, output
	add	r3, r2, r3	@ _123, tmp830, _122
@ dct_loeffler.c:112: 		tmp_1 = output[i][0];
	ldrh	r3, [r3]	@ movhi	@ tmp831, (*_123)[0]
	strh	r3, [fp, #-8]	@ movhi	@ tmp831, tmp_1
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _124, i
	lsl	r3, r3, #4	@ _125, _124,
	ldr	r2, [fp, #-20]	@ tmp832, output
	add	r3, r2, r3	@ _126, tmp832, _125
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	ldrsh	r3, [r3, #12]	@ _127, (*_126)[6]
	lsl	r3, r3, #16	@ tmp833, _127,
	lsr	r2, r3, #16	@ _128, tmp833,
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	ldrh	r3, [fp, #-8]	@ tmp_1.0_129, tmp_1
	add	r3, r2, r3	@ tmp834, _128, tmp_1.0_129
	lsl	r3, r3, #16	@ tmp835, tmp834,
	lsr	r2, r3, #16	@ _130, tmp835,
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _131, i
	lsl	r3, r3, #4	@ _132, _131,
	ldr	r1, [fp, #-20]	@ tmp836, output
	add	r3, r1, r3	@ _133, tmp836, _132
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	lsl	r2, r2, #16	@ tmp837, _130,
	asr	r2, r2, #16	@ _134, tmp837,
@ dct_loeffler.c:113: 		output[i][0] = tmp_1 + output[i][6];
	strh	r2, [r3]	@ movhi	@ _134, (*_133)[0]
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	ldrh	r2, [fp, #-8]	@ tmp_1.1_135, tmp_1
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _136, i
	lsl	r3, r3, #4	@ _137, _136,
	ldr	r1, [fp, #-20]	@ tmp838, output
	add	r3, r1, r3	@ _138, tmp838, _137
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	ldrsh	r3, [r3, #12]	@ _139, (*_138)[6]
	lsl	r3, r3, #16	@ tmp839, _139,
	lsr	r3, r3, #16	@ _140, tmp839,
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	sub	r3, r2, r3	@ tmp840, tmp_1.1_135, _140
	lsl	r3, r3, #16	@ tmp841, tmp840,
	lsr	r2, r3, #16	@ _141, tmp841,
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _142, i
	lsl	r3, r3, #4	@ _143, _142,
	ldr	r1, [fp, #-20]	@ tmp842, output
	add	r3, r1, r3	@ _144, tmp842, _143
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	lsl	r2, r2, #16	@ tmp843, _141,
	asr	r2, r2, #16	@ _145, tmp843,
@ dct_loeffler.c:114: 		output[i][6] = tmp_1 - output[i][6];
	strh	r2, [r3, #12]	@ movhi	@ _145, (*_144)[6]
@ dct_loeffler.c:116: 		tmp_1 = output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _146, i
	lsl	r3, r3, #4	@ _147, _146,
	ldr	r2, [fp, #-20]	@ tmp844, output
	add	r3, r2, r3	@ _148, tmp844, _147
@ dct_loeffler.c:116: 		tmp_1 = output[i][4];
	ldrh	r3, [r3, #8]	@ movhi	@ tmp845, (*_148)[4]
	strh	r3, [fp, #-8]	@ movhi	@ tmp845, tmp_1
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _149, i
	lsl	r3, r3, #4	@ _150, _149,
	ldr	r2, [fp, #-20]	@ tmp846, output
	add	r3, r2, r3	@ _151, tmp846, _150
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	ldrsh	r3, [r3, #4]	@ _152, (*_151)[2]
	lsl	r3, r3, #16	@ tmp847, _152,
	lsr	r2, r3, #16	@ _153, tmp847,
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	ldrh	r3, [fp, #-8]	@ tmp_1.2_154, tmp_1
	add	r3, r2, r3	@ tmp848, _153, tmp_1.2_154
	lsl	r3, r3, #16	@ tmp849, tmp848,
	lsr	r2, r3, #16	@ _155, tmp849,
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _156, i
	lsl	r3, r3, #4	@ _157, _156,
	ldr	r1, [fp, #-20]	@ tmp850, output
	add	r3, r1, r3	@ _158, tmp850, _157
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	lsl	r2, r2, #16	@ tmp851, _155,
	asr	r2, r2, #16	@ _159, tmp851,
@ dct_loeffler.c:117: 		output[i][4] = tmp_1 + output[i][2];
	strh	r2, [r3, #8]	@ movhi	@ _159, (*_158)[4]
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	ldrh	r2, [fp, #-8]	@ tmp_1.3_160, tmp_1
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _161, i
	lsl	r3, r3, #4	@ _162, _161,
	ldr	r1, [fp, #-20]	@ tmp852, output
	add	r3, r1, r3	@ _163, tmp852, _162
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	ldrsh	r3, [r3, #4]	@ _164, (*_163)[2]
	lsl	r3, r3, #16	@ tmp853, _164,
	lsr	r3, r3, #16	@ _165, tmp853,
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	sub	r3, r2, r3	@ tmp854, tmp_1.3_160, _165
	lsl	r3, r3, #16	@ tmp855, tmp854,
	lsr	r2, r3, #16	@ _166, tmp855,
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _167, i
	lsl	r3, r3, #4	@ _168, _167,
	ldr	r1, [fp, #-20]	@ tmp856, output
	add	r3, r1, r3	@ _169, tmp856, _168
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	lsl	r2, r2, #16	@ tmp857, _166,
	asr	r2, r2, #16	@ _170, tmp857,
@ dct_loeffler.c:118: 		output[i][2] = tmp_1 - output[i][2];
	strh	r2, [r3, #4]	@ movhi	@ _170, (*_169)[2]
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _171, i
	lsl	r3, r3, #4	@ _172, _171,
	ldr	r2, [fp, #-20]	@ tmp858, output
	add	r3, r2, r3	@ _173, tmp858, _172
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	ldrsh	r0, [r3, #14]	@ _174, (*_173)[7]
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _175, i
	lsl	r3, r3, #4	@ _176, _175,
	ldr	r2, [fp, #-20]	@ tmp859, output
	add	r3, r2, r3	@ _177, tmp859, _176
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	ldrsh	r1, [r3, #2]	@ _178, (*_177)[1]
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _179, i
	lsl	r3, r3, #4	@ _180, _179,
	ldr	r2, [fp, #-20]	@ tmp860, output
	add	r3, r2, r3	@ _181, tmp860, _180
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	add	ip, r3, #14	@ _182, _181,
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _183, i
	lsl	r3, r3, #4	@ _184, _183,
	ldr	r2, [fp, #-20]	@ tmp861, output
	add	r3, r2, r3	@ _185, tmp861, _184
@ dct_loeffler.c:122: 		butterfly_fp(output[i][7], output[i][1], &output[i][7], &output[i][1], 3);		// Call butterfly function C3
	add	r3, r3, #2	@ _186, _185,
	mov	r2, #3	@ tmp862,
	str	r2, [sp]	@ tmp862,
	mov	r2, ip	@, _182
	bl	butterfly_fp(PLT)	@
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _187, i
	lsl	r3, r3, #4	@ _188, _187,
	ldr	r2, [fp, #-20]	@ tmp863, output
	add	r3, r2, r3	@ _189, tmp863, _188
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	ldrsh	r0, [r3, #6]	@ _190, (*_189)[3]
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _191, i
	lsl	r3, r3, #4	@ _192, _191,
	ldr	r2, [fp, #-20]	@ tmp864, output
	add	r3, r2, r3	@ _193, tmp864, _192
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	ldrsh	r1, [r3, #10]	@ _194, (*_193)[5]
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _195, i
	lsl	r3, r3, #4	@ _196, _195,
	ldr	r2, [fp, #-20]	@ tmp865, output
	add	r3, r2, r3	@ _197, tmp865, _196
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	add	ip, r3, #6	@ _198, _197,
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _199, i
	lsl	r3, r3, #4	@ _200, _199,
	ldr	r2, [fp, #-20]	@ tmp866, output
	add	r3, r2, r3	@ _201, tmp866, _200
@ dct_loeffler.c:123: 		butterfly_fp(output[i][3], output[i][5], &output[i][3], &output[i][5], 1);		// Call butterfly function C1
	add	r3, r3, #10	@ _202, _201,
	mov	r2, #1	@ tmp867,
	str	r2, [sp]	@ tmp867,
	mov	r2, ip	@, _198
	bl	butterfly_fp(PLT)	@
@ dct_loeffler.c:127: 		tmp_1 = output[i][0];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _203, i
	lsl	r3, r3, #4	@ _204, _203,
	ldr	r2, [fp, #-20]	@ tmp868, output
	add	r3, r2, r3	@ _205, tmp868, _204
@ dct_loeffler.c:127: 		tmp_1 = output[i][0];
	ldrh	r3, [r3]	@ movhi	@ tmp869, (*_205)[0]
	strh	r3, [fp, #-8]	@ movhi	@ tmp869, tmp_1
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _206, i
	lsl	r3, r3, #4	@ _207, _206,
	ldr	r2, [fp, #-20]	@ tmp870, output
	add	r3, r2, r3	@ _208, tmp870, _207
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	ldrsh	r3, [r3, #8]	@ _209, (*_208)[4]
	lsl	r3, r3, #16	@ tmp871, _209,
	lsr	r2, r3, #16	@ _210, tmp871,
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	ldrh	r3, [fp, #-8]	@ tmp_1.4_211, tmp_1
	add	r3, r2, r3	@ tmp872, _210, tmp_1.4_211
	lsl	r3, r3, #16	@ tmp873, tmp872,
	lsr	r2, r3, #16	@ _212, tmp873,
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _213, i
	lsl	r3, r3, #4	@ _214, _213,
	ldr	r1, [fp, #-20]	@ tmp874, output
	add	r3, r1, r3	@ _215, tmp874, _214
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	lsl	r2, r2, #16	@ tmp875, _212,
	asr	r2, r2, #16	@ _216, tmp875,
@ dct_loeffler.c:128: 		output[i][0] = tmp_1 + output[i][4];
	strh	r2, [r3]	@ movhi	@ _216, (*_215)[0]
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	ldrh	r2, [fp, #-8]	@ tmp_1.5_217, tmp_1
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _218, i
	lsl	r3, r3, #4	@ _219, _218,
	ldr	r1, [fp, #-20]	@ tmp876, output
	add	r3, r1, r3	@ _220, tmp876, _219
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	ldrsh	r3, [r3, #8]	@ _221, (*_220)[4]
	lsl	r3, r3, #16	@ tmp877, _221,
	lsr	r3, r3, #16	@ _222, tmp877,
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	sub	r3, r2, r3	@ tmp878, tmp_1.5_217, _222
	lsl	r3, r3, #16	@ tmp879, tmp878,
	lsr	r2, r3, #16	@ _223, tmp879,
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _224, i
	lsl	r3, r3, #4	@ _225, _224,
	ldr	r1, [fp, #-20]	@ tmp880, output
	add	r3, r1, r3	@ _226, tmp880, _225
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	lsl	r2, r2, #16	@ tmp881, _223,
	asr	r2, r2, #16	@ _227, tmp881,
@ dct_loeffler.c:129: 		output[i][4] = tmp_1 - output[i][4];
	strh	r2, [r3, #8]	@ movhi	@ _227, (*_226)[4]
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _228, i
	lsl	r3, r3, #4	@ _229, _228,
	ldr	r2, [fp, #-20]	@ tmp882, output
	add	r3, r2, r3	@ _230, tmp882, _229
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	ldrsh	r0, [r3, #4]	@ _231, (*_230)[2]
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _232, i
	lsl	r3, r3, #4	@ _233, _232,
	ldr	r2, [fp, #-20]	@ tmp883, output
	add	r3, r2, r3	@ _234, tmp883, _233
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	ldrsh	r1, [r3, #12]	@ _235, (*_234)[6]
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _236, i
	lsl	r3, r3, #4	@ _237, _236,
	ldr	r2, [fp, #-20]	@ tmp884, output
	add	r3, r2, r3	@ _238, tmp884, _237
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	add	ip, r3, #4	@ _239, _238,
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _240, i
	lsl	r3, r3, #4	@ _241, _240,
	ldr	r2, [fp, #-20]	@ tmp885, output
	add	r3, r2, r3	@ _242, tmp885, _241
@ dct_loeffler.c:131: 		butterfly_fp(output[i][2], output[i][6], &output[i][2], &output[i][6], 2);		// Call butterfly function sqrt(2) * C6
	add	r3, r3, #12	@ _243, _242,
	mov	r2, #2	@ tmp886,
	str	r2, [sp]	@ tmp886,
	mov	r2, ip	@, _239
	bl	butterfly_fp(PLT)	@
@ dct_loeffler.c:134: 		tmp_1 = output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _244, i
	lsl	r3, r3, #4	@ _245, _244,
	ldr	r2, [fp, #-20]	@ tmp887, output
	add	r3, r2, r3	@ _246, tmp887, _245
@ dct_loeffler.c:134: 		tmp_1 = output[i][7];
	ldrh	r3, [r3, #14]	@ movhi	@ tmp888, (*_246)[7]
	strh	r3, [fp, #-8]	@ movhi	@ tmp888, tmp_1
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _247, i
	lsl	r3, r3, #4	@ _248, _247,
	ldr	r2, [fp, #-20]	@ tmp889, output
	add	r3, r2, r3	@ _249, tmp889, _248
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	ldrsh	r3, [r3, #10]	@ _250, (*_249)[5]
	lsl	r3, r3, #16	@ tmp890, _250,
	lsr	r2, r3, #16	@ _251, tmp890,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	ldrh	r3, [fp, #-8]	@ tmp_1.6_252, tmp_1
	add	r3, r2, r3	@ tmp891, _251, tmp_1.6_252
	lsl	r3, r3, #16	@ tmp892, tmp891,
	lsr	r2, r3, #16	@ _253, tmp892,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _254, i
	lsl	r3, r3, #4	@ _255, _254,
	ldr	r1, [fp, #-20]	@ tmp893, output
	add	r3, r1, r3	@ _256, tmp893, _255
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	lsl	r2, r2, #16	@ tmp894, _253,
	asr	r2, r2, #16	@ _257, tmp894,
@ dct_loeffler.c:135: 		output[i][7] = tmp_1 + output[i][5];
	strh	r2, [r3, #14]	@ movhi	@ _257, (*_256)[7]
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	ldrh	r2, [fp, #-8]	@ tmp_1.7_258, tmp_1
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _259, i
	lsl	r3, r3, #4	@ _260, _259,
	ldr	r1, [fp, #-20]	@ tmp895, output
	add	r3, r1, r3	@ _261, tmp895, _260
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	ldrsh	r3, [r3, #10]	@ _262, (*_261)[5]
	lsl	r3, r3, #16	@ tmp896, _262,
	lsr	r3, r3, #16	@ _263, tmp896,
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	sub	r3, r2, r3	@ tmp897, tmp_1.7_258, _263
	lsl	r3, r3, #16	@ tmp898, tmp897,
	lsr	r2, r3, #16	@ _264, tmp898,
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _265, i
	lsl	r3, r3, #4	@ _266, _265,
	ldr	r1, [fp, #-20]	@ tmp899, output
	add	r3, r1, r3	@ _267, tmp899, _266
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	lsl	r2, r2, #16	@ tmp900, _264,
	asr	r2, r2, #16	@ _268, tmp900,
@ dct_loeffler.c:136: 		output[i][5] = tmp_1 - output[i][5];
	strh	r2, [r3, #10]	@ movhi	@ _268, (*_267)[5]
@ dct_loeffler.c:138: 		tmp_1 = output[i][1];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _269, i
	lsl	r3, r3, #4	@ _270, _269,
	ldr	r2, [fp, #-20]	@ tmp901, output
	add	r3, r2, r3	@ _271, tmp901, _270
@ dct_loeffler.c:138: 		tmp_1 = output[i][1];
	ldrh	r3, [r3, #2]	@ movhi	@ tmp902, (*_271)[1]
	strh	r3, [fp, #-8]	@ movhi	@ tmp902, tmp_1
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _272, i
	lsl	r3, r3, #4	@ _273, _272,
	ldr	r2, [fp, #-20]	@ tmp903, output
	add	r3, r2, r3	@ _274, tmp903, _273
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	ldrsh	r3, [r3, #6]	@ _275, (*_274)[3]
	lsl	r3, r3, #16	@ tmp904, _275,
	lsr	r2, r3, #16	@ _276, tmp904,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	ldrh	r3, [fp, #-8]	@ tmp_1.8_277, tmp_1
	add	r3, r2, r3	@ tmp905, _276, tmp_1.8_277
	lsl	r3, r3, #16	@ tmp906, tmp905,
	lsr	r2, r3, #16	@ _278, tmp906,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _279, i
	lsl	r3, r3, #4	@ _280, _279,
	ldr	r1, [fp, #-20]	@ tmp907, output
	add	r3, r1, r3	@ _281, tmp907, _280
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	lsl	r2, r2, #16	@ tmp908, _278,
	asr	r2, r2, #16	@ _282, tmp908,
@ dct_loeffler.c:139: 		output[i][1] = tmp_1 + output[i][3];
	strh	r2, [r3, #2]	@ movhi	@ _282, (*_281)[1]
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	ldrh	r2, [fp, #-8]	@ tmp_1.9_283, tmp_1
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _284, i
	lsl	r3, r3, #4	@ _285, _284,
	ldr	r1, [fp, #-20]	@ tmp909, output
	add	r3, r1, r3	@ _286, tmp909, _285
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	ldrsh	r3, [r3, #6]	@ _287, (*_286)[3]
	lsl	r3, r3, #16	@ tmp910, _287,
	lsr	r3, r3, #16	@ _288, tmp910,
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	sub	r3, r2, r3	@ tmp911, tmp_1.9_283, _288
	lsl	r3, r3, #16	@ tmp912, tmp911,
	lsr	r2, r3, #16	@ _289, tmp912,
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _290, i
	lsl	r3, r3, #4	@ _291, _290,
	ldr	r1, [fp, #-20]	@ tmp913, output
	add	r3, r1, r3	@ _292, tmp913, _291
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	lsl	r2, r2, #16	@ tmp914, _289,
	asr	r2, r2, #16	@ _293, tmp914,
@ dct_loeffler.c:140: 		output[i][3] = tmp_1 - output[i][3];
	strh	r2, [r3, #6]	@ movhi	@ _293, (*_292)[3]
@ dct_loeffler.c:150: 		tmp_1 = output[i][1];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _294, i
	lsl	r3, r3, #4	@ _295, _294,
	ldr	r2, [fp, #-20]	@ tmp915, output
	add	r3, r2, r3	@ _296, tmp915, _295
@ dct_loeffler.c:150: 		tmp_1 = output[i][1];
	ldrh	r3, [r3, #2]	@ movhi	@ tmp916, (*_296)[1]
	strh	r3, [fp, #-8]	@ movhi	@ tmp916, tmp_1
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _297, i
	lsl	r3, r3, #4	@ _298, _297,
	ldr	r2, [fp, #-20]	@ tmp917, output
	add	r3, r2, r3	@ _299, tmp917, _298
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	ldrsh	r3, [r3, #14]	@ _300, (*_299)[7]
	lsl	r3, r3, #16	@ tmp918, _300,
	lsr	r2, r3, #16	@ _301, tmp918,
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	ldrh	r3, [fp, #-8]	@ tmp_1.10_302, tmp_1
	add	r3, r2, r3	@ tmp919, _301, tmp_1.10_302
	lsl	r3, r3, #16	@ tmp920, tmp919,
	lsr	r2, r3, #16	@ _303, tmp920,
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _304, i
	lsl	r3, r3, #4	@ _305, _304,
	ldr	r1, [fp, #-20]	@ tmp921, output
	add	r3, r1, r3	@ _306, tmp921, _305
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	lsl	r2, r2, #16	@ tmp922, _303,
	asr	r2, r2, #16	@ _307, tmp922,
@ dct_loeffler.c:151: 		output[i][1] = tmp_1 + output[i][7];
	strh	r2, [r3, #2]	@ movhi	@ _307, (*_306)[1]
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	ldrh	r2, [fp, #-8]	@ tmp_1.11_308, tmp_1
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _309, i
	lsl	r3, r3, #4	@ _310, _309,
	ldr	r1, [fp, #-20]	@ tmp923, output
	add	r3, r1, r3	@ _311, tmp923, _310
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	ldrsh	r3, [r3, #14]	@ _312, (*_311)[7]
	lsl	r3, r3, #16	@ tmp924, _312,
	lsr	r3, r3, #16	@ _313, tmp924,
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	sub	r3, r2, r3	@ tmp925, tmp_1.11_308, _313
	lsl	r3, r3, #16	@ tmp926, tmp925,
	lsr	r2, r3, #16	@ _314, tmp926,
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _315, i
	lsl	r3, r3, #4	@ _316, _315,
	ldr	r1, [fp, #-20]	@ tmp927, output
	add	r3, r1, r3	@ _317, tmp927, _316
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	lsl	r2, r2, #16	@ tmp928, _314,
	asr	r2, r2, #16	@ _318, tmp928,
@ dct_loeffler.c:152: 		output[i][7] = tmp_1 - output[i][7];
	strh	r2, [r3, #14]	@ movhi	@ _318, (*_317)[7]
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _319, i
	lsl	r3, r3, #4	@ _320, _319,
	ldr	r2, [fp, #-20]	@ tmp929, output
	add	r3, r2, r3	@ _321, tmp929, _320
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrsh	r3, [r3, #6]	@ _322, (*_321)[3]
	mov	r1, r3	@ _323, _322
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	mov	r2, r1	@ tmp930, _323
	lsl	r2, r2, #1	@ tmp930, tmp930,
	add	r2, r2, r1	@ tmp930, tmp930, _323
	lsl	r3, r2, #4	@ tmp931, tmp930,
	sub	r3, r3, r2	@ tmp931, tmp931, tmp930
	lsl	r3, r3, #2	@ tmp931, tmp931,
	add	r3, r3, r1	@ tmp931, tmp931, _323
	lsl	r3, r3, #3	@ tmp932, tmp931,
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _325, _324,
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r2, r3, #10	@ _326, _325,
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _327, i
	lsl	r3, r3, #4	@ _328, _327,
	ldr	r1, [fp, #-20]	@ tmp933, output
	add	r3, r1, r3	@ _329, tmp933, _328
@ dct_loeffler.c:155: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	lsl	r2, r2, #16	@ tmp934, _326,
	asr	r2, r2, #16	@ _330, tmp934,
	strh	r2, [r3, #6]	@ movhi	@ _330, (*_329)[3]
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _331, i
	lsl	r3, r3, #4	@ _332, _331,
	ldr	r2, [fp, #-20]	@ tmp935, output
	add	r3, r2, r3	@ _333, tmp935, _332
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrsh	r3, [r3, #10]	@ _334, (*_333)[5]
	mov	r1, r3	@ _335, _334
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	mov	r2, r1	@ tmp936, _335
	lsl	r2, r2, #1	@ tmp936, tmp936,
	add	r2, r2, r1	@ tmp936, tmp936, _335
	lsl	r3, r2, #4	@ tmp937, tmp936,
	sub	r3, r3, r2	@ tmp937, tmp937, tmp936
	lsl	r3, r3, #2	@ tmp937, tmp937,
	add	r3, r3, r1	@ tmp937, tmp937, _335
	lsl	r3, r3, #3	@ tmp938, tmp937,
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _337, _336,
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r2, r3, #10	@ _338, _337,
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _339, i
	lsl	r3, r3, #4	@ _340, _339,
	ldr	r1, [fp, #-20]	@ tmp939, output
	add	r3, r1, r3	@ _341, tmp939, _340
@ dct_loeffler.c:156: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	lsl	r2, r2, #16	@ tmp940, _338,
	asr	r2, r2, #16	@ _342, tmp940,
	strh	r2, [r3, #10]	@ movhi	@ _342, (*_341)[5]
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ i.12_343, i
	add	r3, r3, #1	@ tmp941, i.12_343,
	strb	r3, [fp, #-5]	@ tmp942, i
.L5:
@ dct_loeffler.c:91: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ tmp945, i
	cmp	r3, #7	@ tmp945,
	bls	.L6		@,
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	mov	r3, #0	@ tmp946,
	strb	r3, [fp, #-5]	@ tmp947, i
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	b	.L7		@
.L8:
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldr	r3, [fp, #-20]	@ tmp948, output
	add	r2, r3, #16	@ _344, tmp948,
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _345, i
	lsl	r3, r3, #1	@ tmp949, _345,
	add	r3, r2, r3	@ tmp950, _344, tmp949
	ldrsh	r3, [r3]	@ _346, (*_344)[_345]
	lsl	r3, r3, #16	@ tmp951, _346,
	lsr	r2, r3, #16	@ _347, tmp951,
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldr	r3, [fp, #-20]	@ tmp952, output
	add	r1, r3, #96	@ _348, tmp952,
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _349, i
	lsl	r3, r3, #1	@ tmp953, _349,
	add	r3, r1, r3	@ tmp954, _348, tmp953
	ldrsh	r3, [r3]	@ _350, (*_348)[_349]
	lsl	r3, r3, #16	@ tmp955, _350,
	lsr	r3, r3, #16	@ _351, tmp955,
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	add	r3, r2, r3	@ tmp956, _347, _351
	lsl	r3, r3, #16	@ tmp957, tmp956,
	lsr	r3, r3, #16	@ _352, tmp957,
@ dct_loeffler.c:164: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	strh	r3, [fp, #-8]	@ movhi	@ _352, tmp_1
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	ldr	r3, [fp, #-20]	@ tmp958, output
	add	r2, r3, #16	@ _353, tmp958,
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _354, i
	lsl	r3, r3, #1	@ tmp959, _354,
	add	r3, r2, r3	@ tmp960, _353, tmp959
	ldrsh	r3, [r3]	@ _355, (*_353)[_354]
	lsl	r3, r3, #16	@ tmp961, _355,
	lsr	r2, r3, #16	@ _356, tmp961,
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	ldr	r3, [fp, #-20]	@ tmp962, output
	add	r1, r3, #96	@ _357, tmp962,
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _358, i
	lsl	r3, r3, #1	@ tmp963, _358,
	add	r3, r1, r3	@ tmp964, _357, tmp963
	ldrsh	r3, [r3]	@ _359, (*_357)[_358]
	lsl	r3, r3, #16	@ tmp965, _359,
	lsr	r3, r3, #16	@ _360, tmp965,
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	sub	r3, r2, r3	@ tmp966, _356, _360
	lsl	r3, r3, #16	@ tmp967, tmp966,
	lsr	r3, r3, #16	@ _361, tmp967,
@ dct_loeffler.c:165: 		tmp_2 = output[1][i] - output[6][i];
	strh	r3, [fp, #-10]	@ movhi	@ _361, tmp_2
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _362, i
	ldr	r2, [fp, #-20]	@ tmp968, output
	lsl	r3, r3, #1	@ tmp969, _362,
	add	r3, r2, r3	@ tmp970, tmp968, tmp969
	ldrsh	r3, [r3]	@ _363, (*output_659(D))[_362]
	lsl	r3, r3, #16	@ tmp971, _363,
	lsr	r2, r3, #16	@ _364, tmp971,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldr	r3, [fp, #-20]	@ tmp972, output
	add	r1, r3, #112	@ _365, tmp972,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _366, i
	lsl	r3, r3, #1	@ tmp973, _366,
	add	r3, r1, r3	@ tmp974, _365, tmp973
	ldrsh	r3, [r3]	@ _367, (*_365)[_366]
	lsl	r3, r3, #16	@ tmp975, _367,
	lsr	r3, r3, #16	@ _368, tmp975,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	sub	r3, r2, r3	@ tmp976, _364, _368
	lsl	r3, r3, #16	@ tmp977, tmp976,
	lsr	r2, r3, #16	@ _369, tmp977,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldr	r3, [fp, #-20]	@ tmp978, output
	add	r1, r3, #16	@ _370, tmp978,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _371, i
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	lsl	r2, r2, #16	@ tmp979, _369,
	asr	r2, r2, #16	@ _372, tmp979,
@ dct_loeffler.c:167: 		output[1][i] = output[0][i] - output[7][i];
	lsl	r3, r3, #1	@ tmp980, _371,
	add	r3, r1, r3	@ tmp981, _370, tmp980
	strh	r2, [r3]	@ movhi	@ _372, (*_370)[_371]
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _373, i
	ldr	r2, [fp, #-20]	@ tmp982, output
	lsl	r3, r3, #1	@ tmp983, _373,
	add	r3, r2, r3	@ tmp984, tmp982, tmp983
	ldrsh	r3, [r3]	@ _374, (*output_659(D))[_373]
	lsl	r3, r3, #16	@ tmp985, _374,
	lsr	r2, r3, #16	@ _375, tmp985,
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	ldr	r3, [fp, #-20]	@ tmp986, output
	add	r1, r3, #112	@ _376, tmp986,
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _377, i
	lsl	r3, r3, #1	@ tmp987, _377,
	add	r3, r1, r3	@ tmp988, _376, tmp987
	ldrsh	r3, [r3]	@ _378, (*_376)[_377]
	lsl	r3, r3, #16	@ tmp989, _378,
	lsr	r3, r3, #16	@ _379, tmp989,
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	add	r3, r2, r3	@ tmp990, _375, _379
	lsl	r3, r3, #16	@ tmp991, tmp990,
	lsr	r2, r3, #16	@ _380, tmp991,
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _381, i
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	lsl	r2, r2, #16	@ tmp992, _380,
	asr	r2, r2, #16	@ _382, tmp992,
@ dct_loeffler.c:168: 		output[0][i] = output[0][i] + output[7][i];
	ldr	r1, [fp, #-20]	@ tmp993, output
	lsl	r3, r3, #1	@ tmp994, _381,
	add	r3, r1, r3	@ tmp995, tmp993, tmp994
	strh	r2, [r3]	@ movhi	@ _382, (*output_659(D))[_381]
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldr	r3, [fp, #-20]	@ tmp996, output
	add	r2, r3, #48	@ _383, tmp996,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _384, i
	lsl	r3, r3, #1	@ tmp997, _384,
	add	r3, r2, r3	@ tmp998, _383, tmp997
	ldrsh	r3, [r3]	@ _385, (*_383)[_384]
	lsl	r3, r3, #16	@ tmp999, _385,
	lsr	r2, r3, #16	@ _386, tmp999,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1000, output
	add	r1, r3, #64	@ _387, tmp1000,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _388, i
	lsl	r3, r3, #1	@ tmp1001, _388,
	add	r3, r1, r3	@ tmp1002, _387, tmp1001
	ldrsh	r3, [r3]	@ _389, (*_387)[_388]
	lsl	r3, r3, #16	@ tmp1003, _389,
	lsr	r3, r3, #16	@ _390, tmp1003,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	add	r3, r2, r3	@ tmp1004, _386, _390
	lsl	r3, r3, #16	@ tmp1005, tmp1004,
	lsr	r2, r3, #16	@ _391, tmp1005,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1006, output
	add	r1, r3, #96	@ _392, tmp1006,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _393, i
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	lsl	r2, r2, #16	@ tmp1007, _391,
	asr	r2, r2, #16	@ _394, tmp1007,
@ dct_loeffler.c:171: 		output[6][i] = output[3][i] + output[4][i];
	lsl	r3, r3, #1	@ tmp1008, _393,
	add	r3, r1, r3	@ tmp1009, _392, tmp1008
	strh	r2, [r3]	@ movhi	@ _394, (*_392)[_393]
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1010, output
	add	r2, r3, #48	@ _395, tmp1010,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _396, i
	lsl	r3, r3, #1	@ tmp1011, _396,
	add	r3, r2, r3	@ tmp1012, _395, tmp1011
	ldrsh	r3, [r3]	@ _397, (*_395)[_396]
	lsl	r3, r3, #16	@ tmp1013, _397,
	lsr	r2, r3, #16	@ _398, tmp1013,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1014, output
	add	r1, r3, #64	@ _399, tmp1014,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _400, i
	lsl	r3, r3, #1	@ tmp1015, _400,
	add	r3, r1, r3	@ tmp1016, _399, tmp1015
	ldrsh	r3, [r3]	@ _401, (*_399)[_400]
	lsl	r3, r3, #16	@ tmp1017, _401,
	lsr	r3, r3, #16	@ _402, tmp1017,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	sub	r3, r2, r3	@ tmp1018, _398, _402
	lsl	r3, r3, #16	@ tmp1019, tmp1018,
	lsr	r2, r3, #16	@ _403, tmp1019,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1020, output
	add	r1, r3, #112	@ _404, tmp1020,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _405, i
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	lsl	r2, r2, #16	@ tmp1021, _403,
	asr	r2, r2, #16	@ _406, tmp1021,
@ dct_loeffler.c:172: 		output[7][i] = output[3][i] - output[4][i];
	lsl	r3, r3, #1	@ tmp1022, _405,
	add	r3, r1, r3	@ tmp1023, _404, tmp1022
	strh	r2, [r3]	@ movhi	@ _406, (*_404)[_405]
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1024, output
	add	r2, r3, #32	@ _407, tmp1024,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _408, i
	lsl	r3, r3, #1	@ tmp1025, _408,
	add	r3, r2, r3	@ tmp1026, _407, tmp1025
	ldrsh	r3, [r3]	@ _409, (*_407)[_408]
	lsl	r3, r3, #16	@ tmp1027, _409,
	lsr	r2, r3, #16	@ _410, tmp1027,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1028, output
	add	r1, r3, #80	@ _411, tmp1028,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _412, i
	lsl	r3, r3, #1	@ tmp1029, _412,
	add	r3, r1, r3	@ tmp1030, _411, tmp1029
	ldrsh	r3, [r3]	@ _413, (*_411)[_412]
	lsl	r3, r3, #16	@ tmp1031, _413,
	lsr	r3, r3, #16	@ _414, tmp1031,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	sub	r3, r2, r3	@ tmp1032, _410, _414
	lsl	r3, r3, #16	@ tmp1033, tmp1032,
	lsr	r2, r3, #16	@ _415, tmp1033,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1034, output
	add	r1, r3, #48	@ _416, tmp1034,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _417, i
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	lsl	r2, r2, #16	@ tmp1035, _415,
	asr	r2, r2, #16	@ _418, tmp1035,
@ dct_loeffler.c:174: 		output[3][i] = output[2][i] - output[5][i];
	lsl	r3, r3, #1	@ tmp1036, _417,
	add	r3, r1, r3	@ tmp1037, _416, tmp1036
	strh	r2, [r3]	@ movhi	@ _418, (*_416)[_417]
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1038, output
	add	r2, r3, #32	@ _419, tmp1038,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _420, i
	lsl	r3, r3, #1	@ tmp1039, _420,
	add	r3, r2, r3	@ tmp1040, _419, tmp1039
	ldrsh	r3, [r3]	@ _421, (*_419)[_420]
	lsl	r3, r3, #16	@ tmp1041, _421,
	lsr	r2, r3, #16	@ _422, tmp1041,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1042, output
	add	r1, r3, #80	@ _423, tmp1042,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _424, i
	lsl	r3, r3, #1	@ tmp1043, _424,
	add	r3, r1, r3	@ tmp1044, _423, tmp1043
	ldrsh	r3, [r3]	@ _425, (*_423)[_424]
	lsl	r3, r3, #16	@ tmp1045, _425,
	lsr	r3, r3, #16	@ _426, tmp1045,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	add	r3, r2, r3	@ tmp1046, _422, _426
	lsl	r3, r3, #16	@ tmp1047, tmp1046,
	lsr	r2, r3, #16	@ _427, tmp1047,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1048, output
	add	r1, r3, #32	@ _428, tmp1048,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _429, i
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	lsl	r2, r2, #16	@ tmp1049, _427,
	asr	r2, r2, #16	@ _430, tmp1049,
@ dct_loeffler.c:175: 		output[2][i] = output[2][i] + output[5][i];
	lsl	r3, r3, #1	@ tmp1050, _429,
	add	r3, r1, r3	@ tmp1051, _428, tmp1050
	strh	r2, [r3]	@ movhi	@ _430, (*_428)[_429]
@ dct_loeffler.c:177: 		output[4][i] = tmp_1;
	ldr	r3, [fp, #-20]	@ tmp1052, output
	add	r2, r3, #64	@ _431, tmp1052,
@ dct_loeffler.c:177: 		output[4][i] = tmp_1;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _432, i
@ dct_loeffler.c:177: 		output[4][i] = tmp_1;
	lsl	r3, r3, #1	@ tmp1053, _432,
	add	r3, r2, r3	@ tmp1054, _431, tmp1053
	ldrh	r2, [fp, #-8]	@ movhi	@ tmp1055, tmp_1
	strh	r2, [r3]	@ movhi	@ tmp1055, (*_431)[_432]
@ dct_loeffler.c:178: 		output[5][i] = tmp_2;
	ldr	r3, [fp, #-20]	@ tmp1056, output
	add	r2, r3, #80	@ _433, tmp1056,
@ dct_loeffler.c:178: 		output[5][i] = tmp_2;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _434, i
@ dct_loeffler.c:178: 		output[5][i] = tmp_2;
	lsl	r3, r3, #1	@ tmp1057, _434,
	add	r3, r2, r3	@ tmp1058, _433, tmp1057
	ldrh	r2, [fp, #-10]	@ movhi	@ tmp1059, tmp_2
	strh	r2, [r3]	@ movhi	@ tmp1059, (*_433)[_434]
@ dct_loeffler.c:182: 		tmp_1 = output[0][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _435, i
@ dct_loeffler.c:182: 		tmp_1 = output[0][i];
	ldr	r2, [fp, #-20]	@ tmp1060, output
	lsl	r3, r3, #1	@ tmp1061, _435,
	add	r3, r2, r3	@ tmp1062, tmp1060, tmp1061
	ldrh	r3, [r3]	@ movhi	@ tmp1063, (*output_659(D))[_435]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1063, tmp_1
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	ldr	r3, [fp, #-20]	@ tmp1064, output
	add	r2, r3, #96	@ _436, tmp1064,
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _437, i
	lsl	r3, r3, #1	@ tmp1065, _437,
	add	r3, r2, r3	@ tmp1066, _436, tmp1065
	ldrsh	r3, [r3]	@ _438, (*_436)[_437]
	lsl	r3, r3, #16	@ tmp1067, _438,
	lsr	r2, r3, #16	@ _439, tmp1067,
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.13_440, tmp_1
	add	r3, r2, r3	@ tmp1068, _439, tmp_1.13_440
	lsl	r3, r3, #16	@ tmp1069, tmp1068,
	lsr	r2, r3, #16	@ _441, tmp1069,
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _442, i
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	lsl	r2, r2, #16	@ tmp1070, _441,
	asr	r2, r2, #16	@ _443, tmp1070,
@ dct_loeffler.c:183: 		output[0][i] = tmp_1 + output[6][i];
	ldr	r1, [fp, #-20]	@ tmp1071, output
	lsl	r3, r3, #1	@ tmp1072, _442,
	add	r3, r1, r3	@ tmp1073, tmp1071, tmp1072
	strh	r2, [r3]	@ movhi	@ _443, (*output_659(D))[_442]
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.14_444, tmp_1
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	ldr	r3, [fp, #-20]	@ tmp1074, output
	add	r1, r3, #96	@ _445, tmp1074,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _446, i
	lsl	r3, r3, #1	@ tmp1075, _446,
	add	r3, r1, r3	@ tmp1076, _445, tmp1075
	ldrsh	r3, [r3]	@ _447, (*_445)[_446]
	lsl	r3, r3, #16	@ tmp1077, _447,
	lsr	r3, r3, #16	@ _448, tmp1077,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	sub	r3, r2, r3	@ tmp1078, tmp_1.14_444, _448
	lsl	r3, r3, #16	@ tmp1079, tmp1078,
	lsr	r2, r3, #16	@ _449, tmp1079,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	ldr	r3, [fp, #-20]	@ tmp1080, output
	add	r1, r3, #96	@ _450, tmp1080,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _451, i
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	lsl	r2, r2, #16	@ tmp1081, _449,
	asr	r2, r2, #16	@ _452, tmp1081,
@ dct_loeffler.c:184: 		output[6][i] = tmp_1 - output[6][i];
	lsl	r3, r3, #1	@ tmp1082, _451,
	add	r3, r1, r3	@ tmp1083, _450, tmp1082
	strh	r2, [r3]	@ movhi	@ _452, (*_450)[_451]
@ dct_loeffler.c:186: 		tmp_1 = output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1084, output
	add	r2, r3, #64	@ _453, tmp1084,
@ dct_loeffler.c:186: 		tmp_1 = output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _454, i
@ dct_loeffler.c:186: 		tmp_1 = output[4][i];
	lsl	r3, r3, #1	@ tmp1085, _454,
	add	r3, r2, r3	@ tmp1086, _453, tmp1085
	ldrh	r3, [r3]	@ movhi	@ tmp1087, (*_453)[_454]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1087, tmp_1
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	ldr	r3, [fp, #-20]	@ tmp1088, output
	add	r2, r3, #32	@ _455, tmp1088,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _456, i
	lsl	r3, r3, #1	@ tmp1089, _456,
	add	r3, r2, r3	@ tmp1090, _455, tmp1089
	ldrsh	r3, [r3]	@ _457, (*_455)[_456]
	lsl	r3, r3, #16	@ tmp1091, _457,
	lsr	r2, r3, #16	@ _458, tmp1091,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.15_459, tmp_1
	add	r3, r2, r3	@ tmp1092, _458, tmp_1.15_459
	lsl	r3, r3, #16	@ tmp1093, tmp1092,
	lsr	r2, r3, #16	@ _460, tmp1093,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	ldr	r3, [fp, #-20]	@ tmp1094, output
	add	r1, r3, #64	@ _461, tmp1094,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _462, i
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	lsl	r2, r2, #16	@ tmp1095, _460,
	asr	r2, r2, #16	@ _463, tmp1095,
@ dct_loeffler.c:187: 		output[4][i] = tmp_1 + output[2][i];
	lsl	r3, r3, #1	@ tmp1096, _462,
	add	r3, r1, r3	@ tmp1097, _461, tmp1096
	strh	r2, [r3]	@ movhi	@ _463, (*_461)[_462]
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.16_464, tmp_1
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	ldr	r3, [fp, #-20]	@ tmp1098, output
	add	r1, r3, #32	@ _465, tmp1098,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _466, i
	lsl	r3, r3, #1	@ tmp1099, _466,
	add	r3, r1, r3	@ tmp1100, _465, tmp1099
	ldrsh	r3, [r3]	@ _467, (*_465)[_466]
	lsl	r3, r3, #16	@ tmp1101, _467,
	lsr	r3, r3, #16	@ _468, tmp1101,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	sub	r3, r2, r3	@ tmp1102, tmp_1.16_464, _468
	lsl	r3, r3, #16	@ tmp1103, tmp1102,
	lsr	r2, r3, #16	@ _469, tmp1103,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	ldr	r3, [fp, #-20]	@ tmp1104, output
	add	r1, r3, #32	@ _470, tmp1104,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _471, i
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	lsl	r2, r2, #16	@ tmp1105, _469,
	asr	r2, r2, #16	@ _472, tmp1105,
@ dct_loeffler.c:188: 		output[2][i] = tmp_1 - output[2][i];
	lsl	r3, r3, #1	@ tmp1106, _471,
	add	r3, r1, r3	@ tmp1107, _470, tmp1106
	strh	r2, [r3]	@ movhi	@ _472, (*_470)[_471]
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldr	r3, [fp, #-20]	@ tmp1108, output
	add	r2, r3, #112	@ _473, tmp1108,
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _474, i
	lsl	r3, r3, #1	@ tmp1109, _474,
	add	r3, r2, r3	@ tmp1110, _473, tmp1109
	ldrsh	r0, [r3]	@ _475, (*_473)[_474]
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldr	r3, [fp, #-20]	@ tmp1111, output
	add	r2, r3, #16	@ _476, tmp1111,
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _477, i
	lsl	r3, r3, #1	@ tmp1112, _477,
	add	r3, r2, r3	@ tmp1113, _476, tmp1112
	ldrsh	r1, [r3]	@ _478, (*_476)[_477]
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldr	r3, [fp, #-20]	@ tmp1114, output
	add	r2, r3, #112	@ _479, tmp1114,
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _480, i
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	lsl	r3, r3, #1	@ tmp1115, _480,
	add	ip, r2, r3	@ _481, _479, tmp1115
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldr	r3, [fp, #-20]	@ tmp1116, output
	add	r2, r3, #16	@ _482, tmp1116,
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _483, i
@ dct_loeffler.c:192: butterfly_fp(output[7][i], output[1][i], &output[7][i], &output[1][i], 3);		// Call butterfly function C3
	lsl	r3, r3, #1	@ tmp1117, _483,
	add	r3, r2, r3	@ _484, _482, tmp1117
	mov	r2, #3	@ tmp1118,
	str	r2, [sp]	@ tmp1118,
	mov	r2, ip	@, _481
	bl	butterfly_fp(PLT)	@
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldr	r3, [fp, #-20]	@ tmp1119, output
	add	r2, r3, #48	@ _485, tmp1119,
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _486, i
	lsl	r3, r3, #1	@ tmp1120, _486,
	add	r3, r2, r3	@ tmp1121, _485, tmp1120
	ldrsh	r0, [r3]	@ _487, (*_485)[_486]
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldr	r3, [fp, #-20]	@ tmp1122, output
	add	r2, r3, #80	@ _488, tmp1122,
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _489, i
	lsl	r3, r3, #1	@ tmp1123, _489,
	add	r3, r2, r3	@ tmp1124, _488, tmp1123
	ldrsh	r1, [r3]	@ _490, (*_488)[_489]
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldr	r3, [fp, #-20]	@ tmp1125, output
	add	r2, r3, #48	@ _491, tmp1125,
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _492, i
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	lsl	r3, r3, #1	@ tmp1126, _492,
	add	ip, r2, r3	@ _493, _491, tmp1126
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldr	r3, [fp, #-20]	@ tmp1127, output
	add	r2, r3, #80	@ _494, tmp1127,
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _495, i
@ dct_loeffler.c:193: 		butterfly_fp(output[3][i], output[5][i], &output[3][i], &output[5][i], 1);		// Call butterfly function C1
	lsl	r3, r3, #1	@ tmp1128, _495,
	add	r3, r2, r3	@ _496, _494, tmp1128
	mov	r2, #1	@ tmp1129,
	str	r2, [sp]	@ tmp1129,
	mov	r2, ip	@, _493
	bl	butterfly_fp(PLT)	@
@ dct_loeffler.c:197: 		tmp_1 = output[0][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _497, i
@ dct_loeffler.c:197: 		tmp_1 = output[0][i];
	ldr	r2, [fp, #-20]	@ tmp1130, output
	lsl	r3, r3, #1	@ tmp1131, _497,
	add	r3, r2, r3	@ tmp1132, tmp1130, tmp1131
	ldrh	r3, [r3]	@ movhi	@ tmp1133, (*output_659(D))[_497]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1133, tmp_1
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1134, output
	add	r2, r3, #64	@ _498, tmp1134,
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _499, i
	lsl	r3, r3, #1	@ tmp1135, _499,
	add	r3, r2, r3	@ tmp1136, _498, tmp1135
	ldrsh	r3, [r3]	@ _500, (*_498)[_499]
	lsl	r3, r3, #16	@ tmp1137, _500,
	lsr	r2, r3, #16	@ _501, tmp1137,
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.17_502, tmp_1
	add	r3, r2, r3	@ tmp1138, _501, tmp_1.17_502
	lsl	r3, r3, #16	@ tmp1139, tmp1138,
	lsr	r2, r3, #16	@ _503, tmp1139,
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _504, i
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	lsl	r2, r2, #16	@ tmp1140, _503,
	asr	r2, r2, #16	@ _505, tmp1140,
@ dct_loeffler.c:198: 		output[0][i] = tmp_1 + output[4][i];
	ldr	r1, [fp, #-20]	@ tmp1141, output
	lsl	r3, r3, #1	@ tmp1142, _504,
	add	r3, r1, r3	@ tmp1143, tmp1141, tmp1142
	strh	r2, [r3]	@ movhi	@ _505, (*output_659(D))[_504]
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.18_506, tmp_1
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1144, output
	add	r1, r3, #64	@ _507, tmp1144,
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _508, i
	lsl	r3, r3, #1	@ tmp1145, _508,
	add	r3, r1, r3	@ tmp1146, _507, tmp1145
	ldrsh	r3, [r3]	@ _509, (*_507)[_508]
	lsl	r3, r3, #16	@ tmp1147, _509,
	lsr	r3, r3, #16	@ _510, tmp1147,
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	sub	r3, r2, r3	@ tmp1148, tmp_1.18_506, _510
	lsl	r3, r3, #16	@ tmp1149, tmp1148,
	lsr	r2, r3, #16	@ _511, tmp1149,
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	ldr	r3, [fp, #-20]	@ tmp1150, output
	add	r1, r3, #64	@ _512, tmp1150,
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _513, i
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	lsl	r2, r2, #16	@ tmp1151, _511,
	asr	r2, r2, #16	@ _514, tmp1151,
@ dct_loeffler.c:199: 		output[4][i] = tmp_1 - output[4][i];
	lsl	r3, r3, #1	@ tmp1152, _513,
	add	r3, r1, r3	@ tmp1153, _512, tmp1152
	strh	r2, [r3]	@ movhi	@ _514, (*_512)[_513]
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldr	r3, [fp, #-20]	@ tmp1154, output
	add	r2, r3, #32	@ _515, tmp1154,
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _516, i
	lsl	r3, r3, #1	@ tmp1155, _516,
	add	r3, r2, r3	@ tmp1156, _515, tmp1155
	ldrsh	r0, [r3]	@ _517, (*_515)[_516]
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldr	r3, [fp, #-20]	@ tmp1157, output
	add	r2, r3, #96	@ _518, tmp1157,
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _519, i
	lsl	r3, r3, #1	@ tmp1158, _519,
	add	r3, r2, r3	@ tmp1159, _518, tmp1158
	ldrsh	r1, [r3]	@ _520, (*_518)[_519]
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldr	r3, [fp, #-20]	@ tmp1160, output
	add	r2, r3, #32	@ _521, tmp1160,
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _522, i
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	lsl	r3, r3, #1	@ tmp1161, _522,
	add	ip, r2, r3	@ _523, _521, tmp1161
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldr	r3, [fp, #-20]	@ tmp1162, output
	add	r2, r3, #96	@ _524, tmp1162,
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _525, i
@ dct_loeffler.c:201: 		butterfly_fp(output[2][i], output[6][i], &output[2][i], &output[6][i], 2);		// Call butterfly function sqrt(2) * C6
	lsl	r3, r3, #1	@ tmp1163, _525,
	add	r3, r2, r3	@ _526, _524, tmp1163
	mov	r2, #2	@ tmp1164,
	str	r2, [sp]	@ tmp1164,
	mov	r2, ip	@, _523
	bl	butterfly_fp(PLT)	@
@ dct_loeffler.c:204: 		tmp_1 = output[7][i];
	ldr	r3, [fp, #-20]	@ tmp1165, output
	add	r2, r3, #112	@ _527, tmp1165,
@ dct_loeffler.c:204: 		tmp_1 = output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _528, i
@ dct_loeffler.c:204: 		tmp_1 = output[7][i];
	lsl	r3, r3, #1	@ tmp1166, _528,
	add	r3, r2, r3	@ tmp1167, _527, tmp1166
	ldrh	r3, [r3]	@ movhi	@ tmp1168, (*_527)[_528]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1168, tmp_1
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1169, output
	add	r2, r3, #80	@ _529, tmp1169,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _530, i
	lsl	r3, r3, #1	@ tmp1170, _530,
	add	r3, r2, r3	@ tmp1171, _529, tmp1170
	ldrsh	r3, [r3]	@ _531, (*_529)[_530]
	lsl	r3, r3, #16	@ tmp1172, _531,
	lsr	r2, r3, #16	@ _532, tmp1172,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.19_533, tmp_1
	add	r3, r2, r3	@ tmp1173, _532, tmp_1.19_533
	lsl	r3, r3, #16	@ tmp1174, tmp1173,
	lsr	r2, r3, #16	@ _534, tmp1174,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1175, output
	add	r1, r3, #112	@ _535, tmp1175,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _536, i
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	lsl	r2, r2, #16	@ tmp1176, _534,
	asr	r2, r2, #16	@ _537, tmp1176,
@ dct_loeffler.c:205: 		output[7][i] = tmp_1 + output[5][i];
	lsl	r3, r3, #1	@ tmp1177, _536,
	add	r3, r1, r3	@ tmp1178, _535, tmp1177
	strh	r2, [r3]	@ movhi	@ _537, (*_535)[_536]
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.20_538, tmp_1
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1179, output
	add	r1, r3, #80	@ _539, tmp1179,
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _540, i
	lsl	r3, r3, #1	@ tmp1180, _540,
	add	r3, r1, r3	@ tmp1181, _539, tmp1180
	ldrsh	r3, [r3]	@ _541, (*_539)[_540]
	lsl	r3, r3, #16	@ tmp1182, _541,
	lsr	r3, r3, #16	@ _542, tmp1182,
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	sub	r3, r2, r3	@ tmp1183, tmp_1.20_538, _542
	lsl	r3, r3, #16	@ tmp1184, tmp1183,
	lsr	r2, r3, #16	@ _543, tmp1184,
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	ldr	r3, [fp, #-20]	@ tmp1185, output
	add	r1, r3, #80	@ _544, tmp1185,
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _545, i
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	lsl	r2, r2, #16	@ tmp1186, _543,
	asr	r2, r2, #16	@ _546, tmp1186,
@ dct_loeffler.c:206: 		output[5][i] = tmp_1 - output[5][i];
	lsl	r3, r3, #1	@ tmp1187, _545,
	add	r3, r1, r3	@ tmp1188, _544, tmp1187
	strh	r2, [r3]	@ movhi	@ _546, (*_544)[_545]
@ dct_loeffler.c:208: 		tmp_1 = output[1][i];
	ldr	r3, [fp, #-20]	@ tmp1189, output
	add	r2, r3, #16	@ _547, tmp1189,
@ dct_loeffler.c:208: 		tmp_1 = output[1][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _548, i
@ dct_loeffler.c:208: 		tmp_1 = output[1][i];
	lsl	r3, r3, #1	@ tmp1190, _548,
	add	r3, r2, r3	@ tmp1191, _547, tmp1190
	ldrh	r3, [r3]	@ movhi	@ tmp1192, (*_547)[_548]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1192, tmp_1
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	ldr	r3, [fp, #-20]	@ tmp1193, output
	add	r2, r3, #48	@ _549, tmp1193,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _550, i
	lsl	r3, r3, #1	@ tmp1194, _550,
	add	r3, r2, r3	@ tmp1195, _549, tmp1194
	ldrsh	r3, [r3]	@ _551, (*_549)[_550]
	lsl	r3, r3, #16	@ tmp1196, _551,
	lsr	r2, r3, #16	@ _552, tmp1196,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.21_553, tmp_1
	add	r3, r2, r3	@ tmp1197, _552, tmp_1.21_553
	lsl	r3, r3, #16	@ tmp1198, tmp1197,
	lsr	r2, r3, #16	@ _554, tmp1198,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	ldr	r3, [fp, #-20]	@ tmp1199, output
	add	r1, r3, #16	@ _555, tmp1199,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _556, i
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	lsl	r2, r2, #16	@ tmp1200, _554,
	asr	r2, r2, #16	@ _557, tmp1200,
@ dct_loeffler.c:210: 		output[1][i] = tmp_1 + output[3][i];
	lsl	r3, r3, #1	@ tmp1201, _556,
	add	r3, r1, r3	@ tmp1202, _555, tmp1201
	strh	r2, [r3]	@ movhi	@ _557, (*_555)[_556]
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.22_558, tmp_1
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	ldr	r3, [fp, #-20]	@ tmp1203, output
	add	r1, r3, #48	@ _559, tmp1203,
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _560, i
	lsl	r3, r3, #1	@ tmp1204, _560,
	add	r3, r1, r3	@ tmp1205, _559, tmp1204
	ldrsh	r3, [r3]	@ _561, (*_559)[_560]
	lsl	r3, r3, #16	@ tmp1206, _561,
	lsr	r3, r3, #16	@ _562, tmp1206,
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	sub	r3, r2, r3	@ tmp1207, tmp_1.22_558, _562
	lsl	r3, r3, #16	@ tmp1208, tmp1207,
	lsr	r2, r3, #16	@ _563, tmp1208,
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	ldr	r3, [fp, #-20]	@ tmp1209, output
	add	r1, r3, #48	@ _564, tmp1209,
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _565, i
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	lsl	r2, r2, #16	@ tmp1210, _563,
	asr	r2, r2, #16	@ _566, tmp1210,
@ dct_loeffler.c:211: 		output[3][i] = tmp_1 - output[3][i];
	lsl	r3, r3, #1	@ tmp1211, _565,
	add	r3, r1, r3	@ tmp1212, _564, tmp1211
	strh	r2, [r3]	@ movhi	@ _566, (*_564)[_565]
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _567, i
	ldr	r2, [fp, #-20]	@ tmp1213, output
	lsl	r3, r3, #1	@ tmp1214, _567,
	add	r3, r2, r3	@ tmp1215, tmp1213, tmp1214
	ldrsh	r3, [r3]	@ _568, (*output_659(D))[_567]
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _570, _569,
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _571, _570,
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _572, i
@ dct_loeffler.c:217: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1216, _571,
	asr	r2, r2, #16	@ _573, tmp1216,
	ldr	r1, [fp, #-20]	@ tmp1217, output
	lsl	r3, r3, #1	@ tmp1218, _572,
	add	r3, r1, r3	@ tmp1219, tmp1217, tmp1218
	strh	r2, [r3]	@ movhi	@ _573, (*output_659(D))[_572]
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1220, output
	add	r2, r3, #64	@ _574, tmp1220,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _575, i
	lsl	r3, r3, #1	@ tmp1221, _575,
	add	r3, r2, r3	@ tmp1222, _574, tmp1221
	ldrsh	r3, [r3]	@ _576, (*_574)[_575]
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _578, _577,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _579, _578,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1223, output
	add	r1, r3, #64	@ _580, tmp1223,
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _581, i
@ dct_loeffler.c:218: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1224, _579,
	asr	r2, r2, #16	@ _582, tmp1224,
	lsl	r3, r3, #1	@ tmp1225, _581,
	add	r3, r1, r3	@ tmp1226, _580, tmp1225
	strh	r2, [r3]	@ movhi	@ _582, (*_580)[_581]
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1227, output
	add	r2, r3, #32	@ _583, tmp1227,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _584, i
	lsl	r3, r3, #1	@ tmp1228, _584,
	add	r3, r2, r3	@ tmp1229, _583, tmp1228
	ldrsh	r3, [r3]	@ _585, (*_583)[_584]
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _587, _586,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _588, _587,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1230, output
	add	r1, r3, #32	@ _589, tmp1230,
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _590, i
@ dct_loeffler.c:219: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1231, _588,
	asr	r2, r2, #16	@ _591, tmp1231,
	lsl	r3, r3, #1	@ tmp1232, _590,
	add	r3, r1, r3	@ tmp1233, _589, tmp1232
	strh	r2, [r3]	@ movhi	@ _591, (*_589)[_590]
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1234, output
	add	r2, r3, #96	@ _592, tmp1234,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _593, i
	lsl	r3, r3, #1	@ tmp1235, _593,
	add	r3, r2, r3	@ tmp1236, _592, tmp1235
	ldrsh	r3, [r3]	@ _594, (*_592)[_593]
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _596, _595,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _597, _596,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1237, output
	add	r1, r3, #96	@ _598, tmp1237,
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _599, i
@ dct_loeffler.c:220: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1238, _597,
	asr	r2, r2, #16	@ _600, tmp1238,
	lsl	r3, r3, #1	@ tmp1239, _599,
	add	r3, r1, r3	@ tmp1240, _598, tmp1239
	strh	r2, [r3]	@ movhi	@ _600, (*_598)[_599]
@ dct_loeffler.c:224: 		tmp_1 = output[1][i];
	ldr	r3, [fp, #-20]	@ tmp1241, output
	add	r2, r3, #16	@ _601, tmp1241,
@ dct_loeffler.c:224: 		tmp_1 = output[1][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _602, i
@ dct_loeffler.c:224: 		tmp_1 = output[1][i];
	lsl	r3, r3, #1	@ tmp1242, _602,
	add	r3, r2, r3	@ tmp1243, _601, tmp1242
	ldrh	r3, [r3]	@ movhi	@ tmp1244, (*_601)[_602]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1244, tmp_1
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _603, tmp_1
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r2, [fp, #-20]	@ tmp1245, output
	add	r1, r2, #112	@ _604, tmp1245,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _605, i
	lsl	r2, r2, #1	@ tmp1246, _605,
	add	r2, r1, r2	@ tmp1247, _604, tmp1246
	ldrsh	r2, [r2]	@ _606, (*_604)[_605]
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, r2	@ _608, _603, _607
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _609, _608,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _610, _609,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1248, output
	add	r1, r3, #16	@ _611, tmp1248,
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _612, i
@ dct_loeffler.c:225: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1249, _610,
	asr	r2, r2, #16	@ _613, tmp1249,
	lsl	r3, r3, #1	@ tmp1250, _612,
	add	r3, r1, r3	@ tmp1251, _611, tmp1250
	strh	r2, [r3]	@ movhi	@ _613, (*_611)[_612]
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _614, tmp_1
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r2, [fp, #-20]	@ tmp1252, output
	add	r1, r2, #112	@ _615, tmp1252,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _616, i
	lsl	r2, r2, #1	@ tmp1253, _616,
	add	r2, r1, r2	@ tmp1254, _615, tmp1253
	ldrsh	r2, [r2]	@ _617, (*_615)[_616]
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	sub	r3, r3, r2	@ _619, _614, _618
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _620, _619,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _621, _620,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1255, output
	add	r1, r3, #112	@ _622, tmp1255,
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _623, i
@ dct_loeffler.c:226: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1256, _621,
	asr	r2, r2, #16	@ _624, tmp1256,
	lsl	r3, r3, #1	@ tmp1257, _623,
	add	r3, r1, r3	@ tmp1258, _622, tmp1257
	strh	r2, [r3]	@ movhi	@ _624, (*_622)[_623]
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldr	r3, [fp, #-20]	@ tmp1259, output
	add	r2, r3, #48	@ _625, tmp1259,
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _626, i
	lsl	r3, r3, #1	@ tmp1260, _626,
	add	r3, r2, r3	@ tmp1261, _625, tmp1260
	ldrsh	r3, [r3]	@ _627, (*_625)[_626]
	mov	r1, r3	@ _628, _627
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	mov	r2, r1	@ tmp1262, _628
	lsl	r2, r2, #1	@ tmp1262, tmp1262,
	add	r2, r2, r1	@ tmp1262, tmp1262, _628
	lsl	r3, r2, #4	@ tmp1263, tmp1262,
	sub	r3, r3, r2	@ tmp1263, tmp1263, tmp1262
	lsl	r3, r3, #2	@ tmp1263, tmp1263,
	add	r3, r3, r1	@ tmp1263, tmp1263, _628
	lsl	r3, r3, #3	@ tmp1264, tmp1263,
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _630, _629,
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r3, r3, #10	@ _631, _630,
@ dct_loeffler.c:228: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	strh	r3, [fp, #-8]	@ movhi	@ _631, tmp_1
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _632, tmp_1
	add	r3, r3, #4	@ _633, _632,
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _634, _633,
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1265, output
	add	r1, r3, #48	@ _635, tmp1265,
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _636, i
@ dct_loeffler.c:229: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1266, _634,
	asr	r2, r2, #16	@ _637, tmp1266,
	lsl	r3, r3, #1	@ tmp1267, _636,
	add	r3, r1, r3	@ tmp1268, _635, tmp1267
	strh	r2, [r3]	@ movhi	@ _637, (*_635)[_636]
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldr	r3, [fp, #-20]	@ tmp1269, output
	add	r2, r3, #80	@ _638, tmp1269,
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _639, i
	lsl	r3, r3, #1	@ tmp1270, _639,
	add	r3, r2, r3	@ tmp1271, _638, tmp1270
	ldrsh	r3, [r3]	@ _640, (*_638)[_639]
	mov	r1, r3	@ _641, _640
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	mov	r2, r1	@ tmp1272, _641
	lsl	r2, r2, #1	@ tmp1272, tmp1272,
	add	r2, r2, r1	@ tmp1272, tmp1272, _641
	lsl	r3, r2, #4	@ tmp1273, tmp1272,
	sub	r3, r3, r2	@ tmp1273, tmp1273, tmp1272
	lsl	r3, r3, #2	@ tmp1273, tmp1273,
	add	r3, r3, r1	@ tmp1273, tmp1273, _641
	lsl	r3, r3, #3	@ tmp1274, tmp1273,
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _643, _642,
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r3, r3, #10	@ _644, _643,
@ dct_loeffler.c:231: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	strh	r3, [fp, #-8]	@ movhi	@ _644, tmp_1
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _645, tmp_1
	add	r3, r3, #4	@ _646, _645,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _647, _646,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-20]	@ tmp1275, output
	add	r1, r3, #80	@ _648, tmp1275,
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _649, i
@ dct_loeffler.c:232: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	lsl	r2, r2, #16	@ tmp1276, _647,
	asr	r2, r2, #16	@ _650, tmp1276,
	lsl	r3, r3, #1	@ tmp1277, _649,
	add	r3, r1, r3	@ tmp1278, _648, tmp1277
	strh	r2, [r3]	@ movhi	@ _650, (*_648)[_649]
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ i.23_651, i
	add	r3, r3, #1	@ tmp1279, i.23_651,
	strb	r3, [fp, #-5]	@ tmp1280, i
.L7:
@ dct_loeffler.c:160: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ tmp1283, i
	cmp	r3, #7	@ tmp1283,
	bls	.L8		@,
@ dct_loeffler.c:234: }
	nop	
	nop	
	sub	sp, fp, #4	@,,
	@ sp needed	@
	pop	{fp, pc}	@
	.size	dct_2d_loeffler, .-dct_2d_loeffler
	.section	.rodata
	.align	2
.LC1:
	.ascii	"DCT Coefficients:\000"
	.align	2
.LC2:
	.ascii	"%6d\000"
	.align	2
.LC0:
	.ascii	"\213\220\225\231\233\233\233\233"
	.ascii	"\220\227\231\234\237\234\234\234"
	.ascii	"\226\233\240\243\236\234\234\234"
	.ascii	"\237\241\242\240\240\237\237\237"
	.ascii	"\237\240\241\242\242\233\233\233"
	.ascii	"\241\241\241\241\240\235\235\235"
	.ascii	"\242\242\241\243\242\235\235\235"
	.ascii	"\242\242\241\241\243\236\236\236"
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 200
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}	@
	add	fp, sp, #4	@,,
	sub	sp, sp, #200	@,,
@ dct_loeffler.c:239: 	uint8_t input[N][N] = {
	ldr	r3, .L15	@ tmp117,
.LPIC1:
	add	r3, pc, r3	@ tmp117, tmp117
	sub	ip, fp, #76	@ tmp118,,
	mov	lr, r3	@ tmp119, tmp117
	ldmia	lr!, {r0, r1, r2, r3}	@ tmp119,,,,
	stmia	ip!, {r0, r1, r2, r3}	@ tmp118,,,,
	ldmia	lr!, {r0, r1, r2, r3}	@ tmp119,,,,
	stmia	ip!, {r0, r1, r2, r3}	@ tmp118,,,,
	ldmia	lr!, {r0, r1, r2, r3}	@ tmp119,,,,
	stmia	ip!, {r0, r1, r2, r3}	@ tmp118,,,,
	ldm	lr, {r0, r1, r2, r3}	@ tmp119,,,,
	stm	ip, {r0, r1, r2, r3}	@ tmp118,,,,
@ dct_loeffler.c:249: 	int16_t output[N][N] = {0};
	sub	r3, fp, #204	@ tmp120,,
	mov	r2, #128	@ tmp121,
	mov	r1, #0	@,
	mov	r0, r3	@, tmp120
	bl	memset(PLT)	@
@ dct_loeffler.c:251: 	dct_2d_loeffler(input, output);
	sub	r2, fp, #204	@ tmp123,,
	sub	r3, fp, #76	@ tmp124,,
	mov	r1, r2	@, tmp123
	mov	r0, r3	@, tmp124
	bl	dct_2d_loeffler(PLT)	@
@ dct_loeffler.c:253: 	printf("DCT Coefficients:\n");
	ldr	r3, .L15+4	@ tmp125,
.LPIC2:
	add	r3, pc, r3	@ tmp125, tmp125
	mov	r0, r3	@, tmp125
	bl	puts(PLT)	@
@ dct_loeffler.c:254: 	for(int x = 0; x < N; x++)
	mov	r3, #0	@ tmp126,
	str	r3, [fp, #-8]	@ tmp126, x
@ dct_loeffler.c:254: 	for(int x = 0; x < N; x++)
	b	.L10		@
.L13:
@ dct_loeffler.c:256: 		for(int y = 0; y < N; y++)
	mov	r3, #0	@ tmp127,
	str	r3, [fp, #-12]	@ tmp127, y
@ dct_loeffler.c:256: 		for(int y = 0; y < N; y++)
	b	.L11		@
.L12:
@ dct_loeffler.c:258: 			printf("%6d", output[x][y]);
	ldr	r3, [fp, #-8]	@ tmp128, x
	lsl	r2, r3, #3	@ tmp129, tmp128,
	ldr	r3, [fp, #-12]	@ tmp131, y
	add	r3, r2, r3	@ tmp130, tmp129, tmp131
	lsl	r3, r3, #1	@ tmp132, tmp130,
	sub	r3, r3, #4	@ tmp144, tmp132,
	add	r3, r3, fp	@ tmp133, tmp144,
	sub	r3, r3, #200	@ tmp134, tmp133,
	ldrsh	r3, [r3]	@ _1, output[x_3][y_4]
@ dct_loeffler.c:258: 			printf("%6d", output[x][y]);
	mov	r1, r3	@, _2
	ldr	r3, .L15+8	@ tmp135,
.LPIC3:
	add	r3, pc, r3	@ tmp135, tmp135
	mov	r0, r3	@, tmp135
	bl	printf(PLT)	@
@ dct_loeffler.c:256: 		for(int y = 0; y < N; y++)
	ldr	r3, [fp, #-12]	@ tmp137, y
	add	r3, r3, #1	@ tmp136, tmp137,
	str	r3, [fp, #-12]	@ tmp136, y
.L11:
@ dct_loeffler.c:256: 		for(int y = 0; y < N; y++)
	ldr	r3, [fp, #-12]	@ tmp138, y
	cmp	r3, #7	@ tmp138,
	ble	.L12		@,
@ dct_loeffler.c:260: 		printf("\n");
	mov	r0, #10	@,
	bl	putchar(PLT)	@
@ dct_loeffler.c:254: 	for(int x = 0; x < N; x++)
	ldr	r3, [fp, #-8]	@ tmp140, x
	add	r3, r3, #1	@ tmp139, tmp140,
	str	r3, [fp, #-8]	@ tmp139, x
.L10:
@ dct_loeffler.c:254: 	for(int x = 0; x < N; x++)
	ldr	r3, [fp, #-8]	@ tmp141, x
	cmp	r3, #7	@ tmp141,
	ble	.L13		@,
@ dct_loeffler.c:263:  	return 0;
	mov	r3, #0	@ _13,
@ dct_loeffler.c:264: }
	mov	r0, r3	@, <retval>
	sub	sp, fp, #4	@,,
	@ sp needed	@
	pop	{fp, pc}	@
.L16:
	.align	2
.L15:
	.word	.LC0-(.LPIC1+8)
	.word	.LC1-(.LPIC2+8)
	.word	.LC2-(.LPIC3+8)
	.size	main, .-main
	.ident	"GCC: (GNU) 11.2.1 20211120"
	.section	.note.GNU-stack,"",%progbits

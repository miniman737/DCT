cat dct_loeffler_asm.s
	.arch armv7-a
	.fpu neon
	.eabi_attribute 28, 1	@ Tag_ABI_VFP_args
	.eabi_attribute 20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute 21, 1	@ Tag_ABI_FP_exceptions
	.eabi_attribute 23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute 24, 1	@ Tag_ABI_align8_needed
	.eabi_attribute 25, 1	@ Tag_ABI_align8_preserved
	.eabi_attribute 26, 2	@ Tag_ABI_enum_size
	.eabi_attribute 30, 6	@ Tag_ABI_optimization_goals
	.eabi_attribute 34, 1	@ Tag_CPU_unaligned_access
	.eabi_attribute 18, 4	@ Tag_ABI_PCS_wchar_t
	.file	"dct_loeffler_asm.c"
@ GNU C17 (GCC) version 11.2.1 20211120 (arm-linux-musleabihf)
@	compiled by GNU C version 11.2.1 20211120, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version none
@ GGC heuristics: --param ggc-min-expand=98 --param ggc-min-heapsize=128978
@ options passed: -mfpu=neon -mfloat-abi=hard -mtls-dialect=gnu -marm -march=armv7-a+simd -O0
	.text
	.section	.rodata
	.align	2
	.type	rotator_table, %object
	.size	rotator_table, 16
rotator_table:
	.space	4
@ cos_coef:
	.short	1004
@ sin_coef:
	.short	200
@ cos_coef:
	.short	554
@ sin_coef:
	.short	1338
@ cos_coef:
	.short	851
@ sin_coef:
	.short	569
	.text
	.align	2
	.syntax unified
	.arm
	.type	butterfly_fw, %function
butterfly_fw:
	@ args = 0, pretend = 0, frame = 56
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!	@,
	add	fp, sp, #0	@,,
	sub	sp, sp, #60	@,,
	str	r0, [fp, #-48]	@ Rs, Rs
	mov	r3, r1	@ tmp123, rotator
	strb	r3, [fp, #-49]	@ tmp124, rotator
@ dct_loeffler_asm.c:59: 	rotator_coef_t coef = rotator_table[rotator];								        // Lookup the rotation coefficients for the specified rotator
	ldrb	r2, [fp, #-49]	@ zero_extendqisi2	@ _1, rotator
@ dct_loeffler_asm.c:59: 	rotator_coef_t coef = rotator_table[rotator];								        // Lookup the rotation coefficients for the specified rotator
	ldr	r3, .L3	@ tmp125,
.LPIC0:
	add	r3, pc, r3	@ tmp125, tmp125
	ldr	r3, [r3, r2, lsl #2]	@ tmp126, rotator_table[_1]
	str	r3, [fp, #-44]	@ tmp126, coef
@ dct_loeffler_asm.c:61:     int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
	ldrsh	r0, [fp, #-44]	@ _2, coef.cos_coef
@ dct_loeffler_asm.c:61:     int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
	ldrsh	r3, [fp, #-42]	@ _3, coef.sin_coef
	uxth	r3, r3	@ _4, _3
@ dct_loeffler_asm.c:61:     int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
	rsb	r3, r3, #0	@ tmp128, tmp127
	uxth	r3, r3	@ _5, tmp128
	sxth	r1, r3	@ _6, _5
@ dct_loeffler_asm.c:61:     int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
	ldrsh	r2, [fp, #-42]	@ _7, coef.sin_coef
@ dct_loeffler_asm.c:61:     int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
	ldrsh	r3, [fp, #-44]	@ _8, coef.cos_coef
@ dct_loeffler_asm.c:61:     int16x4_t coef_vec = {coef.cos_coef, -coef.sin_coef, coef.sin_coef, coef.cos_coef};	// Load the rotation coefficients into a NEON vector
	strh	r0, [fp, #-60]	@ movhi	@ _2,
	strh	r1, [fp, #-58]	@ movhi	@ _6,
	strh	r2, [fp, #-56]	@ movhi	@ _7,
	strh	r3, [fp, #-54]	@ movhi	@ _8,
	vldr	d16, [fp, #-60]	@,
	vstr	d16, [fp, #-12]	@, coef_vec
@ dct_loeffler_asm.c:67: 	__asm__(
	ldr	r3, [fp, #-48]	@ tmp135, Rs
	vldr	d16, [fp, #-12]	@, coef_vec
	.syntax divided
@ 67 "dct_loeffler_asm.c" 1
	vdup.32   d18, r3              	@ data_vec, tmp135
	vmull.s16 q2, d18, d16       	@ data_vec, tmp136
	vpadd.i32 d17, d4, d5          	@ presult
	vrshr.s32 d17, d17, #10 	@ presult
	vmov.32   r1, d17[0]      	@ tmp0, presult
	vmov.32   r2, d17[1]      	@ tmp1, presult
	lsl       r2, r2, #16        	@ tmp1
	uxth      r1, r1             	@ tmp0
	orr       r3, r1, r2      	@ Rt, tmp0, tmp1

@ 0 "" 2
	.arm
	.syntax unified
	vstr	d18, [fp, #-20]	@, data_vec
	vstr	d17, [fp, #-28]	@, presult
	str	r1, [fp, #-32]	@ tmp0, tmp0
	str	r2, [fp, #-36]	@ tmp1, tmp1
	str	r3, [fp, #-40]	@ Rt, Rt
@ dct_loeffler_asm.c:82:     return Rt;
	ldr	r3, [fp, #-40]	@ _19, Rt
@ dct_loeffler_asm.c:83: }
	mov	r0, r3	@, <retval>
	add	sp, fp, #0	@,,
	@ sp needed	@
	ldr	fp, [sp], #4	@,
	bx	lr	@
.L4:
	.align	2
.L3:
	.word	rotator_table-(.LPIC0+8)
	.size	butterfly_fw, .-butterfly_fw
	.align	2
	.global	dct_2d_loeffler
	.syntax unified
	.arm
	.type	dct_2d_loeffler, %function
dct_2d_loeffler:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}	@
	add	fp, sp, #4	@,,
	sub	sp, sp, #32	@,,
	str	r0, [fp, #-32]	@ input, input
	str	r1, [fp, #-36]	@ output, output
@ dct_loeffler_asm.c:99: 	for (i = 0; i < N; i++)
	mov	r3, #0	@ tmp812,
	strb	r3, [fp, #-5]	@ tmp813, i
@ dct_loeffler_asm.c:99: 	for (i = 0; i < N; i++)
	b	.L6		@
.L7:
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _1, i
	lsl	r3, r3, #3	@ _2, _1,
	ldr	r2, [fp, #-32]	@ tmp814, input
	add	r3, r2, r3	@ _3, tmp814, _2
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	ldrb	r3, [r3]	@ zero_extendqisi2	@ _4, (*_3)[0]
	uxth	r2, r3	@ _5, _4
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _6, i
	lsl	r3, r3, #3	@ _7, _6,
	ldr	r1, [fp, #-32]	@ tmp815, input
	add	r3, r1, r3	@ _8, tmp815, _7
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	ldrb	r3, [r3, #7]	@ zero_extendqisi2	@ _9, (*_8)[7]
	uxth	r3, r3	@ _10, _9
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	add	r3, r2, r3	@ tmp816, _5, _10
	uxth	r1, r3	@ _11, tmp816
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _12, i
	lsl	r3, r3, #4	@ _13, _12,
	ldr	r2, [fp, #-36]	@ tmp817, output
	add	r3, r2, r3	@ _14, tmp817, _13
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	sxth	r2, r1	@ _15, _11
@ dct_loeffler_asm.c:103: 		output[i][0] = input[i][0] + input[i][7];
	strh	r2, [r3]	@ movhi	@ _15, (*_14)[0]
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _16, i
	lsl	r3, r3, #3	@ _17, _16,
	ldr	r2, [fp, #-32]	@ tmp818, input
	add	r3, r2, r3	@ _18, tmp818, _17
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	ldrb	r3, [r3, #1]	@ zero_extendqisi2	@ _19, (*_18)[1]
	uxth	r2, r3	@ _20, _19
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _21, i
	lsl	r3, r3, #3	@ _22, _21,
	ldr	r1, [fp, #-32]	@ tmp819, input
	add	r3, r1, r3	@ _23, tmp819, _22
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	ldrb	r3, [r3, #6]	@ zero_extendqisi2	@ _24, (*_23)[6]
	uxth	r3, r3	@ _25, _24
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	add	r3, r2, r3	@ tmp820, _20, _25
	uxth	r1, r3	@ _26, tmp820
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _27, i
	lsl	r3, r3, #4	@ _28, _27,
	ldr	r2, [fp, #-36]	@ tmp821, output
	add	r3, r2, r3	@ _29, tmp821, _28
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	sxth	r2, r1	@ _30, _26
@ dct_loeffler_asm.c:104: 		output[i][4] = input[i][1] + input[i][6];
	strh	r2, [r3, #8]	@ movhi	@ _30, (*_29)[4]
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _31, i
	lsl	r3, r3, #3	@ _32, _31,
	ldr	r2, [fp, #-32]	@ tmp822, input
	add	r3, r2, r3	@ _33, tmp822, _32
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	ldrb	r3, [r3, #2]	@ zero_extendqisi2	@ _34, (*_33)[2]
	uxth	r2, r3	@ _35, _34
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _36, i
	lsl	r3, r3, #3	@ _37, _36,
	ldr	r1, [fp, #-32]	@ tmp823, input
	add	r3, r1, r3	@ _38, tmp823, _37
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	ldrb	r3, [r3, #5]	@ zero_extendqisi2	@ _39, (*_38)[5]
	uxth	r3, r3	@ _40, _39
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	add	r3, r2, r3	@ tmp824, _35, _40
	uxth	r1, r3	@ _41, tmp824
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _42, i
	lsl	r3, r3, #4	@ _43, _42,
	ldr	r2, [fp, #-36]	@ tmp825, output
	add	r3, r2, r3	@ _44, tmp825, _43
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	sxth	r2, r1	@ _45, _41
@ dct_loeffler_asm.c:105: 		output[i][2] = input[i][2] + input[i][5];
	strh	r2, [r3, #4]	@ movhi	@ _45, (*_44)[2]
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _46, i
	lsl	r3, r3, #3	@ _47, _46,
	ldr	r2, [fp, #-32]	@ tmp826, input
	add	r3, r2, r3	@ _48, tmp826, _47
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	ldrb	r3, [r3, #3]	@ zero_extendqisi2	@ _49, (*_48)[3]
	uxth	r2, r3	@ _50, _49
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _51, i
	lsl	r3, r3, #3	@ _52, _51,
	ldr	r1, [fp, #-32]	@ tmp827, input
	add	r3, r1, r3	@ _53, tmp827, _52
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	ldrb	r3, [r3, #4]	@ zero_extendqisi2	@ _54, (*_53)[4]
	uxth	r3, r3	@ _55, _54
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	add	r3, r2, r3	@ tmp828, _50, _55
	uxth	r1, r3	@ _56, tmp828
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _57, i
	lsl	r3, r3, #4	@ _58, _57,
	ldr	r2, [fp, #-36]	@ tmp829, output
	add	r3, r2, r3	@ _59, tmp829, _58
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	sxth	r2, r1	@ _60, _56
@ dct_loeffler_asm.c:106: 		output[i][6] = input[i][3] + input[i][4];
	strh	r2, [r3, #12]	@ movhi	@ _60, (*_59)[6]
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _61, i
	lsl	r3, r3, #3	@ _62, _61,
	ldr	r2, [fp, #-32]	@ tmp830, input
	add	r3, r2, r3	@ _63, tmp830, _62
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	ldrb	r3, [r3, #3]	@ zero_extendqisi2	@ _64, (*_63)[3]
	uxth	r2, r3	@ _65, _64
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _66, i
	lsl	r3, r3, #3	@ _67, _66,
	ldr	r1, [fp, #-32]	@ tmp831, input
	add	r3, r1, r3	@ _68, tmp831, _67
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	ldrb	r3, [r3, #4]	@ zero_extendqisi2	@ _69, (*_68)[4]
	uxth	r3, r3	@ _70, _69
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	sub	r3, r2, r3	@ tmp832, _65, _70
	uxth	r1, r3	@ _71, tmp832
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _72, i
	lsl	r3, r3, #4	@ _73, _72,
	ldr	r2, [fp, #-36]	@ tmp833, output
	add	r3, r2, r3	@ _74, tmp833, _73
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	sxth	r2, r1	@ _75, _71
@ dct_loeffler_asm.c:109: 		output[i][7] = input[i][3] - input[i][4];
	strh	r2, [r3, #14]	@ movhi	@ _75, (*_74)[7]
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _76, i
	lsl	r3, r3, #3	@ _77, _76,
	ldr	r2, [fp, #-32]	@ tmp834, input
	add	r3, r2, r3	@ _78, tmp834, _77
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	ldrb	r3, [r3, #2]	@ zero_extendqisi2	@ _79, (*_78)[2]
	uxth	r2, r3	@ _80, _79
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _81, i
	lsl	r3, r3, #3	@ _82, _81,
	ldr	r1, [fp, #-32]	@ tmp835, input
	add	r3, r1, r3	@ _83, tmp835, _82
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	ldrb	r3, [r3, #5]	@ zero_extendqisi2	@ _84, (*_83)[5]
	uxth	r3, r3	@ _85, _84
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	sub	r3, r2, r3	@ tmp836, _80, _85
	uxth	r1, r3	@ _86, tmp836
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _87, i
	lsl	r3, r3, #4	@ _88, _87,
	ldr	r2, [fp, #-36]	@ tmp837, output
	add	r3, r2, r3	@ _89, tmp837, _88
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	sxth	r2, r1	@ _90, _86
@ dct_loeffler_asm.c:110: 		output[i][3] = input[i][2] - input[i][5];
	strh	r2, [r3, #6]	@ movhi	@ _90, (*_89)[3]
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _91, i
	lsl	r3, r3, #3	@ _92, _91,
	ldr	r2, [fp, #-32]	@ tmp838, input
	add	r3, r2, r3	@ _93, tmp838, _92
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	ldrb	r3, [r3, #1]	@ zero_extendqisi2	@ _94, (*_93)[1]
	uxth	r2, r3	@ _95, _94
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _96, i
	lsl	r3, r3, #3	@ _97, _96,
	ldr	r1, [fp, #-32]	@ tmp839, input
	add	r3, r1, r3	@ _98, tmp839, _97
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	ldrb	r3, [r3, #6]	@ zero_extendqisi2	@ _99, (*_98)[6]
	uxth	r3, r3	@ _100, _99
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	sub	r3, r2, r3	@ tmp840, _95, _100
	uxth	r1, r3	@ _101, tmp840
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _102, i
	lsl	r3, r3, #4	@ _103, _102,
	ldr	r2, [fp, #-36]	@ tmp841, output
	add	r3, r2, r3	@ _104, tmp841, _103
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	sxth	r2, r1	@ _105, _101
@ dct_loeffler_asm.c:111: 		output[i][5] = input[i][1] - input[i][6];
	strh	r2, [r3, #10]	@ movhi	@ _105, (*_104)[5]
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _106, i
	lsl	r3, r3, #3	@ _107, _106,
	ldr	r2, [fp, #-32]	@ tmp842, input
	add	r3, r2, r3	@ _108, tmp842, _107
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	ldrb	r3, [r3]	@ zero_extendqisi2	@ _109, (*_108)[0]
	uxth	r2, r3	@ _110, _109
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _111, i
	lsl	r3, r3, #3	@ _112, _111,
	ldr	r1, [fp, #-32]	@ tmp843, input
	add	r3, r1, r3	@ _113, tmp843, _112
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	ldrb	r3, [r3, #7]	@ zero_extendqisi2	@ _114, (*_113)[7]
	uxth	r3, r3	@ _115, _114
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	sub	r3, r2, r3	@ tmp844, _110, _115
	uxth	r1, r3	@ _116, tmp844
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _117, i
	lsl	r3, r3, #4	@ _118, _117,
	ldr	r2, [fp, #-36]	@ tmp845, output
	add	r3, r2, r3	@ _119, tmp845, _118
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	sxth	r2, r1	@ _120, _116
@ dct_loeffler_asm.c:112: 		output[i][1] = input[i][0] - input[i][7];
	strh	r2, [r3, #2]	@ movhi	@ _120, (*_119)[1]
@ dct_loeffler_asm.c:116: 		tmp_1 = output[i][0];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _121, i
	lsl	r3, r3, #4	@ _122, _121,
	ldr	r2, [fp, #-36]	@ tmp846, output
	add	r3, r2, r3	@ _123, tmp846, _122
@ dct_loeffler_asm.c:116: 		tmp_1 = output[i][0];
	ldrh	r3, [r3]	@ movhi	@ tmp847, (*_123)[0]
	strh	r3, [fp, #-8]	@ movhi	@ tmp847, tmp_1
@ dct_loeffler_asm.c:117: 		output[i][0] = tmp_1 + output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _124, i
	lsl	r3, r3, #4	@ _125, _124,
	ldr	r2, [fp, #-36]	@ tmp848, output
	add	r3, r2, r3	@ _126, tmp848, _125
@ dct_loeffler_asm.c:117: 		output[i][0] = tmp_1 + output[i][6];
	ldrsh	r3, [r3, #12]	@ _127, (*_126)[6]
	uxth	r2, r3	@ _128, _127
@ dct_loeffler_asm.c:117: 		output[i][0] = tmp_1 + output[i][6];
	ldrh	r3, [fp, #-8]	@ tmp_1.0_129, tmp_1
	add	r3, r2, r3	@ tmp849, _128, tmp_1.0_129
	uxth	r1, r3	@ _130, tmp849
@ dct_loeffler_asm.c:117: 		output[i][0] = tmp_1 + output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _131, i
	lsl	r3, r3, #4	@ _132, _131,
	ldr	r2, [fp, #-36]	@ tmp850, output
	add	r3, r2, r3	@ _133, tmp850, _132
@ dct_loeffler_asm.c:117: 		output[i][0] = tmp_1 + output[i][6];
	sxth	r2, r1	@ _134, _130
@ dct_loeffler_asm.c:117: 		output[i][0] = tmp_1 + output[i][6];
	strh	r2, [r3]	@ movhi	@ _134, (*_133)[0]
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	ldrh	r2, [fp, #-8]	@ tmp_1.1_135, tmp_1
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _136, i
	lsl	r3, r3, #4	@ _137, _136,
	ldr	r1, [fp, #-36]	@ tmp851, output
	add	r3, r1, r3	@ _138, tmp851, _137
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	ldrsh	r3, [r3, #12]	@ _139, (*_138)[6]
	uxth	r3, r3	@ _140, _139
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	sub	r3, r2, r3	@ tmp852, tmp_1.1_135, _140
	uxth	r1, r3	@ _141, tmp852
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _142, i
	lsl	r3, r3, #4	@ _143, _142,
	ldr	r2, [fp, #-36]	@ tmp853, output
	add	r3, r2, r3	@ _144, tmp853, _143
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	sxth	r2, r1	@ _145, _141
@ dct_loeffler_asm.c:118: 		output[i][6] = tmp_1 - output[i][6];
	strh	r2, [r3, #12]	@ movhi	@ _145, (*_144)[6]
@ dct_loeffler_asm.c:120: 		tmp_1 = output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _146, i
	lsl	r3, r3, #4	@ _147, _146,
	ldr	r2, [fp, #-36]	@ tmp854, output
	add	r3, r2, r3	@ _148, tmp854, _147
@ dct_loeffler_asm.c:120: 		tmp_1 = output[i][4];
	ldrh	r3, [r3, #8]	@ movhi	@ tmp855, (*_148)[4]
	strh	r3, [fp, #-8]	@ movhi	@ tmp855, tmp_1
@ dct_loeffler_asm.c:121: 		output[i][4] = tmp_1 + output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _149, i
	lsl	r3, r3, #4	@ _150, _149,
	ldr	r2, [fp, #-36]	@ tmp856, output
	add	r3, r2, r3	@ _151, tmp856, _150
@ dct_loeffler_asm.c:121: 		output[i][4] = tmp_1 + output[i][2];
	ldrsh	r3, [r3, #4]	@ _152, (*_151)[2]
	uxth	r2, r3	@ _153, _152
@ dct_loeffler_asm.c:121: 		output[i][4] = tmp_1 + output[i][2];
	ldrh	r3, [fp, #-8]	@ tmp_1.2_154, tmp_1
	add	r3, r2, r3	@ tmp857, _153, tmp_1.2_154
	uxth	r1, r3	@ _155, tmp857
@ dct_loeffler_asm.c:121: 		output[i][4] = tmp_1 + output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _156, i
	lsl	r3, r3, #4	@ _157, _156,
	ldr	r2, [fp, #-36]	@ tmp858, output
	add	r3, r2, r3	@ _158, tmp858, _157
@ dct_loeffler_asm.c:121: 		output[i][4] = tmp_1 + output[i][2];
	sxth	r2, r1	@ _159, _155
@ dct_loeffler_asm.c:121: 		output[i][4] = tmp_1 + output[i][2];
	strh	r2, [r3, #8]	@ movhi	@ _159, (*_158)[4]
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	ldrh	r2, [fp, #-8]	@ tmp_1.3_160, tmp_1
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _161, i
	lsl	r3, r3, #4	@ _162, _161,
	ldr	r1, [fp, #-36]	@ tmp859, output
	add	r3, r1, r3	@ _163, tmp859, _162
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	ldrsh	r3, [r3, #4]	@ _164, (*_163)[2]
	uxth	r3, r3	@ _165, _164
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	sub	r3, r2, r3	@ tmp860, tmp_1.3_160, _165
	uxth	r1, r3	@ _166, tmp860
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _167, i
	lsl	r3, r3, #4	@ _168, _167,
	ldr	r2, [fp, #-36]	@ tmp861, output
	add	r3, r2, r3	@ _169, tmp861, _168
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	sxth	r2, r1	@ _170, _166
@ dct_loeffler_asm.c:122: 		output[i][2] = tmp_1 - output[i][2];
	strh	r2, [r3, #4]	@ movhi	@ _170, (*_169)[2]
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _171, i
	lsl	r3, r3, #4	@ _172, _171,
	ldr	r2, [fp, #-36]	@ tmp862, output
	add	r3, r2, r3	@ _173, tmp862, _172
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	ldrsh	r3, [r3, #14]	@ _174, (*_173)[7]
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	uxth	r3, r3	@ _175, _174
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	lsl	r3, r3, #16	@ _177, _176,
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _178, i
	lsl	r2, r2, #4	@ _179, _178,
	ldr	r1, [fp, #-36]	@ tmp863, output
	add	r2, r1, r2	@ _180, tmp863, _179
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	ldrsh	r2, [r2, #2]	@ _181, (*_180)[1]
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	uxth	r2, r2	@ _182, _181
@ dct_loeffler_asm.c:129:         uint32_t Rs = ((uint32_t)(uint16_t)output[i][7] << 16) | (uint16_t)output[i][1];
	orr	r3, r3, r2	@ tmp864, _177, _183
	str	r3, [fp, #-24]	@ tmp864, Rs
@ dct_loeffler_asm.c:130:         uint32_t Rt = butterfly_fw(Rs, 3); // Call butterfly function C
	ldr	r3, [fp, #-24]	@ Rs.4_184, Rs
	mov	r1, #3	@,
	mov	r0, r3	@, Rs.4_184
	bl	butterfly_fw(PLT)	@
	mov	r3, r0	@ _185,
@ dct_loeffler_asm.c:130:         uint32_t Rt = butterfly_fw(Rs, 3); // Call butterfly function C
	str	r3, [fp, #-28]	@ _185, Rt
@ dct_loeffler_asm.c:132:         output[i][7] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-28]	@ tmp865, Rt
	lsr	r1, r3, #16	@ _186, tmp865,
@ dct_loeffler_asm.c:132:         output[i][7] = (int16_t)(Rt >> 16);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _187, i
	lsl	r3, r3, #4	@ _188, _187,
	ldr	r2, [fp, #-36]	@ tmp866, output
	add	r3, r2, r3	@ _189, tmp866, _188
@ dct_loeffler_asm.c:132:         output[i][7] = (int16_t)(Rt >> 16);
	sxth	r2, r1	@ _190, _186
@ dct_loeffler_asm.c:132:         output[i][7] = (int16_t)(Rt >> 16);
	strh	r2, [r3, #14]	@ movhi	@ _190, (*_189)[7]
@ dct_loeffler_asm.c:133:         output[i][1] = (int16_t)(Rt & 0xFFFF);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _191, i
	lsl	r3, r3, #4	@ _192, _191,
	ldr	r2, [fp, #-36]	@ tmp867, output
	add	r3, r2, r3	@ _193, tmp867, _192
@ dct_loeffler_asm.c:133:         output[i][1] = (int16_t)(Rt & 0xFFFF);
	ldr	r2, [fp, #-28]	@ tmp868, Rt
	sxth	r2, r2	@ _194, tmp868
@ dct_loeffler_asm.c:133:         output[i][1] = (int16_t)(Rt & 0xFFFF);
	strh	r2, [r3, #2]	@ movhi	@ _194, (*_193)[1]
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _195, i
	lsl	r3, r3, #4	@ _196, _195,
	ldr	r2, [fp, #-36]	@ tmp869, output
	add	r3, r2, r3	@ _197, tmp869, _196
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	ldrsh	r3, [r3, #6]	@ _198, (*_197)[3]
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	uxth	r3, r3	@ _199, _198
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	lsl	r3, r3, #16	@ _201, _200,
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _202, i
	lsl	r2, r2, #4	@ _203, _202,
	ldr	r1, [fp, #-36]	@ tmp870, output
	add	r2, r1, r2	@ _204, tmp870, _203
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	ldrsh	r2, [r2, #10]	@ _205, (*_204)[5]
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	uxth	r2, r2	@ _206, _205
@ dct_loeffler_asm.c:136:         Rs = ((uint32_t)(uint16_t)output[i][3] << 16) | (uint16_t)output[i][5];
	orr	r3, r3, r2	@ tmp871, _201, _207
	str	r3, [fp, #-24]	@ tmp871, Rs
@ dct_loeffler_asm.c:137:         Rt = butterfly_fw(Rs, 1); // Call butterfly function C1
	ldr	r3, [fp, #-24]	@ Rs.5_208, Rs
	mov	r1, #1	@,
	mov	r0, r3	@, Rs.5_208
	bl	butterfly_fw(PLT)	@
	mov	r3, r0	@ _209,
@ dct_loeffler_asm.c:137:         Rt = butterfly_fw(Rs, 1); // Call butterfly function C1
	str	r3, [fp, #-28]	@ _209, Rt
@ dct_loeffler_asm.c:139:         output[i][3] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-28]	@ tmp872, Rt
	lsr	r1, r3, #16	@ _210, tmp872,
@ dct_loeffler_asm.c:139:         output[i][3] = (int16_t)(Rt >> 16);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _211, i
	lsl	r3, r3, #4	@ _212, _211,
	ldr	r2, [fp, #-36]	@ tmp873, output
	add	r3, r2, r3	@ _213, tmp873, _212
@ dct_loeffler_asm.c:139:         output[i][3] = (int16_t)(Rt >> 16);
	sxth	r2, r1	@ _214, _210
@ dct_loeffler_asm.c:139:         output[i][3] = (int16_t)(Rt >> 16);
	strh	r2, [r3, #6]	@ movhi	@ _214, (*_213)[3]
@ dct_loeffler_asm.c:140:         output[i][5] = (int16_t)(Rt & 0xFFFF);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _215, i
	lsl	r3, r3, #4	@ _216, _215,
	ldr	r2, [fp, #-36]	@ tmp874, output
	add	r3, r2, r3	@ _217, tmp874, _216
@ dct_loeffler_asm.c:140:         output[i][5] = (int16_t)(Rt & 0xFFFF);
	ldr	r2, [fp, #-28]	@ tmp875, Rt
	sxth	r2, r2	@ _218, tmp875
@ dct_loeffler_asm.c:140:         output[i][5] = (int16_t)(Rt & 0xFFFF);
	strh	r2, [r3, #10]	@ movhi	@ _218, (*_217)[5]
@ dct_loeffler_asm.c:144: 		tmp_1 = output[i][0];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _219, i
	lsl	r3, r3, #4	@ _220, _219,
	ldr	r2, [fp, #-36]	@ tmp876, output
	add	r3, r2, r3	@ _221, tmp876, _220
@ dct_loeffler_asm.c:144: 		tmp_1 = output[i][0];
	ldrh	r3, [r3]	@ movhi	@ tmp877, (*_221)[0]
	strh	r3, [fp, #-8]	@ movhi	@ tmp877, tmp_1
@ dct_loeffler_asm.c:145: 		output[i][0] = tmp_1 + output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _222, i
	lsl	r3, r3, #4	@ _223, _222,
	ldr	r2, [fp, #-36]	@ tmp878, output
	add	r3, r2, r3	@ _224, tmp878, _223
@ dct_loeffler_asm.c:145: 		output[i][0] = tmp_1 + output[i][4];
	ldrsh	r3, [r3, #8]	@ _225, (*_224)[4]
	uxth	r2, r3	@ _226, _225
@ dct_loeffler_asm.c:145: 		output[i][0] = tmp_1 + output[i][4];
	ldrh	r3, [fp, #-8]	@ tmp_1.6_227, tmp_1
	add	r3, r2, r3	@ tmp879, _226, tmp_1.6_227
	uxth	r1, r3	@ _228, tmp879
@ dct_loeffler_asm.c:145: 		output[i][0] = tmp_1 + output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _229, i
	lsl	r3, r3, #4	@ _230, _229,
	ldr	r2, [fp, #-36]	@ tmp880, output
	add	r3, r2, r3	@ _231, tmp880, _230
@ dct_loeffler_asm.c:145: 		output[i][0] = tmp_1 + output[i][4];
	sxth	r2, r1	@ _232, _228
@ dct_loeffler_asm.c:145: 		output[i][0] = tmp_1 + output[i][4];
	strh	r2, [r3]	@ movhi	@ _232, (*_231)[0]
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	ldrh	r2, [fp, #-8]	@ tmp_1.7_233, tmp_1
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _234, i
	lsl	r3, r3, #4	@ _235, _234,
	ldr	r1, [fp, #-36]	@ tmp881, output
	add	r3, r1, r3	@ _236, tmp881, _235
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	ldrsh	r3, [r3, #8]	@ _237, (*_236)[4]
	uxth	r3, r3	@ _238, _237
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	sub	r3, r2, r3	@ tmp882, tmp_1.7_233, _238
	uxth	r1, r3	@ _239, tmp882
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _240, i
	lsl	r3, r3, #4	@ _241, _240,
	ldr	r2, [fp, #-36]	@ tmp883, output
	add	r3, r2, r3	@ _242, tmp883, _241
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	sxth	r2, r1	@ _243, _239
@ dct_loeffler_asm.c:146: 		output[i][4] = tmp_1 - output[i][4];
	strh	r2, [r3, #8]	@ movhi	@ _243, (*_242)[4]
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _244, i
	lsl	r3, r3, #4	@ _245, _244,
	ldr	r2, [fp, #-36]	@ tmp884, output
	add	r3, r2, r3	@ _246, tmp884, _245
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	ldrsh	r3, [r3, #4]	@ _247, (*_246)[2]
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	uxth	r3, r3	@ _248, _247
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	lsl	r3, r3, #16	@ _250, _249,
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _251, i
	lsl	r2, r2, #4	@ _252, _251,
	ldr	r1, [fp, #-36]	@ tmp885, output
	add	r2, r1, r2	@ _253, tmp885, _252
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	ldrsh	r2, [r2, #12]	@ _254, (*_253)[6]
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	uxth	r2, r2	@ _255, _254
@ dct_loeffler_asm.c:149:         Rs = ((uint32_t)(uint16_t)output[i][2] << 16) | (uint16_t)output[i][6];
	orr	r3, r3, r2	@ tmp886, _250, _256
	str	r3, [fp, #-24]	@ tmp886, Rs
@ dct_loeffler_asm.c:150:         Rt = butterfly_fw(Rs, 2); // Call butterfly function sqrt(2) * C6
	ldr	r3, [fp, #-24]	@ Rs.8_257, Rs
	mov	r1, #2	@,
	mov	r0, r3	@, Rs.8_257
	bl	butterfly_fw(PLT)	@
	mov	r3, r0	@ _258,
@ dct_loeffler_asm.c:150:         Rt = butterfly_fw(Rs, 2); // Call butterfly function sqrt(2) * C6
	str	r3, [fp, #-28]	@ _258, Rt
@ dct_loeffler_asm.c:152:         output[i][2] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-28]	@ tmp887, Rt
	lsr	r1, r3, #16	@ _259, tmp887,
@ dct_loeffler_asm.c:152:         output[i][2] = (int16_t)(Rt >> 16);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _260, i
	lsl	r3, r3, #4	@ _261, _260,
	ldr	r2, [fp, #-36]	@ tmp888, output
	add	r3, r2, r3	@ _262, tmp888, _261
@ dct_loeffler_asm.c:152:         output[i][2] = (int16_t)(Rt >> 16);
	sxth	r2, r1	@ _263, _259
@ dct_loeffler_asm.c:152:         output[i][2] = (int16_t)(Rt >> 16);
	strh	r2, [r3, #4]	@ movhi	@ _263, (*_262)[2]
@ dct_loeffler_asm.c:153:         output[i][6] = (int16_t)(Rt & 0xFFFF);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _264, i
	lsl	r3, r3, #4	@ _265, _264,
	ldr	r2, [fp, #-36]	@ tmp889, output
	add	r3, r2, r3	@ _266, tmp889, _265
@ dct_loeffler_asm.c:153:         output[i][6] = (int16_t)(Rt & 0xFFFF);
	ldr	r2, [fp, #-28]	@ tmp890, Rt
	sxth	r2, r2	@ _267, tmp890
@ dct_loeffler_asm.c:153:         output[i][6] = (int16_t)(Rt & 0xFFFF);
	strh	r2, [r3, #12]	@ movhi	@ _267, (*_266)[6]
@ dct_loeffler_asm.c:156: 		tmp_1 = output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _268, i
	lsl	r3, r3, #4	@ _269, _268,
	ldr	r2, [fp, #-36]	@ tmp891, output
	add	r3, r2, r3	@ _270, tmp891, _269
@ dct_loeffler_asm.c:156: 		tmp_1 = output[i][7];
	ldrh	r3, [r3, #14]	@ movhi	@ tmp892, (*_270)[7]
	strh	r3, [fp, #-8]	@ movhi	@ tmp892, tmp_1
@ dct_loeffler_asm.c:157: 		output[i][7] = tmp_1 + output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _271, i
	lsl	r3, r3, #4	@ _272, _271,
	ldr	r2, [fp, #-36]	@ tmp893, output
	add	r3, r2, r3	@ _273, tmp893, _272
@ dct_loeffler_asm.c:157: 		output[i][7] = tmp_1 + output[i][5];
	ldrsh	r3, [r3, #10]	@ _274, (*_273)[5]
	uxth	r2, r3	@ _275, _274
@ dct_loeffler_asm.c:157: 		output[i][7] = tmp_1 + output[i][5];
	ldrh	r3, [fp, #-8]	@ tmp_1.9_276, tmp_1
	add	r3, r2, r3	@ tmp894, _275, tmp_1.9_276
	uxth	r1, r3	@ _277, tmp894
@ dct_loeffler_asm.c:157: 		output[i][7] = tmp_1 + output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _278, i
	lsl	r3, r3, #4	@ _279, _278,
	ldr	r2, [fp, #-36]	@ tmp895, output
	add	r3, r2, r3	@ _280, tmp895, _279
@ dct_loeffler_asm.c:157: 		output[i][7] = tmp_1 + output[i][5];
	sxth	r2, r1	@ _281, _277
@ dct_loeffler_asm.c:157: 		output[i][7] = tmp_1 + output[i][5];
	strh	r2, [r3, #14]	@ movhi	@ _281, (*_280)[7]
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	ldrh	r2, [fp, #-8]	@ tmp_1.10_282, tmp_1
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _283, i
	lsl	r3, r3, #4	@ _284, _283,
	ldr	r1, [fp, #-36]	@ tmp896, output
	add	r3, r1, r3	@ _285, tmp896, _284
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	ldrsh	r3, [r3, #10]	@ _286, (*_285)[5]
	uxth	r3, r3	@ _287, _286
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	sub	r3, r2, r3	@ tmp897, tmp_1.10_282, _287
	uxth	r1, r3	@ _288, tmp897
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _289, i
	lsl	r3, r3, #4	@ _290, _289,
	ldr	r2, [fp, #-36]	@ tmp898, output
	add	r3, r2, r3	@ _291, tmp898, _290
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	sxth	r2, r1	@ _292, _288
@ dct_loeffler_asm.c:158: 		output[i][5] = tmp_1 - output[i][5];
	strh	r2, [r3, #10]	@ movhi	@ _292, (*_291)[5]
@ dct_loeffler_asm.c:160: 		tmp_1 = output[i][1];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _293, i
	lsl	r3, r3, #4	@ _294, _293,
	ldr	r2, [fp, #-36]	@ tmp899, output
	add	r3, r2, r3	@ _295, tmp899, _294
@ dct_loeffler_asm.c:160: 		tmp_1 = output[i][1];
	ldrh	r3, [r3, #2]	@ movhi	@ tmp900, (*_295)[1]
	strh	r3, [fp, #-8]	@ movhi	@ tmp900, tmp_1
@ dct_loeffler_asm.c:161: 		output[i][1] = tmp_1 + output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _296, i
	lsl	r3, r3, #4	@ _297, _296,
	ldr	r2, [fp, #-36]	@ tmp901, output
	add	r3, r2, r3	@ _298, tmp901, _297
@ dct_loeffler_asm.c:161: 		output[i][1] = tmp_1 + output[i][3];
	ldrsh	r3, [r3, #6]	@ _299, (*_298)[3]
	uxth	r2, r3	@ _300, _299
@ dct_loeffler_asm.c:161: 		output[i][1] = tmp_1 + output[i][3];
	ldrh	r3, [fp, #-8]	@ tmp_1.11_301, tmp_1
	add	r3, r2, r3	@ tmp902, _300, tmp_1.11_301
	uxth	r1, r3	@ _302, tmp902
@ dct_loeffler_asm.c:161: 		output[i][1] = tmp_1 + output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _303, i
	lsl	r3, r3, #4	@ _304, _303,
	ldr	r2, [fp, #-36]	@ tmp903, output
	add	r3, r2, r3	@ _305, tmp903, _304
@ dct_loeffler_asm.c:161: 		output[i][1] = tmp_1 + output[i][3];
	sxth	r2, r1	@ _306, _302
@ dct_loeffler_asm.c:161: 		output[i][1] = tmp_1 + output[i][3];
	strh	r2, [r3, #2]	@ movhi	@ _306, (*_305)[1]
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	ldrh	r2, [fp, #-8]	@ tmp_1.12_307, tmp_1
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _308, i
	lsl	r3, r3, #4	@ _309, _308,
	ldr	r1, [fp, #-36]	@ tmp904, output
	add	r3, r1, r3	@ _310, tmp904, _309
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	ldrsh	r3, [r3, #6]	@ _311, (*_310)[3]
	uxth	r3, r3	@ _312, _311
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	sub	r3, r2, r3	@ tmp905, tmp_1.12_307, _312
	uxth	r1, r3	@ _313, tmp905
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _314, i
	lsl	r3, r3, #4	@ _315, _314,
	ldr	r2, [fp, #-36]	@ tmp906, output
	add	r3, r2, r3	@ _316, tmp906, _315
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	sxth	r2, r1	@ _317, _313
@ dct_loeffler_asm.c:162: 		output[i][3] = tmp_1 - output[i][3];
	strh	r2, [r3, #6]	@ movhi	@ _317, (*_316)[3]
@ dct_loeffler_asm.c:172: 		tmp_1 = output[i][1];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _318, i
	lsl	r3, r3, #4	@ _319, _318,
	ldr	r2, [fp, #-36]	@ tmp907, output
	add	r3, r2, r3	@ _320, tmp907, _319
@ dct_loeffler_asm.c:172: 		tmp_1 = output[i][1];
	ldrh	r3, [r3, #2]	@ movhi	@ tmp908, (*_320)[1]
	strh	r3, [fp, #-8]	@ movhi	@ tmp908, tmp_1
@ dct_loeffler_asm.c:173: 		output[i][1] = tmp_1 + output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _321, i
	lsl	r3, r3, #4	@ _322, _321,
	ldr	r2, [fp, #-36]	@ tmp909, output
	add	r3, r2, r3	@ _323, tmp909, _322
@ dct_loeffler_asm.c:173: 		output[i][1] = tmp_1 + output[i][7];
	ldrsh	r3, [r3, #14]	@ _324, (*_323)[7]
	uxth	r2, r3	@ _325, _324
@ dct_loeffler_asm.c:173: 		output[i][1] = tmp_1 + output[i][7];
	ldrh	r3, [fp, #-8]	@ tmp_1.13_326, tmp_1
	add	r3, r2, r3	@ tmp910, _325, tmp_1.13_326
	uxth	r1, r3	@ _327, tmp910
@ dct_loeffler_asm.c:173: 		output[i][1] = tmp_1 + output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _328, i
	lsl	r3, r3, #4	@ _329, _328,
	ldr	r2, [fp, #-36]	@ tmp911, output
	add	r3, r2, r3	@ _330, tmp911, _329
@ dct_loeffler_asm.c:173: 		output[i][1] = tmp_1 + output[i][7];
	sxth	r2, r1	@ _331, _327
@ dct_loeffler_asm.c:173: 		output[i][1] = tmp_1 + output[i][7];
	strh	r2, [r3, #2]	@ movhi	@ _331, (*_330)[1]
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	ldrh	r2, [fp, #-8]	@ tmp_1.14_332, tmp_1
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _333, i
	lsl	r3, r3, #4	@ _334, _333,
	ldr	r1, [fp, #-36]	@ tmp912, output
	add	r3, r1, r3	@ _335, tmp912, _334
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	ldrsh	r3, [r3, #14]	@ _336, (*_335)[7]
	uxth	r3, r3	@ _337, _336
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	sub	r3, r2, r3	@ tmp913, tmp_1.14_332, _337
	uxth	r1, r3	@ _338, tmp913
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _339, i
	lsl	r3, r3, #4	@ _340, _339,
	ldr	r2, [fp, #-36]	@ tmp914, output
	add	r3, r2, r3	@ _341, tmp914, _340
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	sxth	r2, r1	@ _342, _338
@ dct_loeffler_asm.c:174: 		output[i][7] = tmp_1 - output[i][7];
	strh	r2, [r3, #14]	@ movhi	@ _342, (*_341)[7]
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _343, i
	lsl	r3, r3, #4	@ _344, _343,
	ldr	r2, [fp, #-36]	@ tmp915, output
	add	r3, r2, r3	@ _345, tmp915, _344
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrsh	r3, [r3, #6]	@ _346, (*_345)[3]
	mov	r2, r3	@ _347, _346
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	movw	r3, #1448	@ tmp916,
	mul	r3, r3, r2	@ _348, tmp916, _347
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _349, _348,
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r1, r3, #10	@ _350, _349,
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _351, i
	lsl	r3, r3, #4	@ _352, _351,
	ldr	r2, [fp, #-36]	@ tmp917, output
	add	r3, r2, r3	@ _353, tmp917, _352
@ dct_loeffler_asm.c:177: 		output[i][3] = ((output[i][3] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	sxth	r2, r1	@ _354, _350
	strh	r2, [r3, #6]	@ movhi	@ _354, (*_353)[3]
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _355, i
	lsl	r3, r3, #4	@ _356, _355,
	ldr	r2, [fp, #-36]	@ tmp918, output
	add	r3, r2, r3	@ _357, tmp918, _356
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrsh	r3, [r3, #10]	@ _358, (*_357)[5]
	mov	r2, r3	@ _359, _358
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	movw	r3, #1448	@ tmp919,
	mul	r3, r3, r2	@ _360, tmp919, _359
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _361, _360,
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r1, r3, #10	@ _362, _361,
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _363, i
	lsl	r3, r3, #4	@ _364, _363,
	ldr	r2, [fp, #-36]	@ tmp920, output
	add	r3, r2, r3	@ _365, tmp920, _364
@ dct_loeffler_asm.c:178: 		output[i][5] = ((output[i][5] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	sxth	r2, r1	@ _366, _362
	strh	r2, [r3, #10]	@ movhi	@ _366, (*_365)[5]
@ dct_loeffler_asm.c:99: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ i.15_367, i
	add	r3, r3, #1	@ tmp921, i.15_367,
	strb	r3, [fp, #-5]	@ tmp922, i
.L6:
@ dct_loeffler_asm.c:99: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ tmp925, i
	cmp	r3, #7	@ tmp925,
	bls	.L7		@,
@ dct_loeffler_asm.c:182: 	for (i = 0; i < N; i++)
	mov	r3, #0	@ tmp926,
	strb	r3, [fp, #-5]	@ tmp927, i
@ dct_loeffler_asm.c:182: 	for (i = 0; i < N; i++)
	b	.L8		@
.L9:
@ dct_loeffler_asm.c:186: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldr	r3, [fp, #-36]	@ tmp928, output
	add	r2, r3, #16	@ _368, tmp928,
@ dct_loeffler_asm.c:186: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _369, i
	lsl	r3, r3, #1	@ tmp929, _369,
	add	r3, r2, r3	@ tmp930, _368, tmp929
	ldrsh	r3, [r3]	@ _370, (*_368)[_369]
	uxth	r2, r3	@ _371, _370
@ dct_loeffler_asm.c:186: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldr	r3, [fp, #-36]	@ tmp931, output
	add	r1, r3, #96	@ _372, tmp931,
@ dct_loeffler_asm.c:186: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _373, i
	lsl	r3, r3, #1	@ tmp932, _373,
	add	r3, r1, r3	@ tmp933, _372, tmp932
	ldrsh	r3, [r3]	@ _374, (*_372)[_373]
	uxth	r3, r3	@ _375, _374
@ dct_loeffler_asm.c:186: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	add	r3, r2, r3	@ tmp934, _371, _375
	uxth	r3, r3	@ _376, tmp934
@ dct_loeffler_asm.c:186: 		tmp_1 = output[1][i] + output[6][i];		// temp vars for X(4) and X(5) to prevent aliasing of output values
	strh	r3, [fp, #-8]	@ movhi	@ _376, tmp_1
@ dct_loeffler_asm.c:187: 		tmp_2 = output[1][i] - output[6][i];
	ldr	r3, [fp, #-36]	@ tmp935, output
	add	r2, r3, #16	@ _377, tmp935,
@ dct_loeffler_asm.c:187: 		tmp_2 = output[1][i] - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _378, i
	lsl	r3, r3, #1	@ tmp936, _378,
	add	r3, r2, r3	@ tmp937, _377, tmp936
	ldrsh	r3, [r3]	@ _379, (*_377)[_378]
	uxth	r2, r3	@ _380, _379
@ dct_loeffler_asm.c:187: 		tmp_2 = output[1][i] - output[6][i];
	ldr	r3, [fp, #-36]	@ tmp938, output
	add	r1, r3, #96	@ _381, tmp938,
@ dct_loeffler_asm.c:187: 		tmp_2 = output[1][i] - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _382, i
	lsl	r3, r3, #1	@ tmp939, _382,
	add	r3, r1, r3	@ tmp940, _381, tmp939
	ldrsh	r3, [r3]	@ _383, (*_381)[_382]
	uxth	r3, r3	@ _384, _383
@ dct_loeffler_asm.c:187: 		tmp_2 = output[1][i] - output[6][i];
	sub	r3, r2, r3	@ tmp941, _380, _384
	uxth	r3, r3	@ _385, tmp941
@ dct_loeffler_asm.c:187: 		tmp_2 = output[1][i] - output[6][i];
	strh	r3, [fp, #-10]	@ movhi	@ _385, tmp_2
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _386, i
	ldr	r2, [fp, #-36]	@ tmp942, output
	lsl	r3, r3, #1	@ tmp943, _386,
	add	r3, r2, r3	@ tmp944, tmp942, tmp943
	ldrsh	r3, [r3]	@ _387, (*output_707(D))[_386]
	uxth	r2, r3	@ _388, _387
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	ldr	r3, [fp, #-36]	@ tmp945, output
	add	r1, r3, #112	@ _389, tmp945,
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _390, i
	lsl	r3, r3, #1	@ tmp946, _390,
	add	r3, r1, r3	@ tmp947, _389, tmp946
	ldrsh	r3, [r3]	@ _391, (*_389)[_390]
	uxth	r3, r3	@ _392, _391
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	sub	r3, r2, r3	@ tmp948, _388, _392
	uxth	r2, r3	@ _393, tmp948
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	ldr	r3, [fp, #-36]	@ tmp949, output
	add	r1, r3, #16	@ _394, tmp949,
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _395, i
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	sxth	r2, r2	@ _396, _393
@ dct_loeffler_asm.c:189: 		output[1][i] = output[0][i] - output[7][i];
	lsl	r3, r3, #1	@ tmp950, _395,
	add	r3, r1, r3	@ tmp951, _394, tmp950
	strh	r2, [r3]	@ movhi	@ _396, (*_394)[_395]
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _397, i
	ldr	r2, [fp, #-36]	@ tmp952, output
	lsl	r3, r3, #1	@ tmp953, _397,
	add	r3, r2, r3	@ tmp954, tmp952, tmp953
	ldrsh	r3, [r3]	@ _398, (*output_707(D))[_397]
	uxth	r2, r3	@ _399, _398
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	ldr	r3, [fp, #-36]	@ tmp955, output
	add	r1, r3, #112	@ _400, tmp955,
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _401, i
	lsl	r3, r3, #1	@ tmp956, _401,
	add	r3, r1, r3	@ tmp957, _400, tmp956
	ldrsh	r3, [r3]	@ _402, (*_400)[_401]
	uxth	r3, r3	@ _403, _402
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	add	r3, r2, r3	@ tmp958, _399, _403
	uxth	r2, r3	@ _404, tmp958
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _405, i
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	sxth	r2, r2	@ _406, _404
@ dct_loeffler_asm.c:190: 		output[0][i] = output[0][i] + output[7][i];
	ldr	r1, [fp, #-36]	@ tmp959, output
	lsl	r3, r3, #1	@ tmp960, _405,
	add	r3, r1, r3	@ tmp961, tmp959, tmp960
	strh	r2, [r3]	@ movhi	@ _406, (*output_707(D))[_405]
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	ldr	r3, [fp, #-36]	@ tmp962, output
	add	r2, r3, #48	@ _407, tmp962,
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _408, i
	lsl	r3, r3, #1	@ tmp963, _408,
	add	r3, r2, r3	@ tmp964, _407, tmp963
	ldrsh	r3, [r3]	@ _409, (*_407)[_408]
	uxth	r2, r3	@ _410, _409
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	ldr	r3, [fp, #-36]	@ tmp965, output
	add	r1, r3, #64	@ _411, tmp965,
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _412, i
	lsl	r3, r3, #1	@ tmp966, _412,
	add	r3, r1, r3	@ tmp967, _411, tmp966
	ldrsh	r3, [r3]	@ _413, (*_411)[_412]
	uxth	r3, r3	@ _414, _413
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	add	r3, r2, r3	@ tmp968, _410, _414
	uxth	r2, r3	@ _415, tmp968
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	ldr	r3, [fp, #-36]	@ tmp969, output
	add	r1, r3, #96	@ _416, tmp969,
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _417, i
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	sxth	r2, r2	@ _418, _415
@ dct_loeffler_asm.c:193: 		output[6][i] = output[3][i] + output[4][i];
	lsl	r3, r3, #1	@ tmp970, _417,
	add	r3, r1, r3	@ tmp971, _416, tmp970
	strh	r2, [r3]	@ movhi	@ _418, (*_416)[_417]
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	ldr	r3, [fp, #-36]	@ tmp972, output
	add	r2, r3, #48	@ _419, tmp972,
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _420, i
	lsl	r3, r3, #1	@ tmp973, _420,
	add	r3, r2, r3	@ tmp974, _419, tmp973
	ldrsh	r3, [r3]	@ _421, (*_419)[_420]
	uxth	r2, r3	@ _422, _421
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	ldr	r3, [fp, #-36]	@ tmp975, output
	add	r1, r3, #64	@ _423, tmp975,
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _424, i
	lsl	r3, r3, #1	@ tmp976, _424,
	add	r3, r1, r3	@ tmp977, _423, tmp976
	ldrsh	r3, [r3]	@ _425, (*_423)[_424]
	uxth	r3, r3	@ _426, _425
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	sub	r3, r2, r3	@ tmp978, _422, _426
	uxth	r2, r3	@ _427, tmp978
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	ldr	r3, [fp, #-36]	@ tmp979, output
	add	r1, r3, #112	@ _428, tmp979,
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _429, i
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	sxth	r2, r2	@ _430, _427
@ dct_loeffler_asm.c:194: 		output[7][i] = output[3][i] - output[4][i];
	lsl	r3, r3, #1	@ tmp980, _429,
	add	r3, r1, r3	@ tmp981, _428, tmp980
	strh	r2, [r3]	@ movhi	@ _430, (*_428)[_429]
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	ldr	r3, [fp, #-36]	@ tmp982, output
	add	r2, r3, #32	@ _431, tmp982,
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _432, i
	lsl	r3, r3, #1	@ tmp983, _432,
	add	r3, r2, r3	@ tmp984, _431, tmp983
	ldrsh	r3, [r3]	@ _433, (*_431)[_432]
	uxth	r2, r3	@ _434, _433
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	ldr	r3, [fp, #-36]	@ tmp985, output
	add	r1, r3, #80	@ _435, tmp985,
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _436, i
	lsl	r3, r3, #1	@ tmp986, _436,
	add	r3, r1, r3	@ tmp987, _435, tmp986
	ldrsh	r3, [r3]	@ _437, (*_435)[_436]
	uxth	r3, r3	@ _438, _437
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	sub	r3, r2, r3	@ tmp988, _434, _438
	uxth	r2, r3	@ _439, tmp988
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	ldr	r3, [fp, #-36]	@ tmp989, output
	add	r1, r3, #48	@ _440, tmp989,
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _441, i
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	sxth	r2, r2	@ _442, _439
@ dct_loeffler_asm.c:196: 		output[3][i] = output[2][i] - output[5][i];
	lsl	r3, r3, #1	@ tmp990, _441,
	add	r3, r1, r3	@ tmp991, _440, tmp990
	strh	r2, [r3]	@ movhi	@ _442, (*_440)[_441]
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	ldr	r3, [fp, #-36]	@ tmp992, output
	add	r2, r3, #32	@ _443, tmp992,
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _444, i
	lsl	r3, r3, #1	@ tmp993, _444,
	add	r3, r2, r3	@ tmp994, _443, tmp993
	ldrsh	r3, [r3]	@ _445, (*_443)[_444]
	uxth	r2, r3	@ _446, _445
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	ldr	r3, [fp, #-36]	@ tmp995, output
	add	r1, r3, #80	@ _447, tmp995,
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _448, i
	lsl	r3, r3, #1	@ tmp996, _448,
	add	r3, r1, r3	@ tmp997, _447, tmp996
	ldrsh	r3, [r3]	@ _449, (*_447)[_448]
	uxth	r3, r3	@ _450, _449
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	add	r3, r2, r3	@ tmp998, _446, _450
	uxth	r2, r3	@ _451, tmp998
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	ldr	r3, [fp, #-36]	@ tmp999, output
	add	r1, r3, #32	@ _452, tmp999,
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _453, i
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	sxth	r2, r2	@ _454, _451
@ dct_loeffler_asm.c:197: 		output[2][i] = output[2][i] + output[5][i];
	lsl	r3, r3, #1	@ tmp1000, _453,
	add	r3, r1, r3	@ tmp1001, _452, tmp1000
	strh	r2, [r3]	@ movhi	@ _454, (*_452)[_453]
@ dct_loeffler_asm.c:199: 		output[4][i] = tmp_1;
	ldr	r3, [fp, #-36]	@ tmp1002, output
	add	r2, r3, #64	@ _455, tmp1002,
@ dct_loeffler_asm.c:199: 		output[4][i] = tmp_1;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _456, i
@ dct_loeffler_asm.c:199: 		output[4][i] = tmp_1;
	lsl	r3, r3, #1	@ tmp1003, _456,
	add	r3, r2, r3	@ tmp1004, _455, tmp1003
	ldrh	r2, [fp, #-8]	@ movhi	@ tmp1005, tmp_1
	strh	r2, [r3]	@ movhi	@ tmp1005, (*_455)[_456]
@ dct_loeffler_asm.c:200: 		output[5][i] = tmp_2;
	ldr	r3, [fp, #-36]	@ tmp1006, output
	add	r2, r3, #80	@ _457, tmp1006,
@ dct_loeffler_asm.c:200: 		output[5][i] = tmp_2;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _458, i
@ dct_loeffler_asm.c:200: 		output[5][i] = tmp_2;
	lsl	r3, r3, #1	@ tmp1007, _458,
	add	r3, r2, r3	@ tmp1008, _457, tmp1007
	ldrh	r2, [fp, #-10]	@ movhi	@ tmp1009, tmp_2
	strh	r2, [r3]	@ movhi	@ tmp1009, (*_457)[_458]
@ dct_loeffler_asm.c:204: 		tmp_1 = output[0][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _459, i
@ dct_loeffler_asm.c:204: 		tmp_1 = output[0][i];
	ldr	r2, [fp, #-36]	@ tmp1010, output
	lsl	r3, r3, #1	@ tmp1011, _459,
	add	r3, r2, r3	@ tmp1012, tmp1010, tmp1011
	ldrh	r3, [r3]	@ movhi	@ tmp1013, (*output_707(D))[_459]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1013, tmp_1
@ dct_loeffler_asm.c:205: 		output[0][i] = tmp_1 + output[6][i];
	ldr	r3, [fp, #-36]	@ tmp1014, output
	add	r2, r3, #96	@ _460, tmp1014,
@ dct_loeffler_asm.c:205: 		output[0][i] = tmp_1 + output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _461, i
	lsl	r3, r3, #1	@ tmp1015, _461,
	add	r3, r2, r3	@ tmp1016, _460, tmp1015
	ldrsh	r3, [r3]	@ _462, (*_460)[_461]
	uxth	r2, r3	@ _463, _462
@ dct_loeffler_asm.c:205: 		output[0][i] = tmp_1 + output[6][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.16_464, tmp_1
	add	r3, r2, r3	@ tmp1017, _463, tmp_1.16_464
	uxth	r2, r3	@ _465, tmp1017
@ dct_loeffler_asm.c:205: 		output[0][i] = tmp_1 + output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _466, i
@ dct_loeffler_asm.c:205: 		output[0][i] = tmp_1 + output[6][i];
	sxth	r2, r2	@ _467, _465
@ dct_loeffler_asm.c:205: 		output[0][i] = tmp_1 + output[6][i];
	ldr	r1, [fp, #-36]	@ tmp1018, output
	lsl	r3, r3, #1	@ tmp1019, _466,
	add	r3, r1, r3	@ tmp1020, tmp1018, tmp1019
	strh	r2, [r3]	@ movhi	@ _467, (*output_707(D))[_466]
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.17_468, tmp_1
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	ldr	r3, [fp, #-36]	@ tmp1021, output
	add	r1, r3, #96	@ _469, tmp1021,
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _470, i
	lsl	r3, r3, #1	@ tmp1022, _470,
	add	r3, r1, r3	@ tmp1023, _469, tmp1022
	ldrsh	r3, [r3]	@ _471, (*_469)[_470]
	uxth	r3, r3	@ _472, _471
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	sub	r3, r2, r3	@ tmp1024, tmp_1.17_468, _472
	uxth	r2, r3	@ _473, tmp1024
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	ldr	r3, [fp, #-36]	@ tmp1025, output
	add	r1, r3, #96	@ _474, tmp1025,
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _475, i
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	sxth	r2, r2	@ _476, _473
@ dct_loeffler_asm.c:206: 		output[6][i] = tmp_1 - output[6][i];
	lsl	r3, r3, #1	@ tmp1026, _475,
	add	r3, r1, r3	@ tmp1027, _474, tmp1026
	strh	r2, [r3]	@ movhi	@ _476, (*_474)[_475]
@ dct_loeffler_asm.c:208: 		tmp_1 = output[4][i];
	ldr	r3, [fp, #-36]	@ tmp1028, output
	add	r2, r3, #64	@ _477, tmp1028,
@ dct_loeffler_asm.c:208: 		tmp_1 = output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _478, i
@ dct_loeffler_asm.c:208: 		tmp_1 = output[4][i];
	lsl	r3, r3, #1	@ tmp1029, _478,
	add	r3, r2, r3	@ tmp1030, _477, tmp1029
	ldrh	r3, [r3]	@ movhi	@ tmp1031, (*_477)[_478]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1031, tmp_1
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	ldr	r3, [fp, #-36]	@ tmp1032, output
	add	r2, r3, #32	@ _479, tmp1032,
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _480, i
	lsl	r3, r3, #1	@ tmp1033, _480,
	add	r3, r2, r3	@ tmp1034, _479, tmp1033
	ldrsh	r3, [r3]	@ _481, (*_479)[_480]
	uxth	r2, r3	@ _482, _481
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.18_483, tmp_1
	add	r3, r2, r3	@ tmp1035, _482, tmp_1.18_483
	uxth	r2, r3	@ _484, tmp1035
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	ldr	r3, [fp, #-36]	@ tmp1036, output
	add	r1, r3, #64	@ _485, tmp1036,
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _486, i
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	sxth	r2, r2	@ _487, _484
@ dct_loeffler_asm.c:209: 		output[4][i] = tmp_1 + output[2][i];
	lsl	r3, r3, #1	@ tmp1037, _486,
	add	r3, r1, r3	@ tmp1038, _485, tmp1037
	strh	r2, [r3]	@ movhi	@ _487, (*_485)[_486]
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.19_488, tmp_1
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	ldr	r3, [fp, #-36]	@ tmp1039, output
	add	r1, r3, #32	@ _489, tmp1039,
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _490, i
	lsl	r3, r3, #1	@ tmp1040, _490,
	add	r3, r1, r3	@ tmp1041, _489, tmp1040
	ldrsh	r3, [r3]	@ _491, (*_489)[_490]
	uxth	r3, r3	@ _492, _491
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	sub	r3, r2, r3	@ tmp1042, tmp_1.19_488, _492
	uxth	r2, r3	@ _493, tmp1042
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	ldr	r3, [fp, #-36]	@ tmp1043, output
	add	r1, r3, #32	@ _494, tmp1043,
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _495, i
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	sxth	r2, r2	@ _496, _493
@ dct_loeffler_asm.c:210: 		output[2][i] = tmp_1 - output[2][i];
	lsl	r3, r3, #1	@ tmp1044, _495,
	add	r3, r1, r3	@ tmp1045, _494, tmp1044
	strh	r2, [r3]	@ movhi	@ _496, (*_494)[_495]
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	ldr	r3, [fp, #-36]	@ tmp1046, output
	add	r2, r3, #112	@ _497, tmp1046,
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _498, i
	lsl	r3, r3, #1	@ tmp1047, _498,
	add	r3, r2, r3	@ tmp1048, _497, tmp1047
	ldrsh	r3, [r3]	@ _499, (*_497)[_498]
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	uxth	r3, r3	@ _500, _499
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	lsl	r3, r3, #16	@ _502, _501,
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	ldr	r2, [fp, #-36]	@ tmp1049, output
	add	r1, r2, #16	@ _503, tmp1049,
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _504, i
	lsl	r2, r2, #1	@ tmp1050, _504,
	add	r2, r1, r2	@ tmp1051, _503, tmp1050
	ldrsh	r2, [r2]	@ _505, (*_503)[_504]
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	uxth	r2, r2	@ _506, _505
@ dct_loeffler_asm.c:215:         uint32_t Rs = ((uint32_t)(uint16_t)output[7][i] << 16) | (uint16_t)output[1][i];
	orr	r3, r3, r2	@ tmp1052, _502, _507
	str	r3, [fp, #-16]	@ tmp1052, Rs
@ dct_loeffler_asm.c:216:         uint32_t Rt = butterfly_fw(Rs, 3); // Call butterfly function C3
	ldr	r3, [fp, #-16]	@ Rs.20_508, Rs
	mov	r1, #3	@,
	mov	r0, r3	@, Rs.20_508
	bl	butterfly_fw(PLT)	@
	mov	r3, r0	@ _509,
@ dct_loeffler_asm.c:216:         uint32_t Rt = butterfly_fw(Rs, 3); // Call butterfly function C3
	str	r3, [fp, #-20]	@ _509, Rt
@ dct_loeffler_asm.c:218:         output[7][i] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-20]	@ tmp1053, Rt
	lsr	r2, r3, #16	@ _510, tmp1053,
@ dct_loeffler_asm.c:218:         output[7][i] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-36]	@ tmp1054, output
	add	r1, r3, #112	@ _511, tmp1054,
@ dct_loeffler_asm.c:218:         output[7][i] = (int16_t)(Rt >> 16);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _512, i
@ dct_loeffler_asm.c:218:         output[7][i] = (int16_t)(Rt >> 16);
	sxth	r2, r2	@ _513, _510
@ dct_loeffler_asm.c:218:         output[7][i] = (int16_t)(Rt >> 16);
	lsl	r3, r3, #1	@ tmp1055, _512,
	add	r3, r1, r3	@ tmp1056, _511, tmp1055
	strh	r2, [r3]	@ movhi	@ _513, (*_511)[_512]
@ dct_loeffler_asm.c:219:         output[1][i] = (int16_t)(Rt & 0xFFFF);
	ldr	r3, [fp, #-36]	@ tmp1057, output
	add	r1, r3, #16	@ _514, tmp1057,
@ dct_loeffler_asm.c:219:         output[1][i] = (int16_t)(Rt & 0xFFFF);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _515, i
@ dct_loeffler_asm.c:219:         output[1][i] = (int16_t)(Rt & 0xFFFF);
	ldr	r2, [fp, #-20]	@ tmp1058, Rt
	sxth	r2, r2	@ _516, tmp1058
@ dct_loeffler_asm.c:219:         output[1][i] = (int16_t)(Rt & 0xFFFF);
	lsl	r3, r3, #1	@ tmp1059, _515,
	add	r3, r1, r3	@ tmp1060, _514, tmp1059
	strh	r2, [r3]	@ movhi	@ _516, (*_514)[_515]
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	ldr	r3, [fp, #-36]	@ tmp1061, output
	add	r2, r3, #48	@ _517, tmp1061,
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _518, i
	lsl	r3, r3, #1	@ tmp1062, _518,
	add	r3, r2, r3	@ tmp1063, _517, tmp1062
	ldrsh	r3, [r3]	@ _519, (*_517)[_518]
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	uxth	r3, r3	@ _520, _519
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	lsl	r3, r3, #16	@ _522, _521,
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	ldr	r2, [fp, #-36]	@ tmp1064, output
	add	r1, r2, #80	@ _523, tmp1064,
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _524, i
	lsl	r2, r2, #1	@ tmp1065, _524,
	add	r2, r1, r2	@ tmp1066, _523, tmp1065
	ldrsh	r2, [r2]	@ _525, (*_523)[_524]
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	uxth	r2, r2	@ _526, _525
@ dct_loeffler_asm.c:222:         Rs = ((uint32_t)(uint16_t)output[3][i] << 16) | (uint16_t)output[5][i];
	orr	r3, r3, r2	@ tmp1067, _522, _527
	str	r3, [fp, #-16]	@ tmp1067, Rs
@ dct_loeffler_asm.c:223:         Rt = butterfly_fw(Rs, 1); // Call butterfly function C1
	ldr	r3, [fp, #-16]	@ Rs.21_528, Rs
	mov	r1, #1	@,
	mov	r0, r3	@, Rs.21_528
	bl	butterfly_fw(PLT)	@
	mov	r3, r0	@ _529,
@ dct_loeffler_asm.c:223:         Rt = butterfly_fw(Rs, 1); // Call butterfly function C1
	str	r3, [fp, #-20]	@ _529, Rt
@ dct_loeffler_asm.c:225:         output[3][i] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-20]	@ tmp1068, Rt
	lsr	r2, r3, #16	@ _530, tmp1068,
@ dct_loeffler_asm.c:225:         output[3][i] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-36]	@ tmp1069, output
	add	r1, r3, #48	@ _531, tmp1069,
@ dct_loeffler_asm.c:225:         output[3][i] = (int16_t)(Rt >> 16);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _532, i
@ dct_loeffler_asm.c:225:         output[3][i] = (int16_t)(Rt >> 16);
	sxth	r2, r2	@ _533, _530
@ dct_loeffler_asm.c:225:         output[3][i] = (int16_t)(Rt >> 16);
	lsl	r3, r3, #1	@ tmp1070, _532,
	add	r3, r1, r3	@ tmp1071, _531, tmp1070
	strh	r2, [r3]	@ movhi	@ _533, (*_531)[_532]
@ dct_loeffler_asm.c:226:         output[5][i] = (int16_t)(Rt & 0xFFFF);
	ldr	r3, [fp, #-36]	@ tmp1072, output
	add	r1, r3, #80	@ _534, tmp1072,
@ dct_loeffler_asm.c:226:         output[5][i] = (int16_t)(Rt & 0xFFFF);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _535, i
@ dct_loeffler_asm.c:226:         output[5][i] = (int16_t)(Rt & 0xFFFF);
	ldr	r2, [fp, #-20]	@ tmp1073, Rt
	sxth	r2, r2	@ _536, tmp1073
@ dct_loeffler_asm.c:226:         output[5][i] = (int16_t)(Rt & 0xFFFF);
	lsl	r3, r3, #1	@ tmp1074, _535,
	add	r3, r1, r3	@ tmp1075, _534, tmp1074
	strh	r2, [r3]	@ movhi	@ _536, (*_534)[_535]
@ dct_loeffler_asm.c:230: 		tmp_1 = output[0][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _537, i
@ dct_loeffler_asm.c:230: 		tmp_1 = output[0][i];
	ldr	r2, [fp, #-36]	@ tmp1076, output
	lsl	r3, r3, #1	@ tmp1077, _537,
	add	r3, r2, r3	@ tmp1078, tmp1076, tmp1077
	ldrh	r3, [r3]	@ movhi	@ tmp1079, (*output_707(D))[_537]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1079, tmp_1
@ dct_loeffler_asm.c:231: 		output[0][i] = tmp_1 + output[4][i];
	ldr	r3, [fp, #-36]	@ tmp1080, output
	add	r2, r3, #64	@ _538, tmp1080,
@ dct_loeffler_asm.c:231: 		output[0][i] = tmp_1 + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _539, i
	lsl	r3, r3, #1	@ tmp1081, _539,
	add	r3, r2, r3	@ tmp1082, _538, tmp1081
	ldrsh	r3, [r3]	@ _540, (*_538)[_539]
	uxth	r2, r3	@ _541, _540
@ dct_loeffler_asm.c:231: 		output[0][i] = tmp_1 + output[4][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.22_542, tmp_1
	add	r3, r2, r3	@ tmp1083, _541, tmp_1.22_542
	uxth	r2, r3	@ _543, tmp1083
@ dct_loeffler_asm.c:231: 		output[0][i] = tmp_1 + output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _544, i
@ dct_loeffler_asm.c:231: 		output[0][i] = tmp_1 + output[4][i];
	sxth	r2, r2	@ _545, _543
@ dct_loeffler_asm.c:231: 		output[0][i] = tmp_1 + output[4][i];
	ldr	r1, [fp, #-36]	@ tmp1084, output
	lsl	r3, r3, #1	@ tmp1085, _544,
	add	r3, r1, r3	@ tmp1086, tmp1084, tmp1085
	strh	r2, [r3]	@ movhi	@ _545, (*output_707(D))[_544]
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.23_546, tmp_1
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	ldr	r3, [fp, #-36]	@ tmp1087, output
	add	r1, r3, #64	@ _547, tmp1087,
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _548, i
	lsl	r3, r3, #1	@ tmp1088, _548,
	add	r3, r1, r3	@ tmp1089, _547, tmp1088
	ldrsh	r3, [r3]	@ _549, (*_547)[_548]
	uxth	r3, r3	@ _550, _549
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	sub	r3, r2, r3	@ tmp1090, tmp_1.23_546, _550
	uxth	r2, r3	@ _551, tmp1090
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	ldr	r3, [fp, #-36]	@ tmp1091, output
	add	r1, r3, #64	@ _552, tmp1091,
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _553, i
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	sxth	r2, r2	@ _554, _551
@ dct_loeffler_asm.c:232: 		output[4][i] = tmp_1 - output[4][i];
	lsl	r3, r3, #1	@ tmp1092, _553,
	add	r3, r1, r3	@ tmp1093, _552, tmp1092
	strh	r2, [r3]	@ movhi	@ _554, (*_552)[_553]
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	ldr	r3, [fp, #-36]	@ tmp1094, output
	add	r2, r3, #32	@ _555, tmp1094,
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _556, i
	lsl	r3, r3, #1	@ tmp1095, _556,
	add	r3, r2, r3	@ tmp1096, _555, tmp1095
	ldrsh	r3, [r3]	@ _557, (*_555)[_556]
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	uxth	r3, r3	@ _558, _557
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	lsl	r3, r3, #16	@ _560, _559,
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	ldr	r2, [fp, #-36]	@ tmp1097, output
	add	r1, r2, #96	@ _561, tmp1097,
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _562, i
	lsl	r2, r2, #1	@ tmp1098, _562,
	add	r2, r1, r2	@ tmp1099, _561, tmp1098
	ldrsh	r2, [r2]	@ _563, (*_561)[_562]
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	uxth	r2, r2	@ _564, _563
@ dct_loeffler_asm.c:235:         Rs = ((uint32_t)(uint16_t)output[2][i] << 16) | (uint16_t)output[6][i];
	orr	r3, r3, r2	@ tmp1100, _560, _565
	str	r3, [fp, #-16]	@ tmp1100, Rs
@ dct_loeffler_asm.c:236:         Rt = butterfly_fw(Rs, 2); // Call butterfly function sqrt(2) * C6
	ldr	r3, [fp, #-16]	@ Rs.24_566, Rs
	mov	r1, #2	@,
	mov	r0, r3	@, Rs.24_566
	bl	butterfly_fw(PLT)	@
	mov	r3, r0	@ _567,
@ dct_loeffler_asm.c:236:         Rt = butterfly_fw(Rs, 2); // Call butterfly function sqrt(2) * C6
	str	r3, [fp, #-20]	@ _567, Rt
@ dct_loeffler_asm.c:238:         output[2][i] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-20]	@ tmp1101, Rt
	lsr	r2, r3, #16	@ _568, tmp1101,
@ dct_loeffler_asm.c:238:         output[2][i] = (int16_t)(Rt >> 16);
	ldr	r3, [fp, #-36]	@ tmp1102, output
	add	r1, r3, #32	@ _569, tmp1102,
@ dct_loeffler_asm.c:238:         output[2][i] = (int16_t)(Rt >> 16);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _570, i
@ dct_loeffler_asm.c:238:         output[2][i] = (int16_t)(Rt >> 16);
	sxth	r2, r2	@ _571, _568
@ dct_loeffler_asm.c:238:         output[2][i] = (int16_t)(Rt >> 16);
	lsl	r3, r3, #1	@ tmp1103, _570,
	add	r3, r1, r3	@ tmp1104, _569, tmp1103
	strh	r2, [r3]	@ movhi	@ _571, (*_569)[_570]
@ dct_loeffler_asm.c:239:         output[6][i] = (int16_t)(Rt & 0xFFFF);
	ldr	r3, [fp, #-36]	@ tmp1105, output
	add	r1, r3, #96	@ _572, tmp1105,
@ dct_loeffler_asm.c:239:         output[6][i] = (int16_t)(Rt & 0xFFFF);
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _573, i
@ dct_loeffler_asm.c:239:         output[6][i] = (int16_t)(Rt & 0xFFFF);
	ldr	r2, [fp, #-20]	@ tmp1106, Rt
	sxth	r2, r2	@ _574, tmp1106
@ dct_loeffler_asm.c:239:         output[6][i] = (int16_t)(Rt & 0xFFFF);
	lsl	r3, r3, #1	@ tmp1107, _573,
	add	r3, r1, r3	@ tmp1108, _572, tmp1107
	strh	r2, [r3]	@ movhi	@ _574, (*_572)[_573]
@ dct_loeffler_asm.c:242: 		tmp_1 = output[7][i];
	ldr	r3, [fp, #-36]	@ tmp1109, output
	add	r2, r3, #112	@ _575, tmp1109,
@ dct_loeffler_asm.c:242: 		tmp_1 = output[7][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _576, i
@ dct_loeffler_asm.c:242: 		tmp_1 = output[7][i];
	lsl	r3, r3, #1	@ tmp1110, _576,
	add	r3, r2, r3	@ tmp1111, _575, tmp1110
	ldrh	r3, [r3]	@ movhi	@ tmp1112, (*_575)[_576]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1112, tmp_1
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	ldr	r3, [fp, #-36]	@ tmp1113, output
	add	r2, r3, #80	@ _577, tmp1113,
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _578, i
	lsl	r3, r3, #1	@ tmp1114, _578,
	add	r3, r2, r3	@ tmp1115, _577, tmp1114
	ldrsh	r3, [r3]	@ _579, (*_577)[_578]
	uxth	r2, r3	@ _580, _579
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.25_581, tmp_1
	add	r3, r2, r3	@ tmp1116, _580, tmp_1.25_581
	uxth	r2, r3	@ _582, tmp1116
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	ldr	r3, [fp, #-36]	@ tmp1117, output
	add	r1, r3, #112	@ _583, tmp1117,
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _584, i
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	sxth	r2, r2	@ _585, _582
@ dct_loeffler_asm.c:243: 		output[7][i] = tmp_1 + output[5][i];
	lsl	r3, r3, #1	@ tmp1118, _584,
	add	r3, r1, r3	@ tmp1119, _583, tmp1118
	strh	r2, [r3]	@ movhi	@ _585, (*_583)[_584]
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.26_586, tmp_1
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	ldr	r3, [fp, #-36]	@ tmp1120, output
	add	r1, r3, #80	@ _587, tmp1120,
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _588, i
	lsl	r3, r3, #1	@ tmp1121, _588,
	add	r3, r1, r3	@ tmp1122, _587, tmp1121
	ldrsh	r3, [r3]	@ _589, (*_587)[_588]
	uxth	r3, r3	@ _590, _589
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	sub	r3, r2, r3	@ tmp1123, tmp_1.26_586, _590
	uxth	r2, r3	@ _591, tmp1123
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	ldr	r3, [fp, #-36]	@ tmp1124, output
	add	r1, r3, #80	@ _592, tmp1124,
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _593, i
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	sxth	r2, r2	@ _594, _591
@ dct_loeffler_asm.c:244: 		output[5][i] = tmp_1 - output[5][i];
	lsl	r3, r3, #1	@ tmp1125, _593,
	add	r3, r1, r3	@ tmp1126, _592, tmp1125
	strh	r2, [r3]	@ movhi	@ _594, (*_592)[_593]
@ dct_loeffler_asm.c:246: 		tmp_1 = output[1][i];
	ldr	r3, [fp, #-36]	@ tmp1127, output
	add	r2, r3, #16	@ _595, tmp1127,
@ dct_loeffler_asm.c:246: 		tmp_1 = output[1][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _596, i
@ dct_loeffler_asm.c:246: 		tmp_1 = output[1][i];
	lsl	r3, r3, #1	@ tmp1128, _596,
	add	r3, r2, r3	@ tmp1129, _595, tmp1128
	ldrh	r3, [r3]	@ movhi	@ tmp1130, (*_595)[_596]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1130, tmp_1
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	ldr	r3, [fp, #-36]	@ tmp1131, output
	add	r2, r3, #48	@ _597, tmp1131,
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _598, i
	lsl	r3, r3, #1	@ tmp1132, _598,
	add	r3, r2, r3	@ tmp1133, _597, tmp1132
	ldrsh	r3, [r3]	@ _599, (*_597)[_598]
	uxth	r2, r3	@ _600, _599
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	ldrh	r3, [fp, #-8]	@ tmp_1.27_601, tmp_1
	add	r3, r2, r3	@ tmp1134, _600, tmp_1.27_601
	uxth	r2, r3	@ _602, tmp1134
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	ldr	r3, [fp, #-36]	@ tmp1135, output
	add	r1, r3, #16	@ _603, tmp1135,
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _604, i
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	sxth	r2, r2	@ _605, _602
@ dct_loeffler_asm.c:248: 		output[1][i] = tmp_1 + output[3][i];
	lsl	r3, r3, #1	@ tmp1136, _604,
	add	r3, r1, r3	@ tmp1137, _603, tmp1136
	strh	r2, [r3]	@ movhi	@ _605, (*_603)[_604]
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	ldrh	r2, [fp, #-8]	@ tmp_1.28_606, tmp_1
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	ldr	r3, [fp, #-36]	@ tmp1138, output
	add	r1, r3, #48	@ _607, tmp1138,
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _608, i
	lsl	r3, r3, #1	@ tmp1139, _608,
	add	r3, r1, r3	@ tmp1140, _607, tmp1139
	ldrsh	r3, [r3]	@ _609, (*_607)[_608]
	uxth	r3, r3	@ _610, _609
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	sub	r3, r2, r3	@ tmp1141, tmp_1.28_606, _610
	uxth	r2, r3	@ _611, tmp1141
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	ldr	r3, [fp, #-36]	@ tmp1142, output
	add	r1, r3, #48	@ _612, tmp1142,
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _613, i
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	sxth	r2, r2	@ _614, _611
@ dct_loeffler_asm.c:249: 		output[3][i] = tmp_1 - output[3][i];
	lsl	r3, r3, #1	@ tmp1143, _613,
	add	r3, r1, r3	@ tmp1144, _612, tmp1143
	strh	r2, [r3]	@ movhi	@ _614, (*_612)[_613]
@ dct_loeffler_asm.c:255: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _615, i
	ldr	r2, [fp, #-36]	@ tmp1145, output
	lsl	r3, r3, #1	@ tmp1146, _615,
	add	r3, r2, r3	@ tmp1147, tmp1145, tmp1146
	ldrsh	r3, [r3]	@ _616, (*output_707(D))[_615]
@ dct_loeffler_asm.c:255: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _618, _617,
@ dct_loeffler_asm.c:255: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _619, _618,
@ dct_loeffler_asm.c:255: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _620, i
@ dct_loeffler_asm.c:255: 		output[0][i] = (output[0][i] + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _621, _619
	ldr	r1, [fp, #-36]	@ tmp1148, output
	lsl	r3, r3, #1	@ tmp1149, _620,
	add	r3, r1, r3	@ tmp1150, tmp1148, tmp1149
	strh	r2, [r3]	@ movhi	@ _621, (*output_707(D))[_620]
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1151, output
	add	r2, r3, #64	@ _622, tmp1151,
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _623, i
	lsl	r3, r3, #1	@ tmp1152, _623,
	add	r3, r2, r3	@ tmp1153, _622, tmp1152
	ldrsh	r3, [r3]	@ _624, (*_622)[_623]
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _626, _625,
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _627, _626,
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1154, output
	add	r1, r3, #64	@ _628, tmp1154,
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _629, i
@ dct_loeffler_asm.c:256: 		output[4][i] = (output[4][i] + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _630, _627
	lsl	r3, r3, #1	@ tmp1155, _629,
	add	r3, r1, r3	@ tmp1156, _628, tmp1155
	strh	r2, [r3]	@ movhi	@ _630, (*_628)[_629]
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1157, output
	add	r2, r3, #32	@ _631, tmp1157,
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _632, i
	lsl	r3, r3, #1	@ tmp1158, _632,
	add	r3, r2, r3	@ tmp1159, _631, tmp1158
	ldrsh	r3, [r3]	@ _633, (*_631)[_632]
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _635, _634,
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _636, _635,
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1160, output
	add	r1, r3, #32	@ _637, tmp1160,
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _638, i
@ dct_loeffler_asm.c:257: 		output[2][i] = (output[2][i] + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _639, _636
	lsl	r3, r3, #1	@ tmp1161, _638,
	add	r3, r1, r3	@ tmp1162, _637, tmp1161
	strh	r2, [r3]	@ movhi	@ _639, (*_637)[_638]
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1163, output
	add	r2, r3, #96	@ _640, tmp1163,
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _641, i
	lsl	r3, r3, #1	@ tmp1164, _641,
	add	r3, r2, r3	@ tmp1165, _640, tmp1164
	ldrsh	r3, [r3]	@ _642, (*_640)[_641]
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _644, _643,
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _645, _644,
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1166, output
	add	r1, r3, #96	@ _646, tmp1166,
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _647, i
@ dct_loeffler_asm.c:258: 		output[6][i] = (output[6][i] + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _648, _645
	lsl	r3, r3, #1	@ tmp1167, _647,
	add	r3, r1, r3	@ tmp1168, _646, tmp1167
	strh	r2, [r3]	@ movhi	@ _648, (*_646)[_647]
@ dct_loeffler_asm.c:262: 		tmp_1 = output[1][i];
	ldr	r3, [fp, #-36]	@ tmp1169, output
	add	r2, r3, #16	@ _649, tmp1169,
@ dct_loeffler_asm.c:262: 		tmp_1 = output[1][i];
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _650, i
@ dct_loeffler_asm.c:262: 		tmp_1 = output[1][i];
	lsl	r3, r3, #1	@ tmp1170, _650,
	add	r3, r2, r3	@ tmp1171, _649, tmp1170
	ldrh	r3, [r3]	@ movhi	@ tmp1172, (*_649)[_650]
	strh	r3, [fp, #-8]	@ movhi	@ tmp1172, tmp_1
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _651, tmp_1
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r2, [fp, #-36]	@ tmp1173, output
	add	r1, r2, #112	@ _652, tmp1173,
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _653, i
	lsl	r2, r2, #1	@ tmp1174, _653,
	add	r2, r1, r2	@ tmp1175, _652, tmp1174
	ldrsh	r2, [r2]	@ _654, (*_652)[_653]
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, r2	@ _656, _651, _655
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _657, _656,
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _658, _657,
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1176, output
	add	r1, r3, #16	@ _659, tmp1176,
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _660, i
@ dct_loeffler_asm.c:263: 		output[1][i] = ((tmp_1 + output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _661, _658
	lsl	r3, r3, #1	@ tmp1177, _660,
	add	r3, r1, r3	@ tmp1178, _659, tmp1177
	strh	r2, [r3]	@ movhi	@ _661, (*_659)[_660]
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _662, tmp_1
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r2, [fp, #-36]	@ tmp1179, output
	add	r1, r2, #112	@ _663, tmp1179,
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2	@ _664, i
	lsl	r2, r2, #1	@ tmp1180, _664,
	add	r2, r1, r2	@ tmp1181, _663, tmp1180
	ldrsh	r2, [r2]	@ _665, (*_663)[_664]
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	sub	r3, r3, r2	@ _667, _662, _666
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	add	r3, r3, #4	@ _668, _667,
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _669, _668,
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1182, output
	add	r1, r3, #112	@ _670, tmp1182,
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _671, i
@ dct_loeffler_asm.c:264: 		output[7][i] = ((tmp_1 - output[7][i]) + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _672, _669
	lsl	r3, r3, #1	@ tmp1183, _671,
	add	r3, r1, r3	@ tmp1184, _670, tmp1183
	strh	r2, [r3]	@ movhi	@ _672, (*_670)[_671]
@ dct_loeffler_asm.c:266: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldr	r3, [fp, #-36]	@ tmp1185, output
	add	r2, r3, #48	@ _673, tmp1185,
@ dct_loeffler_asm.c:266: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _674, i
	lsl	r3, r3, #1	@ tmp1186, _674,
	add	r3, r2, r3	@ tmp1187, _673, tmp1186
	ldrsh	r3, [r3]	@ _675, (*_673)[_674]
	mov	r2, r3	@ _676, _675
@ dct_loeffler_asm.c:266: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	movw	r3, #1448	@ tmp1188,
	mul	r3, r3, r2	@ _677, tmp1188, _676
@ dct_loeffler_asm.c:266: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _678, _677,
@ dct_loeffler_asm.c:266: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r3, r3, #10	@ _679, _678,
@ dct_loeffler_asm.c:266: 		tmp_1 = ((output[3][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	strh	r3, [fp, #-8]	@ movhi	@ _679, tmp_1
@ dct_loeffler_asm.c:267: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _680, tmp_1
	add	r3, r3, #4	@ _681, _680,
@ dct_loeffler_asm.c:267: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _682, _681,
@ dct_loeffler_asm.c:267: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1189, output
	add	r1, r3, #48	@ _683, tmp1189,
@ dct_loeffler_asm.c:267: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _684, i
@ dct_loeffler_asm.c:267: 		output[3][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _685, _682
	lsl	r3, r3, #1	@ tmp1190, _684,
	add	r3, r1, r3	@ tmp1191, _683, tmp1190
	strh	r2, [r3]	@ movhi	@ _685, (*_683)[_684]
@ dct_loeffler_asm.c:269: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldr	r3, [fp, #-36]	@ tmp1192, output
	add	r2, r3, #80	@ _686, tmp1192,
@ dct_loeffler_asm.c:269: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _687, i
	lsl	r3, r3, #1	@ tmp1193, _687,
	add	r3, r2, r3	@ tmp1194, _686, tmp1193
	ldrsh	r3, [r3]	@ _688, (*_686)[_687]
	mov	r2, r3	@ _689, _688
@ dct_loeffler_asm.c:269: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	movw	r3, #1448	@ tmp1195,
	mul	r3, r3, r2	@ _690, tmp1195, _689
@ dct_loeffler_asm.c:269: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	add	r3, r3, #512	@ _691, _690,
@ dct_loeffler_asm.c:269: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	asr	r3, r3, #10	@ _692, _691,
@ dct_loeffler_asm.c:269: 		tmp_1 = ((output[5][i] * sqrt2) + dct_fp_rounding) >> dct_fp_precision;
	strh	r3, [fp, #-8]	@ movhi	@ _692, tmp_1
@ dct_loeffler_asm.c:270: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrsh	r3, [fp, #-8]	@ _693, tmp_1
	add	r3, r3, #4	@ _694, _693,
@ dct_loeffler_asm.c:270: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	asr	r2, r3, #3	@ _695, _694,
@ dct_loeffler_asm.c:270: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldr	r3, [fp, #-36]	@ tmp1196, output
	add	r1, r3, #80	@ _696, tmp1196,
@ dct_loeffler_asm.c:270: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ _697, i
@ dct_loeffler_asm.c:270: 		output[5][i] = (tmp_1 + dct_gain_rounding) >> dct_gain_scale;
	sxth	r2, r2	@ _698, _695
	lsl	r3, r3, #1	@ tmp1197, _697,
	add	r3, r1, r3	@ tmp1198, _696, tmp1197
	strh	r2, [r3]	@ movhi	@ _698, (*_696)[_697]
@ dct_loeffler_asm.c:182: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ i.29_699, i
	add	r3, r3, #1	@ tmp1199, i.29_699,
	strb	r3, [fp, #-5]	@ tmp1200, i
.L8:
@ dct_loeffler_asm.c:182: 	for (i = 0; i < N; i++)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2	@ tmp1203, i
	cmp	r3, #7	@ tmp1203,
	bls	.L9		@,
@ dct_loeffler_asm.c:272: }
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
@ dct_loeffler_asm.c:277: 	uint8_t input[N][N] = {
	ldr	r3, .L16	@ tmp117,
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
@ dct_loeffler_asm.c:287: 	int16_t output[N][N] = {0};
	sub	r3, fp, #204	@ tmp120,,
	mov	r2, #128	@ tmp121,
	mov	r1, #0	@,
	mov	r0, r3	@, tmp120
	bl	memset(PLT)	@
@ dct_loeffler_asm.c:289: 	dct_2d_loeffler(input, output);
	sub	r2, fp, #204	@ tmp123,,
	sub	r3, fp, #76	@ tmp124,,
	mov	r1, r2	@, tmp123
	mov	r0, r3	@, tmp124
	bl	dct_2d_loeffler(PLT)	@
@ dct_loeffler_asm.c:291: 	printf("DCT Coefficients:\n");
	ldr	r3, .L16+4	@ tmp125,
.LPIC2:
	add	r3, pc, r3	@ tmp125, tmp125
	mov	r0, r3	@, tmp125
	bl	puts(PLT)	@
@ dct_loeffler_asm.c:292: 	for(int x = 0; x < N; x++)
	mov	r3, #0	@ tmp126,
	str	r3, [fp, #-8]	@ tmp126, x
@ dct_loeffler_asm.c:292: 	for(int x = 0; x < N; x++)
	b	.L11		@
.L14:
@ dct_loeffler_asm.c:294: 		for(int y = 0; y < N; y++)
	mov	r3, #0	@ tmp127,
	str	r3, [fp, #-12]	@ tmp127, y
@ dct_loeffler_asm.c:294: 		for(int y = 0; y < N; y++)
	b	.L12		@
.L13:
@ dct_loeffler_asm.c:296: 			printf("%6d", output[x][y]);
	ldr	r3, [fp, #-8]	@ tmp128, x
	lsl	r2, r3, #3	@ tmp129, tmp128,
	ldr	r3, [fp, #-12]	@ tmp131, y
	add	r3, r2, r3	@ tmp130, tmp129, tmp131
	lsl	r3, r3, #1	@ tmp132, tmp130,
	sub	r3, r3, #4	@ tmp144, tmp132,
	add	r3, r3, fp	@ tmp133, tmp144,
	sub	r3, r3, #200	@ tmp134, tmp133,
	ldrsh	r3, [r3]	@ _1, output[x_3][y_4]
@ dct_loeffler_asm.c:296: 			printf("%6d", output[x][y]);
	mov	r1, r3	@, _2
	ldr	r3, .L16+8	@ tmp135,
.LPIC3:
	add	r3, pc, r3	@ tmp135, tmp135
	mov	r0, r3	@, tmp135
	bl	printf(PLT)	@
@ dct_loeffler_asm.c:294: 		for(int y = 0; y < N; y++)
	ldr	r3, [fp, #-12]	@ tmp137, y
	add	r3, r3, #1	@ tmp136, tmp137,
	str	r3, [fp, #-12]	@ tmp136, y
.L12:
@ dct_loeffler_asm.c:294: 		for(int y = 0; y < N; y++)
	ldr	r3, [fp, #-12]	@ tmp138, y
	cmp	r3, #7	@ tmp138,
	ble	.L13		@,
@ dct_loeffler_asm.c:298: 		printf("\n");
	mov	r0, #10	@,
	bl	putchar(PLT)	@
@ dct_loeffler_asm.c:292: 	for(int x = 0; x < N; x++)
	ldr	r3, [fp, #-8]	@ tmp140, x
	add	r3, r3, #1	@ tmp139, tmp140,
	str	r3, [fp, #-8]	@ tmp139, x
.L11:
@ dct_loeffler_asm.c:292: 	for(int x = 0; x < N; x++)
	ldr	r3, [fp, #-8]	@ tmp141, x
	cmp	r3, #7	@ tmp141,
	ble	.L14		@,
@ dct_loeffler_asm.c:301:  	return 0;
	mov	r3, #0	@ _13,
@ dct_loeffler_asm.c:302: }
	mov	r0, r3	@, <retval>
	sub	sp, fp, #4	@,,
	@ sp needed	@
	pop	{fp, pc}	@
.L17:
	.align	2
.L16:
	.word	.LC0-(.LPIC1+8)
	.word	.LC1-(.LPIC2+8)
	.word	.LC2-(.LPIC3+8)
	.size	main, .-main
	.ident	"GCC: (GNU) 11.2.1 20211120"
	.section	.note.GNU-stack,"",%progbits

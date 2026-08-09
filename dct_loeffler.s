	.cpu arm10e
	.arch armv5te
	.fpu vfp
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"dct_loeffler.c"
	.text
	.section	.rodata
	.align	2
	.type	rotator_table, %object
	.size	rotator_table, 24
rotator_table:
	.space	6
	.short	1004
	.short	-805
	.short	-1204
	.short	554
	.short	784
	.short	-1892
	.short	851
	.short	-283
	.short	-1420
	.text
	.align	2
	.syntax unified
	.arm
	.type	butterfly_fp, %function
butterfly_fp:
	@ args = 4, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #40
	str	r2, [fp, #-36]
	str	r3, [fp, #-40]
	mov	r3, r0	@ movhi
	strh	r3, [fp, #-30]	@ movhi
	mov	r3, r1	@ movhi
	strh	r3, [fp, #-32]	@ movhi
	ldrb	r2, [fp, #4]	@ zero_extendqisi2
	ldr	r1, .L2
.LPIC0:
	add	r1, pc, r1
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r2, r1, r3
	sub	r3, fp, #24
	mov	r1, r2
	mov	r2, #6
	mov	r0, r3
	bl	memcpy(PLT)
	ldrsh	r3, [fp, #-24]
	mov	r1, r3
	ldrsh	r2, [fp, #-30]
	ldrsh	r3, [fp, #-32]
	add	r3, r2, r3
	mul	r3, r1, r3
	str	r3, [fp, #-8]
	ldrsh	r3, [fp, #-32]
	ldrsh	r2, [fp, #-22]
	mul	r3, r2, r3
	ldr	r2, [fp, #-8]
	add	r3, r2, r3
	str	r3, [fp, #-12]
	ldrsh	r3, [fp, #-30]
	ldrsh	r2, [fp, #-20]
	mul	r3, r2, r3
	ldr	r2, [fp, #-8]
	add	r3, r2, r3
	str	r3, [fp, #-16]
	ldr	r3, [fp, #-12]
	add	r3, r3, #512
	asr	r3, r3, #10
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [fp, #-36]
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-16]
	add	r3, r3, #512
	asr	r3, r3, #10
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [fp, #-40]
	strh	r2, [r3]	@ movhi
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
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
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r3, #0
	strb	r3, [fp, #-5]
	b	.L5
.L6:
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #7]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #6]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #5]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #4]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3, #3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #4]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #12]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3, #3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #4]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #14]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #5]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #6]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #6]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #10]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #3
	ldr	r1, [fp, #-16]
	add	r3, r1, r3
	ldrb	r3, [r3, #7]	@ zero_extendqisi2
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #2]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #12]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	ldrsh	r3, [r3, #12]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #12]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrh	r3, [r3, #8]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #4]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #8]	@ movhi
	ldrh	r2, [fp, #-8]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	ldrsh	r3, [r3, #4]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #4]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r0, [r3, #14]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r1, [r3, #2]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	add	ip, r3, #14
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	add	r3, r3, #2
	mov	r2, #3
	str	r2, [sp]
	mov	r2, ip
	bl	butterfly_fp(PLT)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r0, [r3, #6]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r1, [r3, #10]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	add	ip, r3, #6
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	add	r3, r3, #10
	mov	r2, #1
	str	r2, [sp]
	mov	r2, ip
	bl	butterfly_fp(PLT)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #8]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	ldrsh	r3, [r3, #8]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r0, [r3, #4]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r1, [r3, #12]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	add	ip, r3, #4
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	add	r3, r3, #12
	mov	r2, #2
	str	r2, [sp]
	mov	r2, ip
	bl	butterfly_fp(PLT)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrh	r3, [r3, #14]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #10]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #14]	@ movhi
	ldrh	r2, [fp, #-8]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	ldrsh	r3, [r3, #10]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #10]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrh	r3, [r3, #2]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #6]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #2]	@ movhi
	ldrh	r2, [fp, #-8]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	ldrsh	r3, [r3, #6]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #6]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrh	r3, [r3, #2]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #14]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #2]	@ movhi
	ldrh	r2, [fp, #-8]
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	ldrsh	r3, [r3, #14]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #14]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #6]
	mov	r1, r3
	mov	r2, r1
	lsl	r2, r2, #1
	add	r2, r2, r1
	lsl	r3, r2, #4
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #3
	add	r3, r3, #512
	asr	r2, r3, #10
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #6]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r3, [r3, #10]
	mov	r1, r3
	mov	r2, r1
	lsl	r2, r2, #1
	add	r2, r2, r1
	lsl	r3, r2, #4
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #3
	add	r3, r3, #512
	asr	r2, r3, #10
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #4
	ldr	r1, [fp, #-20]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3, #10]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	add	r3, r3, #1
	strb	r3, [fp, #-5]
.L5:
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	cmp	r3, #7
	bls	.L6
	mov	r3, #0
	strb	r3, [fp, #-5]
	b	.L7
.L8:
	ldr	r3, [fp, #-20]
	add	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	strh	r3, [fp, #-8]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	strh	r3, [fp, #-10]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	ldr	r2, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	ldr	r2, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	ldr	r1, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r2, [fp, #-8]	@ movhi
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r2, [fp, #-10]	@ movhi
	strh	r2, [r3]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	ldr	r2, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	ldr	r1, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldr	r3, [fp, #-20]
	add	r1, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldr	r3, [fp, #-20]
	add	r1, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r0, [r3]
	ldr	r3, [fp, #-20]
	add	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r1, [r3]
	ldr	r3, [fp, #-20]
	add	r2, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	ip, r2, r3
	ldr	r3, [fp, #-20]
	add	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	mov	r2, #3
	str	r2, [sp]
	mov	r2, ip
	bl	butterfly_fp(PLT)
	ldr	r3, [fp, #-20]
	add	r2, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r0, [r3]
	ldr	r3, [fp, #-20]
	add	r2, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r1, [r3]
	ldr	r3, [fp, #-20]
	add	r2, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	ip, r2, r3
	ldr	r3, [fp, #-20]
	add	r2, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	mov	r2, #1
	str	r2, [sp]
	mov	r2, ip
	bl	butterfly_fp(PLT)
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	ldr	r2, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	ldr	r1, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldr	r3, [fp, #-20]
	add	r1, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r0, [r3]
	ldr	r3, [fp, #-20]
	add	r2, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r1, [r3]
	ldr	r3, [fp, #-20]
	add	r2, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	ip, r2, r3
	ldr	r3, [fp, #-20]
	add	r2, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	mov	r2, #2
	str	r2, [sp]
	mov	r2, ip
	bl	butterfly_fp(PLT)
	ldr	r3, [fp, #-20]
	add	r2, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldr	r3, [fp, #-20]
	add	r1, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldrh	r3, [fp, #-8]
	add	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrh	r2, [fp, #-8]
	ldr	r3, [fp, #-20]
	add	r1, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r1, r3
	ldrsh	r3, [r3]
	lsl	r3, r3, #16
	lsr	r3, r3, #16
	sub	r3, r2, r3
	lsl	r3, r3, #16
	lsr	r2, r3, #16
	ldr	r3, [fp, #-20]
	add	r1, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	ldr	r2, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	add	r3, r3, #4
	asr	r2, r3, #3
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	ldr	r1, [fp, #-20]
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #64
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #32
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #96
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrh	r3, [r3]	@ movhi
	strh	r3, [fp, #-8]	@ movhi
	ldrsh	r3, [fp, #-8]
	ldr	r2, [fp, #-20]
	add	r1, r2, #112
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #1
	add	r2, r1, r2
	ldrsh	r2, [r2]
	add	r3, r3, r2
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #16
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrsh	r3, [fp, #-8]
	ldr	r2, [fp, #-20]
	add	r1, r2, #112
	ldrb	r2, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #1
	add	r2, r1, r2
	ldrsh	r2, [r2]
	sub	r3, r3, r2
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #112
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	mov	r1, r3
	mov	r2, r1
	lsl	r2, r2, #1
	add	r2, r2, r1
	lsl	r3, r2, #4
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #3
	add	r3, r3, #512
	asr	r3, r3, #10
	strh	r3, [fp, #-8]	@ movhi
	ldrsh	r3, [fp, #-8]
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #48
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-20]
	add	r2, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	mov	r1, r3
	mov	r2, r1
	lsl	r2, r2, #1
	add	r2, r2, r1
	lsl	r3, r2, #4
	sub	r3, r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #3
	add	r3, r3, #512
	asr	r3, r3, #10
	strh	r3, [fp, #-8]	@ movhi
	ldrsh	r3, [fp, #-8]
	add	r3, r3, #4
	asr	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r1, r3, #80
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	lsl	r2, r2, #16
	asr	r2, r2, #16
	lsl	r3, r3, #1
	add	r3, r1, r3
	strh	r2, [r3]	@ movhi
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	add	r3, r3, #1
	strb	r3, [fp, #-5]
.L7:
	ldrb	r3, [fp, #-5]	@ zero_extendqisi2
	cmp	r3, #7
	bls	.L8
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	dct_2d_loeffler, .-dct_2d_loeffler
	.section	.rodata
	.align	2
.LC1:
	.ascii	"DCT Coefficients:\000"
	.align	2
.LC2:
	.ascii	"%6d\000"
	.align	2
.LC3:
	.ascii	"X[%d] = %d\012\000"
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
	@ args = 0, pretend = 0, frame = 408
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #408
	ldr	r3, .L23
.LPIC1:
	add	r3, pc, r3
	sub	ip, fp, #88
	mov	lr, r3
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldmia	lr!, {r0, r1, r2, r3}
	stmia	ip!, {r0, r1, r2, r3}
	ldm	lr, {r0, r1, r2, r3}
	stm	ip, {r0, r1, r2, r3}
	sub	r3, fp, #216
	mov	r2, #128
	mov	r1, #0
	mov	r0, r3
	bl	memset(PLT)
	sub	r2, fp, #216
	sub	r3, fp, #88
	mov	r1, r2
	mov	r0, r3
	bl	dct_2d_loeffler(PLT)
	ldr	r3, .L23+4
.LPIC2:
	add	r3, pc, r3
	mov	r0, r3
	bl	puts(PLT)
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L10
.L13:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L11
.L12:
	ldr	r3, [fp, #-8]
	lsl	r2, r3, #3
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	lsl	r3, r3, #1
	sub	r3, r3, #4
	add	r3, r3, fp
	sub	r3, r3, #212
	ldrsh	r3, [r3]
	mov	r1, r3
	ldr	r3, .L23+8
.LPIC3:
	add	r3, pc, r3
	mov	r0, r3
	bl	printf(PLT)
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L11:
	ldr	r3, [fp, #-12]
	cmp	r3, #7
	ble	.L12
	mov	r0, #10
	bl	putchar(PLT)
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L10:
	ldr	r3, [fp, #-8]
	cmp	r3, #7
	ble	.L13
	sub	r3, fp, #408
	mov	r2, #128
	mov	r1, #0
	mov	r0, r3
	bl	memset(PLT)
	mov	r3, #0
	str	r3, [fp, #-16]
	b	.L14
.L19:
	mov	r3, #0
	str	r3, [fp, #-20]
	b	.L15
.L18:
	ldr	r3, [fp, #-20]
	and	r3, r3, #1
	cmp	r3, #0
	bne	.L16
	mov	r1, #228
	b	.L17
.L16:
	mov	r1, #28
.L17:
	ldr	r3, [fp, #-16]
	lsl	r3, r3, #3
	sub	r3, r3, #4
	add	r2, r3, fp
	ldr	r3, [fp, #-20]
	add	r3, r2, r3
	sub	r3, r3, #276
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [fp, #-20]
	add	r3, r3, #1
	str	r3, [fp, #-20]
.L15:
	ldr	r3, [fp, #-20]
	cmp	r3, #7
	ble	.L18
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L14:
	ldr	r3, [fp, #-16]
	cmp	r3, #7
	ble	.L19
	sub	r2, fp, #408
	sub	r3, fp, #280
	mov	r1, r2
	mov	r0, r3
	bl	dct_2d_loeffler(PLT)
	mov	r3, #0
	str	r3, [fp, #-24]
	b	.L20
.L21:
	sub	r3, fp, #4
	sub	r2, r3, #404
	ldr	r3, [fp, #-24]
	lsl	r3, r3, #1
	add	r3, r2, r3
	ldrsh	r3, [r3]
	mov	r2, r3
	ldr	r1, [fp, #-24]
	ldr	r3, .L23+12
.LPIC4:
	add	r3, pc, r3
	mov	r0, r3
	bl	printf(PLT)
	ldr	r3, [fp, #-24]
	add	r3, r3, #1
	str	r3, [fp, #-24]
.L20:
	ldr	r3, [fp, #-24]
	cmp	r3, #7
	ble	.L21
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L24:
	.align	2
.L23:
	.word	.LC0-(.LPIC1+8)
	.word	.LC1-(.LPIC2+8)
	.word	.LC2-(.LPIC3+8)
	.word	.LC3-(.LPIC4+8)
	.size	main, .-main
	.ident	"GCC: (GNU) 11.2.1 20211120"
	.section	.note.GNU-stack,"",%progbits

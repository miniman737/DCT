root@socfpga:~# cat dct_rc.s
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
	.file	"dct_rc.c"
	.text
	.align	2
	.syntax unified
	.arm
	.type	fpga_dct_1d, %function
fpga_dct_1d:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #28
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	str	r2, [fp, #-24]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L2
.L3:
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #1
	ldr	r2, [fp, #-20]
	add	r3, r2, r3
	ldrsh	r1, [r3]
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #2
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	mov	r2, r1
	str	r2, [r3]
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L2:
	ldr	r3, [fp, #-8]
	cmp	r3, #7
	ble	.L3
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L4
.L5:
	ldr	r3, [fp, #-12]
	lsl	r3, r3, #2
	ldr	r2, [fp, #-16]
	add	r3, r2, r3
	ldr	r2, [r3]
	ldr	r3, [fp, #-12]
	lsl	r3, r3, #1
	ldr	r1, [fp, #-24]
	add	r3, r1, r3
	lsl	r2, r2, #16
	asr	r2, r2, #16
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L4:
	ldr	r3, [fp, #-12]
	cmp	r3, #7
	ble	.L5
	nop
	nop
	add	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	fpga_dct_1d, .-fpga_dct_1d
	.align	2
	.syntax unified
	.arm
	.type	dct_2d_fpga, %function
dct_2d_fpga:
	@ args = 0, pretend = 0, frame = 328
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #328
	str	r0, [fp, #-320]
	str	r1, [fp, #-324]
	str	r2, [fp, #-328]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L7
.L12:
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L8
.L9:
	ldr	r3, [fp, #-8]
	lsl	r3, r3, #3
	ldr	r2, [fp, #-324]
	add	r2, r2, r3
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [fp, #-12]
	lsl	r3, r3, #1
	sub	r3, r3, #4
	add	r3, r3, fp
	sub	r3, r3, #40
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L8:
	ldr	r3, [fp, #-12]
	cmp	r3, #7
	ble	.L9
	sub	r2, fp, #60
	sub	r3, fp, #44
	mov	r1, r3
	ldr	r0, [fp, #-320]
	bl	fpga_dct_1d(PLT)
	mov	r3, #0
	str	r3, [fp, #-16]
	b	.L10
.L11:
	ldr	r3, [fp, #-16]
	lsl	r3, r3, #1
	sub	r3, r3, #4
	add	r3, r3, fp
	sub	r3, r3, #56
	ldrsh	r3, [r3]
	mov	r1, r3
	ldr	r3, [fp, #-8]
	lsl	r2, r3, #3
	ldr	r3, [fp, #-16]
	add	r3, r2, r3
	lsl	r3, r3, #2
	sub	r3, r3, #4
	add	r3, r3, fp
	str	r1, [r3, #-312]
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L10:
	ldr	r3, [fp, #-16]
	cmp	r3, #7
	ble	.L11
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L7:
	ldr	r3, [fp, #-8]
	cmp	r3, #7
	ble	.L12
	mov	r3, #0
	str	r3, [fp, #-20]
	b	.L13
.L18:
	mov	r3, #0
	str	r3, [fp, #-24]
	b	.L14
.L15:
	ldr	r3, [fp, #-24]
	lsl	r2, r3, #3
	ldr	r3, [fp, #-20]
	add	r3, r2, r3
	lsl	r3, r3, #2
	sub	r3, r3, #4
	add	r3, r3, fp
	ldr	r3, [r3, #-312]
	lsl	r3, r3, #16
	asr	r2, r3, #16
	ldr	r3, [fp, #-24]
	lsl	r3, r3, #1
	sub	r3, r3, #4
	add	r3, r3, fp
	sub	r3, r3, #40
	strh	r2, [r3]	@ movhi
	ldr	r3, [fp, #-24]
	add	r3, r3, #1
	str	r3, [fp, #-24]
.L14:
	ldr	r3, [fp, #-24]
	cmp	r3, #7
	ble	.L15
	sub	r2, fp, #60
	sub	r3, fp, #44
	mov	r1, r3
	ldr	r0, [fp, #-320]
	bl	fpga_dct_1d(PLT)
	mov	r3, #0
	str	r3, [fp, #-28]
	b	.L16
.L17:
	ldr	r3, [fp, #-28]
	lsl	r3, r3, #1
	sub	r3, r3, #4
	add	r3, r3, fp
	sub	r3, r3, #56
	ldrsh	r1, [r3]
	ldr	r3, [fp, #-28]
	lsl	r3, r3, #5
	ldr	r2, [fp, #-328]
	add	r3, r2, r3
	ldr	r2, [fp, #-20]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-28]
	add	r3, r3, #1
	str	r3, [fp, #-28]
.L16:
	ldr	r3, [fp, #-28]
	cmp	r3, #7
	ble	.L17
	ldr	r3, [fp, #-20]
	add	r3, r3, #1
	str	r3, [fp, #-20]
.L13:
	ldr	r3, [fp, #-20]
	cmp	r3, #7
	ble	.L18
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	dct_2d_fpga, .-dct_2d_fpga
	.section	.rodata
	.align	2
.LC1:
	.ascii	"/dev/mem\000"
	.align	2
.LC2:
	.ascii	"open /dev/mem\000"
	.align	2
.LC3:
	.ascii	"mmap\000"
	.align	2
.LC4:
	.ascii	"2D DCT output (MATLAB-compatible):\000"
	.align	2
.LC5:
	.ascii	"  \000"
	.align	2
.LC6:
	.ascii	"%7d\000"
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
	@ args = 0, pretend = 0, frame = 344
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #360
	ldr	r3, .L28
.LPIC0:
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
	sub	r3, fp, #344
	mov	r2, #256
	mov	r1, #0
	mov	r0, r3
	bl	memset(PLT)
	ldr	r1, .L28+4
	ldr	r3, .L28+8
.LPIC1:
	add	r3, pc, r3
	mov	r0, r3
	bl	open(PLT)
	str	r0, [fp, #-16]
	ldr	r3, [fp, #-16]
	cmp	r3, #0
	bge	.L20
	ldr	r3, .L28+12
.LPIC2:
	add	r3, pc, r3
	mov	r0, r3
	bl	perror(PLT)
	mov	r3, #1
	b	.L27
.L20:
	ldr	r2, .L28+16
	mov	r3, #0
	strd	r2, [sp, #8]
	ldr	r3, [fp, #-16]
	str	r3, [sp]
	mov	r3, #1
	mov	r2, #3
	mov	r1, #2097152
	mov	r0, #0
	bl	mmap(PLT)
	str	r0, [fp, #-20]
	ldr	r3, [fp, #-20]
	cmn	r3, #1
	bne	.L22
	ldr	r3, .L28+20
.LPIC3:
	add	r3, pc, r3
	mov	r0, r3
	bl	perror(PLT)
	ldr	r0, [fp, #-16]
	bl	close(PLT)
	mov	r3, #1
	b	.L27
.L22:
	ldr	r3, [fp, #-20]
	add	r3, r3, #512
	str	r3, [fp, #-24]
	sub	r2, fp, #344
	sub	r3, fp, #88
	mov	r1, r3
	ldr	r0, [fp, #-24]
	bl	dct_2d_fpga(PLT)
	ldr	r3, .L28+24
.LPIC4:
	add	r3, pc, r3
	mov	r0, r3
	bl	puts(PLT)
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L23
.L26:
	ldr	r3, .L28+28
.LPIC5:
	add	r3, pc, r3
	mov	r0, r3
	bl	printf(PLT)
	mov	r3, #0
	str	r3, [fp, #-12]
	b	.L24
.L25:
	ldr	r3, [fp, #-8]
	lsl	r2, r3, #3
	ldr	r3, [fp, #-12]
	add	r3, r2, r3
	lsl	r3, r3, #2
	sub	r3, r3, #4
	add	r3, r3, fp
	ldr	r3, [r3, #-340]
	mov	r1, r3
	ldr	r3, .L28+32
.LPIC6:
	add	r3, pc, r3
	mov	r0, r3
	bl	printf(PLT)
	ldr	r3, [fp, #-12]
	add	r3, r3, #1
	str	r3, [fp, #-12]
.L24:
	ldr	r3, [fp, #-12]
	cmp	r3, #7
	ble	.L25
	mov	r0, #10
	bl	putchar(PLT)
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L23:
	ldr	r3, [fp, #-8]
	cmp	r3, #7
	ble	.L26
	mov	r1, #2097152
	ldr	r0, [fp, #-20]
	bl	munmap(PLT)
	ldr	r0, [fp, #-16]
	bl	close(PLT)
	mov	r3, #0
.L27:
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L29:
	.align	2
.L28:
	.word	.LC0-(.LPIC0+8)
	.word	1052674
	.word	.LC1-(.LPIC1+8)
	.word	.LC2-(.LPIC2+8)
	.word	-14680064
	.word	.LC3-(.LPIC3+8)
	.word	.LC4-(.LPIC4+8)
	.word	.LC5-(.LPIC5+8)
	.word	.LC6-(.LPIC6+8)
	.size	main, .-main
	.ident	"GCC: (GNU) 11.2.1 20211120"
	.section	.note.GNU-stack,"",%progbits

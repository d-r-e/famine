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

section .text
	global _start
_start:
	call exit
exit:
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall

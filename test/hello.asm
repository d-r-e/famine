section .text
global _start

_start:
    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

    jmp string
write:
    mov rax, 0x1
    mov rdi, 0x1
    pop rsi
    mov rdx, 12
    ; syscall
    jmp end
string:
    jmp write
    db "hello world", 0x10, 0
end:
    mov rax, 0x60
    mov rdi ,0
    syscall
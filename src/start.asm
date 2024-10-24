DEFAULT rel

section .rodata
    annoy db 0xff, 0xff, 0xff, 0xff, 0x0f
    testing db "YES", 0

section .bss
    buffer resb 8

section .text
    global _start

_start:
    ; TESTING
    ;lea rdi, [annoy]
    ;call read_varint

    ; TESTING END
    call socket
    call bind

    mov rax, 60
    xor rdi, rdi
    syscall


socket:
    mov rax, 41 ; socket syscall
    mov rdi, 2
    mov rsi, 1
    mov rdx, 0
    syscall
    ret

bind:
    mov r12, rax
    mov rdi, rax
    mov rax, 49 ; bind syscall
    push dword 0 ; 0.0.0.0
    push word 0x3905 ; the port (1337)
    push word 2 ; AF_INET
    mov rcx, rsp
    mov rsi, rsp
    mov rdx, 16
    syscall
listen:
    mov rax, 50 ; listen syscall
    mov rdi, r12
    mov rsi, 0
    syscall
accept:
    mov rax, 43 ; accept syscall
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    syscall
    ; TESTING
    mov r12, rax

read:
    mov rax, 0  ; read syscall
    mov rdi, r12
    lea rsi, [buffer]
    mov rdx, 1
    syscall
    lea rdi, [buffer]
    add rdi, 4
    call read_varint
    lea rdi, [buffer]
    call read_varint
    ;cmp byte [rdi], 'A'
    ;je yes
    ;call print
    jmp read
yes:
    lea rdi, [testing]
    call print
    ;lea rdi, [buffer]
    ;call print

test:
    jmp read
    ret


; Testing
; rdi -> buffer
read_varint:
    xor rax, rax
    xor rcx, rcx
.loop:
    movzx rbx, byte [rdi]
    and rbx, 0x7F
    shl rbx, cl
    or rax, rbx

    test byte [rdi], 0x80
    jz .done
    inc rdi
    add rcx, 7
    cmp rcx, 32
    jae .error
    jmp .loop
.done:
    ret
.error:
    mov rdi, 1
    call exit

; Testing END


strlen:
    xor rax, rax
.find_length:
    cmp byte [rdi + rax], 0
    je .found_length
    inc rax
    jmp .find_length
.found_length:
    ret
print:
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rsi, rdi
    mov rdi, 1
    syscall
    ret

exit:
    mov rax, 60
    syscall

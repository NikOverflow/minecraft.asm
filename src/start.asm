DEFAULT rel

section .rodata
    annoy db 0xff, 0xff, 0xff, 0xff, 0x0f
    testing db "YES", 0

    status_packet db 155, 2, 0, 152, 2, "{'version': {'name': '1.20.4','protocol': 765},'players': {'max': 1337,'online': 1337,'sample': [{'name': 'thinkofdeath','id': '4566e69f-c907-48ee-8d71-d7ba5aa00d20'}]},'description': {'text': 'Hello, world!'},'favicon': 'data:image/png;base64,<data>','enforcesSecureChat': false}"

section .bss
    buffer resb 2097151

section .text
    global _start

    extern malloc
    extern free

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
    ; MORE TESTING
    xor r13, r13

read:
    mov rax, 0  ; read syscall
    mov rdi, r12
    lea rsi, [buffer]
    mov rdx, 2097151
    syscall
    lea rdi, [buffer]
    call read_varint
    inc rdi
    call read_varint
    inc rdi
    call read_varint
    inc rdi
    call read_varint
    inc rdi


    ; Printing the Host c:
    mov rdx, rax
    mov rax, 1
    mov rsi, rdi
    mov rdi, 0
    syscall
    call exit
    ; Well...

    ;cmp r13, 1
    ;je send
    ;inc r13
    ;jmp read
;send:


    ; SEND
    ;mov rax, 1
    ;mov rdi, r12
    ;lea rsi, [status_packet]
    ;mov rdx, 2097151
    ;syscall
    ; END



    ;call print
    ;call exit

    jmp read

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

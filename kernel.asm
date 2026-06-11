org 0x0000
bits 16

; ==============================
; Pangu Kernel 0.0.9
; Features:
; 1. Prevent backspace from deleting prompt "$ "
; 2. Keep all functions from 0.0.8
; 3. Terminal prompt works normally
; ==============================

; 段设置
mov ax, 0x1000
mov ds, ax
mov ax, 0xB800
mov es, ax

call clear_screen       ; 开机清屏

mov di, 0
mov si, msg_kernel
call print_str

; 首次换行并显示提示符
call enter_line

; 光标行列变量
row db 0
col db 0

;--------------------------
; 主循环
;--------------------------
kernel_main:
    call getkey

    cmp al, 'c'
    je  do_clear

    cmp al, 0x0D
    je  enter_line

    cmp al, 0x08
    je  backspace

    mov bl, [col]
    cmp bl, 79
    je  enter_line

    call putc
    jmp kernel_main

;--------------------------
; 换行 + 输出提示符
;--------------------------
enter_line:
    mov byte [col], 0
    inc byte [row]
    mov al, [row]
    mov bl, 160
    mul bl
    mov di, ax

    mov si, prompt
    call print_str
    jmp kernel_main

;--------------------------
; 退格优化：禁止删除提示符
; 提示符占2个字符位置，col < 2 就不能退格
;--------------------------
backspace:
    cmp byte [col], 2    ; 光标在前2位（提示符区域），直接返回
    jle kernel_main

    dec byte [col]
    sub di, 2
    mov byte [es:di], 0
    mov byte [es:di+1], 0x00
    jmp kernel_main

;--------------------------
; 按 c 清屏
;--------------------------
do_clear:
    call clear_screen
    mov di, 0
    mov byte [row], 0
    mov byte [col], 0
    mov si, prompt
    call print_str
    jmp kernel_main

;--------------------------
; 按键读取
;--------------------------
getkey:
    mov ah, 0x00
    int 0x16
    ret

;--------------------------
; 单字符输出
;--------------------------
putc:
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    ret

;--------------------------
; 字符串输出
;--------------------------
print_str:
    lodsb
    test al, al
    je  .end
    call putc
    jmp print_str
.end:
    ret

;--------------------------
; 清屏
;--------------------------
clear_screen:
    push di
    mov di, 0
clear_loop:
    mov byte [es:di], 0
    mov byte [es:di+1], 0x00
    add di, 2
    cmp di, 80*25*2
    jb clear_loop
    pop di
    ret

;--------------------------
; 字符串数据
;--------------------------
msg_kernel db 'Pangu Kernel 0.0.9', 0
prompt     db '$ ', 0

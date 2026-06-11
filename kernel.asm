org 0x0000
bits 16

; ==============================
; Pangu Kernel 0.0.7
; Features:
; 1. Add getkey function for keyboard input
; 2. Encapsulated putc and print_str for output
; 3. Press Enter: new line
; 4. Press Backspace: delete character
; 5. Press 'c' to clear screen
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

; 光标行列变量
row db 0
col db 0

;--------------------------
; 主循环
;--------------------------
kernel_main:
    call getkey        ; 调用按键读取函数，字符存入al

    cmp al, 'c'
    je  do_clear

    cmp al, 0x0D
    je  enter_line

    cmp al, 0x08
    je  backspace

    mov bl, [col]
    cmp bl, 79
    je  enter_line

    call putc          ; 输出普通字符
    jmp kernel_main

;--------------------------
; 换行处理
;--------------------------
enter_line:
    mov byte [col], 0
    inc byte [row]
    mov al, [row]
    mov bl, 160
    mul bl
    mov di, ax
    jmp kernel_main

;--------------------------
; 退格处理
;--------------------------
backspace:
    cmp byte [col], 0
    je  kernel_main
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
    jmp kernel_main

;--------------------------
; 按键读取函数 getkey
; 输出：al = 读取到的按键ASCII码
;--------------------------
getkey:
    mov ah, 0x00
    int 0x16
    ret

;--------------------------
; 单字符输出 putc
; 输入：al = 待打印字符
;--------------------------
putc:
    mov [es:di], al
    mov byte [es:di+1], 0x0E
    add di, 2
    inc byte [col]
    ret

;--------------------------
; 字符串输出 print_str
; 输入：si = 字符串首地址
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
; 清屏函数
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
msg_kernel db 'Pangu Kernel 0.0.7', 0

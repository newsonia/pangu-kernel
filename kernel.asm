org 0x0000
bits 16

; 段设置（关键！你原来的代码，完全不动）
mov ax, 0x1000
mov ds, ax           ; 数据段 = 内核所在段
mov ax, 0xB800
mov es, ax           ; 显存段

;--------------------------
; 0.02 原有代码：打印字符串
;--------------------------
mov si, msg
mov di, 0

print:
    lodsb            ; 读字符 al = [si++]
    test al, al
    je kernel_main    ; 改：打印完进入内核主逻辑

    mov [es:di], al
    mov byte [es:di+1], 0x0A   ; 绿色
    add di, 2
    jmp print

;--------------------------
; 0.03 新增：内核主循环 + 键盘输入
; 功能：按任意键，在屏幕上显示字符
;--------------------------
kernel_main:
    ; 读取键盘（BIOS 中断 16h 00h：等待按键）
    mov ah, 0x00
    int 0x16         ; 按键后，AL = 字符码

    ; 把读到的字符显示在屏幕上
    mov [es:di], al
    mov byte [es:di+1], 0x0E   ; 黄色字符
    add di, 2         ; 光标后移

    ; 循环继续接收下一个按键
    jmp kernel_main

;--------------------------
; 数据（完全保留）
;--------------------------
msg db 'Hello Pangu Kernel!', 0
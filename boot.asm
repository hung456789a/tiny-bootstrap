[org 0x7c00]

; Khai báo các hằng số
%define ENDL 0x0D, 0x0A

    ; Khởi tạo các thanh ghi đoạn
    mov ax, 0x07C0
    mov ds, ax

    ; Khởi tạo Stack (Ngăn xếp)
    mov ax, 0x07E0
    mov ss, ax
    mov sp, 0x2000

    ; Dọn dẹp màn hình
    call clearscreen

    ; Di chuyển con trỏ về góc trên trái (Hàng 0, Cột 0)
    push 0      ; Cột
    push 0      ; Hàng
    call movecursor
    add sp, 4

    ; In chuỗi văn bản ra màn hình
    push msg
    call print
    add sp, 2

    ; Tắt ngắt và dừng CPU
    cli
    hlt

; --- CÁC HÀM CON (SUBROUTINES) ---

; Hàm xóa màn hình
clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07 ; Bios scroll down window
    mov al, 0x00 ; Xóa toàn bộ màn hình
    mov bh, 0x07 ; Chữ xám nền đen
    mov cx, 0x00 ; Góc trên trái (0,0)
    mov dx, 0x184F ; Góc dưới phải (24,79)
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

; Hàm di chuyển con trỏ
movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4] ; Hàng
    mov cx, [bp+6] ; Cột

    mov ah, 0x02
    mov bh, 0x00 ; Trang màn hình 0
    mov dh, dl   ; Hàng
    mov dl, cl   ; Cột
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

; Hàm in chuỗi ký tự (kết thúc bằng byte 0)
print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+4] ; Địa chỉ chuỗi cần in
.loop:
    lodsb          ; Tải byte tại [SI] vào AL và tăng SI
    cmp al, 0      ; Kiểm tra xem đã hết chuỗi chưa
    je .done
    mov ah, 0x0E   ; Chế độ Teletype của BIOS
    int 0x10
    jmp .loop
.done:
    popa
    mov sp, bp
    pop bp
    ret

; Dữ liệu chuỗi
msg: db "Oh boy do I sure love assembly!", ENDL, 0

; Lấp đầy vùng trống sao cho đủ 510 bytes
times 510 - ($ - $$) db 0

; Chữ ký Boot Signature (2 bytes cuối cùng)
dw 0xAA55
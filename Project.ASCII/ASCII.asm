;define the data segment
data segment
	ascii_high		db	0	;用于控制ASCII码高位的参数
	ascii_low		db	0	;用于控制ASCII码低位的参数
	horizontal		dw	0	;用于控制每行打印的参数
	vertical		dw	0	;用于控制每列打印的参数
	count			db	0	;用于计数的参数
data ends
;code segment begins
code segment
assume cs:code,ds:data
;打印控制函数print，用于控制打印效果与打印的实现
print:
	mov al, count
	mov ah, 0
	mov bl, 16	;控制正确的使用16进制输出ASCII码
	div bl	
	cmp al, 10
	jb al_below_10
	add al, 7	;当ASCII码转为16进制后，高位超过9后控制其输出格式
al_below_10:
	add al, '0'	
	mov ascii_high, al 	;ASCII码低位输出从0开始计数
	cmp ah, 10
	jb ah_below_10
	add ah, 7	;当ASCII码转为16进制后，低位超过9后控制其输出格式
ah_below_10:
	add ah, '0'
	mov ascii_low, ah 	;ASCII码高位输出从0开始计数
print_to_screen:
	mov bx, horizontal
	mov di, vertical
	mov al, count
	mov ah, 12	;控制背景为黑色, 字符前景为高亮度红色
	mov es:[bx + di], ax	;控制ASCII码对应字符打印位置
	mov al, ascii_high
	mov ah, 10	;控制背景为黑色, ASCII码前景为高亮度绿色
	mov es:[bx + di + 2], ax 	;控制ASCII码高位在字符后紧随字符被打印
	mov al, ascii_low
	mov es:[bx + di + 4], ax 	;控制ASCII码低位在字符和ASCII码高位后紧随其后被打印
	ret
main:
	mov ax, data
	mov ds, ax	;将data放入ds寄存器
	mov ax, 0b800h	;0b800h为显示区缓存地址开始位置，将b800h放入AX寄存器中，实现打印到屏幕的目的
	mov es, ax
	mov count, 0
	mov vertical, 0
	;通过变量count、horizontal、vertical的设置，建立循环，实现ASCII码向屏幕的打印
before_print:
	mov horizontal, 0
while_print:
	call print	;调用打印函数
	add horizontal, 160	;从某一列的上一行指向下一行
	add count, 1	;count作为计数用参数
	mov ah, 0
	mov al, count
	cmp al, 0	;通过对count参数与0的比较，判断整个程序的结束，当count从0xFF变成0x00,也即重新变为0时，256个ASCII码已穷尽，程序运行结束
	je	end_of_main	;如果count为0，则结束程序
	mov bl, 25	;每列输出25个ASCII码, 即每列有25行
	div bl	;除以25，判断是否需要进入新的循环并进行新一列打印
	cmp ah, 0
	jne while_print	;通过al寄存器除以25，判断是否应该重新进入循环，通过这个除法过程的判断，实现了对每列25行的控制
	add vertical, 14	;根据前后两列首地址相差14字节的规律,用加法计算出下一列的地址
	jmp before_print	;更改horizontal为0
end_of_main:
	mov ah,0
	int 16h	;结束程序
code ends
end main
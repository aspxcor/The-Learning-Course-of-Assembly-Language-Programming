;College of Computer Science and Technology, Zhejiang University
;Comment uses ANSI, so when running this program in the doxbox, maybe you cannnot see the comments using Chinese,but in the EditPlus,it's normal.
;Just get the value of inputs, and using division to get binary, decimal, and hexadecimal number, then convert to ascil.

;-----------------------------------------------------------------------------数据段
.386
assume cs:code,ds:data,ss:stack1
data segment use16
	firstNumberSTR db 10		    ;存储第一个输入数的内容，形式为字符串
		db ?                        ;存储输入数的长度
		db 10 dup('$'),'*'          ;存储实际内容
	secondNumberSTR db 10               ;存储第二个输入数的内容，形式为字符串
		db ?
		db 10 dup('$'),'='
	firstNumberHEX dw 0                 ;存储第一个输入数的值，形式为十六进制
	secondNumberHEX dw 0                ;存储第二个输入数的值，形式为十六进制
	decimalSTR db 13 dup(?),'$'         ;存储结果的十进制格式，形式为字符串，ASCII
	decimalBits db 0                    ;存储结果十进制的位数
	binarySTR db 39 dup(0),'B','$'      ;存储结果的二进制格式，形式为字符串，ASCII
	binaryBits db 0                     ;存储结果二进制的位数
	hexaSTR db 8 dup(0),'h','$'         ;存储结果的十六进制格式，形式为字符串，ASCII
	hexBits db 0                        ;存储结果的十六进制的位数
	errorMessage db 'input invalid,exit!',0dh,0ah,'$'	;存储错误消息
data ends


;-----------------------------------------------------------------------------堆栈段
stack1 segment use16
	dw 100 dup(?)
stack1 ends


;-----------------------------------------------------------------------------代码段
code segment use16


;-------------------------------主函数
main:
	mov ax,data                         ;绑定数据段
	mov ds,ax

    ;读取输入数
	mov dx,offset firstNumberSTR        ;调用Get_Input函数读取输入数
	call Get_Input
	mov dx,offset secondNumberSTR
	call Get_Input
	
    ;转换输入数的字符串为其十六进制值
	xor cx,cx                           ;由于String_To_Hexs使用了cx，故必须cx清零
	mov cl,firstNumberSTR[1]            ;cx存储输入数的字符数，定为循环次数
	mov di,offset firstNumberSTR+2      ;移至实际数据的起始位置
	call String_To_Hex                  ;调用转换函数，结果存储在ax寄存器中
	mov firstNumberHEX,ax               ;将结果储存至变量中

    ;对第二个输入数操作，同上
	xor cx,cx
	mov cl,secondNumberSTR[1]
	mov di,offset secondNumberSTR+2
	call String_To_Hex
	mov secondNumberHEX,ax

    ;使用32位寄存器计算结果，结果形式为十六进制值
    ;由于输入位数被限定，使用32位寄存器并没有明显优势，只是可读性更好一点
	xor eax,eax                         ;清零
	xor ecx,ecx                         ;清零
	mov ax,firstNumberHEX               ;第一个乘数
	mov cx,secondNumberHEX              ;第二个乘数
	mul ecx                             ;乘法运算，结果在edx:eax中，实际上在eax中

    ;转换进制格式前的准备
	xor ecx,ecx                         ;清零ecx，防止对后续程序造成干扰
	push eax                            ;由于结果需转三种格式，故进行保护，可多次调用

    ;输入eax中的结果，转换为十进制的字符串形式，存储decimalSTR中，AScii码
	call Get_Decimal
	
    ;出栈以重新获取乘法结果，并再次压栈保护
	pop eax
	push eax
	
    ;输入eax中的结果，转换成二进制的字符串形式，存在binarySTR中，ASCII码
	call Get_Binary

    ;出栈以重新获取乘法结果，并再次压栈保护
	pop eax
	push eax

    ;输入eax中的结果，转换成十六进制的字符串形式，存储hexaSTR中，ASCII码
	call Get_Hexadecimal
	
    ;设定输出的内容及格式，调用int 21h中断的二号功能输出字符
	call Set_The_Output_Content

    ;调用int 21h显示字符
Done_Output:                            ;标志主函数的功能性结尾
	mov ah,4Ch
	int 21h


;-------------------------------获取输入数，并保持其在终端可见
Get_Input:
	mov ah,0Ah	
	int 21h

	mov ah,2                            ;输出回车
	mov dl,0Dh
	int 21h

	mov ah,2                            ;输出换行
	mov dl,0Ah
	int 21h
	ret                                 ;子函数结束，返回被调用时的位置



;------------------------------非法输入，输出提示消息，并不计算
Ilegal_Quit:
	mov dx,offset errorMessage
	call Output_The_Result
	jmp Done_Output
	ret


;-------------------------------将输入数的字符串转成其十六进制的值
String_To_Hex:
	xor ax,ax                           ;储存最终结果，清零
	mov si,0Ah                          ;字符串表示十进制形式，循环中对结果乘十以进位
string_not_over:
	xor bx,bx                           ;存储字符串ASCII码表示的数的实际值，循环前清零
	mov bl,byte ptr [di]                ;获取
	
	cmp bl,39h			    ;若大于字符9，不合法
	ja to_illegal_quit
	cmp bl,30h			    ;若小于字符0，不合法
	jb to_illegal_quit
	
	sub bl,30h                          ;ASCII码转为其表示的值
	mul si                              ;十进制每次对上次结果ax乘十进位
	add ax,bx                           ;ax=ax*10+bx
	inc di                              ;移动至下一个字符    
	loop string_not_over
	ret
to_illegal_quit:
	call Ilegal_Quit 
	ret                                 ;子函数结束


;-------------------------------将计算结果值转成十进制字符串，ASCII
Get_Decimal:
	;第一部分计算各位的数值
    mov ebx,0000000Ah                   ;过程中不断除以十取余，由低向高获取各位数的值
decimal_divisor_not_zero:               
	xor edx,edx                         ;edx存储余数，清零
	div ebx                             ;eax=eax/ebx,edx=eax%ebx
	inc cx                              ;cx记录十进制格式的位数
	push edx                            ;将低位的值压栈存储，以保证各位数的顺序
	xor edx,edx                         ;清零
	cmp eax,0                           ;判断eax是否为零，为零则转换完成，循环结束
	jne decimal_divisor_not_zero

    ;存储十进制格式的位数至decimalBits中
	mov decimalBits,cl

    ;第二部分将数值转为对应ASCII值，并存储至字符串中，循环次数为第一部分中的cx的值
	mov di,offset decimalSTR            ;存储的位置是decimalSTR
convert_to_decimal:
	pop eax                             ;将之前压入堆栈的edx值由高向低取出
	add al,'0'                  
	mov byte ptr[di],al                 ;转成对应的ASCII的值
	inc di                              ;移至下一个字符
	loop convert_to_decimal
	mov byte ptr[di] ,'$'               ;添加字符串结尾标记，方便后续输出
	ret                                 ;返回子函数被调用的位置


;--------------------------------将计算结果转成二进制字符串，ASCII
Get_Binary:
	;第一部分计算二进制各位的数值
    mov cx,39                           ;输出格式要求前导零和每四位间断一个空格，总字符
                                        ;总字符数被限定为39个，则循环39次
	mov di,offset binarySTR             ;结果存储至binarySTR中
binary_not_over:
	call Set_Interval_For_Binary        ;每次循环判断是否需要设定间隔
	shl eax,1                           ;移位
	jnc next_bits_operation             ;判断是否发生进位，发生则将此位的值加1来设定为1
	inc byte ptr [di]
next_bits_operation:
	add di,1                            ;移动至下一个字符
	loop binary_not_over

    ;第二部分将数值转为对应的ASCII值，并存储至字符串中
	mov cx,39
	mov di,offset binarySTR
convert_to_binary_asc:
	call Set_Interval_For_Binary        ;以重复设定间隔的方式跳过此位，避免冗长代码
	mov al,byte ptr [di]                
	add al,'0'                          ;转成此位数对应的ASCII值
	mov byte ptr [di],al
	inc di                              ;移动至下一个字符
	loop convert_to_binary_asc
	ret                                 ;返回函数被调用的位置


;---------------------------------将计算结果转成十六进制字符串，ASCII
Get_Hexadecimal:
	;第一部分计算十六进制各位的数值
    xor cx,cx                           ;清零
	mov di,offset hexaSTR	            ;结果存储至hexaSTR中
	mov ebx,00000010h                   ;过程中不断除以十六取余，由低向高获取各位数的值
not_zero_for_sixteen:
	xor edx,edx                         ;每次循环前置余数为零   
	div ebx                             ;eax=eax/ebx,edx=eax%ebx
	inc cx                              ;记录十六进制字符串的位数
	push edx                            ;将低位数值压入栈
	xor edx,edx         
	cmp eax,0                           ;判断eax是否为零，为零，转换结束
	jne not_zero_for_sixteen

	mov hexBits,cl                      ;将十六进制的位数存储至hexBits中

    ;第二部分将数值转为对应的ASCII值，并存储至字符串中
	mov di,offset hexaSTR
convert_to_hex_asc:
	pop eax                             ;由高向低取出各位数值
	add al,'0'                          ;将各位数值转换成对应的ASCII码值
	cmp al,3Ah                          ;判断是否小于等于9，如果大于，需要加7转成字母
	jl not_carry
	add al,7
not_carry:
	mov byte ptr[di],al             
	inc di
	loop convert_to_hex_asc
	mov byte ptr[di],'h'                ;输出数字的末尾加后缀表明进制
	inc di
	mov byte ptr[di],'$'                ;添加字符串结尾，方便后续输出
	ret                                 ;返回函数被调用的位置


;--------------------------------为二进制格式的字符串设定间断
Set_Interval_For_Binary:                
	;下列数字是需要设定间断的位置，如果满足，则设定此位为间断，并移至下一个字符
    cmp cx,35                           
	je is_white
	cmp cx,30
	je is_white
	cmp cx,25
	je is_white
	cmp cx,20
	je is_white
	cmp cx,15
	je is_white
	cmp cx,10
	je is_white
	cmp cx,5
	je is_white
	ret                                 ;此位不需要设定为间断，返回函数被调用处的位置
    ;此位需要被设定间断
is_white:
	mov byte ptr[di],' '                ;设定此位为空格以间断
	inc di
	dec cx                              ;由于调用处的特殊位置，需要手动将循环次数减去1
	ret                                 ;设定间断并移至下一位后移至函数被调用处的位置


;---------------------------------设定输出的内容及其格式，内部的子函数位于该段代码后
Set_The_Output_Content:
	;第一部分设定第一行输出 A*B=
	mov bx,offset firstNumberSTR+2      ;输出第一个输入数
	xor cx,cx
	mov cl,firstNumberSTR[1]
	call Output_The_Input

	mov ah,02h                          ;第一个输入数后补充输出乘号*
	mov dl,'*'
	int 21h

	mov bx,offset secondNumberSTR+2     ;输出第二个输入数
	xor cx,cx
	mov cl,secondNumberSTR[1]
	call Output_The_Input

	mov ah,02h                          ;第二个输入数后补充输出等号=
	mov dl,'='
	int 21h
	
	call For_Wrap                       ;换行

    ;第二部分分别在三行中输出计算结果的三种不同进制形式
	mov dx,offset decimalSTR            ;首先输出十进制
	call Output_The_Result

	mov dx,offset hexaSTR               ;其次换行输出十六进制
	call Output_The_Result

	mov dx,offset binarySTR             ;最后换行输出二进制
	call Output_The_Result
	
	ret                                 ;返回函数被调用处的位置


;---------------------------------隶属Set_The_Output_Content，用于输出结果
Output_The_Result:
	mov ah,9                            ;调用int 21h的九号功能输出字符串
	int 21h
	call For_Wrap                       ;输出后换行
	ret                                 ;返回


;---------------------------------隶属Set_The_Output_Content，用于输出初始输入数
Output_The_Input:
	xor ax,ax
not_all_output:
	mov ah,02h
	mov dl,byte ptr [bx]
	int 21h
	inc bx
	loop not_all_output
	ret


;---------------------------------隶属Set_The_Output_Content，用于换行
For_Wrap:
	mov ah,2                             ;输出回车
	mov dl,0Dh
	int 21h

	mov ah,2                             ;输出换行
	mov dl,0Ah
	int 21h
	ret


;-------------------------------------------------------------------------代码段结束
code ends
end main                                ;自main函数处开始运行
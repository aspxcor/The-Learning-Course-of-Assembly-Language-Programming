.386
assume cs:code,ds:data
data segment use16
	multiplicand	db	7	dup('$')	;存储被乘数
	multiplier	db	7	dup('$')	;存储乘数
	result dd 0	;存储乘积
	product	db	12	dup(0),'$'	;存储乘积十进制字符串形式
	productHex db 8 dup(0),'h','$'	;存储乘积十六进制字符串形式
	productBin db 39 dup(0),'B','$'	;存储乘积二进制字符串形式
data ends
code segment use16
inputAndNewline:	;读入数据并完成换行
	mov ah,10	
  	int 21h		;读入数据
  	mov ah,2 	
	mov dl,10
	int 21h		;换行	
	ret
digitalTrans:	;字符串与数值转换，eax存储转换后的数字，ebx是转换的进制，用作乘法系数
	mov bl,byte ptr [di]
	sub bl,'0'	;将字符串转换为阿拉伯数字
	mul si 
	add eax,ebx
	inc di
	loop digitalTrans	;逐个字符通过循环完成转换
	ret
isWhite:	;判断输出二进制乘积时应该输出数字还是输出空格作为间隔
	cmp bx,4	;bx寄存器用于计数，4个数一组，若bx=4表示输出一组数，需要输出空格;否则尚未输出一组数，则直接返回而不输出空格
	jnz return
	mov bx,0	;将用于计数的bx寄存器置零进行下一轮计数
	mov byte ptr[di],' '	;输出空格
	add di,1
	sub cx,1	;输出空格的情况处于cx控制下的loop循环里的一种特殊情况，需要特别将cx减去1
return:
	ret		;返回原函数继续输出二进制乘积运算结果
printMultiplicands:	;本函数用于输入完成后输出被乘数
	mov ah,2
	mov dl,byte ptr [bx]
	int 21h		;调用int 21h的二号功能
	add bx,1
	loop printMultiplicands		;循环实现输出
	ret
controlLine:	;本函数实现输出时的换行
	mov ah,2	;调用int 21h的二号功能实现换行
	mov dl,0Dh
	int 21h		;实现输出回车
	mov dl,0Ah
	int 21h		;实现输出换行
	ret
printProduct:	;本函数输出乘法运算结果
	mov ah,9	;调用int 21h的九号功能实现字符串的输出
	int 21h
	ret   
begin:		;程序主函数
	mov ax,data
	mov ds,ax	;关联data和ds
	mov si,10	;si将参与字符串与十进制数字转换
	lea dx,multiplicand
	call inputAndNewline	;输入被乘数并换行
	lea dx,multiplier
	call inputAndNewline	;输入乘数并换行
	mov ch,0
	mov cl,multiplicand+1
	lea di,multiplicand+2
	mov ax,0
	call digitalTrans	;实现输入的被乘数的字符串与数值量的转换
	push ax	;将转换完的被乘数入栈保护
	mov cl,multiplier+1
	lea di,multiplier+2
	mov ax,0
	call digitalTrans	;实现输入的乘数的字符串与数值量的转换
	pop cx	;先前被转换的被乘数出栈
	mul ecx	;完成两数乘法运算
	mov result,eax	;保存乘积数据，便于后续使用
	mov ecx,0	;ecx置零防止干扰程序运行
	mov ebx,10	;十进制转换前准备，将ebx初始化为进制转换系数10
transDec:	;十进制转换	
	div ebx
	add cx,1	
	push dx
	mov dx,0	;edx在除法中保存余数，将本次余数入栈保存后置零
	cmp eax,0
	jne transDec	;判断是否完成进制转换，如未完成则循环转换，运算时cx记录位数，ax与dx参与除法运算，bx为定义的系数
	lea di,product 	;转换结果存储在product中
printDec:	;十进制输出
	pop ax	;取出之前存储的余数，保存在ax中
	add ax,'0'
	mov [di],ax		;转换为ASCII码
	add di,1
	loop printDec	;移动到下一个字符，循环输出
	mov eax,result	;从result中取出之前乘法运算结果，并再次
	mov result,eax
	mov ebx,16
transHex:	;十六进制转换	
	div ebx
	add cx,1	
	push dx
	mov dx,0
	cmp eax,0
	jne transHex	;判断是否完成进制转换，如未完成则循环转换，运算时cx记录位数，ax与dx参与除法运算，bx为定义的系数
	lea di,productHex
printHex:	;十六进制输出
	pop ax
	add ax,'0'	;将数值转换为字符
	cmp ax,'9'	;判断数字值，若大于9则转成字母再输出,否则直接输出
	jng nowPrint
	add ax,7
nowPrint:	;输出完成字母转换后的字符串
	mov [di],ax
	add di,1
	loop printHex	;取出转换得到的结果并转为对应字符循环输出
	mov byte ptr[di],'h'	
	mov byte ptr[di+1],'$'
	mov eax,result
	mov result,eax
	mov cx,39
	lea di,productBin
	mov bx,0	;在这个二进制转换过程中，将bx寄存器用于计数，每满4输出一个空格作为二进制输出时的间隔，使用前首先置零bx
transBin:	;二进制转换
	call isWhite
	sal eax,1	;移位
	jnc transNextBit	;对进位判断，进位则设定此位为1
	add byte ptr [di],1
transNextBit:	;对下一个字符进行操作
	add byte ptr [di],'0'	;将数字转换为对应ASCII码
	add di,1	;操作下一个字符
	add bx,1	;操作了一个字符，计数寄存器bx加一
	loop transBin	;循环执行实现转换
	lea di,productBin
	mov cx,39
	mov bx,0	;再次调用isWhite函数前重置相关寄存器
printBin:
	call isWhite	;设定间隔输出
	add di,1	;移动到下一个字符处
	loop printBin	;循环输出每一个字符
	lea bx,multiplicand+2	;输出被乘数
	mov cl,multiplicand+1
	call printMultiplicands	;调用被乘数输出函数，输出被乘数
	mov dl,'*'	;输出乘号
	int 21h
	lea bx,multiplier+2	;输出乘数
	mov cl,multiplier+1
	call printMultiplicands ;使用被乘数输出函数输出乘数
	mov dl,'='	;输出等于号
	int 21h
	call controlLine	;换行
	lea dx,product            ;输出十进制结果
	call printProduct
	call controlLine	;输出十进制乘积后换行
	lea dx,productHex               ;输出十六进制结果
	call printProduct
	call controlLine	;输出十六进制乘积后换行
	lea dx,productBin             ;输出二进制结果
	call printProduct
	mov ah,4Ch
	int 21h
	code ends
	end begin
.386
assume cs:code,ds:data
data segment use16
	file db 80 dup('$')	;保存文件名                      
	filePointer dw 0 	;指向文件数据
	isPointer dd 0 		;表示当前的阅读的文件位置	
	countIndex dd 0 	;用于计数，表征文件容量
	dataIndex dw 0 	;指示控制台显示的数据量大小
	dataPerPage db 256 dup(' ')	;保存当前显示的文件数据信息
	controlLine db 9 dup('0')	;行输出控制的指示符
	whereData dw 0 	;指示打印数据位置
	whereAscii dw 0	;指示打印数据ASCII值位置
data ends
code segment use16
switchKey:
    mov ah,0
	int 16h		;读取键盘信息
	cmp ax,011Bh	;cmp with Esc
	jz whilePressEsc
	cmp ax,4700h	;cmp with Home
	jz whilePressHome
	cmp ax,4F00h	;cmp with End
	jz whilePressEnd
	cmp ax,4900h	;cmp with PageUp
	jz whilePressPageUp
	cmp ax,5100h	;cmp with PageDown
	jz whilePressPageDown
begin:
	mov ax,0B800h                       
	mov es,ax	;es与显卡关联
	mov ax,data
	mov ds,ax	;关联data和ds
	lea dx,file
	mov ah,10
	int 21h		;读入文件名
	mov cl,byte ptr file[1]
	add cx,offset file+2
	mov di,cx	;将读入的文件名末尾置'\0'
	mov ax,3D30h
	lea dx,file+2
	mov byte ptr[di],0
	int 21h		;打开用户指定的文件
	jnc Initialise
exit:
	mov ax, 4C00h
	int 21h		;退出程序
Initialise:		;此函数用于计算、存储文件信息并初始化窗口
	mov filePointer, ax
	push ax		;存储文件相关信息
	mov ax,4202h
	pop bx
	xor cx,cx
	int 21h		;计算文件大小，调整指向文件的指针的位置
	shl edx,10h
	mov countIndex,eax
	add countIndex,edx	;计算文件容量
	mov ax,4200h
	int 21h		;初始化首页的16行字符
Refresh:		;用于刷新各类型数据信息
	lea di,controlLine+7	;调整数组位置信息
	mov eax,isPointer	;加载首字符的位置信息
	mov ebx,10h		;与16进行除法运算，对行号转换
	mov ecx,08h		;设置8次循环加载文件十六进制显示时的8位数行号
transLineIndexLoop:		;循环转换行号
	cmp eax,0	;对eax除法结果进行判断，如果为0，则行号循环转换结束，否则持续循环
	mov edx,0	;清空余数edx，防止Divide Overflow错误
	jnz inLineLoop
	mov edx,30h
	jmp saveLineIndex
inLineLoop:		;对行号转换的内循环
	div ebx		;除法运算完成行号数据格式转换
	add edx,30h 	;转换为对应字符串
	cmp edx,39h 	;判断是否发生进位
	jng saveLineIndex
	add edx,7		;对字母判断
saveLineIndex:		;保存行号并完成相关参数配置工作
	mov byte ptr [di],dl
	sub edi,1
	loop transLineIndexLoop	;进入转换循环，循环完成行号信息设置
	add edi,09h
	mov edx,':'
	mov byte ptr [di],dl		;行号后输出冒号
	mov ecx,10h
	xor esi,esi
	xor ebx,ebx
resetMonitor:	;更新控制台的显示
	mov es:[bx+si],ax
	add esi,2
	cmp esi,0A0h		;换行判断
	jnz resetMonitor
	xor esi,esi
	add ebx,0A0h
	loop resetMonitor	;转入下一行并继续循环
	lea di,dataPerPage
	mov ecx,0100h
inDataLoop:		;更新页面中实时显示的数据信息
	mov byte ptr[di],al
	add edi,1
	loop inDataLoop
	mov eax,countIndex
	sub eax,isPointer
	cmp ax,0100h	;判断当前控制台窗口中数据量是否符合预期
	jnae capacityLessThanExpected		;当数据量足够填满页面，则要求数据填满，否则将数据加载完即可
	mov dataIndex,0100h
	jmp loadChar
capacityLessThanExpected:
	mov dataIndex,ax
loadChar:	;加载当前页数据的字符信息
	mov ah,3Fh		;为显示数据对应字符信息初始化空间
	mov bx,filePointer
	mov cx,dataIndex
	lea edx,dataPerPage
	lea edi,dataPerPage
	int 21h		;初始化各项数据并加载信息
	xor ebx,ebx
	xor ecx,ecx
	mov edx,076h
	mov whereData,dx
	mov edx,014h
	mov whereAscii,dx
printLine:		;打印行号
	cmp edx,014h	;对当前行是否输出完全进行判断，判断此函数是否应该被执行
	jnz printChar
	xor esi,esi
	push di
	lea di,controlLine
charOfLineControl:	;对打印过程中是否为首行、字符位是否需要改变等细节进行控制，保证输出正确
	cmp ecx,010h 	;关于是否为首行进行判断
	mov ax,[di]
	jc lineControlWhilePrinting	;第一行输出时要控制行参数加一
	cmp esi,0Ch	;对字符进位的判断与控制
	jnz lineControlWhilePrinting
	inc eax		;对进位字符控制，将其自增1
	cmp al,3Ah	;判断是否需要对数字转换为字母
	jnz lineControlWhilePrinting
	add eax,7
lineControlWhilePrinting:	;在打印行号时进行必要格式控制与转换
	mov [di],al
	mov ah,07h
	mov es:[ebx+esi],eax
	add di,1
	add esi,2	;加载行号信息
	cmp esi,012h
	jnz charOfLineControl	;若尚未完成加载则循环完成加载
	pop di 		;解除保护，重新恢复di初始值
printChar:		;打印字符它的十六进制形式ASCII码
	mov si,whereData
	mov ah,07h
	mov al,[di]
	mov es:[bx+si],ax
	add esi,2
	add ecx,1
	mov whereData,si
	mov si,whereAscii
	mov ax,[di]
	and ax,0FFh
	mov dl,010h
	div dl 	;读取字符ASCII码值
	cmp al,0Ah
	jnae isLower
	add eax,07h
isLower:	;对低位ASCII码取出讨论
	add eax,030h
	mov dh,al	;dh寄存器保存当前第一个ASCII字符数据
	cmp ah,0Ah	
	jnae isHigher
	add eax,0700h
isHigher:	;对高位ASCII码取出讨论
	add eax,3000h	;将ah加'0'
	push ax		;目的在于将低位ASCII码ah压入堆栈保护
	mov al,dh 	;恢复先前al数值
	mov ah,07h
	mov es:[ebx+esi],eax
	add esi,2	;实现对高位ASCII码显示
	pop ax
	mov al,ah
	mov ah,07h 	;恢复ah值
	mov es:[ebx+esi],eax
	add esi,2	;实现对低位ASCII码显示
	cmp esi,05Ah
	jz setSeparator
	cmp esi,042h
	jz setSeparator
	cmp esi,02Ah
	jz setSeparator
	mov al,' '
	jmp short printSet
setSeparator:	;设置打印分界线
	mov al,'|'
printSet:	;设置打印参数
	mov es:[ebx+esi],eax
	add esi,2
	mov whereAscii,si
	mov dx,whereData
	add edi,1	;存储有关参数
	cmp edx,150
	jnz lineFeed	;换行输出
	add ebx,160
	mov edx,118
	mov recordPosChar,dx
	mov edx,20
	mov recordPosAscii,dx 	;控制输出格式参数
lineFeed:
	cmp cx,dataIndex
	jnz printLine
	call switchKey
whilePressEsc:	;关闭文件
	mov ah, 3Eh
	mov bx, filePointer
	int 21h
	call exit
code ends
end begin
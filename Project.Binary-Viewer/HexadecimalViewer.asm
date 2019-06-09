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
	FirstDigital db 0 	;存储字符ASCII的高位数据
	SecondDigital db 0 	;存储字符ASCII的低位数据
data ends
code segment use16
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
	mov edx,20
	mov whereAscii,dx
printLine:		;对每行内容进行打印

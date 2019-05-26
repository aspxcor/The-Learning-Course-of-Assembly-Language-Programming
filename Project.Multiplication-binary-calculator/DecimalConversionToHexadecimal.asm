.386
data segment use16
bufa db 12
  db 12 dup(0)
  crlf db 0ah,'$'   ;用于换行
bufb db 12 dup(0)
data ends
code segment use16
  assume cs:code,ds:data
start:
  mov ax,data
  mov ds,ax
  lea dx,bufa
  mov ah,0Ah
  int 21h
  lea dx,crlf
  mov ah,9
  int 21h   ;换行，使进制转换结果在下一行输出
  mov bl,bufa+1 ;bl存放本次实际输入字符数
  mov bh,0
  lea si,bufa+2 ;si指向用户键入的第一个数字
  mov eax,0 ;将eax清零，用于存储被转换完成的十六进制数字
transfer:
  mov cl,[si]
  sub cl,30h  ;将输入的数字的ASCII码转换为数字，30h为数字0的ascii码
  movzx ecx,cl
  add eax,ecx
  imul eax,10
  inc si
  dec bx
  cmp bx,1
  mov ecx,0
  jne transfer
  mov cl,[si]
  sub cl,30h
  movzx ecx,cl
  add eax,ecx
  mov ecx,0
  mov ebx,16
j2:
  xor edx,edx
  div ebx
  push dx
  inc cx
  or eax,eax
  jnz j2
  lea di,bufb
j3:
  pop ax
  cmp al,10
  jb  l1
  add al,7
l1:
  add al,30h
  mov [di],al
  inc di
  loop j3
  mov byte ptr [di],'h'
  mov byte ptr [di+1],'$'
  lea dx,bufb
  mov ah,9
  int 21h
  mov ah,4ch
  int 21h
code ends
end start
;College of Computer Science and Technology, Zhejiang University
;Comment uses ANSI
;This is the easiest implementation that I can think about.
;Just fix column, then move row, every column has 19 rows. When row's number is 19,move to the next column,then recycle.




;This is the code as followed:

assume cs:code, ds:data 

;数据段，共设有五个中间变量，简化操作

data segment 
Row dw 0			;储存第几行，并同时初始化为 0，第一个符号的输出位置在第零行
Col dw 0			;储存第几列，并同时初始化为 0，第一个符号的输出位置在第零列
Total db 0			;储存已经操作的ASCII数目，并同时代表当前操作的ASCII值，初始化为 0 
FirstDigital db 0		;储存符号ASCII值的第一位（高位），并同时初始化为 0
SecondDigital db 0		;储存符号ASCII值的第二位（低位），并同时初始化为 0
data ends

;代码段

code segment 
start: 
        ;以下操作为初始化
	
	mov ax, data		
        mov ds, ax		;确定数据段
        
	mov ax, 0B800h		
        mov es, ax		;移动至显卡位置

        mov Total, 0		;已经输出的ASCII码的数量，同时也是ASCII的十进位值
        mov Col, 0		;设置行的纵坐标设为0

	;以下操作为一段循环代码，跳出的条件是总数Total（即ASCII码值）溢出，重新变为零

Recycle:    
	;以下操作将符号的ASCII数字分别以对应的ASCII值表示出来
	
	mov al, Total		;将当前ASCII赋值给AL
        mov ah, 0		;令AX = AL，为后面的除法做准备
        mov bl, 16		;令除数为16
        div bl			;AX%=BL，将十六进制转为十进制数字
        cmp al, 10		;判断商（低位），是否为0-9
        jb OperateFirstD	;如果是0-9，跳转处理
        add al, 7		;如果是A-F，加7进位，字母转为数字
OperateFirstD:	
        add al, '0'		;将数字转为对应的ASCII码值
        mov FirstDigital, al	
        cmp ah, 10		;判断余数（高位）是否为0-9
        jb OperateSecondD	;如果是0-9，跳转处理
        add ah, 7		;如果是A-F，加7进位，字母转为数字
OperateSecondD:
        add ah, '0'		;将数字转为对应的ASCII码值
        mov SecondDigital, ah	
	
	;以下操作将要显示的值传入显卡缓存
        ;符号
	mov al, Total		;符号的ASCII值
        mov ah, 0Ch		;颜色为亮红色
        mov bx, Row		;确定所处的行
        mov di, Col		;确定所处的列
        mov es:[bx + di], ax	;赋值
        add di,2		;移动到下一个字符位置

	;符号的ASCII码值的高位
        mov al, FirstDigital	;第一个数字的ASCII值
        mov ah, 0Ah		;颜色为亮绿色
        mov es:[bx + di], ax	;赋值
        add di,2		;移动到下一个字符位置
        
	;符号的ASCII码值的低位
	mov al, SecondDigital	;第二个数字的ASCII值，颜色不变
        mov es:[bx + di], ax	;赋值
        add di,2		;移动到下一个字符位置

	;以下操作将每组输出间的显卡缓存更新为空格，防止有命令行字符残留
	mov cx,4		;循环四次
setWhiteSpace:			
        mov al,' '		;赋值为空格
        mov es:[bx+di],ax	;赋值
        add di,2		;移动到下一个字符位置
        sub cx,1		;循环次数减一
        jnz setWhiteSpace	;CX非零继续循环

	;以下操作移动字符位置坐标，并为下一次循环做准备
        
	add Row, 160		;移动到下一行
        add Total,1		;输出的字符数加一，ASCII值加一
        cmp Total, 0		;判断是否完成256个值的输出，如果完成，Total溢出，重新变零
        je ProgramOver		;如果Total为零，程序结束，DOS显示
        
	;以下操作判断是否需要更换所处列，如果需要，更换列
	
	mov al, Total		;Total为十进制，代表字符总数
        mov ah, 0		;AX=AL=Total
        mov bl, 19h		;设置除数为25 = 19H，因为总共为19行，所以可以令下一步的AH一定是当前第N行的行数N，（且N<19）
        div bl			;令AX/op，则AH为余数，为处于第N行，且AH=N H，则相当于直接将N与19比较，判断是否处于最后一行
        cmp ah, 0		;比较判断是否处于最后一行，如果最后一行，19%19，AH=0, 继续运行，更换列后循环，如果不是，N%19，AH！=0，则直接跳转继续循环
        
	;如果处在当前列的最后一行，则不跳转，执行更换列的操作，如果不是，则跳转，直接继续循环

	jne NotMoveCol		;跳过更换所处列的操作，直接进入下一循环
        add Col, 14		;更换当前所处的列
        mov Row, 0		;将输出位置更改为新的输出列的第零行
NotMoveCol:
	jmp Recycle		;跳转回去，循环继续，不改变所处列
ProgramOver: 
        mov ax, 4C00h		
        int 21h			;DOS输出显示

code ends 
end start

# 第二汇编语言项目*乘法二进制计算器*|The Second Assembly Language Project *Multiplication Binary Calculator*
## 项目任务描述 | Project Task Description
*在键盘上输入两个十进制非符号数字（≤65535）并计算两个数字的乘积。 product，结果分别以十进制，十六进制和二进制输出。
*例如：输入数字12345和65535时，您可以在屏幕上看到：
* Enter two decimal non-symbol numbers (≤65535) on the keyboard and calculate the multiplication of the two numbers. product,The results are output in decimal, hexadecimal, and binary, respectively.
* E.g: When you input number 12345 and 65535,you can see this on the screen:
```
12345
65535
12345*65535=
809029575
3038CFC7h 
0011 0000 0011 1000 1100 1111 1100 0111B 
```
*输入一行字符串可以通过调用int 21h的0Ah子函数来完成。现在，请参阅教科书P.216了解详情。此外，程序中允许32位寄存器。
* Entering a line of string can be done by calling the 0Ah sub-function of int 21h. Now, please refer to the textbook P.216 for details. In addition, 32-bit registers are allowed in the program. 
## 文件介绍 | Document Introduction
* **DecimalConversionToHexadecimal.asm**是一个分离出的功能片段，能够将输入数字转换为十六进制并在屏幕上输出
* **MultiplicationBinaryCalculator.exe**是编译项目后的Win32可执行文件。
* **MultiplicationBinaryCalculator.asm**是我完成的项目源代码。
* **DecimalConversionToHexadecimal.asm** is a separate function segment that converts input numbers to hexadecimal and outputs them on the screen
* **MultiplicationBinaryCalculator.exe** is the Win32 executable after the project is compiled.
* **MultiplicationBinaryCalculator.asm** is the project source code I completed.

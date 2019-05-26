# The Second Assembly Language Project          *Multiplication Binary Calculator*
## Project Task Description
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
* Entering a line of string can be done by calling the 0Ah sub-function of int 21h. Now, please refer to the textbook P.216 for details. In addition, 32-bit registers are allowed in the program. 
## Document Introduction
* **DecimalConversionToHexadecimal.asm** is able to convert the input digits into hexadecimal and output on the screen
* **MultiplicationBinaryCalculator.exe** is the Win32 executable after the project is compiled.
* **P2.asm** is a sample code of a project of a previous senior

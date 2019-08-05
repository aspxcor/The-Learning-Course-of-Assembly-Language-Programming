# 汇编语言程序设计|The-Learning-Course-of-Assembly-Language-Programming
本项目**汇编语言程序设计**记录了我在学习汇编语言方面的经验和教训。

The learning process of assembly language programming has recorded my experience in learning assembly language.
## About Me
My Blog: http://dingzhi.ga
## 警告 | Warning Before The Project
项目部分代码内容来自浙江大学计算机学院相关课程的课程设计作业。 

**如果您是浙江大学的学生，请不要直接复制源代码，因为会检查课程的相关设计代码。如果您坚持直接复制代码，后果将由您自己负责。**

*Part of the project heres come from the curriculum design of related courses in the College of Computer Science, Zhejiang University. **If you are a student from Zhejiang University, please do not copy the source code directly,because the relevant design code of the course will be checked.If you insist on copying the code directly, the consequences will be your own responsibility.***
## 项目内容介绍 | Project Introduction
> 本项目记录了我学习汇编语言过程中写过的程序，本项目持续更新。目前的几个项目介绍如下,具体程序内容可以进入项目文件中了解，此外，Lecture目录下记录了我曾经学习汇编语言时的笔记仅供读者参考。
* 简易ASCII码转换表——根据ASCII码打印对应的字符
* 简易的支持二进制与十六进制的计算器
* 简易的文件十六进制读取查看器程序。

*This project records the procedures I have written in the process of learning assembly language, and the project is continuously updated. The current several projects are introduced as follows.In addition, the notes in the Lecture directory that I used to learn assembly language are for readers' reference only.*

* Simple ASCII conversion table - prints the corresponding characters according to ASCII code;
* Simple support for binary and hexadecimal calculators
* Simple file hex read viewer program. The specific program content can be found in the project file. 
## 什么是汇编语言 | What is Assembly Language
汇编语言（或汇编语言），通常缩写为m，是任何低级编程语言，其中程序的语句与架构的机器代码指令之间存在非常强的对应关系。
汇编代码由称为汇编程序的实用程序转换为可执行机器代码。转换过程称为汇编或汇编源代码。汇编语言通常每个机器指令有一个语句，但通常也支持作为汇编程序指令，宏和程序和内存位置的符号标签的注释和语句。
每种汇编语言都特定于特定的计算机体系结构，有时特定于操作系统。但是，某些汇编语言不提供操作系统调用的特定语法，并且大多数汇编语言可以普遍用于任何操作系统，因为该语言提供对处理器的所有实际功能的访问，所有系统调用机制最终都依赖于此。与汇编语言相比，大多数高级编程语言通常可跨多个体系结构移植，但需要解释或编译。
汇编语言也可称为符号机器码。

*An assembly language (or assembler language), often abbreviated asm, is any low-level programming language in which there is a very strong correspondence between the program's statements and the architecture's machine code instructions.
Assembly code is converted into executable machine code by a utility program referred to as an assembler. The conversion process is referred to as assembly, or assembling the source code. Assembly language usually has one statement per machine instruction, but comments and statements that are assembler directives, macros, and symbolic labels of program and memory locations are often also supported.
Each assembly language is specific to a particular computer architecture and sometimes to an operating system. However, some assembly languages do not provide specific syntax for operating system calls, and most assembly languages can be used universally with any operating system, as the language provides access to all the real capabilities of the processor, upon which all system call mechanisms ultimately rest. In contrast to assembly languages, most high-level programming languages are generally portable across multiple architectures but require interpreting or compiling.
Assembly language may also be called symbolic machine code.*
## 汇编语言语法 | Assembly language syntax

汇编语言使用助记符来表示每个低级机器指令或操作码，通常还有每个架构寄存器，标志等。许多操作需要一个或多个操作数才能形成完整的指令。 大多数汇编程序允许程序和内存位置的命名常量，寄存器和标签，并且可以计算操作数的表达式。 因此，程序员不再需要繁琐的重复计算，汇编程序比机器代码更易读。 根据体系结构，这些元素也可以使用偏移或其他数据以及固定地址组合用于特定指令或寻址模式。 许多装配工提供了额外的机制来促进程序开发，控制装配过程以及帮助调试。

*Assembly language uses a mnemonic to represent each low-level machine instruction or opcode, typically also each architectural register, flag, etc. Many operations require one or more operands in order to form a complete instruction. Most assemblers permit named constants, registers, and labels for program and memory locations, and can calculate expressions for operands. Thus, the programmers are freed from tedious repetitive calculations and assembler programs are much more readable than machine code. Depending on the architecture, these elements may also be combined for specific instructions or addressing modes using offsets or other data as well as fixed addresses. Many assemblers offer additional mechanisms to facilitate program development, to control the assembly process, and to aid debugging.*
## 术语 | Terminology
宏汇编程序包含一个宏指令工具，以便（参数化）汇编语言文本可以用名称表示，并且该名称可用于将扩展文本插入到其他代码中。
交叉汇编程序（另请参见交叉编译器）是一个汇编程序，它运行在与运行结果代码的系统（目标系统）不同类型的计算机或操作系统（主机系统）上。交叉组装有助于为没有资源支持软件开发的系统（例如嵌入式系统）开发程序。在这种情况下，必须通过只读存储器（ROM，EPROM等）或使用目标代码的精确逐位副本的数据链接将结果目标代码传送到目标系统。基于文本的代码表示，例如Motorola S-record或Intel HEX。
高级汇编程序是一种程序，它提供更常与高级语言相关的语言抽象，例如高级控制结构（IF / THEN / ELSE，DO CASE等）和高级抽象数据类型，包括结构/记录，联合，类和集合。
微装配器是一种程序，可帮助准备称为固件的微程序，以控制计算机的低级操作。
元汇编程序是在某些圈子中用于“接受汇编语言的句法和语义描述并为该语言生成汇编程序的程序”的术语。
汇编时间是运行汇编程序的计算步骤。

*A macro assembler includes a macroinstruction facility so that (parameterized) assembly language text can be represented by a name, and that name can be used to insert the expanded text into other code.
A cross assembler (see also cross compiler) is an assembler that is run on a computer or operating system (the host system) of a different type from the system on which the resulting code is to run (the target system). Cross-assembling facilitates the development of programs for systems that do not have the resources to support software development, such as an embedded system. In such a case, the resulting object code must be transferred to the target system, either via read-only memory (ROM, EPROM, etc.) or a data link using an exact bit-by-bit copy of the object code or a text-based representation of that code, such as Motorola S-record or Intel HEX.
A high-level assembler is a program that provides language abstractions more often associated with high-level languages, such as advanced control structures (IF/THEN/ELSE, DO CASE, etc.) and high-level abstract data types, including structures/records, unions, classes, and sets.
A microassembler is a program that helps prepare a microprogram, called firmware, to control the low level operation of a computer.
A meta-assembler is a term used in some circles for "a program that accepts the syntactic and semantic description of an assembly language, and generates an assembler for that language."
Assembly time is the computational step where an assembler is run.*
## 课本推荐 | Textbook recommendation
* *汇编语言*作者：清华大学 王爽
> 这是一本对新手较为友好的，易于新手接受，有利于对汇编已有了解的学生对汇编语言有新的认识的教材，在此向大家推荐。
* *Assembly Language* Author: Wang Shuang ,Tsinghua University

/* ���벽��:
(1.1) �Ѵ��ļ����Ƶ�xp�����d:\tc��
˫�������ϵ�tcͼ������tc
      ��
(1.2) �Ѵ��ļ����Ƶ�dosbox86\tc��, 
����dosbox86
File->DOS Shell
cd \tc
tc

(2)
Alt+Fѡ��File->Load->ascii.c
Alt+Cѡ��Compile->Compile to OBJ ����
Alt+Cѡ��Compile->Line EXE file ����
Alt+Rѡ��Run->Run ����
Alt+Rѡ��Run->User Screen �鿴���
*/
#include <dos.h>
#include <bios.h>
main()
{
   unsigned char a=0, hex[3];
   char far *p = (char far *)0xB8000000;
   int i, j, k;
   _AX = 0x0003;
   geninterrupt(0x10);     /* ������ƵģʽΪ80*25�ı�ģʽ, ͬʱ������Ч�� */
   for(j=0; j<11; j++)     /* ��11�� */
   {
      p = (char far *)0xB8000000;
      p += j*7*2;          /* �����j�е�0�еĵ�ַ, ע�����֮�����7���ַ�(���ո�) */
                           /* ����п��Ը���ǰ�������׵�ַ���14�ֽڵĹ���,�üӷ�����
                              ����һ�еĵ�ַ
                            */
      for(i=0; i<25; i++)  /* ÿ�����25��ASCII��, ��ÿ����25�� */
      {
         *p = a;           /* �����ǰASCII�ַ� */
         *(p+1) = 0x0C;    /* ����Ϊ��ɫ, ǰ��Ϊ�����Ⱥ�ɫ */
         sprintf(hex, "%02X", a);
                           /* ����п��������Ͽν�����ѭ������4λ�ķ�����a��ֵת��
                              ��2λʮ�����Ʋ����浽����hex��
                            */
         for(k=0; k<2; k++)/* ���2λʮ�������� */
         {
            *(p+2+k*2) = hex[k];
            *(p+2+k*2+1) = 0x0A; /* ����Ϊ��ɫ, ǰ��Ϊ��������ɫ */
         }
         a++;
         if(a==0)          /* ��a��0xFF���0x00, ��ʾ256��ASCII����� */
            goto done;
         p += 160;         /* pָ���j�еĵ�i+1�� */
      }
   }
   done:
   bioskey(0);             /* ����п�����mov ah,0; int 16h;����˺������� */
}

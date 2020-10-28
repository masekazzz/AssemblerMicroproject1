format PE Console 4.0
include 'win32a.inc'
entry Start


section '.data' data readable writeable

; Справка об использовании программы
help db 'This program, which according to the parameters of three segments, decides whether the given segments can be sides of right triangle.', \
        ' ',13,10,0
; Scanf формат ввода
inputFormat db '%lf', 0
; Prinf формат вывода
outtFormat db '%lf',0
outFormat db '%d',0
outFormat1 db '%lf %lf %lf %lf %lf %lf', 0
outFormat2 db '%s',0
outFormat3 db '%lf%s',0
answerYES db 'Triangle is right',13,10,0
answerNO db 'Triangle is not right',13,10,0
otvetERROR db 'This is not a triangle',13,10,0
input1 db 'Enter x1',13,10,0
input2 db 'Enter y1',13,10,0
input3 db 'Enter x2',13,10,0
input4 db 'Enter y2',13,10,0
input5 db 'Enter x3',13,10,0
input6 db 'Enter y3',13,10,0
pressAnyKey db 'Press any key to close program...',13,10,0
nline db 13,10,0
x1  dq ?
x2  dq ?
x3  dq ?
y1  dq ?
y2  dq ?
y3  dq ?
a  dq ?
b  dq ?
c  dq ?
a2 dq ?
b2 dq ?
c2 dq ?

section '.code' code readable executable

Start:
  ; Ввод данных
  invoke printf, help
  invoke printf, input1
  invoke scanf, inputFormat, x1
  invoke printf, input2
  invoke scanf, inputFormat, y1
  invoke printf, input3
  invoke scanf, inputFormat, x2
  invoke printf, input4
  invoke scanf, inputFormat, y2
  invoke printf, input5
  invoke scanf, inputFormat, x3
  invoke printf, input6
  invoke scanf, inputFormat, y3
;  **************************************************

  ; Начало FPU вычислений
  finit 
   ;    
   ;            a = sqrt(([x1] - [x2])*([x1] - [x2]) + ([y1] - [y2])*([y1] - [y2]));
   ;    
        fld     qword  [x1]
        fsub    qword  [x2]
        fld     qword  [x1]
        fsub    qword  [x2]
        fmulp st1,st0   
        fld     qword  [y1]
        fsub    qword  [y2]
        fld     qword  [y1]
        fsub    qword  [y2]
        fmulp st1,st0    
        faddp st1,st0
        fst qword [a2]
        fsqrt
        fstp    qword  [a]

   ;    
   ;            b = sqrt(([x1] - [x3])*([x1] - [x3]) + ([y1] - [y3])*([y1] - [y3]));
   ;    
        fld     qword  [x1]
        fsub    qword  [x3]
        fld     qword  [x1]
        fsub    qword  [x3]
        fmulp st1,st0    
        fld     qword  [y1]
        fsub    qword  [y3]
        fld     qword  [y1]
        fsub    qword  [y3]
        fmulp st1,st0    
        faddp st1,st0
        fst   qword [b2]
        fsqrt
        fstp    qword  [b]
   ;    
   ;            c = sqrt(([x3] - [x2])*([x3] - [x2]) + ([y3] - [y2])*([y3] - [y2]));
   ;    
        fld     qword  [x3]
        fsub    qword  [x2]
        fld     qword  [x3]
        fsub    qword  [x2]
        fmulp st1,st0    
        fld     qword  [y3]
        fsub    qword  [y2]
        fld     qword  [y3]
        fsub    qword  [y2]
        fmulp st1,st0    
        faddp st1,st0
        fst qword [c2]
        fsqrt
        fstp    qword  [c]
   ;    
   ;            if ((a + b > c) && (a + c > b) && (b + c > a))
   ;    
        fld     qword  [a]
        fadd    qword  [b]
        fcomp   qword  [c]
        fstsw   ax
        sahf    
        ja      checkIsTriangle2
        jmp     ErrorMessage
checkIsTriangle2:
        fld     qword  [a]
        fadd    qword  [c]
        fcomp   qword  [b]
        fstsw   ax
        sahf    
        ja      checkIsTriangle3
        jmp     ErrorMessage
checkIsTriangle3:
        fld     qword  [b]
        fadd    qword  [c]
        fcomp   qword  [a]
        fstsw   ax
        sahf    
        ja  checkIsRightTriangle1
        jmp   ErrorMessage
   ;    
   ;            
   ;                    if a^2 + b^2 == c^2 || a^2 + c^2 == b^2 || b^2 + c^2 == a^2
   ;    
 checkIsRightTriangle1:
        fld   qword  [a2]
        fadd  qword  [b2]
        fcomp qword  [c2]
        fstsw   ax
        sahf    
        jne checkIsRightTriangle2
        jmp Success
checkIsRightTriangle2:
        fld   qword  [b2]
        fadd  qword  [c2]
        fcomp qword  [a2]
        fstsw   ax
        sahf    
        jne checkIsRightTriangle3
        jmp Success
checkIsRightTriangle3:
        fld   qword  [a2]
        fadd  qword  [c2]
        fcomp qword  [b2]
        fstsw   ax
        sahf    
        jne Failure
Success:
   ;    
   ;                            printf("\nTriangle is right\n");
   ;    
 cinvoke printf, outFormat2,answerYES
        jmp     exip
Failure:
   ;    
   ;                    else
   ;                            printf("\nTriangle is not right\n");
   ;    
 cinvoke printf, outFormat2,answerNO
        jmp     exip
ErrorMessage:
   ;    
   ;            }
   ;            else
   ;                    printf("\nThis is not triangle\n");
   ;    
 cinvoke printf, outFormat2,otvetERROR
 cinvoke printf, outFormat2,pressAnyKey
 cinvoke getch
 invoke ExitProcess, 0
; **********************************************************************
exip:
; Вывод  a, b, c
;
  mov eax, dword [a2]
  mov ebx, dword [a2 + 4]
  cinvoke printf, outFormat3, eax, ebx,nline
  mov eax, dword [b2]
  mov ebx, dword [b2 + 4]
  cinvoke printf, outFormat3, eax, ebx,nline
  mov eax, dword [c2]
  mov ebx, dword [c2 + 4]
  cinvoke printf, outFormat3, eax, ebx,nline
  cinvoke printf, outFormat2,pressAnyKey
  cinvoke getch
  invoke ExitProcess, 0


; Подключение внешних функций
section '.idata' import data readable

  library msvcrt, 'msvcrt.dll', kernel, 'kernel32.dll'
  import msvcrt, scanf, 'scanf', printf, 'printf', getch, '_getch'
  import kernel, ExitProcess, 'ExitProcess'

.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Calculator",0
area_width EQU 320;640
area_height EQU 520;480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24 ;symbol_width
arg6 EQU 28 ;symbol_height
botton_x EQU 500
botton_y EQU 150
botton_size EQU 80

symbol_width dd 10
symbol_height dd 20
x dd 0
include digits.inc
include letters.inc
include zero.inc
include fundal.inc
include semne.inc
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg6]
	cmp edx,516
	je make_fundal
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	mov edx, [ebp+arg6]
	mov symbol_height,edx
	mov edx, [ebp+arg5]
	mov symbol_width,edx
	cmp symbol_height, 27
	je make_zero
	lea esi, digits
	jmp draw_text
make_space:
    cmp eax,' '
    jne make_zero	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
make_zero:
	;sub eax, '0'
	lea esi, zero
	jmp draw_text
make_fundal:
	mov eax,0
    lea esi, fundal
	jmp draw_text

	
	
draw_text:
	mov ebx, [ebp+arg5];symbol_width
	mul ebx
	mov ebx, [ebp+arg6];symbol_height
	mul ebx
	add esi, eax
	mov ecx, [ebp+arg6];symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	; mov symbol_height, [ebp+arg6]
	; mov symbol_width, [ebp+arg5]
	add eax, [ebp+arg6];symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, [ebp+arg5];symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	cmp byte ptr[esi],2
	je simbol_pixel_fundal
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_fundal:
mov dword ptr [edi], 0f6f0f9h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y,symbol_height,symbol_width
	push symbol_height;arg6
	push symbol_width;arg5
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 24
endm

linie_1 macro x, y, len, color
local bucla_line
 mov eax,y ;eax=y
 mov ebx, area_width
 mul ebx ; eax=y*area_width +x
 add eax,x
 shl eax,2 ;eax=(y*area_width + x) *4
 add eax,area
 mov ecx,len
 bucla_line:
 mov dword  ptr[eax] ,color
 add eax, 4
 loop bucla_line
 endm
 
linie_2 macro x, y, len, color
local bucla_line
 mov eax,y ;eax=y
 mov ebx, area_width
 mul ebx ; eax=y*area_width +x
 add eax,x
 shl eax,2 ;eax=(y*area_width + x) *4
 add eax,area
 mov ecx,len
 bucla_line:
 mov dword  ptr[eax] ,color
 add eax, area_width*4
 loop bucla_line
 endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
; mov eax, [ebp+arg3];
; mov ebx ,area_width
; mul ebx
; add eax , [ebp+arg2]
; shl eax,2	
; add eax,area
; mov dword ptr[eax], 0FF0000h
linie_2 [ebp+arg2], [ebp+arg3], 10 , 0FFh
	jmp afisare_litere
	
evt_timer:
	; inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	; mov ebx, 10
	; mov eax, counter
	;cifra unitatilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 30, 10
	;cifra zecilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 20, 10
	;cifra sutelor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	; make_text_macro 'P', area, 110, 100
	; make_text_macro 'R', area, 120, 100
	; make_text_macro 'O', area, 130, 100
	; make_text_macro 'I', area, 140, 100
	; make_text_macro 'E', area, 150, 100
	; make_text_macro 'C', area, 160, 100
	; make_text_macro 'T', area, 170, 100
	
	; make_text_macro 'L', area, 130, 120
	; make_text_macro 'A', area, 140, 120
	
	; make_text_macro 'A', area, 100, 140
	; make_text_macro 'S', area, 110, 140
	; make_text_macro 'A', area, 120, 140
	; make_text_macro 'M', area, 130, 140
	; make_text_macro 'B', area, 140, 140
	; make_text_macro 'L', area, 150, 140
	; make_text_macro 'A', area, 160, 140
	; make_text_macro 'R', area, 170, 140
	; make_text_macro 'E', area, 180, 140
	make_text_macro ' ', area, 0, 0, 516, 42
make_text_macro ' ', area, 42, 0, 516, 42
make_text_macro ' ', area, 84, 0, 516, 42
make_text_macro ' ', area, 126, 0, 516, 42
make_text_macro ' ', area, 168, 0, 516, 42
make_text_macro ' ', area, 210, 0, 516, 42
make_text_macro ' ', area, 252, 0, 516, 42
make_text_macro ' ', area, 294, 0, 516, 42
linie_1 1, 40, 318, 0
linie_1 7,16,15,0
linie_1 7,20,15,0
linie_1 7,24,15,0
make_text_macro 'S', area, 30, 7, 20, 10
; make_text_macro 'T', area, 40, 7
; make_text_macro 'A', area, 50, 7
; make_text_macro 'N', area, 60, 7
; make_text_macro 'D', area, 70, 7
; make_text_macro 'A', area, 80, 7
; make_text_macro 'R', area, 90, 7
; make_text_macro 'D', area, 100, 7
;make_text_macro '2', area, 220, 60, 20, 10
;make_text_macro ' ', area, 0, 0, 393, 320
make_text_macro ' ', area, 294, 0, 516, 42
make_text_macro '9', area, 280, 60, 27, 14
make_text_macro '8', area, 265, 60, 27, 14
make_text_macro '7', area, 250, 60, 27, 14
make_text_macro '6', area, 235, 60, 27, 14
make_text_macro '5', area, 220, 60, 27, 14
make_text_macro '4', area, 205, 60, 27, 14
make_text_macro '3', area, 190, 60, 27, 14
make_text_macro '2', area, 175, 60, 27, 14
make_text_macro '1', area, 160, 60, 27, 14
make_text_macro '0', area, 145, 60, 27, 14

; make_text_macro 'M', area, 7, 140
; make_text_macro 'C', area, 17, 140
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start

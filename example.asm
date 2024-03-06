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
button_x_1 equ 3; coord pt 1
button_y_1 equ 416
button_size_x equ 80
button_size_y EQU 50
button_x_2 equ 83; coord pt 1
button_y_2 equ 416

symbol_width dd 10
symbol_height dd 20
x byte 0
include digits.inc
include letters.inc
include zero.inc
include fundal.inc
include semne.inc
include egal.inc
include puteri.inc
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

make_semne proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg6]
	cmp eax,'+'
	je make_ad
	cmp eax, '-'
	je make_sub
	cmp eax, 'x'
	je make_inm
	cmp eax, 's'
	je make_imp
	cmp eax, 'j'
	je make_jos
	cmp eax, '%'
	je make_suta
	cmp eax ,'.'
	je make_pct
	make_ad:
	mov eax,0
    lea esi, semne
	jmp draw_text
	
	make_sub:
	mov eax,1
    lea esi, semne
	jmp draw_text
	
	make_imp:
	mov eax,2
    lea esi, semne
	jmp draw_text
	
	make_inm:
	mov eax,3
    lea esi, semne
	jmp draw_text
	
	make_jos:
	mov eax,4
    lea esi, semne
	jmp draw_text
	
	make_suta:
	mov eax,5
    lea esi, semne
	jmp draw_text
	
	make_pct:
	mov eax,6
    lea esi, semne
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
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
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
make_semne endp

; un macro ca sa apelam mai usor desenarea simbolului
make_semne_macro macro symbol, drawArea, x, y, symbol_height, symbol_width
push symbol_height
push symbol_width
	push y
	push x
	push drawArea
	push symbol
	call make_semne
	add esp, 24
endm

make_egal proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg6]
	cmp eax,'='
	je make_eg
	cmp eax , ' ' 
	je make_cl
	make_eg:
	mov eax,0
    lea esi, egal
	jmp draw_text
	make_cl:
	mov eax,1
    lea esi, egal
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
	je simbol_pixel_albastru
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_albastru:
mov dword ptr [edi], 0000FFh
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
make_egal endp

make_egal_macro macro symbol, drawArea, x, y, symbol_height, symbol_width
push symbol_height
push symbol_width
	push y
	push x
	push drawArea
	push symbol
	call make_egal
	add esp, 24
endm

make_put proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg6]
	cmp eax,'/'
	je make_1
	cmp eax , '2' 
	je make_cl
	cmp eax , 'r' 
	je make_rad
	cmp eax , 'f' 
	je make_x
	make_1:
	mov eax,0
    lea esi, puteri
	jmp draw_text
	make_cl:
	mov eax,1
    lea esi, puteri
	jmp draw_text
	
	make_rad:
	mov eax,2
    lea esi, puteri
	jmp draw_text
	
	make_x:
	mov eax,3
    lea esi, puteri
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
	mov dword ptr [edi], 0h
	jmp simbol_pixel_next
simbol_pixel_alb:
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
make_put endp

make_put_macro macro symbol, drawArea, x, y, symbol_height, symbol_width
push symbol_height
push symbol_width
	push y
	push x
	push drawArea
	push symbol
	call make_put
	add esp, 24
endm

make_mutare proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg3]
	
	cmp edx,306
	jl make_schimbare
make_schimbare:
	mov eax,1
	lea esi, zero
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
	mov dword ptr [edi], 0h
	jmp simbol_pixel_next
simbol_pixel_alb:
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
make_mutare endp

make_mutare_macro macro symbol, drawArea, x, y, symbol_height, symbol_width
push symbol_height
push symbol_width
	push y
	push x
	push drawArea
	push symbol
	call make_mutare
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

 ; calcul_nr1 macro symbol,x
 ; mov eax,x
 ; mul 10
 ; add eax,symbol-'0'
 ; endm
 
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
	make_text_macro ' ', area, 0, 0, 516, 42
make_text_macro ' ', area, 42, 0, 516, 42
make_text_macro ' ', area, 84, 0, 516, 42
make_text_macro ' ', area, 126, 0, 516, 42
make_text_macro ' ', area, 168, 0, 516, 42
make_text_macro ' ', area, 210, 0, 516, 42
make_text_macro ' ', area, 252, 0, 516, 42
make_text_macro ' ', area, 294, 0, 516, 42
	jmp afisare_litere
	
evt_click:
mov eax, [ebp+arg2];
mov ebx,button_x_1
cmp eax, button_x_1
jle button_fail
cmp eax, button_x_1+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_1
cmp eax, button_y_1
jle button_fail
cmp eax, button_y_1+button_size_y
jg button_fail

make_text_macro '1',area, 300,150,27,14
; mul ebx
; add eax , [ebp+arg2]
; shl eax,2	
; add eax,area
; mov dword ptr[eax], 0FF0000h
	button_fail:
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
	;desenam fundal
	; make_text_macro ' ', area, 0, 0, 516, 42
; make_text_macro ' ', area, 42, 0, 516, 42
; make_text_macro ' ', area, 84, 0, 516, 42
; make_text_macro ' ', area, 126, 0, 516, 42
; make_text_macro ' ', area, 168, 0, 516, 42
; make_text_macro ' ', area, 210, 0, 516, 42
; make_text_macro ' ', area, 252, 0, 516, 42
; make_text_macro ' ', area, 294, 0, 516, 42
;desenam sus
linie_1 7,16,15,0
linie_1 7,20,15,0
linie_1 7,24,15,0
linie_1 0,202,320,0FFFFFFh
linie_1 0,203,320,0FFFFFFh
linie_1 0,204,320,0FFFFFFh
;desenam patratele,cifrele,semnele
linie_1 0,255,320,0FFFFFFh
linie_1 0,256,320,0FFFFFFh
linie_1 0,257,320,0FFFFFFh;1 terminarea

linie_1 0,308,320,0FFFFFFh
linie_1 0,309,320,0FFFFFFh
linie_1 0,310,320,0FFFFFFh;2

linie_1 0,361,320,0FFFFFFh
linie_1 0,362,320,0FFFFFFh
linie_1 0,363,320,0FFFFFFh;3

linie_1 0,414,320,0FFFFFFh
linie_1 0,415,320,0FFFFFFh
linie_1 0,416,320,0FFFFFFh;4

linie_1 0,467,320,0FFFFFFh
linie_1 0,468,320,0FFFFFFh
linie_1 0,469,320,0FFFFFFh;5

linie_1 0,517,320,0FFFFFFh
linie_1 0,518,320,0FFFFFFh
linie_1 0,519,320,0FFFFFFh
linie_1 0,520,320,0FFFFFFh;6

linie_2 0,202,318,0FFFFFFh
linie_2 1,202,318,0FFFFFFh
linie_2 2,202,318,0FFFFFFh
linie_2 3,202,318,0FFFFFFh

linie_2 82,202,318,0FFFFFFh
linie_2 83,202,318,0FFFFFFh
linie_2 84,202,318,0FFFFFFh

linie_2 164,202,318,0FFFFFFh
linie_2 165,202,318,0FFFFFFh
linie_2 166,202,318,0FFFFFFh

linie_2 246,202,318,0FFFFFFh
linie_2 247,202,318,0FFFFFFh
linie_2 248,202,318,0FFFFFFh
linie_2 317,202,318,0FFFFFFh
linie_2 318,202,318,0FFFFFFh
linie_2 319,202,318,0FFFFFFh
linie_2 320,202,318,0FFFFFFh

make_semne_macro 'j',area, 40,480,20,10
make_text_macro '0',area, 120,480,20,10
make_semne_macro '.',area, 200,480,20,10
make_egal_macro ' ',area, 275,472,40,42
make_egal_macro '=',area, 252,472,40,42

make_text_macro '1',area, 40,429,20,10
make_text_macro '2',area, 120,429,20,10
make_text_macro '3',area, 200,429,20,10
make_semne_macro '+',area, 280,429,20,10

 make_text_macro '4',area, 40,376,20,10
make_text_macro '5',area, 120,376,20,10
make_text_macro '6',area, 200,376,20,10
make_semne_macro '-',area, 280,376,20,10

 make_text_macro '7',area, 40,323,20,10
make_text_macro '8',area, 120,323,20,10
make_text_macro '9',area, 200,323,20,10
make_semne_macro 'x',area, 280,323,20,10

make_put_macro '/',area, 20,260,40,42
make_put_macro '2',area, 100,260,40,42
make_put_macro 'r',area, 180,260,40,42
make_semne_macro 's',area, 280,270,20,10

 make_semne_macro '%',area, 40,217,20,10
make_text_macro 'C',area, 110,217,20,10
make_text_macro 'E',area, 120,217,20,10
make_text_macro 'C',area, 200,217,20,10
make_put_macro 'f',area, 260,210,40,42

make_text_macro '0', area, 250, 60, 27, 14
make_text_macro 'S', area, 30, 7, 20, 10
make_text_macro 'T', area, 40, 7,20,10
make_text_macro 'A', area, 50, 7,20,10
make_text_macro 'N', area, 60, 7,20,10
make_text_macro 'D', area, 70, 7, 20, 10
make_text_macro 'A', area, 80, 7, 20, 10
make_text_macro 'R', area, 90, 7, 20, 10
make_text_macro 'D', area, 100, 7, 20,10
;desenam linii
;make_text_macro '2', area, 220, 60, 20, 10
;make_text_macro ' ', area, 0, 0, 393, 320
; make_text_macro '9', area, 280, 60, 27, 14


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

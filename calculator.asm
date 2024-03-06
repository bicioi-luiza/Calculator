.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

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
format db "%d", 13, 10, 0; in timpul in care lucram la proiect ,mi-am afisat in felul acesta nr1&nr2 pt a putea verifca daca pastrarea lor se face cum trebuie,apealarea functiei de printf se face in calcul2
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24 ;symbol_width, folosite pt a modifica macroul si procedura de desenare a textului ,astfel incat odata apelata sa poata face fie cifre mari , fie cifre mici , in functie de coordonatele date
arg6 EQU 28 ;symbol_height
button_x_1 equ 3; coord pt 1,4,7 si button_change
button_y_1 equ 416; coord pt 1,2,3 si plus
button_size_x equ 80;atat linia aceasta cat si cea de jos,sunt utilizate pt a specifica dimensiunea butoanelor calculatorului
button_size_y EQU 50
button_x_2 equ 83; coord pt 2,5,8,0, x^2 si CE
button_y_2 equ 416
button_x_3 equ 163; pt 3,6,9,sqrt(x) si C
button_y_0 equ 456;coord pt change,0 si =
button_y_5 equ 366;coord pt 4,5,6&-
button_y_8 equ 316; coord pt 7,8,9&x
button_x_plus equ 243; coord pt maj operatiilor , =,+,-,x,/ si stergere de o cfira pe rand
button_y_imp equ 266;1/x,x^2,sqrt(x)
button_y_ultim equ 216 ; folosit pt stergere cifre,CE,C,%

symbol_width dd 10
symbol_height dd 20
nr_cifre dd 0; variabila utilizata pentru calcularea nr de cifre ale rezultatului afisat
afisat dd 100; se foloseste in click event ,la fel ca variabila de mai jos si este utilizata pt a afisa atat nr introduse cat si rezultatul unei operatii
afisat1 dd 100
nr1 dd 0 ;folosit pt primul nr introdus
nr2 dd 0; in nr2 se va pastra primul nr introdus,odata ce se va apasa pe vreuna din operatiile puse la dispozitie ,urmand ca nr1 sa se initializeze cu 0 si a incepe sa se formeze din nou odata cu apasarea altor cifre
var dd 10
op dd 0; daca op este 1 ,atunci se face adunare ,daca este 2 se face scadere,daca estte trei se face inmultire si daca este 4 se face impartire
zece dd 10; se foloseste foarte des impartirea la 10 atat pt a afla cifrele rezultatului calculat si a le afisa ,cat si pentru stergerea 
rez dd 0; in functie de op , pe rez se va pune rezultatul operatiei dintre nr1&nr2
u dd 0; utilizat pt a scoate cate o cfira dintr-un nr, altfel zis u este echivalentul n%10 in c
cif1 dd 0; rezultatul va fi afisat pe 8 cifre 
cif2 dd 0
cif3 dd 0
cif4 dd 0
cif5 dd 0
cif6 dd 0
cif7 dd 0
cif8 dd 0
minus dd 0; se probeaza daca rezultatul este neg sau poz , daca este neg , minus se va pune pe 1 si se va afisa la final in fata modulului rezultatului ,un minus  
min dd -1
nr_cifre_f dd 0
nr_neg dd 0; daca se doreste inmultirea dintre 2 nr ,se va proba daca exista sau nu unul negativ printre ele ,daca nr_neg va fi 1 ,ceea ce inseamna ca doar un nr e neg , in timp ce celalalt e poz , atunci minus se va pune pe 1 si se va afisa asa cum am specificat mai sus
ver_ad dd 0
; nu am sters toate comentariile existente in exemplul dat ,asa ca vor mai fi de-a lungul proiectului si comentarii care nu sunt ale mele ,ci era acolo de dinainte pt a ne face sa intelegem cum functioneaza 

include digits.inc
include letters.inc
include zero.inc; fisierul cu cifrele mai mari , au dimensiunea 27 pe 14
include fundal.inc; am pus 4 fasii de "fundal" pt a imi face fundalulul de o anumita culaore 
include semne.inc; in fisierul acesta se afla plus,minus,inmultire,impartire,%,.,change
include egal.inc; deoarece am vrut ca butonul de = sa fie albastru ,am decis sa creez si egal.inc in care sa se afle doar egalul si inca un asa zis fundal albastru
include puteri.inc; folosit pt 1/x,x^2 ,sqrt(x),stergere
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
	cmp symbol_height, 27; probam daca argumentul din macro ,are val 27 ceea ce inseamna ca se doreste sa se deseneze cifre mai mari , care sunt in fisierul zero.inc
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

; un macro ca sa apelam mai usor desenarea simbolului, dupa cum se poate vedea am plasat mai multe argumente , asta pt nu a rescrie din nou aceeasi procedura doar ca sa ii schimb dimensiuniile cifrelor 
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
;apoi am scris procedurile necesare pt a imi desena toate simbolurile existente in calculator
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

make_calcul proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ebx, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg3]
	
	cmp ebx,'+'
	je save_number1
	cmp ebx,'-'
	je save_number2
	cmp ebx,'x'
	je save_number3
	cmp ebx,'s'
	je save_number4
	cmp ebx, '0'
	jl make_schimbare
	cmp ebx, '9'
	jg make_schimbare
	sub ebx, '0'
	mov edx,0; il punem pe 0 pt a putea face inmultirea
	mov eax,nr1; il punem pe nr1 in eax si apoi inmultim cu 10
	mul zece;inmultim cu 10
	add eax,ebx;adaugam cifra la nr anterior
	mov nr1,eax;pastram rezultatul tot in eax
	mov edx, [ebp+arg6]
	mov symbol_height,edx
	mov edx, [ebp+arg5]
	mov symbol_width,edx
	; cmp symbol_height, 27
	; je make_zero
	mov edx, [ebp+arg3]
	mov eax,ebx
	lea esi, digits
	jmp draw_text
	; save_number:
	; mov eax,nr1
	; mov nr2,eax
	; mov eax,0
	; mov nr1,0
	save_number1:
	mov op,1
	mov eax,nr1
	mov nr2,eax
	mov eax,0
	mov nr1,0
	jmp make_schimbare
	save_number2:
	mov op,2
	mov eax,nr1
	mov nr2,eax
	mov eax,0
	mov nr1,0
	jmp make_schimbare
	save_number3:
	mov op,3
	mov eax,nr1
	mov nr2,eax
	mov eax,0
	mov nr1,0
	jmp make_schimbare
	save_number4:
	mov op,4
	mov eax,nr1
	mov nr2,eax
	mov eax,0
	mov nr1,0
	jmp make_schimbare
	make_schimbare:
	; mov eax,1
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
make_calcul endp

make_calcul_macro macro symbol, drawArea, x, y, symbol_height, symbol_width
push symbol_height
push symbol_width
	push y
	push x
	push drawArea
	push symbol
	call make_calcul
	add esp, 24
endm

make_calcul2 proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ebx, [ebp+arg1] ; citim simbolul de afisat
	mov edx, [ebp+arg3]
	push nr1
push offset format
call printf
add esp, 8

push nr2
push offset format
call printf
add esp, 8

push op
push offset format
call printf
add esp, 8
mov minus,0
	cmp op,1
	je make_add
	cmp op,2
	je make_sub
	cmp op,3
	je make_inm
	cmp op,4
	je make_imp
	
	make_add:; procedura pt calculul adunarii
	mov eax,nr1
	add eax,nr2
	mov rez,eax
	mov nr1,eax; se pastreaza rez in nr1 ,pt o eventuala operatie urmatoare
	mov edx,0
	mov nr_cifre,0
	cmp rez,0; daca si dupa adunare rez este negativ ,el se va face poz si se va afisa un minus ulterior
	jl make_poz
	mov minus,0; in rest ,vom avea grija sa trecem minus pe 0 de fiecare data ccand rez nu este neg ,pt a evita posibilitatea ca minus sa ramana pe 1 si sa afiseze valori negative mai tarziu
	jmp et_loop
	
	make_sub:; procedura pt calculul sumei
	; cmp op,3
	; jge make_inm
	mov eax,nr2
	sub eax,nr1
	mov rez,eax
	mov nr1,eax
	mov edx,0
	mov nr_cifre,0
	cmp rez,0; la fel ca mai sus
	jl make_poz
	mov minus,0
	jmp et_loop
	
	make_inm:; procedura pt calculul inmultirii
	mov edx,0
	mov eax,nr1
	mul nr2
	mov rez,eax
	mov nr1,eax; se pastreaza rez in nr1 ,pt o eventuala operatie urmatoare
	mov edx,0
	mov nr_cifre,0
	cmp rez,0;la fel ca la adunare
	jl make_poz
	mov minus,0
	jmp et_loop
	
	make_imp:; procedura pt calculul impartiri
	cmp nr1,0
	jl make_poz11
	cmp nr2,0
	jl make_poz12
	mov edx,0
	mov eax,nr2
	div nr1
	mov rez,eax
	mov nr1,eax; se pastreaza rez in nr1 ,pt o eventuala operatie urmatoare
	mov edx,0
	mov nr_cifre,0
	cmp nr_neg,1;la fel ca la adunare
	je make_minus
	jmp et_loop
	
	make_poz:
	mov minus,1
	mov eax,rez
	mul min
	mov rez,eax
	mov edx,0
	mov nr_cifre,0
	jmp et_loop
	
	make_poz11:; se inmulteste primul nr cu -1 si se incrementeaza nr_neg
	inc nr_neg
	mov eax,nr1
	mul min
	mov nr1,eax
	mov edx,0
	mov nr_cifre,0
	jmp make_imp; din make_imp se trece la et_loop doar atunci cand toate nr au luat val poz
	
	make_poz12:; se inmulteste al doilea nr cu -1 si se incrementeaza nr_neg
	inc nr_neg
	mov eax,nr2
	mul min
	mov nr2,eax
	mov edx,0
	mov nr_cifre,0
	jmp make_imp
	
	make_minus:
	mov minus,1
	jmp et_loop
	
	
	
et_loop:;este un for pt eax=rez,eax<0,eax--
mov eax,rez
div zece
mov rez,eax
mov u,edx

;in edx se pastreaza rez de la rez%10
inc nr_cifre
cmp nr_cifre,1
je adaugare_1
cmp nr_cifre,2
je adaugare_2
cmp nr_cifre,3
jge adaugare_3
cmp nr_cifre,4
; je adaugare_4
; cmp nr_cifre,5
; je adaugare_5
; cmp nr_cifre,6
; je adaugare_6
; cmp nr_cifre,7
; je adaugare_7
; cmp nr_cifre,8
; je adaugare_8
cmp eax,0
jne et_loop
adaugare_1:
mov ebx,u
mov cif1,ebx
mov edx,0
mov eax,rez
cmp eax,0
jne et_loop
je make_schimbare; trebuie fortat sa iasa ,pt a nu se duce si la celelalte loopuri
adaugare_2:
cmp nr_cifre,2
jg adaugare_3
mov ebx,u
mov cif2,ebx
mov edx,0
mov eax,rez
cmp eax,0
jne et_loop
je make_schimbare
adaugare_3:
cmp nr_cifre,4
jge adaugare_4
mov ebx,u
mov cif3,ebx
mov edx,0
mov eax,rez
cmp eax,0
je make_schimbare
jne et_loop
adaugare_4:
cmp nr_cifre,5
jge adaugare_5
mov ebx,u
mov cif4,ebx
mov edx,0
mov eax,rez
cmp eax,0
je make_schimbare
jne et_loop
adaugare_5:
cmp nr_cifre,6
jge adaugare_6
mov ebx,u
mov cif5,ebx
mov edx,0
mov eax,rez
cmp eax,0
je make_schimbare
jne et_loop
adaugare_6:
cmp nr_cifre,7
jge adaugare_7
mov ebx,u
mov cif6,ebx
mov edx,0
mov eax,rez
cmp eax,0
je make_schimbare
jne et_loop
adaugare_7:
cmp nr_cifre,8
je adaugare_8
mov ebx,u
mov cif7,ebx
mov edx,0
mov eax,rez
cmp eax,0
je make_schimbare
jne et_loop
adaugare_8:
mov ebx,u
mov cif8,ebx
mov edx,0
mov eax,rez
cmp eax,0
je make_schimbare
jne et_loop

make_schimbare:
mov eax,0 ; citim simbolul de afisat
	mov edx, [ebp+arg3]
	mov eax, 0
	lea esi, egal
	jmp draw_text
	; mov eax,cif1
	; add edx,15
	; lea esi, digits
	; jmp draw_text
	
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
	


make_calcul2 endp

make_calcul2_macro macro symbol, drawArea, x, y, symbol_height, symbol_width
push symbol_height
push symbol_width
	push y
	push x
	push drawArea
	push symbol
	call make_calcul2
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
	make_text_macro ' ', area, 0, 0, 516, 42; aici se face prima afisare de fundal ,pt caa daca as pune-o la afisare_litere mi-ar afisa fundalulu peste rezultat
make_text_macro ' ', area, 42, 0, 516, 42
make_text_macro ' ', area, 84, 0, 516, 42
make_text_macro ' ', area, 126, 0, 516, 42
make_text_macro ' ', area, 168, 0, 516, 42
make_text_macro ' ', area, 210, 0, 516, 42
make_text_macro ' ', area, 252, 0, 516, 42
make_text_macro ' ', area, 294, 0, 516, 42
	jmp afisare_litere
	
evt_click:
add afisat,14
mov eax, [ebp+arg2];probam daca s-a apasat pe 1
mov ebx,button_x_1
cmp eax, button_x_1
jle button_fail
cmp eax, button_x_1+button_size_x
jg button_2
mov eax, [ebp+arg3]; y
mov ebx ,button_y_1
cmp eax, button_y_1
jle button_4
cmp eax, button_y_1+button_size_y
jg button_change
inc nr_cifre
make_calcul_macro '1',area,afisat,90,20,10
make_text_macro '1',area, afisat,150,27,14
;probam daca s-a apasat 2
button_2:
mov eax, [ebp+arg2];
mov ebx,button_x_2
cmp eax, button_x_2
jle button_fail
cmp eax, button_x_2+button_size_x
jg button_3
mov eax, [ebp+arg3]; y
mov ebx ,button_y_2
cmp eax, button_y_2
jle button_5
cmp eax, button_y_2+button_size_y
jg button_0
inc nr_cifre
make_calcul_macro '2',area,afisat,90,20,10
make_text_macro '2',area, afisat,150,27,14
;probam daca s-a apasat 3
button_3:
mov eax, [ebp+arg2];
mov ebx,button_x_3
cmp eax, button_x_3
jle button_fail
cmp eax, button_x_3+button_size_x
jg button_plus
mov eax, [ebp+arg3]; y
mov ebx ,button_y_2
cmp eax, button_y_2
jle button_6
cmp eax, button_y_2+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '3',area,afisat,90,20,10
make_text_macro '3',area,afisat,150,27,14
;probam daca s-a apasat 0
button_0:
mov eax, [ebp+arg2];
mov ebx,button_x_2; se foloseste coordonata lui 2 fiindca 0 e sub 2
cmp eax, button_x_2
jle button_fail
cmp eax, button_x_2+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_0
cmp eax, button_y_0
jle button_fail
cmp eax, button_y_0+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '0',area,afisat,90,20,10
make_text_macro '0',area, afisat,150,27,14
;probam daca s-a apasta 5
button_5:
mov eax, [ebp+arg2];
mov ebx,button_x_2; coordonatele lui x sunt la fel
cmp eax, button_x_2
jle button_fail
cmp eax, button_x_2+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_5
cmp eax, button_y_5
jle button_8
cmp eax, button_y_5+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '5',area,afisat,90,20,10
make_text_macro '5',area, afisat,150,27,14
;probam daca s-a apasat 8
button_8:
mov eax, [ebp+arg2];
mov ebx,button_x_2; coordonatele lui x sunt la fel
cmp eax, button_x_2
jle button_fail
cmp eax, button_x_2+button_size_x
jg button_9
mov eax, [ebp+arg3]; y
mov ebx ,button_y_8
cmp eax, button_y_8
jle button_patrat
cmp eax, button_y_8+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '8',area,afisat,90,20,10
make_text_macro '8',area, afisat,150,27,14
;probam daca s-a apasa pe 4
button_4:
mov eax, [ebp+arg2];probam daca s-a apasat pe 4
mov ebx,button_x_1
cmp eax, button_x_1
jle button_fail
cmp eax, button_x_1+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_5
cmp eax, button_y_5
jle button_7
cmp eax, button_y_5+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '4',area,afisat,90,20,10
make_text_macro '4',area, afisat,150,27,14
button_7:
mov eax, [ebp+arg2];probam daca s-a apasat pe 1
mov ebx,button_x_1
cmp eax, button_x_1
jle button_fail
cmp eax, button_x_1+button_size_x
jg button_8
mov eax, [ebp+arg3]; y
mov ebx ,button_y_8
cmp eax, button_y_8
jle button_fail
cmp eax, button_y_8+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '7',area,afisat,90,20,10
make_text_macro '7',area, afisat,150,27,14
;probam daca s-a apsat 6
button_6:
mov eax, [ebp+arg2];
mov ebx,button_x_3
cmp eax, button_x_3
jle button_fail
cmp eax, button_x_3+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_5
cmp eax, button_y_5
jle button_9
cmp eax, button_y_5+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '6',area,afisat,90,20,10
make_text_macro '6',area,afisat,150,27,14
;probam daca s-a apasat 9
button_9:
mov eax, [ebp+arg2];
mov ebx,button_x_3
cmp eax, button_x_3
jle button_fail
cmp eax, button_x_3+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_8
cmp eax, button_y_8
jle button_C
cmp eax, button_y_8+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '9',area,afisat,90,20,10
make_text_macro '9',area, afisat,150,27,14
button_plus:
mov eax, [ebp+arg2];
mov ebx,button_x_plus
cmp eax, button_x_plus
jle button_fail
cmp eax, button_x_plus+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_2
cmp eax, button_y_2
jle button_minus
cmp eax, button_y_2+button_size_y
jg button_egal
inc nr_cifre
make_calcul_macro '+',area,afisat,90,20,10
make_semne_macro '+',area, afisat,150,20,10
button_egal:
mov eax, [ebp+arg2];
mov ebx,button_x_plus
cmp eax, button_x_plus
jle button_fail
cmp eax, button_x_plus+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_0
cmp eax, button_y_0
jle button_fail
cmp eax, button_y_0+button_size_y
jg button_fail
inc nr_cifre
mov ver_ad,0
; inainte de calculul propriu zis al rezultatului ,avem grija sa punem toate cifrele care urmeaza sa ia val rezultatului ,pe 0 , pt a evita posibilitaatea ca rezultatul nou sa aiba mai putine cifre decat cel anterior si sa ramana vreo valoare din a celui vechi pe vreo cifra
mov cif1,0
mov cif2,0
mov cif3,0
mov cif4,0
mov cif5,0
mov cif6,0
mov cif7,0
mov cif8,0
make_calcul2_macro '=',area,afisat,90,20,10
; make_egal_macro '=',area, afisat,150,40,42
mov ebx,cif8
add ebx,'0'
make_text_macro ebx,area,afisat1,150,27,14
mov ecx,afisat1
add ecx,14
mov ebx,cif7
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif6
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif5
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif4
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif3
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif2
cmp cif2,'-'
je make_minus
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif1
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
mov afisat,212
cmp minus,1
je make_minus
jne button_fail
make_minus:
make_semne_macro '-',area,90,150,20,10


button_minus:
mov eax, [ebp+arg2];
mov ebx,button_x_plus
cmp eax, button_x_plus
jle button_fail
cmp eax, button_x_plus+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_5
cmp eax, button_y_5
jle button_inmul
cmp eax, button_y_5+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro '-',area,afisat,90,20,10
make_semne_macro '-',area,afisat,90,20,10
make_semne_macro '-',area, afisat,150,20,10
button_inmul:
mov eax, [ebp+arg2];
mov ebx,button_x_plus
cmp eax, button_x_plus
jle button_fail
cmp eax, button_x_plus+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_8
cmp eax, button_y_8
jle button_imp
cmp eax, button_y_8+button_size_y
jg button_fail
inc nr_cifre
make_calcul_macro 'x',area,afisat,90,20,10
make_semne_macro 'x',area,afisat,90,20,10
make_semne_macro 'x',area, afisat,150,20,10
button_imp:
mov eax, [ebp+arg2];
mov ebx,button_x_plus
cmp eax, button_x_plus
jle button_fail
cmp eax, button_x_plus+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_imp
cmp eax, button_y_imp
jle button_stergere1cif
cmp eax, button_y_imp+button_size_y
jg button_fail
inc nr_cifre
mov nr_neg,0
make_calcul_macro 's',area,afisat,90,20,10
make_semne_macro 's',area, afisat,90,20,10
make_semne_macro 's',area, afisat,150,20,10
button_patrat:
mov eax, [ebp+arg2];
mov ebx,button_x_2; coordonatele lui x sunt la fel
cmp eax, button_x_2
jle button_fail
cmp eax, button_x_2+button_size_x
jg button_9
mov eax, [ebp+arg3]; y
mov ebx ,button_y_imp
cmp eax, button_y_imp
jle button_CE
cmp eax, button_y_imp+button_size_y
jg button_fail
inc nr_cifre
mov ebx,nr1
mov nr2,ebx
mov op,3
mov cif1,0
mov cif2,0
mov cif3,0
mov cif4,0
mov cif5,0
mov cif6,0
mov cif7,0
mov cif8,0
make_calcul2_macro '=',area,afisat,90,20,10
mov ebx,cif8
add ebx,'0'
make_text_macro ebx,area,afisat1,150,27,14
mov ecx,afisat1
add ecx,14
mov ebx,cif7
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif6
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif5
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif4
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif3
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif2
cmp cif2,'-'
je make_minus
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif1
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
mov afisat,212
cmp minus,1
je make_minus2
jne button_fail
make_minus2:
make_semne_macro '-',area,90,150,20,10
button_stergere1cif:
mov eax, [ebp+arg2];
mov ebx,button_x_plus
cmp eax, button_x_plus
jle button_fail
cmp eax, button_x_plus+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_ultim
cmp eax, button_y_ultim
jle button_fail
cmp eax, button_y_ultim+button_size_y
jg button_fail
inc nr_cifre
mov nr_neg,0
mov ebx,nr1
mov nr2,ebx
mov nr1,10
mov op,4
mov ver_ad,1
mov cif1,0
mov cif2,0
mov cif3,0
mov cif4,0
mov cif5,0
mov cif6,0
mov cif7,0
mov cif8,0
make_calcul2_macro '=',area,afisat,90,20,10
mov ebx,cif8
add ebx,'0'
make_text_macro ebx,area,afisat1,150,27,14
mov ecx,afisat1
add ecx,14
mov ebx,cif7
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif6
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif5
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif4
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif3
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif2
cmp cif2,'-'
je make_minus
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif1
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
mov afisat,198
cmp minus,1
je make_minus3
jne button_fail
make_minus3:
make_semne_macro '-',area,90,150,20,10


button_CE:
mov eax, [ebp+arg2];
mov ebx,button_x_2
cmp eax, button_x_2
jle button_fail
cmp eax, button_x_2+button_size_x
jg button_C
mov eax, [ebp+arg3]; y
mov ebx ,button_y_ultim
cmp eax, button_y_ultim
jle button_fail
cmp eax, button_y_ultim+button_size_y
jg button_fail
mov nr1,0
mov nr2,0
mov op,1
mov cif1,0
mov cif2,0
mov cif3,0
mov cif4,0
mov cif5,0
mov cif6,0
mov cif7,0
mov cif8,0
make_calcul2_macro '=',area,afisat,90,20,10
mov ebx,cif8
add ebx,'0'
make_text_macro ebx,area,afisat1,150,27,14
mov ecx,afisat1
add ecx,14
mov ebx,cif7
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif6
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif5
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif4
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif3
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif2
cmp cif2,'-'
je make_minus
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif1
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
mov afisat,212
cmp minus,1
je make_minus5
jne button_fail
make_minus5:
make_semne_macro '-',area,90,150,20,10
; implementare butonului care schimba semnul nr existent,fie el tastat sau deja calculat
button_change:
mov eax, [ebp+arg2]
mov ebx,button_x_1
cmp eax, button_x_1
jle button_fail
cmp eax, button_x_1+button_size_x
jg button_fail
mov eax, [ebp+arg3]; y
mov ebx ,button_y_0
cmp eax, button_y_0
jle button_fail
cmp eax, button_y_0+button_size_y
jg button_fail
inc nr_cifre
mov ebx,nr1
mov nr2,ebx
mov nr1,-1
mov op,3; se va apela inmultire dintre nr existent si -1,motiv pt care trebuie sa specificam ca operatia dorita este 3
mov cif1,0
mov cif2,0
mov cif3,0
mov cif4,0
mov cif5,0
mov cif6,0
mov cif7,0
mov cif8,0
make_calcul2_macro '=',area,afisat,90,20,10
mov ebx,cif8
add ebx,'0'
make_text_macro ebx,area,afisat1,150,27,14
mov ecx,afisat1
add ecx,14
mov ebx,cif7
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif6
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif5
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif4
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif3
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif2
cmp cif2,'-'
je make_minus
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif1
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
mov afisat,212
cmp minus,1
je make_minusf
jne button_fail
make_minusf:
make_semne_macro '-',area,90,150,20,10

button_C:
mov eax, [ebp+arg2];
mov ebx, button_x_3
cmp eax, button_x_3
jle button_fail
cmp eax, button_x_3+button_size_x
jg button_stergere1cif
mov eax, [ebp+arg3]; y
mov ebx, button_y_ultim
cmp eax, button_y_ultim
jle button_fail
cmp eax, button_y_ultim+button_size_y
jg button_fail
mov nr1,0
mov nr2,0
mov op,1
mov cif1,0
mov cif2,0
mov cif3,0
mov cif4,0
mov cif5,0
mov cif6,0
mov cif7,0
mov cif8,0
make_calcul2_macro '=',area,afisat,90,20,10
mov ebx,cif8
add ebx,'0'
make_text_macro ebx,area,afisat1,150,27,14
mov ecx,afisat1
add ecx,14
mov ebx,cif7
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif6
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif5
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif4
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif3
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif2
cmp cif2,'-'
je make_minus
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,cif1
add ebx,'0'
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
add ecx,14
mov ebx,' '
make_text_macro ebx,area,ecx,150,27,14
mov afisat,198
cmp minus,1
je make_minus4
jne button_fail
make_minus4:
make_semne_macro '-',area,90,150,20,10
; mul ebx
; add eax , [ebp+arg2]
; shl eax,2	
; add eax,area
; mov dword ptr[eax], 0FF0000h
	button_fail:
	cmp minus,0
	je acopera; acopera este pt atunci cand se vor adauga prea multe cifre si o sa treaca de pe partea stanga , pe partea drepata a ecranului , putand afecta afisarea 
	jmp afisare_litere
	acopera:
	make_text_macro ' ',area,86,150,27,14
	make_text_macro ' ',area,72,150,27,14
	make_text_macro ' ',area,58,150,27,14
	make_text_macro ' ',area,44,150,27,14
	make_text_macro ' ',area,30,150,27,14
	make_text_macro ' ',area,16,150,27,14
	make_text_macro ' ',area,2,150,27,14
	make_text_macro ' ',area,86,90,20,10
	make_text_macro ' ',area,76,90,20,10
	make_text_macro ' ',area,66,90,20,10
	make_text_macro ' ',area,56,90,20,10
	make_text_macro ' ',area,46,90,20,10
	make_text_macro ' ',area,36,90,20,10
	make_text_macro ' ',area,26,90,20,10
	make_text_macro ' ',area,16,90,20,10
	make_text_macro ' ',area,6,90,20,10
	jmp afisare_litere
	
evt_timer:
	; inc counter
	
afisare_litere:
	
	
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

;make_text_macro '0', area, 250, 60, 27, 14
make_text_macro 'S', area, 30, 7, 20, 10
make_text_macro 'T', area, 40, 7,20,10
make_text_macro 'A', area, 50, 7,20,10
make_text_macro 'N', area, 60, 7,20,10
make_text_macro 'D', area, 70, 7, 20, 10
make_text_macro 'A', area, 80, 7, 20, 10
make_text_macro 'R', area, 90, 7, 20, 10
make_text_macro 'D', area, 100, 7, 20,10


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

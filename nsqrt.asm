; Autor Jan Ciecierki

section .text

global nsqrt

; X w pammięci [rsi + n/4 - 1] ... [rsi]
; Q w pamięci [rdi + n/8 - 1] ... [rdi]
; unsigned n w rdx, a nawet edx

; Program liczy podłogę z pierwiastka z X do Q




nsqrt:
	push rbp
	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r10, rdx ; W r10 trzymamy iterator

; Dla j-tego wywołania pętli r10 = n-j+1 (iterujemy tak długo jak n-j+1>0)

;Zerujemy Q przechodząc posłowach od [rdi + (n/64-1)*8] -> [rdi]
.przygDoZerowaniaQ:
	mov r8, rdx ; r8 = n
	shr r8, 6 ; r8 = n/64
	dec r8 ; r = n/64 - 1
	jmp .zerujQ
	
.zerujQ:
	mov qword [rdi + r8*8], 0 ; zerujemy pojedyńcze słowo w Q
	dec r8
	jns .zerujQ
	jmp .petla


; Główna pętla zaczynająca iteracje 
.petla:
	; Wyliczamy kolejno n/32 i (n-j)/32 do r8, r9
	mov r8, rdx ; Przypisujemy r8 = n
	shr r8, 5 ; r8 = n / 32 czyli r8'ósme-słowo (mamy dodatek do adresu najstarszego słowa)
	dec r8 ; r8 = n / 32 - 1, bo nie chcemy słowa n/32
	mov r9, r10 ; r9 = n-j+1
	dec r9 ; r9 = n-j
	shr r9, 5 ; r9 = (n-j)/32 , bo 2(n-j)/64
	jmp .oblicz4


; Obliczamy 4^(n-j), przesunięte do dobrego słowa 
.oblicz4:
	mov rax, 1 ; ustawiamy rax na 1 jako zmienną pom
	mov rcx, r10 ; rcx = n-j+1
	dec rcx ; rcx = n-j
	shl rcx, 1 ; rcx = 2(n-j)
	and rcx, 63 ; rcx % 64, żeby wiedzieć gdzie wylądował po przesunęciu
	shl rax, cl ; przesuwamy w lewo o 2(n-j), rax = 4^(n-j)%64
	jmp .sprawdzCzyZerowe



; Iterujemy po blokach pamięci od najstraszego [rsi + n/32-1] do [rsi + (n-j)/32 + 8] włącznie
; zmniejszając r8 
.sprawdzCzyZerowe:
	cmp r8, r9 ; Sprawdzamy czy jeszcze jesteśmy w dobrym bloku r8>r9
	jbe .sprawdzCzyWystarczy
	test qword [rsi + r8*8], -1 ; Sprawdzamy czy blok nie pusty
	jnz .odejmij4 ; Jeśli tak
	dec r8 ; Odejmujemy 1 od iteratora r8
	jmp .sprawdzCzyZerowe


.sprawdzCzyWystarczy:
	;add qword [rsi], 1 TEST
	cmp qword [rsi + r9*8], rax
	jae .odejmij4
	jmp .przygDoKolejnejIteracji
	

	
; Odejmujemy 4^(n-j) od X
; rsi, rdx, rdi NIE RUSZAMY
; r10 = n-j+1 (nie ruszamy bo to iterator po głównej pętli)
; r9 = 2(n-j)/64
; r8 = wolne (bo nie możemy założyć czym jest)
; rcx = 2(n-j)%64
; rax = 4(n-j), ale tylko słowo z jedynką

.odejmij4:
	mov r11, qword [rsi + r9*8] ; Zachowujemy w r11 jakby nie starczyło
	sub qword [rsi + r9*8], rax ; Próbujemy odjąć, w tym rejestrze	
	jc .braklo
	jmp .porRzQ ; Jeśli nie brakło, to idziemy do porównywania z Q

; Wracamy stan [rsi + (n-j)/4 + 8] i negujemy bity na lewo od bitu 2(n-j)%64 (rcx)
.braklo:
	mov qword [rsi + r9*8], r11 ; wracamy ten pierwszy rejestr do stanu początkowego
	mov r11, -1
	shl r11, cl
	;mov qword [rsi], r11 ; DO TESTU !!
	or qword [rsi + r9*8], r11
	jmp .brakloLoop
	
; Robimy dec po każdym rejestrze, aż znajdziemy rejestr nie zerowy
; wiemy że taki znajdziemy, bo jesteśmy wyowałani wtw, sprawdziliśmy że da się odjąć
.brakloLoop:
	add r9, 1 ; Idziemy do starszego adresu
	dec qword [rsi + r9*8]
	js .brakloLoop
	jmp .porRzQ

; Jesteśmy na etapie że mamy odjęte X - 4^(n-j)
; Stan rejestrów:
; r8 - wolne
; r9 - indeks najstarszego słowa, które brało udział w odejmowaniu czwórki
; r10 = n-j+1 (nie ruszamy bo iterator pętli)
; r11 = wolne
; rcx = 2(n-j)%64
; rax = 4(n-j), ale tylko słowo z jedynką;
; callee saved - "wolne"
.porRzQ:
	mov rcx, r10 ; rcx = n-j+1
	and rcx, 63 ; rcx = (n-j+1)%64
	; Obliczamy indeks adresu pierwszego znaczącego słwoa Q do r12
	mov r12, rdx ; r12 = n
	shr r12, 6 ; r12 = n/64
	mov r13, r10 ; r13 = n-j+1
	shr r13, 6 ; r13 = (n-j+1)/64
	add r12, r13 ; r12 += r13
	; r13 wolne
	; Obliczamy indeks najstarszego adresu X do r13
	mov r13, rdx
	shr r13, 5 ; r13 = 2n/64
	dec r13 ; r13 = 2n/64 - 1


; Mamy indeksy w których wystarczy sprawdzić czy X puste, więc sprawdzamy
; rcx = (n-j+1)%64
; r13 = 2n/64 - 1
; r12 = n/64 + (n-j+1)/64
.sprawdzCzyPuste:
	cmp r13, r12 ; Sprawdzamy czy nadal jesteśmy w dobrym bloku
	jbe .przygDoPor ; Jeśli nie to idziemy do porównywania poszczególnych słów
	; Sprawdzamy czy puste
	test qword [rsi + r13*8], -1
	jnz .odejmijQ
	dec r13
	jmp .sprawdzCzyPuste
; r13 - wolne
; r12 - indeks najstarszego znaczącego słowa w Q


.przygDoPor:
	mov rbp, r12 ; zapsiujemy sobie na przyszłość
	mov r8, 0
	mov r13, rdx ; r13 = n
	shr r13, 6; r13 = n/64
	dec r13 ;r13 = n/64 - 1
	jmp .porownojXzQ 

; Będziemy teraz to sprawdzać takim przechodzącmy okienkiem z dwóch rejestrów <r8><r11>, tak długo
; jak nie będą równe lub skończy nam się Q, czyli są równe
; r8 = lewe słowo w ramce
; r11 = prawe słowo w ramce
; r12 - indeks porównywanego słowa z X
; r13 = indeks porównywanego słowa z Q
.porownojXzQ:
	mov r11, qword [rdi + r13*8] ; r11 to nowe słowo do naszej ramki
	shld r8, r11, cl ; w r8 mamy teraz cykliczne przesunięcie ramkiz nowym słowem w lewo o (n-j+1)%64
	cmp r8, qword [rsi + r12*8] ; porównujemy
	ja .dodaj4 ; Q > X, czyli dodaj 4^(n-j) z powrotem
	jb .przygDoOdejmijQ ; Q < X, czyli odejmujemy Q i zmieniamy bit (n-j) w Q
	; Jeśli są równe to sprawdzamy dalej, chyba że poza zakresem
	mov r8, r11 ; prawe okienko dajemy na lewo
	dec r12 ; tu się nie martwimy bo r12 >= r13
	dec r13 ; idziemy z r13 w lewo
	jns .porownojXzQ ;r13 > 0, sprawdzamy dalej
	jmp .porownajOstatnie ; wszystie równe, aż do ostatniego


.porownajOstatnie:
	mov r11, 0
	shld r8, r11 , cl ; ostatnie słowo, przesuwamy razem z zerami, bo nie chcemy sięgać do adresu za Q
	cmp r8, qword [rsi + r12*8]
	jbe .przygDoOdejmijQ
	ja .dodaj4

; Idziemy teraz od najmłodszych słów Q po przesunięciu
; rcx = (n-j+1)%64
; r8 - wolne
; r11 - wolne
; r12 - wolne
; r13 - wolne

; Obliczamy indeks najmłodszego znaczącego słowa z Q do r12 i  indeks najbardziej
; znaczącego słowa z Q

.przygDoOdejmijQ:
	mov r12, r10 ; r12 = n-j+1
	shr r12, 6 ; r12 = (n-j+1)/64
	mov r11, 0 ; na początku prawa część ramki pusta
	mov r13, 0
	jmp .odejmijQ

; rbp = n/64 + (n-j+1)/64, czyli najbardziej znaczące słowo w przesuniętym Q
; r12 = (n-j+1)/64
; rcx = (n-j+1)%64
.odejmijQ:
	cmp r12, rbp ; Iterujemy od r12 do rbp
	ja .ustawQ
	mov r8, qword [rdi + r13*8] ; r8 nowe słowo do ramki
	mov rbx, r8 ;  zapisujemy lewą strone słowa 
	shld r8, r11, cl ; przesuwamy r8 i częsć r11 do r8 o (n-j+1)%64
	mov r11, rbx ; r11, byłe lewe słowo
	sub qword [rsi + r12*8], r8 ; odejmujemy słowa
	; Jeśli nie starczyło to wchodzimy do pętli, a wiemy że X > Q, więc znajdziemy pożyczkę 
	jc .petlaBorrow
	inc r12
	inc r13
	jmp .odejmijQ

; Pętla do szukania pożyczki	
.petlaBorrow:
	inc r12
	inc r13
	sub qword [rsi + r12*8], 1
	jc .petlaBorrow ; jeśli znowu braknie to dalej szukamy pożyczki
	dec r13
	mov r11, qword [rdi + r13*8]
	inc r13
	jmp .odejmijQ

; w rax dalej mamy znaczące słowo 4^(n-j)
; r8 -wolne
; r11 - wolne
; Jeśli Q > X, po odjęciu 4^(n-j), to musimy dodać to 4^(n-j)
.dodaj4:
	mov r8, r10 ; r8 = n-j+1
	dec r8 ; r8 = n-j
	shr r8, 5 ; r8 = 2(n-j)/64
	add qword [rsi + r8*8], rax ; dodaj znaczące słowo z 4^(n-j)
	jc .petlaCarry
	jmp .przygDoKolejnejIteracji

.petlaCarry:
	inc r8 ; idziemy do bardziej znaczącego słowa
	add qword [rsi + r8*8], 1 ; próbujemy dodać to carry
	jc .petlaCarry
	jmp .przygDoKolejnejIteracji

; r8 - wolne
; r9 - wolne
.ustawQ:
	mov r8, r10 ; r8 = n-j+1
	dec r8 ; r8 = n-j
	mov r9, r8 ; r9 = n-j
	shr r8, 6 ; r8 = (n-j)/64
	and r9, 63 ; r9 = (n-j)%64
	bts qword [rdi + r8*8], r9 ; ustawiamy bit n-j w Q na 1
	jmp .przygDoKolejnejIteracji

.przygDoKolejnejIteracji:
	dec r10
	jnz .petla
	jmp .koniec

.koniec:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

	
	



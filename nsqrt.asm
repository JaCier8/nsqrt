global nsqrt

; X w pamięci [rsi + n/4] ... [rsi]
; Q w pamięci [rdi + n/8] ... [rdi]
; unsigned n w rdx, a nawet edx


nsqrt:
	mov rcx, rdx ; Trzymamy iterator w rcx

; Dla j-tego wywołania pętli rcx = n-j+1 (iterujemy tak długo jak n-j>=0)
.loop:
	; Wyliczamy kolejno n/4 i (n-j)/4 + 8 do r8, r9
	mov r8, edx ; Przypisujemy r8 = n
	shr r8, 2 ; Dzielimy n przez 4 (mamy dodatek do adresu najstar słw)
	mov r9, rcx ; r9 = n-j+1
	dec r9 ; r9 = n-j
	shr r9, 2 ; r9 = (n-j)/4
	add r9, 8 ; r9 = (n-j)/4 + 8
	jmp .oblicz4
	jmp ; TODO skaczemy do sprawdzacza czy są jakieś bity w rejestrach

; Iterujemy po blokach pamięci od najstraszego [rsi + n/4] do [rsi + (n-j)/4 + 8] włącznie
; zmniejszając n/4 czyli r8 o 8
.sprawdzCzyZerowe:
	cmp r8, r9 ; Sprawdzamy czy jeszcze jesteśmy w dobrym bloku
	jmb .sprawdzCzyWystaraczy
	test qword [rsi + r8], -1 ; Sprawdzamy czy blok pusty
	jnz .odejmij4
	sub r8, 8 ; Odejmujemy 8 od iteratora
	jmp .sprawdzCzyZerowe

; Kod głównie taki sam jak w odejmij, bo też próbujemy uzyskać to 4^(n-j)
.sprawdzCzyWystarczy:
	mov r11, qword [rsi + r9]
	sub r11, r8
	

; Obliczamy 4^(n-j), 
.oblicz4:
	mov rax, 1 ; ustawiamy r8 na 1 jako zmienną pom
	mov r10, rcx ; r10 = n-j+1
	dec r10 ; r10 = n-j
	shl r10, 1 ; r10 = 2(n-j)
	and r10, 63 ; r10 % 64, żeby wiedzieć gdzie wylądował po przesunęciu
	shl rax, r10 ; Mnożymy r8 z 4^(n-j)
	jmp .sprawdzCzyZerowe

	
; Odejmujemy 4^(n-j) od X
.odejmij4:	
	mov r11, qword [rsi + r9]
	sub r11, rax
	
	jc .braklo
	jmp .porRzQ; TODO jeśli nie brakło, to idziemy do porównywania z Q

; Wracamy stan [rsi + 2(n-j)/4 + 8] i negujemy bity na lewo od bitu 2(n-j)%64 (r10)
.braklo:
	mov qword [rsi + r9], r11 ; wracamy ten pierwszy rejestr do stanu początkowego	
	mov r11, -1
	shl r11, r10
	and qword [rsi + r9], r11
	jmp.brakloLoop
	
; Robimy dec po każdym rejestrze, aż znajdziemy rejestr nie zerowy
; wiemy że taki znajdziemy, bo jesteśmy wyowałani wtw, sprawdziliśmy że da się odjąć
.brakloLoop:
	add r9, 8 ; Idziemy do starszego adresu
	dec [rsi + r9]
	js .brakloLoop
	jmp .porRzQ
	
.porRzQ

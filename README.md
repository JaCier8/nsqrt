# nsqrt

**Autor: Jan Ciecierki**

## Opis

`nsqrt` to wysoce zoptymalizowany program do obliczania podłogi z pierwiastka kwadratowego z bardzo dużych liczb całkowitych. Rdzeń logiczny projektu jest zaimplementowany bezpośrednio w **asemblerze x86-64 (NASM)**, co zapewnia maksymalną wydajność operacji bitowych.

Projekt zawiera:
* **`nsqrt.asm`**: Plik źródłowy asemblera zawierający główną, eksportowaną funkcję `nsqrt`.
* **`main.c`**: Przykładowy program w C, służący jako test i demonstracja wywołania zewnętrznej funkcji asemblerowej `nsqrt`.

## Algorytm

Implementacja w `nsqrt.asm` wykorzystuje klasyczny algorytm (podobny do dzielenia pisemnego) do obliczania pierwiastka kwadratowego. Kluczowe kroki algorytmu widoczne w kodzie to:

1.  **Inicjalizacja**: Zerowanie rejestrów i pamięci wynikowej `Q`.
2.  **Iteracja**: Pętla (`.petla`) wykonująca się `n` razy (dla `n` bitów).
3.  **Obliczanie kandydata**: Obliczanie wartości `4^(n-j)` (w `.oblicz4`).
4.  **Test i odjęcie**: Sprawdzenie, czy `X` (reszta) jest większe lub równe kandydatowi. Jeśli tak, kandydat jest odejmowany od `X` (w `.odejmij4` i `.braklo`).
5.  **Porównanie z Q**: Porównanie `X` z aktualną wartością `Q` przesuniętą bitowo (w `.porRzQ`).
6.  **Aktualizacja Q**: Jeśli warunki są spełnione, odpowiedni bit w `Q` jest ustawiany na 1 (w `.ustawQ`).

## Interfejs API (C/C++)

Funkcja asemblerowa `nsqrt` jest zgodna ze standardową konwencją wywołań x86-64 System V (używaną w Linuksie i macOS), co pozwala na jej bezpośrednie wywołanie z C.

**Deklaracja w C:**
```c
/* * Oblicza pierwiastek kwadratowy z 'n'-bitowej liczby.
 * Q - wskaźnik na pamięć wyjściową (wynik)
 * X - wskaźnik na pamięć wejściową (liczba)
 * n - liczba bitów (rozmiar X i Q)
 */
extern void nsqrt(void *Q, void *X, unsigned n);

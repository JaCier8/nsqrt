# nsqrt

## Opis

`nsqrt` to projekt w języku C przeznaczony do wydajnego obliczania pierwiastka kwadratowego z bardzo dużych liczb całkowitych. Implementacja opiera się na algorytmach operujących bezpośrednio na reprezentacji bitowej liczb, co pozwala na obsługę typów wykraczających poza standardowe `double`.

Główna logika programu znajduje się w pliku `main.c` i obejmuje funkcje do obliczeń na liczbach 64-bitowych (`uint64_t`) oraz 128-bitowych (realizowanych za pomocą wskaźników na `uint64_t`).

## Funkcjonalności

* **Obliczanie pierwiastka z `uint64_t`:** Implementacja funkcji `nsqrt` dla 64-bitowych liczb całkowitych bez znaku.
* **Wsparcie dla 128-bitów:** Implementacja funkcji `nsqrt128` pozwalającej na obliczenia dla 128-bitowych liczb całkowitych.
* **Optymalizacje bitowe:** Wykorzystanie makr i operacji bitowych (`IS_1`, `SET_1`, `SET_0`) do szybkiego przetwarzania danych.
* **Standard C11:** Kod napisany jest w nowoczesnym standardzie C11.

## Wymagania systemowe

Do zbudowania projektu potrzebne są:
* **CMake** (wersja 3.31 lub nowsza)
* Kompilator C wspierający standard C11 (np. GCC, Clang)
* Narzędzie budowania (np. Ninja lub Make)

## Kompilacja i uruchamianie

Projekt wykorzystuje system budowania CMake. Aby go skompilować, wykonaj poniższe kroki w terminalu:

1.  **Utwórz katalog na pliki budowania:**
    ```bash
    mkdir build
    cd build
    ```

2.  **Skonfiguruj projekt za pomocą CMake:**
    ```bash
    cmake ..
    ```

3.  **Zbuduj projekt:**
    ```bash
    cmake --build .
    ```

4.  **Uruchom program:**
    Po pomyślnej kompilacji plik wykonywalny `nsqrt` znajdzie się w katalogu `build` (lub `cmake-build-debug`, jeśli używasz IDE takiego jak CLion).

    ```bash
    ./nsqrt
    ```

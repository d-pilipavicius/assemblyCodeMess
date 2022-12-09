.MODEL small
.STACK 100h
.DATA
savedValue dw 0
textOutput db "Iveskite teksto eilute: $"
inputBuf db 255,0,255 DUP(?)

.CODE
strt:
mov ax,@data
mov ds,ax

mov ah,09h                        ;isveda textOutput
mov dx,OFFSET textOutput
int 21h

mov ah,0Ah                        ;eilutes nuskaitymas
mov dx,OFFSET inputBuf
int 21h
mov ah,02h                        ;simbolio isvedimas
mov dl,0Dh                        ;zymeklio padejimas i pradzia
int 21h
mov dl,0Ah                        ;persokimas i kita eilute
int 21h
mov si,00h                        ;si registrui priskiriama reiksme 0, nes ji bus naudojama tikrinti kuri simboli dabar nagrineja programa.

find:
inc si                            ;si reiksmes padidinimas vienetu, t.y. perejimas prie kito simbolio nagrinejimo
mov savedValue,si                 ;kadangi si reiksme kis, kad programa nepamestu kuri nari eileje seka iraso ji i kintamaji
mov bx,OFFSET inputBuf            ;nustatoma pointerio reiksme po truputi, kuri bus naudojama nuskaitymui			              
mov al,[bx+si+01h]                ;is pointerio paimamas atitinkamai analizuojamas simbolis
cmp al,30h						  ;patikrinama ar reiksme didesne uz '0' ascii koda
jae areTheseNumbers               ;jei taip, sokama i tikrinima ar reiksme yra skaiciu intervale

thoseWerentNumbers:               
cmp al,61h                        ;patikrinama ar reiksme didesne arba lygi reiksmei 'a' ASCII kode
jnae break                        ;jei salyga nepatenkinama, persokama i break
cmp al,7Ah                        ;jei salyga patenkinama, patikrinama ar reisme mazesne ar lygi reiksmei 'z' ASCII kode 
jnbe break                        ;jei salyga nepatenkinama, persokama i break
                                  ;jei salyga patenkinama, prieinama i isvedima i ekrana
thoseWereNumbers:

mov bx,0h                         ;bx priskiriama 0, nes siame registre bus sekama kiek reiksmiu padeta i steka
bigNumber:                        ;salyga daroma, kol si skaicius isdalijamas i skaitmenis
cmp si,0Ah                        ;patikrinama, ar si(reiksme, kuri naudojama nustatyti kuri simboli eiluteje dabar tikrina) nera didesne ar lygi 10
jae modulo                        ;jei ji didesne ar lygi 10, sokama i modulo

printNumber:
mov ah,02h                        ;pasiruosiama skaitmens isvedimui
add si,30h                        ;pridedama 48 prie skaiciaus reiksmes, kad isvedus ji kaip simboli sis atitiktu savo zymejima ASCII sistemoje
mov dx,si                         ;isvedama si reiksme kaip simbolis, kuris atitinka savo zymejima skaiciu aibeje
int 21h
cmp bx,0h                         ;patikrinama ar steke nera papildomu skaiciu
jne pushStack                     ;jei yra, sokama i pushStack, kol nelieka papildomu skaiciu ir visi isvesti i ekrana

mov dx,20h                        ;isvedamas tarpas tarp skaiciu kai pilnai isvedamas vienazenklis/daugiazenklis skaicius
int 21h
jmp break                         ;kai isvedamas skaicius sokama i break, kad si padidetu vienetu ir butu tikrinamas sekantis simbolis

break:                            ;cia sokama po si pozicijos patikrinimo/isvedimo
mov si,savedValue                 ;jei buvo keiciama si reiksme dalijant skaiciu i skaitmenis, grazinama pradine si pozicija, kuri sikart buvo tikrinama
mov bx,OFFSET inputBuf	          ;nustatoma pointerio reiksme po truputi, kuri bus naudojama nuskaitymui
mov al,[bx+si+01h]                ;is pointerio paimamas atitinkamai analizuojamas simbolis
cmp al,0Dh                        ;patikrinamas dabartinis analizuotas simbolis ir ar jis atvaizduoja pabaiga
jne find                          ;jei simbolis neatvaizduoja pabaigos, griztama tikrinti likusiu simboliu, jei atvaizduoja, tada programa baigia darba
jmp endProgram                    ;jei simbolis atvaizduoja pabaiga, sokama i ja

areTheseNumbers:
cmp al,39h						  ;patikrinama, ar reiksme yra skaiciu intervale
jbe thoseWereNumbers              ;jei taip, praleidziamas raidziu tikrinimas
jmp thoseWerentNumbers            ;jei ne, tikrinama ar ten mazosios raides

modulo:                           ;cia daugiazenklis skaicius po truputi dalijamas i skaitmenis, kurie surasomi i steka
mov dx,0h                         ;ruosiamasi dalybai
mov ax,si                         ;ax priskiriama si reiksme, nes si elementas bus skirstomas i individualius skaitmenis
mov cx,0Ah                        ;daliklis priskiriamas skaiciui 10, nes tokiu butu i liekana isiraso skaitmuo                        
div cx                            ;dalinama is 10, nes siekiama paskutini skaiciu patalpinti i steka, kad isvedant skaiciu pagal ASCII reiksmes visas skaicius neatitiktu netinkamo simbolio
mov si,ax                         ;dalmuo priskiriamas si reiksmei
push dx                           ;i steka patalpinama liekana
inc bx                            ;nurodoma, kad steke +1 liekanos reiksme
jmp bigNumber                     ;griztama patikrinti ar si nera didesnis ar lygus 10

pushStack:
pop si                            ;si priskiriama steko reiksme
dec bx                            ;pasakoma, kad steke viena reiksme maziau
jmp printNumber                   ;griztama isvesti nauja si reiksme

endProgram:
mov ax,04C00h
int 21h

end strt                                    
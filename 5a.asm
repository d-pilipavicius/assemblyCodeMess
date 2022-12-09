.MODEL small
.STACK 100h
.DATA
errorBadParametersMessage db "Blogai ivesti pradiniai parametrai! Patikrinkite, ar ivedete parametrus ir ar jie turi tipa (pvz.: .txt).",0Dh,0Ah,'$'
errorNoEnterMessage db "Pries paleidziant programa, privaloma priskirti jai parametrus!",0Dh,0Ah,'$'
errorTooMuchEnteredMessage db "Itraukta per daug pradiniu parametru!",0Dh,0Ah,'$'
howToUseMessage db "Si programa reikalauja tokiu pradiniu parametru kaip: ",'"',"5a duom.txt rez.txt",'".',0Dh,0Ah,"Cia duom.txt - duomenu failo pavadinimas, rez.txt - sukuriamo failo pavadinimas, kuriame bus irasomi rezultatai.",0Ah,0Dh,'$'
errorNoFileFound db "Neimanoma atidaryti ar nerastas irasytas failas: $"
taskDoneMessage db "Failas sekmingai nuskaitytas ir informacija patalpinta byloje $"
enterSymbols db 0Dh,0Ah,'$'

openFile db 100h DUP(0)
writeFile db 100h DUP(0)
openHandle dw 0
writeHandle dw 0
readFileSize dw 0
fileBuf db 100h DUP(?)
readCharPrint db 0,0,0,' '

.CODE
strt:
mov ax,@data
mov ds,ax

mov bx,81h                                    ;Konstanta, kuri naudojama prieiti prie parametru

;----------------------------------------------PARAMETRU PRADININS TIKRINIMAS
recheck:
mov ax,es:[bx]                                ;ax priskiriama parametro reiksme
inc bx                                        ;Padidinamas bx 1, kitam kartui kai bus tikrinamas parametras
cmp al,0Dh                                    ;Patikrinama, ar varotojas ivede kazkokius parametrus (jei neivede, reiskia ras tik enter paspaudima)
je noValueHelp                                ;Jei vartotojas neivede parametru, isvedama klaida i ekrana
cmp al,' '                                    ;Jei nepaspausta enter, tikrinama ar yra tarpas
je recheck                                    ;Tarpas praleidziamas, jei jis randamas
cmp ax,"?/"                                   ;Tikrinama, ar vartotojas parametre nepraso pagalbos
je help                                       ;Jei varotojas praso pagalbos, i ekrana isvedama ka reikia daryti
;----------------------------------------------PARAMETRU PRADININS TIKRINIMAS

jmp getAroundErrors
;----------------------------------------------KLAIDU ZINUTES
noValueHelp:
mov dx,OFFSET errorNoEnterMessage             ;Klaidos zinute, kuri pasako, kad parametrai nebuvo ivesti
CALL Write                                    ;Isvedama klaida i ekrana
jmp help                                      ;Prieinama prie isvedimo i ekrana kaip be klaidu reikia ijungti programa su parametrais

badParametersHelp:
mov dx,OFFSET errorBadParametersMessage       ;Klaidos zinute, kuri pasako, kad blogai ivesti parametrai (ju nepakanka, nepridetas failo tipas)
CALL Write                                    ;Isvedama klaida i ekrana
jmp help                                      ;Prieinama prie isvedimo i ekrana kaip be klaidu reikia ijungti programa su parametrais

help:                                         
mov dx,OFFSET howToUseMessage                 ;Zinute, nurodanti kaip naudotis programa
CALL Write                                    ;Isvedama zinute i ekrana
jmp endOfExe                                  ;Programa baigia darba
;----------------------------------------------KLAIDU ZINUTES
getAroundErrors:

;----------------------------------------------PIRMO PARAMETRO ILGIO NUSTATYMAS
dec bx                                        ;Jei nustatoma, kad vartotojas ivede kazkokius parametrus, sumazinamas bx 1, kad kita sekcija toliau nagrinetu esanti simboli
mov si,bx                                     ;Nustatomas atidaromo failo pavadinimo pradzios indeksas
mov cx,0                                      ;Ateinanciam LOOP bus naudojamas cx registras, kuris duoda parametro ilgi
CALL GetNameLength                            ;Randama duomenu failo pavadinimo ilgis
cmp al,0Dh                                    ;Patikrinama, ar nebuvo irasytas tik vienas parametras
je badParametersHelp                          ;Jei buvo, ismetama klaida
;----------------------------------------------PIRMO PARAMETRO ILGIO NUSTATYMAS

;----------------------------------------------BX REGISTRO POSLINKIS IKI ANTRO PARAMETRO
loopForWhiteSpaces1:
inc bx                                        ;Padidinamas bx 1 naujo simbolio tikrinimui
mov al,es:[bx]                                ;Ikeliamas naujas simbolis i registra al is parametru
cmp al,' '                                    ;Tikrinama, ar naujas simbolis yra tarpas
je loopForWhiteSpaces1                        ;Jei taip, pradedamas tikrinimas is naujo, kol al nebebus tarpo reiksme
cmp al,0Dh                                    ;Jei al reiksme ne tarpas, tikrinama ar ten enter simbolis 
je badParametersHelp                          ;Jei al reiksme enter simbolis, ismetama klaidos zinute
;----------------------------------------------BX REGISTRO POSLINKIS IKI ANTRO PARAMETRO

;----------------------------------------------PIRMO PARAMETRO IVEDIMAS I openFile BUFFERI
mov dx,0                                      ;Registras dx naudojamas '.' simboliui skaiciuoti
getOpenFileSizeName:
push bx                                       ;Registras bx laiko svarbia reiksme, taciau bx reikia naudoti, todel jo reiksme trumpam patalpinama i steka
mov bx,cx                                     ;bx priskiriama cx reiksme
mov al,es:[bx+si-1]                           ;I al perkeliamas sekamas simbolis
cmp al,'.'                                    ;Patikrinama, ar al yra '.' simbolis
je callF                                      ;Jei yra, kvieciama funkcija Extension
jmp noCallF                                   ;Jei nera, praleidziama funkcija
callF:
CALL Extension                                ;Funkcija patikrina, ar irasytas failo pavadinimas turi ir pavadinima, ir tipa.
noCallF:                                      
push si                                       ;Registras si laiko svarbia reiksme, taciau si reikia naudoti, todel jo reiksme trumpam patalpinama i steka
mov si,OFFSET openFile                        ;I si patalpinama atidaromo dokumento pavadinimo laikymo kintamojo adresas
mov [bx+si-1],al                              ;I tam tikra pozicija patalpinama pavadinimo atitinkamas simbolis
pop si                                        ;Grazinamos pradines si ir bx reiksmes
pop bx                                        ;^
LOOP getOpenFileSizeName                      ;Ciklas vykdomas, kol irasomas visas pavadinimas
cmp dx,0                                      ;Patikrinama, ar buvo rastas failo tipas
je badParametersHelp                          ;Jei nebuvo, ismetama klaida
;----------------------------------------------PIRMO PARAMETRO IVEDIMAS I openFile BUFFERI

;----------------------------------------------ANTRO PARAMETRO ILGIO NUSTATYMAS
mov si,bx                                     ;Nustatomas antro parametro pradzios indeksas
mov cx,0                                      ;Ateinanciam LOOP bus naudojamas cx registras, kuris duoda parametro ilgi
CALL GetNameLength                            ;Gaunamas antro parametro ilgis
;----------------------------------------------ANTRO PARAMETRO ILGIO NUSTATYMAS
jmp o1
iBadParameters1:                              ;jmp ilgiui pratesti skirta kodo dalis
jmp badParametersHelp
o1:
;----------------------------------------------TIKRINIMAS AR NERA DAUGIAU NEI 2 PARAMETRAI
loopForWhiteSpaces2:
inc bx                                        ;Didinamas skaitomo parametro indeksas 1
mov al,es:[bx]                                ;Ikeliamas analizuojamas parametro simbolis
cmp al,' '                                    ;Tikrinama, ar simbolis nera tarpas
je loopForWhiteSpaces2                        ;Jei simbolis yra tarpas, sukamas ciklas, kol nebebus tarpu
cmp al,0Dh                                    ;Tikrinama, ar vartotojas  
je badParametersHelp
mov dx,0
jmp getWriteFileSizeName
;----------------------------------------------TIKRINIMAS AR NERA DAUGIAU NEI 2 PARAMETRAI

;----------------------------------------------ANTRO PARAMETRO IVEDIMAS I writeFile BUFFERI
getWriteFileSizeName:
push bx                                       ;Registras bx laiko svarbia reiksme, taciau bx reikia naudoti, todel jo reiksme trumpam patalpinama i steka
mov bx,cx                                     ;bx priskiriama cx reiksme
mov al,es:[bx+si-1]                           ;I al perkeliamas sekamas simbolis
cmp al,'.'                                    ;Patikrinama, ar al yra '.' simbolis
je callF2                                     ;Jei yra, kvieciama funkcija Extension
jmp noCallF2                                  ;Jei nera, praleidziama funkcija
callF2:
CALL Extension                                ;Funkcija patikrina, ar irasytas failo pavadinimas turi ir pavadinima, ir tipa.
noCallF2:                                      
push si                                       ;Registras si laiko svarbia reiksme, taciau si reikia naudoti, todel jo reiksme trumpam patalpinama i steka
mov si,OFFSET writeFile                       ;I si patalpinama atidaromo dokumento pavadinimo laikymo kintamojo adresas
mov [bx+si-1],al                              ;I tam tikra pozicija patalpinama pavadinimo atitinkamas simbolis
pop si                                        ;Grazinamos pradines si ir bx reiksmes
pop bx                                        ;^
LOOP getWriteFileSizeName                     ;Ciklas vykdomas, kol irasomas visas pavadinimas
cmp dx,0                                      ;Patikrinama, ar buvo rastas failo tipas
je iBadParameters1                            ;Jei nebuvo, ismetama klaida

;----------------------------------------------ANTRO PARAMETRO IVEDIMAS I writeFile BUFFERI


;----------------------------------------------1 FAILO ATIDARYMAS
mov dx,OFFSET openFile                        ;I dx perkeliamas atidaromo failo pavadinimas
mov ax,3D00h                                  ;Failo atidarymas
int 21h                                       ;^
mov si,OFFSET openFile                        ;I si perkeliamas atidaromo failo pavadinimas klaidos atveju
jc errorWhileOpening                          ;Patikrinama ar failas neatsidare
mov [openHandle],ax                           ;Jei failas atsidare, issaugojamas bylos deskriptorius
jmp createFile                                ;Einama prie failo kurimo
errorWhileOpening:
mov dx,OFFSET errorNoFileFound                ;I dx perkeliama klaidos zinute
CALL Write                                    ;Klaidos zinute isvedama i ekrana
CALL PrintString                              ;Isvedama klaidingai atidaryto/sukurto failo pavadinimas
mov dx,OFFSET enterSymbols                    ;I dx perkeliami tarpo simboliai
CALL Write                                    ;Isvedamas tarpas i ekrana
jmp help                                      ;Einama prie teisingu parametru ivedimo paaiskinimo
;----------------------------------------------1 FAILO ATIDARYMAS

;----------------------------------------------2 FAILO ATIDARYMAS
createFile:
mov dx,OFFSET writeFile                       ;I dx irasoma kuriamo failo pavadinimas
mov ah,3Ch                                    ;Sukurimo funkcija
mov cx,0                                      ;Failas sukuriamas paprastai, be papildomu daliu
int 21h                                       ;Sukuriamas failas
mov si,OFFSET writeFile                       ;I si perkeliama failo pavadinimas klaidos atveju
jc errorWhileOpening                          ;Jei ivyko klaida kuriant faila, ismetama klaidos zinute
mov [writeHandle],ax                          ;Jei sekmingai sukurtas failas, sukurtos bylos deskriptorius irasomas i kintamaji
jmp readFile                                  ;Einama prie failu skaitymo/rasymo

;----------------------------------------------2 FAILO ATIDARYMAS
iBadParameters2:
jmp iBadParameters1
;----------------------------------------------openFile SKAITYMAS
readFile:
mov ah,3Fh                                    ;Failo skaitymo funkcija
mov bx,[openHandle]                           ;I bx perkeliama skaitomo failo bylos deskriptorius
mov cx,100h                                   ;Irasoma, kiek simboliu bandys perskaityti failas (512)
mov dx,OFFSET fileBuf                         ;Irasomas bufferio pavadinimas i kuri bus rasomas failas
int 21h                                       ;Ivykdomas failo skaitymas
jc closeFile                                  ;Jei nebegalima skaityti failo, failai uzdaromi

or ax,ax                                      ;Patikrinama, ar neperskaityta 0 simboliu
jz closeFile                                  ;Jei perskaityta 0, uzdaromi failai
mov [readFileSize],ax                         ;Issaugoma, kiek failo yra perskaityta
mov cx,ax                                     ;I cx patalpinama kiek simboliu reikes pavertineti i 16taine sis. ir irasineti i faila
jmp writeToFile                               ;Perejimas prie rasymo i faila
closeFile:
mov bx,[openHandle]                           ;Irasomas skaitomo failo deskriptorius
or bx,bx                                      ;Patikrinama, ar skaitomos bylos deskriptorius nelygus 0
jz endOfExe                                   ;Jei deskriptorius lygus 0, baigiamas darbas
mov ah,3Eh                                    ;Uzdaromas skaitomas failas
int 21h                                       ;^

mov bx,[writeHandle]                          ;Irasomas rasomo failo deskriptorius
or bx,bx                                      ;Patikrinama, ar rasomos bylos deskriptorius nelygus 0
jz endOfExe                                   ;Jei deskriptorius lygus 0, baigiamas darbas
mov ah,3Eh                                    ;Uzdaromas rasomas failas
int 21h                                       ;^
jmp successfulTask                            ;Baigiamas programos darbas

writeToFile:
mov bx,OFFSET fileBuf                         ;I bx keliamas buferio adresas
mov si,[readFileSize]                         ;I si keliamas skaitomo teksto ilgis
sub si,cx                                     ;Atimama cx, kad si atsirastu dabartinio skaitomo simoblio indeskas
mov al,[bx+si]                                ;I al patalpinamas skaitomas simbolis
cmp al,0Dh
je addEnter
mov ah,0                                      ;I ah patalpinamas 0 (svarbu dalybai)
CALL asciiToHex                               ;Simbolio pavertimas 16 sistema
push cx                                       ;Cx reiksme padalpinama i steka
mov cx,04h                                    ;Nurodoma, kad i faila spausdinami 3 simboliai
mov bx,[writeHandle]                          ;I bx perkeliamas rasomo failo deskriptorius
mov ah,40h                                    ;Simboliu ivedimo i rasymo faila funkcija
mov dx,OFFSET readCharPrint                   ;16tainio pavidalo simboliai
int 21h                                       ;Isvedami simboliai i faila
pop cx                                        ;Cx reiksme susgrazinama is steko
LOOP writeToFile                              ;Sukamas ciklas, kol isvesti visi simboliai
jmp readFile                                  ;Failas skaitomas, kol nebera simboliu
addEnter:
mov [readCharPrint],0Dh
mov [readCharPrint+1],0Ah
dec cx
push cx                                     
mov cx,02h                                   
mov bx,[writeHandle]                         
mov ah,40h                                   
mov dx,OFFSET readCharPrint                  
int 21h                                       
pop cx
LOOP writeToFile                                     
jmp readFile
;----------------------------------------------openFile SKAITYMAS IR writeFile RASYMAS
iBadParameters3:
jmp iBadParameters2

successfulTask:                               ;Isvedimas i ekrana, kad uzduotis atlikta sekmingai
mov dx,OFFSET taskDoneMessage
CALL Write
mov si,OFFSET writeFile
CALL PrintString
mov dx,OFFSET enterSymbols
CALL Write
endOfExe:
mov ax,4C00h
int 21h


Write PROC                                    ;Rasymo i ekrana funkcija
push ax
mov ah,09h
int 21h
pop ax
ret
Write ENDP;-----------------------------------------------------------------------------------------------------

GetNameLength PROC                            ;Funkcija, skirta failo pavadinimo simboliu skaiciui rasti
anotherLetter:
mov al,es:[bx]                                ;Skaiciuojamo simbolio is parametro ikelimas i al registra lyginimui
cmp al,' '                                    ;Tikrinama, ar vis dar narginejamas failo pavadinimas
je lengthGot                                  ;Jei ne, baigiamas ilgio skaiciavimas, kuris talpinamas cx registre
cmp al,0Dh                                    ;^^
je lengthGot                                  ;^^
inc bx                                        ;Einama prie kitos parametro reiksmes
inc cx                                        ;Kadangi rasta, kad sis simbolis priklauso failo pavadinimui, padidinama teksto ilgio reiksme 1
jmp anotherLetter                             ;Einama prie kito simbolio analizavimo
lengthGot:
ret
GetNameLength ENDP;---------------------------------------------------------------------------------------------

Extension PROC                                ;Funkcija, skirta patikrinti, ar failas turi pavadinima ir tipa
mov al,es:[bx+si]                             ;Paimamas uz '.' simbolio esantis simbolis
cmp al,' '                                    ;Paimtas simbolis lyginamas su ' ' simboliu
je iBadParameters3                            ;Jei uz '.' yra padetas tarpas, ismetama klaidos zinute
cmp al,0Dh                                    ;^^
je iBadParameters3                            ;Jei uz '.' yra padetas enter zenklas, falio pavadinimas parasytas klaidingai
cmp dx,0                                      ;Kadangi failas turi tipa, patikrinama, ar analizuojamas '.' simbolis rastas pirma karta
je isThereName                                ;Jei '.' rastas pirma karta, tikrinama ar failas turi ir pavadinima
jmp nextOpen1                                 ;Jei '.' rastas ne pirma karta, grazinamas simbolis ivedimui i kintamaji
isThereName:                                  
mov al,es:[bx+si-2]                           ;Paimamas pirmas simbolis pries '.' simboli
cmp al,' '                                    ;Tikrinama ar pries '.' simboli yra tarpas 
je iBadParameters3                            ;Jei prie '.' yra padetas tarpas, ismetama klaidos zinute
nextOpen1:
inc dx                                        ;Registras dx padidinamas 1 ir nurodo, kad rastas +1 '.' simbolis
mov al,es:[bx+si-1]                           ;I registra al grazinamas '.' simbolis, kuris buvo tikrinamas
ret
Extension ENDP;--------------------------------------------------------------------------------------------------

PrintString PROC
push ax                                       ;Issaugoja ax ir dx reiksmes steke
push dx                                       ;^

cld                                           ;Isvalo df flag
mov ah,2h                                     ;Simboliu isvedimas

@@Repeat:
lodsb                                         ;Patalpina i al bufferi
or al,al                                      ;Jei al = 0, tai
jz @@Exit                                     ;^ sokama i @@Exit
mov dl,al                                     ;I dl patalpinama reiksme, kuri bus isvedama
int 21h                                       
jmp SHORT @@Repeat                            ;Ciklas vykdomas kol isvedamas visas bufferis
@@Exit:

pop dx                                        ;Grazinamos dx ir ax reiksmes
pop ax                                        ;^
ret
PrintString ENDP;--------------------------------------------------------------------------------------------------

asciiToHex PROC
push dx                                       ;Patalpinama dx reiksme i steka, jei tokia buvo
mov dl,0Ah                                    ;Paruosiama dalyba is 10
div dl                                        ;Dalinamas simbolio ascii kodas is 10
pop dx                                        ;Grazinama dx reiksme is steko
cmp al,9
ja twoNr
or al,al
jz noNr
jmp oneNr
twoNr:
add ah,30h
mov [readCharPrint+2],ah
mov ah,0
push dx
mov dl,0Ah
div dl
pop dx
add al,30h
add ah,30h
mov [readCharPrint],al
mov [readCharPrint+1],ah
jmp toReturn
oneNr:
add al,30h
add ah,30h
mov [readCharPrint+2],ah
mov [readCharPrint+1],al
mov [readCharPrint],' '
jmp toReturn
noNr:
add ah,30h
mov [readCharPrint+2],ah
mov [readCharPrint+1],' '
mov [readCharPrint],' '
toReturn:
ret
asciiToHex ENDP;---------------------------------------------------------------------------------------------------

end strt
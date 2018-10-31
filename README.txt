kl.txt: lista klas do głosowania na, w tej samej kolejności w której, będzie się odbywać głosowanie, kolejne linie zostaną użyte do napisów na ekranie głosowania.

os.txt: lista osób w żyrii, w tej samej kolejności w której są zapisane w progeamie id ich pilotów (najlepiej stwierdzić komu dać dany pilot po uruchomieniu programu), jest to też kolejność w której żyrii wyświetli się na głosowaniu

temp/data.txt: nie ruszać (zmieniać nazwy, usuwać przenosić) plik push-pull używany jako most dla danych między silnikiem by spidi ritsu, a front endem by piotrenewcz.
można otwierać, a nawet manualnie wpisywać "//" podczas działania silnika, żeby zgłosić gotowość przy debuggowaniu silnika. (dane na tym pokazują się od razu, w gedit trzeba zapisać zamknąć ii otworzyć ponownie żeby odświeżyć plik)

install.sh: zautomatyzowana instalacja silnika dla linuxa, teoretycznie da się ten silnik zainstalować na windows, ale nie wiem jak.

cfg.txt: ustawienia graficzne do front endu
plik używa formatu:
rozmiar_małego_tekstu;rozmiar_dużego_tekstu
kolor_tła_R;kolor_tła_G;kolor_tła_B
kolor_nie_zagłosowano_R;kolor_nie_zagłosowano_G;kolor_nie_zagłosowano_B
kolor_zagłosowano_R;kolor_zagłosowano_G;kolor_zagłosowano_B

jeśli nie wiadomo jakie wartości powinny być ustawione, najlepiej poexperymentować na docelowym ekranie, żeby dostosować rozmiary tekstu, aby były czytelne, i kolory aby były wyraźne.

don't ask me why did i name it yzi, i have no idea.

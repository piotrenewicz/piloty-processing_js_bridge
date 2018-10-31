void setup(){
  fullScreen();
  zyrii = loadStrings("os.txt"); // osoby głosujące
  classes = loadStrings("kl.txt"); // klasy do głosowania na (program był pisany, do głosowania na klasy wykonujące piosenki)
  String[] cfg = loadStrings("cfg.txt"); // konfiguracja
  ilezyrii = zyrii.length; // ilość osób głosujących
  ileclass = classes.length; // ilość klass do głosowania na
  textAlign(CENTER, CENTER);
  bigText = int(split(cfg[0], ";")[1]); // wielkość dużego tekstu
  smallText = int(split(cfg[0], ";")[0]);; // wielkość małego tekstu
  spacin = width / ilezyrii;
  
  voted = new boolean[ilezyrii];  // lista booleanów trymająca kto oddał już głos
  for(int i =0; i<ilezyrii; i++)voted[i]=false; // init
  votes = new int[ilezyrii]; // lista int trymająca kto ile dał
  for(int i =0; i<ilezyrii; i++)votes[i]=0; // init
  scores = new int[ileclass]; // lista int trymająca kto z klass ile uzyskał punktów (sumowane z kto ile dał)
  for(int i =0; i<ileclass; i++)scores[i]=0; // init
  bg=color(int(split(cfg[1],";")[0]), int(split(cfg[1],";")[1]), int(split(cfg[1],";")[2])); // kolor tła
  bl=color(int(split(cfg[2],";")[0]), int(split(cfg[2],";")[1]), int(split(cfg[2],";")[2])); // kolor nie zagłosowano
  hl=color(int(split(cfg[3],";")[0]), int(split(cfg[3],";")[1]), int(split(cfg[3],";")[2])); // kolor zagłosowano
}  

String[] IDS = new String[] { // to są id pilotów które były wtedy, jak macie inne piloty, to musicie znaleźć ich id i tu dodać
      "1796",
      "1c08",
      "1aef",
      "177d",
      "19f0",
      "11d3",
      "19c4",
      "13d5",
      "1c52",
      "19e7"
};


// deklaracja zmiennych przypisanych w setup()
color bg;
color bl;
color hl;

int bigText;
int smallText;
int ilezyrii;
int ileclass;
String[] zyrii;
String[] classes;

int[] votes;
int[] scores;
boolean[] voted;

int currentClass=0;
int spacin;
int mode=0; // przełącznik funkcji programu niżej rozpisane:
/* 0 - pre voting (parowanie konkretnych pilotów do członków żyrii)
   1 - collectiong votes for each klass (tryb głosowania na kolejne klasy)
   2 - results (podsumowanie wyników)
*/

void draw(){// funkcja główna 
  background(bg);// rysuje tło  
  pullData();    // nakręca push-pull żeby używać silnika js
  junction();    // używa skrzyżowania żeby podać kontrole, do odpowiedniej funkcji programu. (patrz. mode)
}

void pullData(){ // druga strona połączenia push-pull fs., nie używać na laptopie za każdą klatką czyta fs, pożera baterie jak szalone.
  String[] raw = loadStrings("temp/data.txt"); // czyta fs/data
  if(raw.length>0){ // jak coś tam jest (zdarzało się że jest pusto między poleceniami silnika)
    String[] data = split(raw[0], ";");
    if(!(data[0].equals("//"))){ // jeżeli jest coś innego niż nasz znak gotowości
      saveStrings("temp/data.txt", new String[] {"//"}); // zajmujemy się już tymi danymi zgłoś gotowość przez wstawienie "//" do fs
      // print(data[0]);  // odkomętowanie tej lini zwraca id pilota który coś wysłał. Można tego użyć żeby znaleźć id nowego pilota.
      for(int i=0; i<data[1].length(); i++){ // w wiadomości wysłanej z pilota nie może być poniższych znaków
        if(data[1].charAt(i)=='/' || data[1].charAt(i)=='.' || data[1].charAt(i)=='-')return; // zbieramy głosy, nie ma że ktoś wystawi "4.5" albo "2/10" jak będą te znaki to zignoruj wiadomość
      } 
      // print(data[0]);  // odkomętowanie tej lini zwraca id pilota który coś wysłał. Można tego użyć żeby znaleźć id nowego pilota.
      for(int i=0; i<ilezyrii; i++){
        if(IDS[i].equals(data[0])){ // szukamy po id pilotów, który to pilot (idziemy tylko tyle ile jest żyrii)
          //print("ding");
           votes[i] = int(data[1]); // jedyna rzecz łącząca piloty z osobami w żyrii to kolejność w IDS i w zyrii
           voted[i] = true;         // jak znajdziemy który to pilot to przypisujemy wiadomość z tego pilota do indexu osoby w żyrii, i w voted ustawiamy że ta osoba już zagłosowała
        }
      }
    }
  }
}

void junction(){ // skrzyżowanie
  if(mode==0)pre(); // parowanie pilotów (czyli można sobie przed wszystkim powysyłać żeby zobaczyć który jest który, ekran pokaże który żyrii właśnie coś wysłał)
  if(mode==1)voteCollect(); // właściwy tryb w, którym oddajemy głosy
  if(mode==2)results(); // posumowanie wyników
}

void voteCollect(){ // tryb właściwy
  pushMatrix(); // graficzne komędy do rozrysowania kto zagłosował i ile dał, to głosowanie jest jawne, jak chcemy tajne to trzeba tu ukryć
  translate(spacin/2, height/2);
  int side = spacin-smallText;
  for(int i =0; i<ilezyrii; i++){ // dla każdego żyrii rysujemy 
    if(voted[i])fill(255); // odpowiedni kolor jak zagłosował
    else fill(bl);
    rect(-side/2, -side/2, side, side);
    fill(bl);
    textSize(smallText);
    text(zyrii[i], 0, -side/2-smallText); // imię tego członka żyrii
    if(voted[i]){
      textSize(bigText);
      text(votes[i],0,0); // jego głos (zakomętowanie zrobi głosowanie tajne)
    }
    translate(spacin, 0);
  }
  popMatrix();
  textSize(bigText);
  text(classes[currentClass], width/2, height/6); // A no i jeszcze na kogo głosujemy teraz (aka która to klasa)
}



void pre(){ // tryb do przygotowania pilotów 
  // praktycznie te same graficzne komędy
  pushMatrix();
  translate(spacin/2, height/2);
  int side = spacin-smallText;
  for(int i =0; i<ilezyrii; i++){
    if(voted[i]){ // tylko że jak któryś pilot coś wyśle to ma się pokazać tylko ten głos 
      for(int j=0; j<ilezyrii; j++){ 
        voted[j]=false;  // wszystkie głosy na czarno
        votes[j]=0;
      }
      votes[i]=1; // tylko ten co pilot który coś wysłał teraz jest ważny.
    }
    if(votes[i]==1)fill(hl); // odpowiedni kolor itd
    else fill(bl);
    rect(-side/2, -side/2, side, side);
    fill(bl);
    textSize(smallText);
    text(zyrii[i], 0, -side/2-smallText);
    translate(spacin, 0); 
  }
  popMatrix();
  textSize(bigText);
  text("Witamy, Witamy", width/2, height/6); // tutaj głosujemy na napis "Witamy, Witamy", xd
  
}

int space;
int sidee;
int max;

void results(){ // podsumowanie wyników 
  // znowu graficzne komędy, tym razem rysujemy automatycznie skalowany wykres słupkowy, dla każdej z klass, na którym widać która klasa wygrała
  pushMatrix();
  translate(space/2, height-3*bigText);
  for(int i=0; i<ileclass; i++){ // dla wszystkich klas rysujemy słupki
    textSize(bigText);
    fill(hl);
    text(scores[i], 0, 1*bigText); 
    rect(-sidee/2, 0, sidee, smallText-map(scores[i], 0, max, 0, height-3*bigText));
    textSize(smallText);
    fill(bl);
    text(classes[i], 0, 2*bigText);
    translate(space, 0);
  }
  popMatrix();
}


// kolejne funkcje służą do sterowania skrzyżowaniem za pomocą mode.
void end(){ // ta oblicza i ustawia odstępy graficzne dla ekranu z podumowaniem, żeby się ładnie skalował
  space = width/ileclass;
  sidee = space - smallText;
  max=0;
  for(int s : scores){
    if(s>max)max=s;
  }
  mode=2; // no i przełącza tryb na 2 czyli posumowanie
}

void next(){ // ta nie zmienia trybu, ale po każdym głosowaniu:
  for(int v : votes)scores[currentClass]+=v; // zlicza punkty jakie zdobyła ta klasa
  for(int i =0; i<ilezyrii; i++)voted[i]=false; // resetuje głosy na kolejne głosowanie
  for(int i =0; i<ilezyrii; i++)votes[i]=0;
  currentClass++; // i szykuje kolejną klasę do głosowania.
  if(currentClass==ileclass)end(); // jak brakło klas to autmoatycznie przechodzi do podsumowania.
}

void begin(){ // sprząta po trybie parowania
  for(int i =0; i<ilezyrii; i++)voted[i]=false; // resetuje głosy, 
  for(int i =0; i<ilezyrii; i++)votes[i]=0;
  mode=1; // i przełącza tryb na 1 czyli tryb właściwy
}

// tryb jest zdefiniowany na 0 po załączeniu programu, nie trzeba na niego przełączać


void keyPressed(){ // specjalna funkcja processingu, umożliwia sterowanie za pomocą klawiatury
  if((key=='b'||key=='B')&&mode==0)begin(); // klawisz b przypisany do rozpoczęcia trybu właściwego
  if((key=='n'||key=='N')&&mode==1)next();  // klawisz n skończy głosowanie na daną klasę i przejdzie do kolejnej.
}  
// trzeba używać tych klawiszy, program sam nie przejdzie do kolejnego głosowania.

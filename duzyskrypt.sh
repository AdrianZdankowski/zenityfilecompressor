#!/bin/bash

# Author           : Adrian Zdankowski ( s193480@student.pg.edu.pl )
# Created On       : 22.05.2023
# Last Modified By : Adrian Zdankowski ( s193480@student.pg.edu.pl )
# Last Modified On : 27.05.2023 
# Version          : 1.0
#
# Description      :
# Program służący do pakowania, wypakowania, kompresji, dekompresji plików i katalogów w interfejsie graficznym Zenity.
# Obsługiwane formaty plików: tar,gz,tar.gz,zip,gpg. Możliwe jest ustawienie harmonogramu kompresji dla wybranego katalogu.
# Opcje: -h pomoc -v informacje o wersji
# Skrypt wykorzystuje program cron
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

MAINMENU=("Pakowanie" "Rozpakowanie" "Kompresja" "Dekompresja" "Dodanie do archiwum" "Harmonogram kompresji" "Podejrzenie zawartości archiwum" "Szyfrowanie" "Odszyfrowanie" "Koniec")
PACKMENU=("Pakowanie plików" "Pakowanie katalogu" "Usunięcie z archiwum")
UNPACKMENU=("Wypakowanie zip" "Wypakowanie tar/tar.gz")
COMPRESSIONMENU=("Kompresowanie plików" "Kompresowanie katalogu")
CURRENTDIR=$(pwd)

showVersion() {
echo "dużyskrypt wersja 1.0 Adrian Zdankowski 193480"
}

showHelp() {
echo "Opcje: -h pomoc -v informacje o wersji"
echo "Pakowanie -> Pakowanie plików/Pakowanie katalogu/Usunięcie z archiwum"
echo "Rozpakowanie -> Wypakowanie zip/Wypakowanie tar/tar.gz"
echo "Kompresja -> Kompresowanie plików/Kompresowanie katalogu"
echo "Dekompresja - dekompresowanie plików .gz"
echo "Dodanie do archiwum -> Wybierz format"
echo "Podejrzenie zawartości archiwum - sprawdzenie plików znajdujących się w archiwum i ich zawartości"
echo "Szyfrowanie - pozwala zaszyfrować plik hasłem wybranym algorytmem szyfrowania gpg"
echo "Odszyfrowanie - odszyfrowanie pliku .gpg"
echo "Harmonogram kompresji - pozwala ustalić zadanie kompresji danego katalogu o podanym przez użytkownika czasie"
echo "Harmonogram kompresji -> Dodaj do harmonogramu/Zobacz harmonogram/Usuń z harmonogramu"
echo "Format czasu:"
echo "minuta godzina dzień_miesiąca miesiąc dzień_tygodnia"
echo "Przykład: kompresja katalogu co minutę"
echo "* * * * * polecenie"
echo "Przykład: kompresja katalogu codziennie o 19:30"
echo "30 19 * * * polecenie"
}

packing() {
PCHOICE=`zenity --list --column=Menu "${PACKMENU[@]}" --height 400`

case $PCHOICE in
"Pakowanie plików")
TARGETDIR=$(zenity --file-selection --multiple --directory --title="Wybierz katalog docelowy dla archiwum")
TARGETDIR=${TARGETDIR//${CURRENTDIR}\/}
if [ -n "$TARGETDIR" ]; then 
   SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --title="Wybierz pliki do spakowania")
   SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
      if [ -n "$SELECTEDFILES" ]; then
         ARCHIVENAME=`zenity --entry --title "Nazwa archiwum" --text "Wprowadź nazwę archiwum"`
         if [ -n "$ARCHIVENAME" ]; then
            zenity --question --title "Kompresja" --text "Skompresować archiwum? (gzip)"
            if [[ $? -eq 0 ]]; then
            OPTION="-czf"
            EXTENSION=".tar.gz"
            else
            OPTION="-cf"
            EXTENSION=".tar"
            fi
            if [[ "$CURRENTDIR" = "$TARGETDIR" && -n $OPTION && -n $EXTENSION ]]; then
               tar $OPTION "$ARCHIVENAME$EXTENSION" $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Archiwum $ARCHIVENAME$EXTENSION zostało utworzone") || (zenity --error --text "Nie udało się stworzyć archiwum")
            else
               tar $OPTION "$TARGETDIR/$ARCHIVENAME$EXTENSION" $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Archiwum $ARCHIVENAME$EXTENSION zostało utworzone") || (zenity --error --text "Nie udało się stworzyć archiwum")
            fi
         fi
      fi
fi;;

"Pakowanie katalogu")
TARGETDIR=$(zenity --file-selection --multiple --directory --title="Wybierz katalog docelowy dla archiwum")
TARGETDIR=${TARGETDIR//${CURRENTDIR}\/}
if [ -n "$TARGETDIR" ]; then 
SELECTEDDIR=$(zenity --file-selection --directory --multiple --separator=" " --title="Wybierz katalogi do skompresowania")
if [ -n "$SELECTEDDIR" ]; then
   SELECTEDDIR=${SELECTEDDIR//${CURRENTDIR}\//}
   ARCHIVENAME=`zenity --entry --title "Nazwa archiwum" --text "Wprowadź nazwę archiwum"`
   if [ -n "$ARCHIVENAME" ]; then
            zenity --question --title "Kompresja" --text "Skompresować archiwum? (gzip)"
            if [[ $? -eq 0 ]]; then
            OPTION="-czf"
            EXTENSION=".tar.gz"
            else
            OPTION="-cf"
            EXTENSION=".tar"
            fi
	   if [[ "$CURRENTDIR" = "$TARGETDIR" && -n $OPTION && -n $EXTENSION ]]; then
	   tar $OPTION "$ARCHIVENAME$EXTENSION" $SELECTEDDIR/* > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Archiwum $ARCHIVENAME$EXTENSION zostało utworzone") || (zenity --error --text "Nie udało się stworzyć archiwum")
      else
      tar $OPTION $TARGETDIR/$ARCHIVENAME$EXTENSION $SELECTEDDIR/* > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Archiwum $ARCHIVENAME$EXTENSION zostało utworzone") || (zenity --error --text "Nie udało się stworzyć archiwum")
	   fi
   fi
fi
fi;;

"Usunięcie z archiwum")
SELECTEDARCH=$(zenity --file-selection --title="Wybierz archiwum" --file-filter=""*.tar" "*.zip"")
SELECTEDARCH=${SELECTEDARCH//${CURRENTDIR}\//}
if [[ "$SELECTEDARCH" =~ \.(tar|zip)$ ]]; then
   if [[ $SELECTEDARCH =~ \.tar$ ]]; then
       SELECTEDFILES=$(zenity --list --title="Wybierz pliki" --multiple --separator=" " --column="Pliki" $(tar -tf $SELECTEDARCH))
      if [[ -n $SELECTEDFILES ]]; then
         tar --delete --file="$SELECTEDARCH" $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Usunięto pliki z $SELECTEDARCH") || (zenity --error --text "Wystąpił błąd przy usuwaniu plików!")
      fi
   fi
   if [[ $SELECTEDARCH =~ \.zip$ ]]; then
      SELECTEDFILES=$(zenity --list --title="Wybierz pliki" --multiple --separator=" " --column="Pliki" $(zipinfo -1 $SELECTEDARCH))
      if [[ -n $SELECTEDFILES ]]; then
         zip -d $SELECTEDARCH $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Usunięto pliki z $SELECTEDARCH") || (zenity --error --text "Wystąpił błąd przy usuwaniu plików!")
      fi
   fi
fi;;
esac

}

compression() {
CCHOICE=`zenity --list --column=Menu "${COMPRESSIONMENU[@]}" --height 400`
case $CCHOICE in
"Kompresowanie plików")
FORMAT=$(zenity --list --title="Wybierz format kompresji" --column="Opcje kompresji" zip gzip)
if [[ -n $FORMAT ]]; then
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --title="Wybierz pliki do kompresji")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
   if [[ -n SELECTEDFILES ]]; then
      if [[ "$FORMAT" == "gzip" ]]; then
      gzip -k $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Skompresowano pliki") || (zenity --error --text "Wystąpił błąd przy kompresji plików!")
      fi
      if [[ "$FORMAT" == "zip" ]]; then
      TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy dla archiwum")
      TARGETDIR=${TARGETDIR//${CURRENTDIR}\/}
         if [[ -n $TARGETDIR ]]; then
            ARCHIVENAME=`zenity --entry --title "Nazwa katalogu zip" --text "Wprowadź nazwę katalogu zip do utworzenia"`
            if [[ -n $ARCHIVENAME ]]; then
               if [[ "$CURRENTDIR" = "$TARGETDIR" ]]; then
                  zip $ARCHIVENAME $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Skompresowano pliki") || (zenity --error --text "Wystąpił błąd przy kompresji plików!")
               else
                  zip $TARGETDIR/$ARCHIVENAME $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Skompresowano pliki") || (zenity --error --text "Wystąpił błąd przy kompresji plików!")
               fi
            fi
         fi
      fi
   fi
fi;;

"Kompresowanie katalogu")
FORMAT=$(zenity --list --title="Wybierz format kompresji" --column="Opcje kompresji" zip gzip)
if [[ -n $FORMAT ]]; then
SELECTEDDIR=$(zenity --file-selection --directory --title="Wybierz katalog do kompresji")
SELECTEDDIR=${SELECTEDDIR//${CURRENTDIR}\/}
   if [[ -n $SELECTEDDIR ]]; then
      if [[ "$FORMAT" == "gzip" ]]; then
      gzip -k -r $SELECTEDDIR > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Skompresowano pliki w katalogu $SELECTEDDIR") || (zenity --error --text "Wystąpił błąd przy kompresji plików!")
      fi
      if [[ "$FORMAT" == "zip" ]]; then
      TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy dla pliku zip")
      TARGETDIR=${TARGETDIR//${CURRENTDIR}\/}
         if [[ -n $TARGETDIR ]]; then
            ARCHIVENAME=`zenity --entry --title "Nazwa katalogu zip" --text "Wprowadź nazwę katalogu zip do utworzenia"`
            if [[ -n $ARCHIVENAME ]]; then
               if [[ "$CURRENTDIR" = "$TARGETDIR" ]]; then
                  zip -r $ARCHIVENAME $SELECTEDDIR > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Skompresowano katalog w $ARCHIVENAME.zip") || (zenity --error --text "Wystąpił błąd przy kompresji plików!")
               else
                  zip -r $TARGETDIR/$ARCHIVENAME $SELECTEDDIR > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Skompresowano katalog w $ARCHIVENAME.zip") || (zenity --error --text "Wystąpił błąd przy kompresji plików!")
               fi
            fi
         fi
      fi
   fi
fi;;
esac
}

decompression() {
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --file-filter="*.gz" --title="Wybierz pliki do dekompresji")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
if [[ -n $SELECTEDFILES ]]; then
   gunzip -f $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Zdekompresowano pliki") || (zenity --error --text "Wystąpił błąd przy dekompresji plików!")
fi
}

unpacking() {
UNCHOICE=`zenity --list --column=Menu "${UNPACKMENU[@]}" --height 400`  
case $UNCHOICE in
"Wypakowanie zip")
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --file-filter='*.zip' --title="Wybierz pliki do rozpakowania")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
if [[ -n $SELECTEDFILES ]]; then
   for file in $SELECTEDFILES; do
      if [[ ! $file =~ \.zip$ ]]; then
         zenity --error --text "Wybrano pliki inne niż zip!" > /dev/null 2>&1
         return
      fi
   done

   TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy do wypakowania plików")
      TARGETDIR=${TARGETDIR//${CURRENTDIR}\/}
         if [[ -n $TARGETDIR ]]; then
            for file in $SELECTEDFILES; do
               unzip -o "$file" -d $TARGETDIR 
            done
            if [[ $? -eq 0 ]]; then
               zenity --info --title "Sukces" --text "Wypakowano pliki do $TARGETDIR"
            else
               zenity --error --text "Wystąpił błąd przy wypakowaniu plików!"
            fi
         fi
fi;;

"Wypakowanie tar/tar.gz")
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --file-filter='*.tar *.tar.gz' --title="Wybierz pliki do rozpakowania")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
if [[ -n $SELECTEDFILES ]]; then
   for file in $SELECTEDFILES; do
      if [[ ! $file =~ \.tar(\.gz)?$ ]]; then
         zenity --error --text "Wybrano pliki inne niż .tar .tar.gz!"
         return
      fi
   done
   TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy do wypakowania plików")
      TARGETDIR=${TARGETDIR//${CURRENTDIR}\/}
         if [[ -n $TARGETDIR ]]; then
            for file in $SELECTEDFILES; do
               if [[ $file =~ \.tar$ ]]; then
                  tar -xf $file -C $TARGETDIR
               else
                  tar -xzf $file -C $TARGETDIR
               fi
            done
            if [[ $? -eq 0 ]]; then
               zenity --info --title "Sukces" --text "Wypakowano pliki do $TARGETDIR"
            else
               zenity --error --text "Wystąpił błąd przy wypakowaniu plików!"
            fi
         fi
fi
esac
}

addToArchive() {
FORMAT=$(zenity --list --title="Wybierz format archiwum do którego dodać pliki" --column="Formaty archiwów" zip tar tar.gz)
case $FORMAT in
zip)
SELECTEDARCH=$(zenity --file-selection --title="Wybierz archiwum" --file-filter='*.zip')
SELECTEDARCH=${SELECTEDARCH//${CURRENTDIR}\//}
if [[ ! $SELECTEDARCH =~ \.zip$ ]]; then
   zenity --error --text "Wybrano plik inny niż .zip!"
   return
fi
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --title="Wybierz pliki do dodania")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
if [[ -n $SELECTEDFILES ]]; then
   zip -ur $SELECTEDARCH $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Dodano pliki do $SELECTEDARCH") || (zenity --error --text "Nie udało się dodać plików do archiwum")
fi;;
tar)
SELECTEDARCH=$(zenity --file-selection --title="Wybierz archiwum" --file-filter='*.tar')
SELECTEDARCH=${SELECTEDARCH//${CURRENTDIR}\//}
if [[ ! $SELECTEDARCH =~ \.tar$ ]]; then
   zenity --error --text "Wybrano plik inny niż .tar!"
   return
fi
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --title="Wybierz pliki do dodania")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
if [[ -n $SELECTEDFILES ]]; then
   tar -rf $SELECTEDARCH $SELECTEDFILES > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Dodano pliki do $SELECTEDARCH") || (zenity --error --text "Nie udało się dodać plików do archiwum")
fi;;
tar.gz)
SELECTEDARCH=$(zenity --file-selection --title="Wybierz archiwum" --file-filter='*.tar.gz')
SELECTEDARCH=${SELECTEDARCH//${CURRENTDIR}\//}
if [[ ! $SELECTEDARCH =~ \.tar.gz$ ]]; then
   zenity --error --text "Wybrano plik inny niż .tar.gz!"
   return
fi
SELECTEDFILES=$(zenity --file-selection --multiple --separator=" " --title="Wybierz pliki do dodania")
SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
if [[ -n $SELECTEDFILES ]]; then
   gunzip $SELECTEDARCH
   SELECTEDARCH="${SELECTEDARCH%.gz}"
   tar -rf "$SELECTEDARCH" $SELECTEDFILES > /dev/null 2>&1
   gzip $SELECTEDARCH > /dev/null 2>&1 && (zenity --info --title "Sukces" --text "Dodano pliki do $SELECTEDARCH.gz") || (zenity --error --text "Nie udało się dodać plików do archiwum")
fi;;
esac
}

listfiles() {
SELECTEDARCH=$(zenity --file-selection --title="Wybierz archiwum" --file-filter='*.tar *.tar.gz *.zip')
SELECTEDARCH=${SELECTEDARCH//${CURRENTDIR}\//}
if [[ -n $SELECTEDARCH ]]; then
   if [[ "$SELECTEDARCH" =~ \.(tar|tar\.gz|zip)$ ]]; then
        EXTENSION="${SELECTEDARCH##*.}"
        case $EXTENSION in
        tar|gz)
            SELECTEDFILES=$(zenity --list --title="Wybierz pliki" --multiple --separator=" " --column="Pliki" $(tar -tf $SELECTEDARCH))
            SELECTEDFILES=${SELECTEDFILES//${CURRENTDIR}\/}
            if [[ -n $SELECTEDFILES ]]; then
               for file in $SELECTEDFILES; do
                  if [[ -f $file ]]; then
                     CONTENT=$(tar -xf $SELECTEDARCH --to-stdout $file)
                     TEMPFILE=$(mktemp)
                     echo "$CONTENT" > "$TEMPFILE"
                     zenity --text-info --title="Zawartość pliku $file" --filename="$TEMPFILE"
                     rm "$TEMPFILE"
                  else
                     zenity --error --text "Plik jest katalogiem!"
                  fi
               done
            fi;;
         zip)
            SELECTEDFILES=$(zenity --list --title="Wybierz pliki" --multiple --separator=" " --column="Pliki" $(zipinfo -1 $SELECTEDARCH))
             if [[ -n $SELECTEDFILES ]]; then
               for file in $SELECTEDFILES; do
                  if [[ -f $file ]]; then
                     CONTENT=$(unzip -p $SELECTEDARCH $file)
                     TEMPFILE=$(mktemp)
                     echo "$CONTENT" > "$TEMPFILE"
                     zenity --text-info --title="Zawartość pliku $file" --filename="$TEMPFILE"
                     rm "$TEMPFILE"
                  else
                     zenity --error --text "Plik jest katalogiem!"
                  fi
               done
            fi;;
        esac
   else
        zenity --error --text "Nie wybrano archiwum!"
   fi


fi
}

schedule() {
SCHOICE=$(zenity --list --title="Zarządzanie harmonogramem" --column="Opcje" "Dodaj do harmonogramu" "Zobacz harmonogram" "Usuń z harmonogramu")

case $SCHOICE in
"Dodaj do harmonogramu")
SELECTEDDIR=$(zenity --file-selection --directory --title="Wybierz katalog, który ma być dodany do harmonogramu")
FORMAT=$(zenity --list --title="Wybierz format" --column="Formaty archiwów" zip tar tar.gz)
OPTIONS=$(zenity --forms --title="Wybierz czas wykonania" --separator=" " --text="Wprowadź dane" \
    --add-entry="Minuty (*|0-59):" \
    --add-entry="Godziny (*|0-23):" \
    --add-entry="Dzień miesiąca (*|1-31):" \
    --add-entry="Miesiąc (*|1-12):" \
    --add-entry="Dzień tygodnia (*|0-6):")
MINUTE=$(awk -F' ' '{print $1}' <<<$OPTIONS)
HOUR=$(awk -F' ' '{print $2}' <<<$OPTIONS)
DAY=$(awk -F' ' '{print $3}' <<<$OPTIONS)
MONTH=$(awk -F' ' '{print $4}' <<<$OPTIONS)
WEEKDAY=$(awk -F' ' '{print $5}' <<<$OPTIONS)
if ! [[ $MINUTE == "*" || $MINUTE =~ ^([0-9]|[1-5][0-9])$ ]]; then
   zenity --error --text "Nieprawidłowy format minut!"
   return
fi
if ! [[ $HOUR == "*" || $HOUR =~ ^([0-9]|1[0-9]|2[0-3])$ ]]; then
   zenity --error --text "Nieprawidłowy format godziny!"
   return
fi
if ! [[ $DAY == "*" || $DAY =~ ^([1-9]|[1-2][0-9]|3[0-1])$ ]]; then
   zenity --error --text "Nieprawidłowy format dnia miesiąca!"
   return
fi
if ! [[ $MONTH == "*" || $MONTH =~ ^(1[0-2]|[1-9])$ ]]; then
   zenity --error --text "Nieprawidłowy format miesiąca!"
   return
fi
if ! [[ $WEEKDAY == "*" || $WEEKDAY =~ ^(0|1|2|3|4|5|6)$ ]]; then
   zenity --error --text "Nieprawidłowy format dnia tygodnia!"
   return
fi
case $FORMAT in
zip)
   TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy dla pliku zip")
      if [[ -n $TARGETDIR ]]; then
         ARCHIVENAME=`zenity --entry --title "Nazwa katalogu zip" --text "Wprowadź nazwę katalogu zip do utworzenia"`
         if [[ -n $ARCHIVENAME ]]; then
            COMMAND="zip $TARGETDIR/$ARCHIVENAME $SELECTEDDIR/*"
            TEMPCRON=$(mktemp)
            crontab -l > $TEMPCRON
            echo "$OPTIONS $COMMAND" >> $TEMPCRON
            crontab $TEMPCRON && (zenity --info --title "Sukces" --text "Dodano zadanie do harmonogramu") || (zenity --error --text "Nie udało się dodać zadania")
            rm $TEMPCRON
         fi
      fi;;
tar)
   TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy dla pliku tar")
      if [[ -n $TARGETDIR ]]; then
         ARCHIVENAME=`zenity --entry --title "Nazwa pliku tar" --text "Wprowadź nazwę pliku tar do utworzenia"`
         if [[ -n $ARCHIVENAME ]]; then
               COMMAND="tar -cf $TARGETDIR/$ARCHIVENAME.tar $SELECTEDDIR/*"
               TEMPCRON=$(mktemp)
               crontab -l > $TEMPCRON
               echo "$OPTIONS $COMMAND" >> $TEMPCRON
               crontab $TEMPCRON && (zenity --info --title "Sukces" --text "Dodano zadanie do harmonogramu") || (zenity --error --text "Nie udało się dodać zadania")
               rm $TEMPCRON
            fi
      fi;;
tar.gz)
      TARGETDIR=$(zenity --file-selection --directory --title="Wybierz katalog docelowy dla pliku tar.gz")
      if [[ -n $TARGETDIR ]]; then
         ARCHIVENAME=`zenity --entry --title "Nazwa pliku tar.gz" --text "Wprowadź nazwę pliku tar.gz do utworzenia"`
         if [[ -n $ARCHIVENAME ]]; then
               COMMAND="tar -czf $TARGETDIR/$ARCHIVENAME.tar.gz $SELECTEDDIR/*"
               TEMPCRON=$(mktemp)
               crontab -l > $TEMPCRON
               echo "$OPTIONS $COMMAND" >> $TEMPCRON
               crontab $TEMPCRON && (zenity --info --title "Sukces" --text "Dodano zadanie do harmonogramu") || (zenity --error --text "Nie udało się dodać zadania")
               rm $TEMPCRON
         fi
      fi;;
esac;;

"Zobacz harmonogram")
TEMPFILE=$(mktemp)
crontab -l > $TEMPFILE
zenity --text-info --title="Zawartość pliku $file" --filename="$TEMPFILE" --width="600"
rm "$TEMPFILE";;

"Usuń z harmonogramu")
TEMPFILE=$(mktemp)
crontab -l > $TEMPFILE
if [ -s $TEMPFILE ]; then
   LINES=()
   i=1
   while read -r line; do
      LINES+=("$i$line")
      ((i++))
   done < "$TEMPFILE"
   TASK=$(zenity --list --text "Wybierz zadanie do usunięcia:" --column "Zadania" "${LINES[@]}")
   if [[ -n $TASK ]]; then
      INDEX="${TASK:0:1}"
      sed -i $INDEX"d" $TEMPFILE
      crontab $TEMPFILE && (zenity --info --title "Sukces" --text "Usunięto zadanie $TASK") || (zenity --error --text "Nie udało się usunąć zadania")
   fi
else
zenity --error --text "Harmonogram jest pusty!"
fi
rm "$TEMPFILE";;
esac
}

encrypt() {
SELECTEDFILE=$(zenity --file-selection --title="Wybierz plik do zaszyfrowania")
if [[ -n $SELECTEDFILE && ! $SELECTEDFILE =~ \.gpg$ ]]; then
   ALGORITHM=$(zenity --list --text "Wybierz algorytm szyfrowania" --column "Algorytmy" aes aes192 aes256 twofish camellia128 camellia192 camellia256)
   if [[ -n $ALGORITHM ]]; then
      gpg --symmetric --cipher-algo $ALGORITHM --passphrase --output $SELECTEDFILE.gpg $SELECTEDFILE && (zenity --info --title "Sukces" --text "Zaszyfrowano plik $SELECTEDFILE") || (zenity --error --text "Nie udało się zaszyfrować $SELECTEDFILE")
   fi
fi
}

decrypt() {
SELECTEDFILE=$(zenity --file-selection --title="Wybierz plik do odszyfrowania" --file-filter='*.gpg')
if [[ -n $SELECTEDFILE && $SELECTEDFILE =~ \.gpg$ ]]; then
      FILENAME="${SELECTEDFILE%.gpg}"
      gpg --decrypt --passphrase --yes --output $FILENAME $SELECTEDFILE && (zenity --info --title "Sukces" --text "Odszyfrowano plik $SELECTEDFILE") || (zenity --error --text "Nie udało się odszyfrować $SELECTEDFILE")
fi
}

while getopts ":vh" option; do
   case $option in
      h)
         showHelp
         exit;;
      v)
         showVersion
         exit;;
     \?) 
         echo "Nieprawidlowa opcja"
         exit;;
   esac
done

while [ "$CHOICE" != "KONIEC" ]; do
   CHOICE=`zenity --list --column=Menu "${MAINMENU[@]}" --height 400`
   case $CHOICE in
      Pakowanie)
         packing;;
      Rozpakowanie)
         unpacking;;
      Kompresja)
         compression;;
      Dekompresja)
         decompression;;
      "Dodanie do archiwum")
         addToArchive;;
      "Harmonogram kompresji")
         schedule;;
      "Podejrzenie zawartości archiwum")
         listfiles;;
      "Szyfrowanie")
         encrypt;;
      "Odszyfrowanie")
         decrypt;;
      Koniec)
         exit;;
   esac
done



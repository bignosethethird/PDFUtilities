#!/usr/bin/bash

which pandoc >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  cat << !
I find your lack of faith disturbing:
PANDOC needs to be installed first.
Exiting...
!
  exit 1
fi

rename --version | grep "using File::Rename" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  cat << !
I find your lack of faith disturbing:
You do not have the Perl version of 'rename' installed.
Exiting...
!
  exit 1
fi


echo "Preparing for the arrival of Lord Vader..."
Year=$(date "+%Y")
if [[ ! -e .attribution ]]; then
  FullUserName=$(getent passwd $USER | cut -d':' -f5 | cut -d',' -f1)
  echo "Adding a default attribution notice for $FullUserName..."
  echo "Make up your own by editing the .attribution file."
  cat << ! > .attribution
# Add any attribution and copyright notes in here.
# Use © (copy & paste this) instead of %169 or &copy
Arranged by: $FullUserName $Year
!
fi

echo "Sweeping the floors of the Death Star..."
rename 's/-/ - /g' *.pdf
rename 's/_/ /g' *.pdf
rename 's/  -  / - /g' *.pdf

# Get Packname from Conductor PDF file
PackName=$(ls *Conductor*.pdf | sed -e 's/\s*\.pdf\s*//' | sed -e 's/\s*-*\s*Conductor.*//')
if [[ -n $PackName ]]; then
   # Sanity check:
   if [[ $(ls *Conductor*.pdf | wc -l) -gt 1 ]]; then
       echo "Do. Or do not. There is no try. There are more than 1 conductor score files."
       echo "Exiting..."
       exit 1
   fi
   rename 's/\s*-\s*Conductor.*\.pdf/.pdf/' *.pdf
else
  # Get Packname from shortest PDF file
  PackName=$(ls *.pdf | awk '{print length","$0}' | sort -n | cut -d"," -f2 | head -1 | sed -e 's/\.pdf\s*//' -e 's/\s*$//')
fi

PackFileName="${PackName} - Publisher Pack.pdf"
ContentsName="${PackName} - 00"
rm "${PackFileName}" > /dev/null 2>&1
rm "${ContentsName}.pdf" > /dev/null 2>&1
rm "${ContentsName}.md" > /dev/null 2>&1
rm ".bookmarks" > /dev/null 2>&1
echo "Making publisher pack of '$PackName':"
echo "Setting up Conductor Score for $PackName..."
# Ensure that conductor score is the first listed instrument after the contents page
cp "${PackName}.pdf" "${PackName} - 01.pdf"
echo "Make up contents page in markdown..."
cat << ! > "${ContentsName}.md"
|*Music score and parts for*|
|:---:|
||
|**${PackName}**|
||
!
cat .attribution | grep -v "#" | sed -e "s/^/\|*/" | sed -e "s/$/\*\|/" | sed -e 's/\*\s*\*//'>> "${ContentsName}.md"
cat << ! >> "${ContentsName}.md"
||

|Part|Instrument|Page|
|---:|:---|---:|
!

declare Instrument
declare -i PageCount=2
declare -i Part=1
declare -i NumberOfPages=0
for f in *.pdf; do
  Instrument=$(echo "$f" | sed -e 's/.* - //' | sed -e 's/\.pdf//')
  case "$Instrument" in
    "")
      # Skip if we have base conductor score, as this is the "01" file
      continue;;
    "00")
      # Skip if we have the contents file (never going to happen)
      echo "It's a trap!"
      continue;;
    "01")
      # The "01" file is conductor score to be used
      Instrument="Conductor Score";;
  esac
  echo "Processing $Instrument score..."
  NumberOfPages=$(pdftk "$f" dump_data | grep NumberOfPages | cut -d":" -f2)
  printf "|%d|%s|%d|\n" $Part "$Instrument" $PageCount >> "${ContentsName}.md"
  # Adding bookmark
  printf 'BookmarkBegin
BookmarkTitle: %s
BookmarkLevel: 1
BookmarkPageNumber: %d
' "$Instrument" $PageCount >> ".bookmarks"
  ((Part+=1))
  ((PageCount+=NumberOfPages))
done

echo "Converting markdown contents page to A4-sized PDF..."
pandoc -s -V papersize:a4 -o "${ContentsName}.pdf" "${ContentsName}.md"
if [[ $? -ne 0 ]]; then
  echo "These are not the droids you're looking for."
  echo "Error converting markdown to PDF."
  echo "Exiting..."
  exit 1
fi

echo "Collating into publisher pack '$PackFileName'..."
pdftk *.pdf cat output "${PackFileName}"
echo "Cleaning up with light sabre..."
rm "${PackName} - 01.pdf" > /dev/null 2>&1
rm "${ContentsName}.pdf" > /dev/null 2>&1
#cp "${ContentsName}.md" .contents.md
rm "${ContentsName}.md" > /dev/null 2>&1

echo "Adding a PDF bookmark for each instrument..."
pdftk "$PackFileName" update_info .bookmarks output ".${PackFileName}"
mv ".${PackFileName}" "${PackFileName}"
echo "Publisher Pack in file '$PackFileName' now is."
echo "Done. May the Force be with you."

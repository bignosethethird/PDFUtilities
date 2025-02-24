#!/bin/bash
# The main tool needs to be installed!
[[ -z $(which pdftk)  ]] && printf "pdftk is ont install\nExiting...\n" && exit 1
# Use only file in CWD if none specified on command line
[[ -f $1  ]] && f=$1 || f=$(ls -S *.pdf | head -1)
# Make up title
t=$(echo ${f%.pdf})
# Check that this file has a table of contents
pdftk "Just a Gigolo - Bass.pdf" dump_data |  grep "BookmarkTitle: "

if [[ -n "$1" && "$1" != "$f" ]]; then
  cat <<!
Chunks a PDF file with a table of contents into separate PDF files by chapter.

Usage:
  $0 [filename.pdf]
    or
  $0
    use the first listed PDF file in the current directory

This is how it works:
  When we have a table of contents, we can view chapters' page boundaries
  (called "bookmarks" here) using pdftk as a basis to automate the  file
  splitting into a separate file per chapter:

    $ pdftk BigBook.pdf dump_data | grep -2 "BookmarkTitle:"
    NumberOfPages: 74
    BookmarkBegin
    BookmarkTitle: Chapter 1
    BookmarkLevel: 1
    BookmarkPageNumber: 1
    BookmarkBegin
    BookmarkTitle: Chapter 2
    BookmarkLevel: 1
    BookmarkPageNumber: 18
    ...

Bookmark "Full Score" starts from page 1 and ends at page 18 - 1 = 17.
Make a new document from the chapter pages:
    $ pdftk a.pdf cat 1-17 output "Full Score.pdf"
!
  exit 1
fi

declare -a bookmarks
declare -a starpages
declare -a endpages
readarray -t bookmarks < <(pdftk "$f" dump_data | grep "BookmarkTitle: " | sed -e "s/.*: //" )
readarray -t starpages < <(pdftk "$f" dump_data | grep -2 "BookmarkTitle: " | grep "BookmarkPageNumber:" | sed -e "s/.*: //" )
lastpage=$(pdftk "$f" dump_data | grep "NumberOfPages: " | sed -e "s/.*: //" )

echo "Chunking $f into ${#starpages[@]} files:"

for ((i=0; i<${#starpages[@]}; i++)); do
  if [[ $i -lt  $((${#starpages[@]} - 1 )) ]]; then
    endpages[$i]=$(( ${starpages[$(($i+1))]} - 1 ))
  else
    endpages[$i]=$lastpage
  fi
  echo "Assembling $t - ${bookmarks[$i]}.pdf from pages ${starpages[$i]} to ${endpages[$i]}..."
  pdftk  "$f" cat ${starpages[$i]}-${endpages[$i]} output "$t - ${bookmarks[$i]}.pdf"
done

echo "Done"


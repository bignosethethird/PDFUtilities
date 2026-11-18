#!/usr/bin/bash

PROGNAME=$(basename "$0")
PROGNAME=${PROGNAME%%\.*}
CWD="$PWD"

function help {
cat <<EOF
NAME:
  $PROGNAME - Clean up poor document scans, especially sheet music
  that has been scibbled on with pencil or with a librarian's stamp on it.

SYNOPSIS:

  $PROGNAME <input.pdf> <output.pdf> {stamp_color}

DESCRIPTION:

  Cleans up poor document scans, especially sheet music, but can be used for
  any scanned document where the original document was scruffy or discolored,
  or full of pencil scibbles, and enhances the black and white contrast. It
  removes most pencil marks and also removes the librarian's stamp of a
  specified color, which is often found on scanned sheet music.

  You should compare the result with the original to ensure that this clean-up
  process has not removed any important details. This utility is designed to
  enhance the readability of scanned documents, but it may not be suitable for
  you, so use with caution and only replace the original file if you are
  satisfied with the results.

  Smart people always keep a backup of the original file.

PARAMETERS:

  <input.pdf>   The input PDF file to be cleaned up.
  <output.pdf>  The output PDF file to be created.
  {stamp_color} Optional. The color of the stamp to be removed, specified in
                hex format (e.g., #b67472). If not specified, the default
                color #b67472 (a rusty red) will be used.

REQUIREMENTS:

  This utility is run in a BASH shell and requires the following command line
  utilities to be installed:

  - ImageMagick  https://imagemagick.org/
  - pdftk        https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
  - replacecolor https://www.fmwconcepts.com/imagemagick/replacecolor
  - color2gray   https://www.fmwconcepts.com/imagemagick/color2gray
  - noisecleaner https://www.fmwconcepts.com/imagemagick/noisecleaner
  - bordereffects https://www.fmwconcepts.com/imagemagick/bordereffects

  You may need to change this in your ImageMagick configuration file
  /etc/ImageMagick-6/policy.xml) to allow the use of large files:

    <policy domain="resource" name="width" value="128KP"/>
    <policy domain="resource" name="height" value="128KP"/>

INSTALLATION:

  Download the script, copy it to a directory on your PATH and make it
  executable, eg:

    cp $PROGNAME.sh /usr/local/bin/$PROGNAME
    chmod +x $PROGNAME.sh

  Then run it with the input and output PDF files as arguments:
    $PROGNAME input.pdf output.pdf

SEE ALSO:

  ImageMagick: https://imagemagick.org/
  PDTK: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
  Fred's ImageMagick Scripts: https://www.fmwconcepts.com/imagemagick

ABOUT:

  This script was created by Gerrit Hoekstra in 2026. It is licensed under the
  GPL2.0 license. No cats were left unfed in the making of this script.


EOF
exit 1
}

function cleanup {
  rm -fr pg_*.pdf 2>/dev/null
  rm -fr pg_*.png 2>/dev/null
  rm doc_data.txt 2>/dev/null
  [ -f "$TMPFILE1" ] && rm "$TMPFILE1" 2>/dev/null
  [ -f "$TMPFILE2" ] && rm "$TMPFILE2" 2>/dev/null
  [ -f "$TMPFILE3" ] && rm "$TMPFILE3" 2>/dev/null
  [ -f "$TMPFILE4" ] && rm "$TMPFILE4" 2>/dev/null
  [ -f "$TMPFILE5" ] && rm "$TMPFILE5" 2>/dev/null
  [ -f "$TMPFILE6" ] && rm "$TMPFILE6" 2>/dev/null
  [ -d "$TMPDIR" ]   && rm -rf "$TMPDIR" 2>/dev/null
  cd "$CWD" 2>/dev/null || exit 1
}

trap cleanup EXIT

# Deal with Input parameters
if [ $# -ne 2 ]; then
  help
fi
INFILE="$1"
OUTFILE="$2"
[ -x "$INFILE" ] || ( echo "Input file does not exist: $INFILE"; exit 1 )
[ -x "$OUTFILE" ] && ( echo "Output file already exists: $OUTFILE. Overwriting...." )
STAMP_COLOR="${3:-#b67472}"
[ ${#STAMP_COLOR} -eq 7 ] || ( echo "Invalid stamp color: $STAMP_COLOR"; exit 1 )

which pdftk >/dev/null 2>&1 || ( echo "pdftk not found. Install pdftk."; exit 1; )
which replacecolor >/dev/null 2>&1 || ( echo "replacecolor not found. Install replacecolor."; exit 1; )
which color2gray >/dev/null 2>&1 || ( echo "color2gray not found. Install color2gray."; exit 1; )


START_TIME=$(date +%s)
cleanup

# Use temporary files in /tmp to avoid filling up the current working directory.
# Work in raw bit-mapped format to avoid compression artefacts and speed up processing.
TMPFILE1=$(mktemp  "/tmp/${PROGNAME}.$$.XXXXXX.1.bmp")
TMPFILE2=$(mktemp  "/tmp/${PROGNAME}.$$.XXXXXX.2.bmp")
TMPFILE3=$(mktemp  "/tmp/${PROGNAME}.$$.XXXXXX.3.bmp")
TMPFILE4=$(mktemp  "/tmp/${PROGNAME}.$$.XXXXXX.4.bmp")
TMPFILE5=$(mktemp  "/tmp/${PROGNAME}.$$.XXXXXX.5.bmp")
TMPFILE6=$(mktemp  "/tmp/${PROGNAME}.$$.XXXXXX.6.bmp")
TMPDIR=$(mktemp -d "/tmp/${PROGNAME}.$$.XXXXXX")


TOTAL_PAGES=$(pdftk "$INFILE" dump_data output | grep -i NumberOfPages | cut -f 2 -d ':')

echo -n "Splitting input PDF file '$INFILE' into ${TOTAL_PAGES} ages..."
cd "$TMPDIR" || ( echo "Failed to change directory to $TMPDIR"; exit 1 )
pdftk "$CWD/$INFILE" burst
rm doc_data.txt 2>/dev/null
cd "$CWD" || ( echo "Failed to change directory back to $CWD"; exit 1 )
echo "done."

for f in "$TMPDIR"/pg_*.pdf; do
  PAGE=${f##*/}
  PAGE=${PAGE/pg_/}
  PAGE=${PAGE/\.pdf/}
  echo -n "Processing page ${PAGE} of ${TOTAL_PAGES}: "
  echo -n "Convert to bit-mapped image..."
  convert -density 300 "$f" "$TMPFILE1" 2> /dev/null
  echo -n "Remove stamp..."
  replacecolor -i "$STAMP_COLOR" -o white -f 20  "$TMPFILE1" "$TMPFILE2" 2>/dev/null
  echo -n "Denoise..."
  noisecleaner "$TMPFILE2" "$TMPFILE3" 2>/dev/null
  echo -n "Make it grayscale..."
  color2gray -f rms -c HSL -C 10 -B 10 "$TMPFILE3" "$TMPFILE4" 2>/dev/null 1>&2
  echo -n "Add border..."
  bordereffects -s 20 -d 1 -c 0 -g 1 -p 40  "$TMPFILE4" "$TMPFILE5"
  echo -n "Remove artefacts..."
  convert "$TMPFILE5" -normalize -level 25%,75% "$TMPFILE6" 2>/dev/null
  echo -n "Convert back to PDF..."
  convert -compress WebP "$TMPFILE6" "$f" 2>/dev/null
  echo "done."
  rm "$g" 2>/dev/null
done

echo -n "Assembling output PDF file $OUTFILE..."
pdftk "$TMPDIR"/pg_*.pdf cat output "$OUTFILE"
echo "done."

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MIN=$((DURATION / 60))
SEC=$((DURATION % 60))
cleanup
echo "Total processing time: ${MIN} minutes and ${SEC} seconds."

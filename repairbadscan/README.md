# NAME:

  repairbadscan - Clean up poor document scans, especially sheet music
  that has been scibbled on with pencil or with a librarian's stamp on it.

## SYNOPSIS:

  repairbadscan <input.pdf> <output.pdf> {stamp_color}

## DESCRIPTION:

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

## PARAMETERS:

  - <input.pdf>   The input PDF file to be cleaned up.
  - <output.pdf>  The output PDF file to be created.
  - {stamp_color} Optional. The color of the stamp to be removed, specified in
                hex format (e.g., #b67472). If not specified, the default
                color #b67472 (a rusty red) will be used.

## REQUIREMENTS:

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

# INSTALLATION:

  Download the script, copy it to a directory on your PATH and make it
  executable, eg:

    cp repairbadscan.sh /usr/local/bin/repairbadscan
    chmod +x repairbadscan.sh

  Then run it with the input and output PDF files as arguments:
    repairbadscan input.pdf output.pdf

## SEE ALSO:

  ImageMagick: https://imagemagick.org/
  PDTK: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
  Fred's ImageMagick Scripts: https://www.fmwconcepts.com/imagemagick

## ABOUT:

  This script was created by Gerrit Hoekstra in 2026. It is licensed under the
  GPL2.0 license. No cats were left unfed in the making of this script.



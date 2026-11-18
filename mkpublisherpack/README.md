# mkpublisherpack

This utility builds a sheet music publication pack that can be submitted to sheet music resellers. 
It uses the PDF-exported output of a MuseScore composition or arrangement and combines and bookmarks all the parts into a single PDF file,
complete with a front cover page. 

![Coverpage](.images/coverpage.png)

![Bookmarks](.images/bookmarks.png)

# Prerequisites:

You need to have the PDF Toolkit installed, a.k.a. "pdftk", as well as "pandoc".

# Usage:

    mkpublisherpack.sh

# Example:

To create the publisher pack, go to the current working directory to where the PDF parts are, and run this:

    mkpublisherpack.sh

The name of the publisher pack is based on the shortest PDF filename in the directory, which, by default, is the conductor score, as exported as a PDF file by MuseScore.
You would end up with a file called something like this:

    [Composition Name] - PublisherPack.pdf

Upload this to your chosen sheet music reseller. 
I use https://www.arrangeme.com, who then also re-publish on https://sheetmusicplus.com

# Installation:

Copy these files into your /usr/local/bin directory

    $ chmod +x mkpublisherpack.sh
    $ sudo cp mkpublisherpack.sh /usr/local/bin

# Configuration

Edit the file .attribution. If the file does not exist, it will automatically be created.
The content of this file will appear on the cover page. Example:

    $ cat .attribution
    Arranged for Big Band: Gerrit Hoekstra

    Composers: Cathal Smyth, Chris Foreman
    Original Artists: Madness

# Author:

Gerrit Hoekstra. You can contact me via https://github.com/bignosethethird

# Environmental Notice:

This work was created from 100%-recycled electrons. No animals were hurt during the production of this work, except when I forgot to feed my cats that one time. The cats and I are on speaking terms again.

You can burst a PDF doc with a table of contents into separate chapter PDF files, with each file named according to the chapter's name. 
This is a description of how to go about it, and in the end there is a full "Burst By Bookmark" shell script to do exactly this.  
If the PDF doc doesn't have a table of content, you can add one using a bespoke and expensive PDF tool, or use a different method to chunk the doc up into chapters. 

Here is a quick demonstration of what happens: We start with a single PDF file that has a table of contents:

```bash
gerrit@z3:~/Music/Just a Gigolo$ ls 
'Just a Gigolo.pdf'
```

Rnning this script, we get:

```
gerrit@z3:~/Music/Just a Gigolo$ ./burstbybookmark  
Chuking Just a Gigolo.pdf into 20 files:
Assembling Just a Gigolo - Full Score.pdf from pages 1 to 17... 
Assembling Just a Gigolo - Vocal.pdf from pages 18 to 20...
...
Assembling Just a Gigolo - Bass.pdf from pages 69 to 71...
Assembling Just a Gigolo - Drum Set.pdf from pages 72 to 74...
Done
```

How does this work? 

When we have a table of contents, we can view chapters' page boundaries (called "bookmarks" here) using pdftk, and use this as a basis to automate the file splitting into a separate file per chapter:

```bash
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
```

We see ere that the chapter "Chapter 1" starts from page 1, and that "Chapter 2" begins at page 18. Therefore "Chapter 1" ends at page 18 - 1 = 17.
Using pdftk, one can make a new document from these pages:

$ pdftk BigBook.pdf cat 1-17 output "Chapter 1.pdf"

And so on for each chapter. 

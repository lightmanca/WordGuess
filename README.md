Word Guess.... A "Wordle" clone written for CP/M machines.
By Sam Weiss, samweiss@lightman.org

Word Guess is written in Turbo Pascal 3.0, and consists of the main program, WrdGuess.com, and a word dictionary, Words.DTA.

This was written entirely on a real CP/M computer, an SC503 Z180 machine created by Stephen Cousins, based on the Z250 bus.  This machine uses RomWBW for it's firmware, and produces VT100 compatible serial output.

A few notes:

* The serial terminal used was PUTTY running on a "PiTop".  It has been found that VT100 control codes are not standard, and seem to vary based terminal emulation.  The source code is provided for the user to modify the "AnsiVid" procedure to change video settings for the display letters.

* The dictionary was found online, and contains 14,848 words.  The Author is NOT the source of these words, and an attempt was made to remove offensive words.  However if an offensive word is found it is not the author's doing.  Please email me, samweiss@lightman.org, and I will remove it.

* The dictionary is stored in a binary format in order to allow for random access to the words.  This was necessary to create a binary search routine to search entries to make sure words entered are valid.  Also to maintain a level of surprise the words are encoded, so as not to be directly readable.  It is understood it would be a very simple effort to write a program to "unencode" the words, if desired.

* Game play is quite accurate to the popular "Word Guess" game you may find on a popular news site.  However the detection of double letters in a guess was not implemented.  What this means is that if the guess you input has double letters, and it's not in the right spot it may erroneously report that the word has the letter.  This may or may not be the case.  At any rate if the letter is in the right spot it will highlight green, as expected.

* The word dictionary is huge.  Any word in the dictionary will be randomly picked as the word you need to guess.  This may frustrate the user, as many of the words are obscure.  The source of the word dictionary claims they came from the official source code of "Wordle".  I cannot verify this claim.  

* If you wish to use a new dictionary it will have to be modified to work with Word Guess.  I"ve included the program "WFileINI.pas" to do just that.  Please note that the word list you give it must be sorted A-Z, and should be a list of 5 letter words, 1 word per line.  Since modern OS's have built in sort routines it did not seem that creating an 8 bit sorter would be worth the time or energy.

Word list source: https://github.com/tabatkins/wordle-list

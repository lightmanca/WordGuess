Program WordGuess;  {Wordle Clone}

{WordDictionaryFile contains the word dictionary}
{It is a sorted binary file of 5 letter words   }
{To use your own dictionary run 'WFILEINI.PAS'  }
{To read a text file of words, and Put them in  }
{in the right format.                           }
{WordFileSize must contain the number of records}
{in WordDictionaryFile                          }
const WordDictionaryFile = 'Words.dta';
const WordFileSize = 14848;

const NumberOfGuesses = 6;
const GuessSize = 5;
const LettersSize = 26;

type
  {Letter status:                                           }
  {  Hit:     Letter is correct and in right place          }
  {  HalfHit: Letter is used in word, but is in wrong place.}
  {  NoHit:   Letter is not used in word.                   }
  {  UnUsed:  Letter has not been used in game yet.         }
  StatusT = (NoHit, Hit, HalfHit, UnUsed);

  WordType = string[5];
  StrGuessT = string[GuessSize];
  LetterT = 'A'..'Z';
  AnyString = string[255];

  {We're using a binary file to hold our word dictionary.  }
  {This is so we can use random access to get to the words.}
  {This is the record for the word storage.                }
  WordFileRecordT = record
    Word:  WordType;
  end;

  {Letter record stores a letter, and the associated status.}
  LetterRecord = record
    Letter: LetterT;
    Status: StatusT
  end;

var
  TheWord : WordType;
  GuessNumberMain: integer;
  GuessFoundInDictionary: boolean;
  Guess: StrGuessT;
  Letters: array[1..26] of LetterRecord;
  GuessLetters: array[1..6,1..5] of LetterRecord;
  InputCh : char;
  Winner : boolean;

  WordFile : file of WordFileRecordT;

{Set video attributes for each letter.       }
{Note: Even Vt100 Terminals vary. You may    }
{      have to modify this for your terminal.}
procedure AnsiVid(status: StatusT);
begin
  case status of
    NoHit  : write(chr(27),'[5;1m');     {Grey Bold}
    Hit    : write(chr(27),'[42;29;1m'); {Green}
    HalfHit: write(chr(27),'[43;29;1m'); {Yellow}
    Unused : write(chr(27),'[1m');       {Grey not bold normal}
  end;
end;

{Set video attributes to normal}
procedure NormalVideo;
begin
  write(chr(27),'[37;0m');
end;

{Convert Word to upper case}
function Upper(St : AnyString) : AnyString;
  var
    i:integer;
    result : StrGuessT;
  begin
    for i:=1 to Length(St) do
    begin
      St[i] := UpCase(St[i]);
    end;
    Upper := St;
  end;

{We did some 'Cheap' encoding work on }
{Dictionary words.  This function     }
{Decodes them.                        }
function Decode(s: WordType) : WordType;
  var
    i:integer;
    result : WordType;
  begin
    for i:=0 to GuessSize do
    begin
      result[i] := Chr(ord(s[i])+30);
    end;
    Decode := result;
  end;

{Open the Word Dictionary File}
procedure InitFile;
Begin
  Randomize;
  Assign(WordFile, WordDictionaryFile);
  Reset(WordFile);
End;

{Get a random word to use for Word Guess!}
function GetWord : WordType;
var
  WordFileRecord : WordFileRecordT;
  RecordNumber: integer;

Begin
  recordnumber := Random(WordFileSize);
  Seek(WordFile, recordnumber);
  Read(WordFile, wordfileRecord);
  GetWord := Decode(WordFileRecord.Word);
end;

{Binary Search for word in Dictionary file}
function FindWord(Word: WordType; low: integer; high :integer): Boolean;

var
  middle     : integer;
  workRecord : WordFileRecordT;

begin
  if high < low then
  begin
    FindWord := False;
    exit;
  end;
  middle := (low + high) div 2;
  Seek(WordFile, middle);
  Read(WordFile, WorkRecord);
  WorkRecord.Word := Decode(WorkRecord.Word);
  if WorkRecord.Word = Word then
  begin
     FindWord := True;
     exit;
  end;

  if(WorkRecord.word < Word) then
  begin
    FindWord := FindWord(Word, middle + 1, high);
    exit;
  end;

  FindWord := FindWord(Word, low, middle -1);
end;


{Init The Letters array in the order of the QWERTY Keyboard}
procedure InitLetters;

  procedure InitLetter(index: integer; letter: LetterT);
  begin
    Letters[index].Letter := letter;
    Letters[index].Status := Unused;
  end;

begin
  InitLetter(1,  'Q');
  InitLetter(2,  'W');
  InitLetter(3,  'E');
  InitLetter(4,  'R');
  InitLetter(5,  'T');
  InitLetter(6,  'Y');
  InitLetter(7,  'U');
  InitLetter(8,  'I');
  InitLetter(9,  'O');
  InitLetter(10, 'P');
  InitLetter(11, 'A');
  InitLetter(12, 'S');
  InitLetter(13, 'D');
  InitLetter(14, 'F');
  InitLetter(15, 'G');
  InitLetter(16, 'H');
  InitLetter(17, 'J');
  InitLetter(18, 'K');
  InitLetter(19, 'L');
  InitLetter(20, 'Z');
  InitLetter(21, 'X');
  InitLetter(22, 'C');
  InitLetter(23, 'V');
  InitLetter(24, 'B');
  InitLetter(25, 'N');
  InitLetter(26, 'M');
end;

{Initialize the letters to print for the guesses}
procedure InitGuessLetters(guessNumber: integer; guess: StrGuessT);
var
  i : integer;
begin
  for i := 1 to GuessSize do
  begin
    GuessLetters[guessNumber,i].Letter := guess[i];
    GuessLetters[guessNumber,i].Status := Unused;
  end;
end;

{Processing guess logic.  This looks at the guess, compares it}
{to the input word, and also goes through the keyboard letters}
{to mark letters as hit, halfhit, or nohit.                   }
procedure ProcessGuess(guessNumber: integer; guess: StrGuessT);
  var
    guessI     : integer;
    lettersI   : integer;
    MyWordI   : integer;
    halfHitFlag: boolean;
  begin
    {Brute forcing it}
    for guessI:= 1 to GuessSize do
    begin
      for lettersI := 1 to LettersSize do
      begin
        if guess[guessI] = Letters[lettersI].letter then
        begin
          if guess[guessI] = TheWord[guessI] then
          begin
            Letters[lettersI].Status := Hit;
            GuessLetters[guessNumber,guessI].Status := Hit;
          end
          else
          begin
            halfHitFlag := false;
            for MyWordI := 1 to guessSize do
            begin
              if guess[guessI] = TheWord[MyWordI] then
              begin
                Letters[lettersI].Status := HalfHit;
                GuessLetters[guessNumber, guessI].Status := HalfHit;
                halfHitFlag := true;
              end;
            end;
            if not halfHitFlag then
            begin
              Letters[lettersI].Status := NoHit;
              GuessLetters[guessNumber, guessI].Status := NoHit;
            end;
          end;
        end; {if guess[guessI] = letters[lettersI]}
      end; {for l}
    end; {for g}
  end;

{Print a letter, with appropriate highlighting}
procedure printLetter(lr: LetterRecord);
  begin
    AnsiVid(lr.status);
    write(' ',lr.letter,' ');
    NormalVideo;
    write(' ');
  end;

{Print the guesses}
procedure PrintGuesses(guessNumber: integer);
  var
    g: integer;
    l: integer;
  begin
    if guessNumber = 1 then
    begin
      WriteLn;
      WriteLn('                             No previous guesses');
      WriteLn;
      Exit;
    end;
    for g:=1 to guessNumber -1 do
    begin
      write('                             ');
      for l:=1 to GuessSize do
        PrintLetter(GuessLetters[g,l]);
      WriteLn;
      WriteLn;
    end; {For g}
    WriteLn;
  end; {of procedure}

{Print the keyboard, with appropriate letters highlighted}
procedure PrintKeyboard;
  var l: integer;

  begin
    write('                   ');
    for l:= 1 to LettersSize do
    begin
      PrintLetter(Letters[l]);
      if (l = 10) or (l = 19)  then
      begin
        writeln;
        writeln;
        if l=10 then
          write('                     ')
        else
          write('                         ');
      end;
    end;
    WriteLn;
    WriteLn;
  end;

{Print an intro banner.  Also calls PrintLetters,}
{and PrintKeyboard.  This method pretty much     }
{controls most of the display work.              }
procedure Banner(guessNumber: integer);
  begin
    clrscr;
    Writeln;
    WriteLn('                                  Word Guess');
    Writeln;
    Writeln('       Guess # ',guessNumber);
    Writeln;
    PrintGuesses(guessNumber);
    Writeln;
    PrintKeyboard;
    WriteLn;
  end;

{Winner!!!}
procedure WinnerWinnerChickenDinner(guessNumber: integer);
  begin
    Banner(guessNumber + 1);
    WriteLn;
    Writeln('Winner in ',guessNumber,' Guesses!!!');
    Writeln;
  end;

{Loser!!}
procedure LoserLoserRamenDinner(guessNumber: integer);
  begin
    Banner(guessNumber + 1);
    WriteLn;
    Writeln('Sorry. You Lost in ',guessNumber,' Guesses.');
    Writeln('The word was: ',TheWord);
    Writeln;
  end;

{Main Loop.                                                }
{1.  Find a word to play wordle with                       }
{2.  Ask player for a guess.                               }
{3.  Try to find Guess in word dictionary                  }
{3a. If guess word is not found in dictionary then ask     }
{    player for new word                                   }
{4.  Process word to determine Letters used.               }
{5.  Print result, and give the user 6 tries to guess word.}
begin {Main Program}
  InitFile;
  repeat {Play Loop}
    Winner := false;
    TheWord := GetWord;
    InitLetters;
    GuessNumberMain := 1;
    repeat {Until Winner or Guess # = 5}
      repeat {Guess Found in Dictionary}
        Banner(GuessNumberMain);
        Write('        Enter guess: ');
        Readln(Guess);
        WriteLn;
        WriteLn('        Searching Dictonary for Word...');
        Guess := Upper(Guess);
        GuessFoundInDictionary := FindWord(Guess, 0, WordFileSize);
        if not GuessFoundInDictionary then
        begin
          WriteLn('Guess Not Found in dictionary. Please enter a valid 5 letter word.');
          Writeln;
          Write('Press a key to continue');
          Read(Kbd, InputCh);
        end;
      until GuessFoundInDictionary;
      InitGuessLetters(GuessNumberMain, Guess);
      ProcessGuess(GuessNumberMain, Guess);

      if guess = TheWord then
      begin
        WinnerWinnerChickenDinner(GuessNumberMain);
        winner := true;
      end;
      GuessNumberMain := GuessNumberMain + 1;
    until Winner or (GuessNumberMain > NumberOfGuesses);
    if(not Winner) then
      LoserLoserRamenDinner(NumberOfGuesses);
    WriteLn;
    Write('Play Again? ');
    Read(Kbd, InputCh)
  Until(UpCase(InputCh) <> 'Y');
  WriteLn;
  WriteLn('Thanks for playing!!');
  WriteLn;
end.

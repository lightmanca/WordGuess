{Wordle dictionary initializer.     }
{Reads a text file of sorted 5 letter words}
{And Writes them in a Turbo pascal binary  }
{file format.  Also words are converted to }
{all uppercase, and "encoded" so that a    }
{user cannot simply read the word file.    }

{Important: words must be sorted in the    }
{input file from a to z so the binary      }
{search in worle will work.                }

program WordleFileInitializer;

const InputTextFile = 'Words.txt';
const OutputDictionaryFile = 'Words.dta'; {This file will be erased.}

type
  WordType = string[5];
  WordFileRecordT = record
    Word:  WordType;
  end;

var
  WordFile : file of WordFileRecordT;
  WordTextFile: Text;

  WordFileRecord : WordFileRecordT;
  Line : WordType;

  x : integer;

{Converts word to upper case, and then 'encodes'}
{it so it cannot be read from the file.         }
function UpperEncode(s : WordType) : WordType;
  var
    i:integer;
    result : WordType;
  begin
    for i:=0 to 5 do
    begin
      result[i] := UpCase(s[i]);
      result[i] := Chr(ord(result[i])-30);
    end;
    UpperEncode := result;
  end;

{Decoding method, so we can see that the words}
{Can be decoded by Wordle.                    }
function Decode(s: WordType) : WordType;
  var
    i:integer;
    result : WordType;
  begin
    for i:=0 to 5 do
    begin
      result[i] := Chr(ord(s[i])+30);
    end;
    Decode := result;
  end;

begin
  x := 0;
  Assign(WordTextFile, InputTextFile);
  Assign(WordFile, OutputDictionaryFile);

  Reset(WordTextFile);
  Rewrite(WordFile);

  While not EOF(WordTextFile) do
  begin
    x := x + 1;
    Readln(WordTextFile, Line);
    WordFileRecord.Word := UpperEncode(Line);
    Write(WordFile, WordFileRecord);
    WriteLn(Line, '     ', WordFileRecord.Word, '     ', Decode(WordFileRecord.Word));
  End;
  Close(WordFile);
  writeln;
  writeln('Number of records : ',x);
end.


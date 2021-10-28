unit umain;

{$mode objfpc}{$H+}

{ Noso TrxReader v 0.1.
  Made in 2021 by P Bjørn Biermann Madsen
  The Noso TrxReader is partly based on code made by NosoCoin Project.
  This is free and unencumbered software released into the public domain.
  Anyone is free to copy, modify, publish, use, compile, sell, or
  distribute this software, either in source code form or as a compiled
  binary, for any purpose, commercial or non-commercial, and by any
  means.
  In jurisdictions that recognize copyright laws, the author or authors
  of this software dedicate any and all copyright interest in the
  software to the public domain. We make this dedication for the benefit
  of the public at large and to the detriment of our heirs and
  successors. We intend this dedication to be an overt act of
  relinquishment in perpetuity of all present and future rights to this
  software under copyright law.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.
  For more information, please refer to <http://unlicense.org/>
  }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  DateUtils, StrUtils;

type

  MyTrxData = packed record
     block : integer;
     time  : int64;
     tipo  : string[6];
     receiver : string[64];
     monto    : int64;
     trfrID   : string[64];
     OrderID  : String[64];
     reference : String[64];
     end;


Type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    FileMyTrx  : File of MyTrxData;
    MyTrxFilename : string;
    ListaMisTrx : Array of MyTrxData;
    SearchAfterPos: Integer;
    Procedure LoadMyTrx(FileName: string);
    function Int2Curr(Value: int64): string;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

// Loads user transactions from disk
Procedure TForm1.LoadMyTrx(FileName: string);
var
  dato : MyTrxData;
Begin
   try
   assignfile(FileMyTrx,FileName);
   reset(FileMyTrx);
   setlength(ListaMisTrx,0);
   while not eof(FileMyTrx) do
      begin
      Dato := Default(MyTrxData);
      setlength(ListaMisTrx,length(ListaMisTrx)+1);
      read(FileMyTrx,dato);
      ListaMisTrx[length(ListaMisTrx)-1] := dato;
      end;
   closefile(FileMyTrx);
   Except on E:Exception do
     ShowMessage('Error can not open ' + FileName);
   end;
End;

function TForm1.Int2Curr(Value: int64): string;
begin
Result := IntTostr(Abs(Value));
result :=  AddChar('0',Result, 9);
Insert('.',Result, Length(Result)-7);
If Value <0 THen Result := '-'+Result;
end;

{ TForm1 }


procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
begin
  if Not FileExists(MyTrxFilename) then
  begin
    OpenDialog1.InitialDir := ExtractFileDir(Application.Exename);
    if OpenDialog1.Execute then
      if fileExists(OpenDialog1.Filename) then  MyTrxFilename := OpenDialog1.Filename
      else ShowMessage('No file selected');
  end;
  LoadMyTrx('mytrx.nos');
  for i := Length(ListaMisTrx) - 1 downto 0 do
  begin
    Memo1.Lines.Add('Block:     ' + IntToStr(ListaMisTrx[i].block));
    Memo1.Lines.Add('Time:      ' + DateTimeToStr(UnixToDateTime((ListaMisTrx[i].time), True)));
    Memo1.Lines.Add('Type:      ' + ListaMisTrx[i].tipo);
    Memo1.Lines.Add('Reciever:  ' + ListaMisTrx[i].receiver);
    Memo1.Lines.Add('Amount:    ' + Int2Curr(ListaMisTrx[i].monto) + ' Noso');
    Memo1.Lines.Add('TrfrID:    ' + ListaMisTrx[i].trfrID);
    Memo1.Lines.Add('OrderID:   ' + ListaMisTrx[i].OrderID);
    Memo1.Lines.Add('Reference: ' + ListaMisTrx[i].reference);
    Memo1.Lines.Add('--------------------------');
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  s: string;
  i, searchstart: Integer;
begin
  if Button2.Caption = 'Search' then
  begin
    SearchAfterPos := 0;
    Button2.Caption := 'Next';
  end;
  searchstart:=SearchAfterPos+1;
  s := Copy(Memo1.Text, searchstart, length(Memo1.Text)-(searchstart));
  i := PosEx(Edit1.Text, s);
  if (i <> 0) then begin
    Memo1.SelStart := (i-2)+(searchstart);
    Memo1.SelLength := length(edit1.Text);
    memo1.SetFocus;
    SearchAfterPos:=SearchAfterPos+i+Length(Edit1.Text)-1;
  end else begin
    ShowMessage('No more foud');
    SearchAfterPos:=0;
    Button2.Caption := 'Search';
  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button2.Caption := 'Search';
end;


end.

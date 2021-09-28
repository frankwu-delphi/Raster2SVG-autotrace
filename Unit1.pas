unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, JvComponentBase, JvAppCommand, DosCommand, Vcl.ExtDlgs,
  SVGIconImage;

type
  TImageType = (IT_None, IT_Error, IT_Bmp, IT_JPEG, IT_GIF, IT_PCX, IT_PNG,
    IT_PSD, IT_RAS, IT_SGI, IT_TIFF);

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    OpenPictureDialog1: TOpenPictureDialog;
    SVGIconImage1: TSVGIconImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FDosCommand: TDosCommand;
    FSvgText: TStringList;
    FTempFile: string;
    FCRCCode: string;
    FBitmap: TBitmap;
    procedure DosCommandNewLine(ASender: TObject; const ANewLine: string;
      AOutputType: TOutputType);
    procedure DosCommandTemTerminated(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


uses
  System.IOUtils, IdHashCRC, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg;

function CheckImageType(FileName: string): TImageType;
var
  LImage: TMemoryStream;
  Buffer: Word;
begin
  LImage := TMemoryStream.Create;
  try
    LImage.LoadFromFile(FileName);
    LImage.Position := 0;
    if LImage.Size = 0 then // 如果文件大小等于0，那么错误(
    begin
      Result := IT_Error;
      Exit;
    end;
    LImage.ReadBuffer(Buffer, 2); // 读取文件的前２个字节,放到Buffer里面

    case Buffer of
      $4D42:
        Result := IT_Bmp;
      $D8FF:
        Result := IT_JPEG;
      $4947:
        Result := IT_GIF;
      $050A:
        Result := IT_PCX;
      $5089:
        Result := IT_PNG;
      $4238:
        Result := IT_PSD;
      $A659:
        Result := IT_RAS;
      $DA01:
        Result := IT_SGI;
      $4949:
        Result := IT_TIFF;
    else
      Result := IT_None;
    end;
  finally
    LImage.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  LEXEPath: string;
begin
  LEXEPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'autotrace\autotrace.exe';

  Edit1.Text := LEXEPath;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  LEXEPath: string;
  LCRCHash: TIdHashCRC32;
  LStream: TStream;
  LPng: TPngImage;
  LJPG: TJpegImage;
  LImageType: TImageType;
  LFileName: string;
  IsOK: Boolean;
  LHashSize: Integer;
begin
  if OpenPictureDialog1.Execute then
  begin
    IsOK := False;
    FSvgText.Clear;
    LHashSize := 1024 * 10; // Hash size 10Kb
    LFileName := OpenPictureDialog1.FileName;
    Edit2.Text := LFileName;
    LImageType := CheckImageType(LFileName);

    case LImageType of
      IT_None:
        ;
      IT_Error:
        ;
      IT_Bmp:
        begin
          LStream := TMemoryStream.Create;
          TMemoryStream(LStream).LoadFromFile(LFileName);
          if TMemoryStream(LStream).Size < LHashSize then
            LHashSize := TMemoryStream(LStream).Size;
          LCRCHash := TIdHashCRC32.Create;
          LStream.Position := 0;
          FTempFile := LCRCHash.HashStreamAsHex(LStream,0,LHashSize) + '.bmp';
          TMemoryStream(LStream).SaveToFile(FTempFile);
          LStream.Position := 0;
          FBitmap.LoadFromStream(LStream);
          FBitmap.SaveToFile(FTempFile);
          LStream.Free;
          LCRCHash.Free;

          IsOK := True;
        end;
      IT_JPEG:
        begin
          LJPG := TJpegImage.Create;
          LJPG.LoadFromFile(LFileName);

          LStream := TMemoryStream.Create;
          LJPG.SaveToStream(LStream);
          if TMemoryStream(LStream).Size < LHashSize then
            LHashSize := TMemoryStream(LStream).Size;
          LCRCHash := TIdHashCRC32.Create;
          LStream.Position := 0;
          FTempFile := LCRCHash.HashStreamAsHex(LStream, 0, LHashSize) + '.bmp';
          LCRCHash.Free;
          LStream.Free;
          FBitmap.Assign(LJPG);
          FBitmap.SaveToFile(FTempFile);
          LJPG.Free;

          IsOK := True;
        end;
      IT_GIF:
        ;
      IT_PCX:
        ;
      IT_PNG:
        begin
          LPng := TPngImage.Create;
          LPng.LoadFromFile(LFileName);

          LStream := TMemoryStream.Create;
          LPng.SaveToStream(LStream);
          if TMemoryStream(LStream).Size < LHashSize then
            LHashSize := TMemoryStream(LStream).Size;
          LCRCHash := TIdHashCRC32.Create;
          LStream.Position := 0;
          FTempFile := LCRCHash.HashStreamAsHex(LStream, 0, LHashSize) + '.bmp';
          LCRCHash.Free;
          LStream.Free;
          FBitmap.Assign(LPng);
          FBitmap.SaveToFile(FTempFile);
          LPng.Free;

          IsOK := True;
        end;
      IT_PSD:
        ;
      IT_RAS:
        ;
      IT_SGI:
        ;
      IT_TIFF:
        ;
    end;

    if IsOK then
    begin
      FDosCommand.Stop;
      FDosCommand.CommandLine :=
        Edit1.Text +
        ' --color-count=256 --output-format=svg ' + FTempFile;
      FDosCommand.CurrentDir := GetCurrentDir;
      FDosCommand.Execute;
    end;
  end;
end;

procedure TForm1.DosCommandNewLine(ASender: TObject; const ANewLine: string;
  AOutputType: TOutputType);
begin
  if AOutputType = otEntireLine then
    FSvgText.Add(ANewLine);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDosCommand := TDosCommand.Create(Self);
  with FDosCommand do
  begin
    InputToOutput := False;
    MaxTimeAfterBeginning := 0;
    MaxTimeAfterLastOutput := 0;
    OnNewLine := DosCommandNewLine;
    OnTerminated := DosCommandTemTerminated;
  end;

  Edit1.Text :=
  // 'E:\Raster2SVG\autotrace\autotrace.exe';
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'autotrace\autotrace.exe';

  FSvgText := TStringList.Create;
  FBitmap := TBitmap.Create;
end;

procedure TForm1.DosCommandTemTerminated(Sender: TObject);
begin
  SVGIconImage1.SVGText := FSvgText.Text;
  if FileExists(FTempFile) then
    DeleteFile(FTempFile);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FBitmap.Free;
  FSvgText.Free;
  FDosCommand.Free;
end;

end.

object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Form1'
  ClientHeight = 378
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object SVGIconImage1: TSVGIconImage
    Left = 8
    Top = 122
    Width = 250
    Height = 250
    AutoSize = False
  end
  object Button1: TButton
    Left = 8
    Top = 31
    Width = 250
    Height = 30
    Caption = 'load autotrace.exe'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 86
    Width = 250
    Height = 30
    Caption = 'load image'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 250
    Height = 21
    TabOrder = 2
  end
  object Edit2: TEdit
    Left = 8
    Top = 63
    Width = 250
    Height = 21
    TabOrder = 3
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = '*.png|*.png|*.bmp|*.bmp|*.jpg|*.jpg'
    Left = 120
    Top = 184
  end
end

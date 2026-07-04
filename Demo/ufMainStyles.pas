unit ufMainStyles;

interface

uses
  System.SysUtils, System.Types, System.UIConsts, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uRhoTrackBar,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects,FMX.Utils, FMX.StdCtrls;

type
  TfrmMain = class(TForm)
    RhoTrackBar1: TRhoTrackBar;
    StyleBook1: TStyleBook;
    RhoTrackBar2: TRhoTrackBar;
    Edit1: TEdit;
    Rectangle1: TRectangle;
    ProgressBar1: TProgressBar;
    procedure RhoTrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RhoTrackBar2Change(Sender: TObject);
  private
    { Private declarations }
    procedure SetColorValue (Value : Single);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

USes System.Math;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Edit1.text := Format('%.2f', [RhoTrackBar1.Value]);
  SetColorValue(RhoTrackBar2.Value);
  ProgressBar1.Value := RhoTrackBar2.Value;
end;

procedure TfrmMain.RhoTrackBar1Change(Sender: TObject);
begin
  Edit1.text := Format('%.2f', [RhoTrackBar1.Value]);
end;


procedure TfrmMain.SetColorValue (Value : Single);
var Percentage : Single;
  R, G: Byte;
begin
  Percentage := RhoTrackBar2.Value / 100.0;

  R := Round(Percentage * 255);       // Low input = No Red, High input = Max Red
  G := Round((1.0 - Percentage) * 255); // Low input = Max Blue, High input = No Blue

  Rectangle1.Fill.Kind := TBrushKind.Solid;
  Rectangle1.Fill.Color := MakeColor(R, G, 0, 255);
end;


procedure TfrmMain.RhoTrackBar2Change(Sender: TObject);
begin
  SetColorValue(RhoTrackBar2.Value);
  ProgressBar1.Value := RhoTrackBar2.Value;
end;

end.

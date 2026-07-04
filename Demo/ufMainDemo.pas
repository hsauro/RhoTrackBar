unit ufMainDemo;

interface

uses
  System.SysUtils, System.Types, System.UIConsts, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uRhoTrackBar,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Utils;

type
  TfrmMain = class(TForm)
    RhoTrackBar1: TRhoTrackBar;
    ProgressBar1: TProgressBar;
    Rectangle1: TRectangle;
    RhoTrackBar2: TRhoTrackBar;
    Label1: TLabel;
    RhoTrackBar4: TRhoTrackBar;
    RhoTrackBar5: TRhoTrackBar;
    RhoTrackBar3: TRhoTrackBar;
    RhoTrackBar6: TRhoTrackBar;
    RhoTrackBar7: TRhoTrackBar;
    RhoTrackBar8: TRhoTrackBar;
    RhoTrackBar9: TRhoTrackBar;
    RhoTrackBar10: TRhoTrackBar;
    RhoTrackBar11: TRhoTrackBar;
    RhoTrackBar12: TRhoTrackBar;
    RhoTrackBar13: TRhoTrackBar;
    RhoTrackBar14: TRhoTrackBar;
    procedure RhoTrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

Uses Math;

function GetInterpolatedColor(StartColor, EndColor: TAlphaColor; Value: Integer): TAlphaColor;
var
  C1, C2: TAlphaColorRec;
  ResultRec: TAlphaColorRec;
  Factor: Single;
begin
  // Clamp value strictly between 0 and 100
  Value := EnsureRange(Value, 0, 100);

  // Convert 0..100 into a 0.0..1.0 multiplier
  Factor := Value / 100.0;

  C1 := TAlphaColorRec(StartColor);
  C2 := TAlphaColorRec(EndColor);

  // Linearly interpolate each individual channel
  ResultRec.A := Round(C1.A + (C2.A - C1.A) * Factor);
  ResultRec.R := Round(C1.R + (C2.R - C1.R) * Factor);
  ResultRec.G := Round(C1.G + (C2.G - C1.G) * Factor);
  ResultRec.B := Round(C1.B + (C2.B - C1.B) * Factor);

  Result := TAlphaColor(ResultRec);
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Rectangle1.Fill.Color := GetInterpolatedColor(claRed, claBlue, trunc (RhoTrackBar1.Value));
end;

procedure TfrmMain.RhoTrackBar1Change(Sender: TObject);
begin
  ProgressBar1.Value := (Sender as TRhoTrackBar).Value;

  Rectangle1.Fill.Color := GetInterpolatedColor(claRed, claBlue, trunc ((Sender as TRhoTrackBar).Value));
end;

end.

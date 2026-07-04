program TrackbarStylesDemoProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  ufMainStyles in 'ufMainStyles.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

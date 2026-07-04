program TrackBarDemoProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  ufMainDemo in 'ufMainDemo.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

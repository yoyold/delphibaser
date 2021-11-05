program Delphibaser;

uses
  System.StartUpCopy,
  FMX.Forms,
  SQLViewer in 'SQLViewer.pas' {DelphiBaserFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDelphiBaserFrm, DelphiBaserFrm);
  Application.Run;
end.

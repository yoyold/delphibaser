unit SQLViewer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation,
  System.Rtti, FMX.Grid.Style, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.ScrollBox, FMX.Grid, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Controls, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, FMX.Layouts, Fmx.Bind.Navigator,
  Data.Bind.Grid, Data.Bind.DBScope, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FMX.Memo,
  FMX.ListBox, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Phys.FBDef, FireDAC.Phys.MSAccDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSAcc, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Phys.PGDef,
  FireDAC.Phys.PG, FireDAC.Phys.SQLiteWrapper.Stat;

type
  TDelphiBaserFrm = class(TForm)
    TopPanel: TPanel;
    RightPanel: TPanel;
    LeftPanel: TPanel;
    CenterInformationPanel: TPanel;
    BottomPanel: TPanel;
    CenterPanel: TPanel;
    CloseFrmBtn: TSpeedButton;
    DBFDConnection: TFDConnection;
    DBFDQuery: TFDQuery;
    EdModeSwitch: TSwitch;
    EdModeLbl: TLabel;
    BindSourceDB: TBindSourceDB;
    StringGridBindSourceDB: TStringGrid;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    NavigatorBindSourceDB: TBindNavigator;
    BindingsList: TBindingsList;
    GoButton: TButton;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    TableNamesComboBox: TComboBox;
    OpenDialog: TOpenDialog;
    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
    OpenDbFileSpBtn: TSpeedButton;
    SelectedDBLabel: TLabel;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDPhysMSAccessDriverLink: TFDPhysMSAccessDriverLink;
    DriversComboBox: TComboBox;
    DriverLabel: TLabel;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    procedure CloseFrmBtnClick(Sender: TObject);
    procedure EdModeSwitchSwitch(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DriversComboBoxChange(Sender: TObject);
    procedure OpenDbFileSpBtnClick(Sender: TObject);

  private // procedures, functions
    procedure SetConnectionParams();
    procedure SetConnectionDriverID();
    procedure OpenQuery();
    procedure FillTableNamesComboBox();
    procedure FillDriverNamesComboBox();
    procedure LoadIniFile();
    procedure SaveIniFile();

  private // var
    DatabasePath : string;
    SQLStatement : string;

  public
    // public-Declarations
end;

  var
    DelphiBaserFrm: TDelphiBaserFrm;

implementation

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Surface.fmx MSWINDOWS}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TDelphiBaserFrm.FormCreate(Sender: TObject);
begin
  //FillComboBoxWithTableNames();
  FillDriverNamesComboBox();
  LoadIniFile();
end;

procedure TDelphiBaserFrm.FillDriverNamesComboBox();
begin                                       // Index
  DriversComboBox.Items.Add('MySQL');       //   0
  DriversComboBox.Items.Add('SQLite');      //   1
  DriversComboBox.Items.Add('PostgreSQL');  //   2
  DriversComboBox.Items.Add('Firebird');    //   3
  DriversComboBox.Items.Add('MSAccess');    //   4
end;

procedure TDelphiBaserFrm.DriversComboBoxChange(Sender: TObject);
begin
  SetConnectionDriverID();
end;

procedure TDelphiBaserFrm.SetConnectionDriverID();
begin
  case DriversComboBox.ItemIndex of
     0: DBFDConnection.Params.DriverID := 'MySQL';
     1: DBFDConnection.Params.DriverID := 'SQLite';
     2: DBFDConnection.Params.DriverID := 'PG';
     3: DBFDConnection.Params.DriverID := 'FB';
     4: DBFDConnection.Params.DriverID := 'MSAcc';
end;
end;

procedure TDelphiBaserFrm.EdModeSwitchSwitch(Sender: TObject);
begin
  if EdModeSwitch.IsChecked then begin
    // do all read-only settings
    EdModeLbl.Text := 'Edit Mode';
    NavigatorBindSourceDB.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast,nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh];
  end
  else begin
    EdModeLbl.Text := 'Read-only Mode';
    NavigatorBindSourceDB.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast];
  end;
end;

// for connection test purposes
procedure TDelphiBaserFrm.GoButtonClick(Sender: TObject);
begin
  SetConnectionParams();
  OpenQuery();
end;


procedure TDelphiBaserFrm.SetConnectionParams();
begin
  DBFDConnection.Params.Clear;
  DBFDConnection.Params.Add('Database=' + DatabasePath);
  SetConnectionParams();
  DbFDConnection.Connected := true;
  FillTableNamesComboBox();
end;

procedure TDelphiBaserFrm.OpenQuery();
begin
  DBFDQuery.Active   := false;
  if Trim(SQLStatement) <> '' then begin
    DBFDQuery.SQL.Text := SQLStatement + TableNamesComboBox.Items[TableNamesComboBox.ItemIndex];
    DBFDQuery.Active   := true;
  end;
end;

procedure TDelphiBaserFrm.FillTableNamesComboBox();
begin
  DBFDConnection.GetTableNames('','','',TableNamesComboBox.Items,[osMy],[tkTable],true);
end;

procedure TDelphiBaserFrm.LoadIniFile();
begin
    // load settings from file after start
end;

procedure TDelphiBaserFrm.SaveIniFile();
begin
    // save settings when closing form
end;

procedure TDelphiBaserFrm.OpenDbFileSpBtnClick(Sender: TObject);
begin
  OpenDialog.Title := 'Choose a database file';
  if OpenDialog.Execute then begin
    DatabasePath := OpenDialog.FileName;
  end;
end;

procedure TDelphiBaserFrm.CloseFrmBtnClick(Sender: TObject);
begin
  SaveIniFile();
  Application.Terminate();
end;

end.

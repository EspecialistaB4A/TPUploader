unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Data.Win.ADODB, DBAccess, Uni, MySQLUniProvider, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Mask, System.IniFiles, IdCoderMIME, System.UITypes;

const
    SW_VERSION    = 'v1.0';
    DATABASE_NAME = 'almoxarifado';
    TABLE_NAME    = 'itens';
    SHEET_NAME    = 'QuantumGrid1';
    FORM_CAPTION  = 'Atualizador de Dados - Consumo ' + SW_VERSION;

type
  TfrmMain = class(TForm)
    gbItensQtd: TGroupBox;
    btAtualizar: TBitBtn;
    gbServidor: TGroupBox;
    btFechar: TBitBtn;
    btCarregarImagens: TBitBtn;
    lbServidor: TLabel;
    bUsuario: TLabel;
    edUsuario: TEdit;
    lbSenha: TLabel;
    edSenha: TEdit;
    edServidor: TEdit;
    procedure btAtualizarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btCarregarImagensClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ExportExcelToMySQL(const ExcelFile, SheetName, MySQLTable: string);
    procedure EnableItems(Value: Boolean);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

/////////////////////////////////////////////////////////////////////////////

procedure TfrmMain.btAtualizarClick(Sender: TObject);
var
  sExcelFile:       String;
begin
  // Assemble the OpenDialog
  with TFileOpenDialog.Create(nil) do begin
    try
      // Title and options
      Title := 'Selecione o Arquivo Excel a ser importado...';
      Options := [fdoNoDereferenceLinks, fdoDontAddToRecent, fdoPathMustExist, fdoForceFileSystem];
      OkButtonLabel := 'Selecionar';

      // File types
      with FileTypes.Add do begin
        DisplayName := 'Arquivos Excel';
        FileMask := '*.xlsx';
      end;
      with FileTypes.Add do begin
        DisplayName := 'Arquivos Excel (97-2003)';
        FileMask := '*.xls';
      end;
      FileTypeIndex := 0;

      // initial folder
      DefaultFolder := ExtractFilePath(Application.ExeName);
      FileName := ExtractFilePath(Application.ExeName);

      // run dialog
      if Execute then begin
        // a file is choosen
        sExcelFile := FileName;
      end else begin
        // no file chosen, sign and exit
        MessageDlg('Interrompido!', TMsgDlgType.mtWarning, [mbOk], 0);
        Exit;
      end;

    finally
      // free dialog
      Free;
    end;
  end;

  // upload excel file to the server
  try
    // Call the procedure with your Excel file, sheet name, and MySQL table name
    Self.EnableItems(False);
    Screen.Cursor := crSQLWait;
    ExportExcelToMySQL(sExcelFile, SHEET_NAME, TABLE_NAME);
    Screen.Cursor := crDefault;
    MessageDlg('Dados atualizados!!', TMsgDlgType.mtInformation, [mbOk], 0, mbOk)
  except
    // on exceptin, warn and exit
    on E: Exception do begin
      Screen.Cursor := crDefault;
      Self.EnableItems(True);
      MessageDlg('Erro Crítico: ' + E.Message, TMsgDlgType.mtError, [mbOk], 0, mbOk);
      Exit;
    end;
  end;

  // enable panels
  Self.EnableItems(True);
end;

procedure TfrmMain.btCarregarImagensClick(Sender: TObject);
var
  sImgPath:             String;
  sImgName:             String;
  stImgStream:          TFileStream;
  uniConnection:        TuniConnection;
  uniQuery:             TuniQuery;
begin
  // find pictures folder
  with TFileOpenDialog.Create(nil) do
    try
      Title := 'Selecione a pasta com as fotos';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
      OkButtonLabel := 'Selecionar';
      DefaultFolder := ExtractFilePath(Application.ExeName);
      FileName := ExtractFilePath(Application.ExeName);
      if Execute then begin
        sImgPath := IncludeTrailingPathDelimiter(FileName);
      end else begin
        // sing and exit
        MessageDlg('Interrompido!', TMsgDlgType.mtWarning, [mbOk], 0);
        Exit;
      end;
    finally
      Free;
    end;

  // Initialize MySQL connection
  Self.EnableItems(False);
  uniConnection := TuniConnection.Create(nil);
  uniQuery := TuniQuery.Create(nil);

  // start connection to MySQL Server
  try
    // Setup the MySQL connection (adjust the properties as per your MySQL setup)
    Screen.Cursor := crSQLWait;
    uniConnection.ProviderName := 'MySQL';
    uniConnection.Server := edServidor.Text;
    uniConnection.Database := DATABASE_NAME;
    uniConnection.Username := edUsuario.Text;
    uniConnection.Password := edSenha.Text;
    uniConnection.Connect;
    uniQuery.Connection := uniConnection;

    // create query
    uniQuery.SQL.Add(Format('SELECT * FROM %s;', [TABLE_NAME]));
    uniQuery.Open;
    uniQuery.First;

    // search for all registers
    while not uniQuery.Eof do begin
      // assemble file name
      sImgName := sImgPath + uniQuery.FieldByName('cod_reduzido').AsString + '.jpg';

      // check for the file
      if FileExists(sImgName) then begin
        // load image
        stImgStream := TFileStream.Create(sImgName, fmOpenRead);
        // edit record
        uniQuery.Edit;
        (uniQuery.FieldByName('image') as TBlobField).LoadFromStream(stImgStream);
        // post modifications
        uniQuery.Post;
        // discard stream
        stImgStream.Free;
      end;

      // next record
      uniQuery.Next;
    end;
  finally
    uniQuery.Free;
    uniConnection.Free;
  end;

  // commit all transactions
  uniQuery.Connection.Commit;
  Screen.Cursor := crDefault;
  Self.EnableItems(True);

  // notify
  MessageDlg('Carregamento Concluido!!', TMsgDlgType.mtInformation, [mbOk], 0);
end;

procedure TfrmMain.btFecharClick(Sender: TObject);
begin
  // close
  Close;
end;

procedure TfrmMain.ExportExcelToMySQL(const ExcelFile, SheetName, MySQLTable: string);
var
  ADOConnection:              TADOConnection;
  ADOQuery:                   TADOQuery;
  uniConnection:              TUniConnection; // DevArt MySQL connection component
  uniQuery:                   TUniQuery;
  NomeAlmox, Desc, Sigla:     String;
  Qtd, Codigo:                Integer;
begin
  // Initialize MySQL connection
  uniConnection := TuniConnection.Create(nil);
  uniQuery := TuniQuery.Create(nil);

  // start connection to MySQL Server
  try
    // Setup the MySQL connection (adjust the properties as per your MySQL setup)
    uniConnection.ProviderName := 'MySQL';
    uniConnection.Server := edServidor.Text;
    uniConnection.Database := DATABASE_NAME;
    uniConnection.Username := edUsuario.Text;
    uniConnection.Password := edSenha.Text;
    uniConnection.Connect;

    // query connection
    uniQuery.Connection := uniConnection;

    // Initialize ADO components
    ADOConnection := TADOConnection.Create(nil);
    ADOQuery := TADOQuery.Create(nil);
    try
      // Set up the ADO connection to the Excel file
      ADOConnection.ConnectionString := Format(
        'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=%s;Extended Properties="Excel 12.0 Xml;HDR=Yes";',
        [ExcelFile]);
      ADOConnection.LoginPrompt := False;
      ADOConnection.Open;

      // Prepare to select from the Excel sheet
      ADOQuery.Connection := ADOConnection;
      ADOQuery.SQL.Text := 'SELECT * FROM [' + SheetName + '$]'; // Sheet name with $ is required in ADO for Excel
      ADOQuery.Open;

      try
        // Loop through all the records in the Excel sheet
        while not ADOQuery.Eof do begin

          NomeAlmox := QuotedStr(ADOQuery.FieldByName('nome_almox').AsString);
          Qtd       := ADOQuery.FieldByName('quantidade').AsInteger;
          Codigo    := ADOQuery.FieldByName('cod_reduzido').AsInteger;
          Desc      := QuotedStr(ADOQuery.FieldByName('descr_produto').AsString);
          Sigla     := QuotedStr(ADOQuery.FieldByName('sigla_unidade').AsString);

          // Prepare the MySQL insert query
          uniQuery.SQL.Add('START TRANSACTION;');
          uniQuery.SQL.Add('-- Try to update the existing record');
          uniQuery.SQL.Add(Format('UPDATE %s', [MySQLTable]));
          uniQuery.SQL.Add(Format('SET quantidade = %d', [Qtd]));
          uniQuery.SQL.Add(Format('WHERE (nome_almox = %s) AND (cod_reduzido = %d);', [NomeAlmox, Codigo]));
          uniQuery.SQL.Add('-- Insert a new record if no update occurred');
          uniQuery.SQL.Add(Format('INSERT INTO %s (nome_almox, quantidade, cod_reduzido, descr_produto, sigla_unidade)', [MySQLTable]));
          uniQuery.SQL.Add(Format('  SELECT %s, %d, %d, %s, %s from DUAL', [NomeAlmox, Qtd, Codigo, Desc, Sigla]));
          uniQuery.SQL.Add(Format('  WHERE NOT EXISTS (SELECT quantidade FROM %s WHERE (nome_almox = %s) AND (cod_reduzido = %d));', [MySQLTable, NomeAlmox, Codigo]));

          // Execute the query to insert the data
          uniQuery.ExecSQL;

          // Move to the next record and process pending messages
          ADOQuery.Next;
          Application.ProcessMessages;
        end;
      finally
      end;
    finally
      ADOQuery.Free;
      ADOConnection.Free;
    end;
  finally
    uniQuery.Free;
    uniConnection.Free;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IniFile:          TIniFile;
  Encoder:          TIdEncoderMIME;
begin
  // create decoder
  Encoder := TIdEncoderMIME.Create(nil);

  // manage INI file
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));

  // read parameters
  IniFile.WriteString('MainProg', 'Server', Self.edServidor.Text);
  IniFile.WriteString('MainProg', 'User', edUsuario.Text);
  IniFile.WriteString('MainProg', 'Password', Encoder.EncodeString(edSenha.Text));

  // free stuff
  Encoder.Free;
  IniFile.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  IniFile:          TIniFile;
  Decoder:          TIdDecoderMIME;
begin
  // caption
  Caption := FORM_CAPTION;

  // restore old behaviour for messageDlg
  MsgDlgIcons[TMsgDlgType.mtInformation] := TMsgDlgIcon.mdiInformation;

  // create decoder
  Decoder := TIdDecoderMIME.Create(nil);

  // manage INI file
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));

  // read parameters
  Self.edServidor.Text := IniFile.ReadString('MainProg', 'Server', 'localhost');
  edUsuario.Text       := IniFile.ReadString('MainProg', 'User', '');
  edSenha.Text         := Decoder.DecodeString(IniFile.ReadString('MainProg', 'Password', ''));

  // free stuff
  Decoder.Free;
  IniFile.Free;
end;

procedure TfrmMain.EnableItems(Value: Boolean);
begin
  // enable Panels
  gbItensQtd.Enabled := Value;
  gbServidor.Enabled := Value;

end;

initialization
  // report leaks
  System.ReportMemoryLeaksOnShutdown := True;

end.

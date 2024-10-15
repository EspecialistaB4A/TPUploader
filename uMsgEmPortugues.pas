unit uMsgEmPortugues;

interface

implementation

uses
  Windows, Consts, DBConsts;

// Troca todas as strings especificadas, na inicializa��o do aplicativo
procedure TrocaStringsDoDelphi(ResStringRec: pResStringRec; NewStr: pChar) ;
var
  OldProtect: DWORD;
begin
  VirtualProtect(ResStringRec, SizeOf(ResStringRec^), PAGE_EXECUTE_READWRITE, @OldProtect) ;
  ResStringRec^.Identifier := Integer(NewStr) ;
  VirtualProtect(ResStringRec, SizeOf(ResStringRec^), OldProtect, @OldProtect) ;
end;

initialization
  // inicializa o aplicativo com as novas strings  (Vcl.Consts.pas)
  TrocaStringsDoDelphi(@SMsgDlgWarning, 'Aviso');
  TrocaStringsDoDelphi(@SMsgDlgError, 'Erro');
  TrocaStringsDoDelphi(@SMsgDlgInformation, 'Informa��o');
  TrocaStringsDoDelphi(@SMsgDlgConfirm, 'Confirma��o');
  TrocaStringsDoDelphi(@SMsgDlgYes, '&Sim');
  TrocaStringsDoDelphi(@SMsgDlgNo, '&N�o');
  TrocaStringsDoDelphi(@SMsgDlgOK, 'OK');
  TrocaStringsDoDelphi(@SMsgDlgCancel, 'Cancelar');
  TrocaStringsDoDelphi(@SMsgDlgHelp, '&Ajuda');
  TrocaStringsDoDelphi(@SMsgDlgHelpNone, 'Ajuda n�o localizada');
  TrocaStringsDoDelphi(@SMsgDlgHelpHelp, 'Ajuda');
  TrocaStringsDoDelphi(@SMsgDlgAbort, '&Abortar');
  TrocaStringsDoDelphi(@SMsgDlgRetry, '&Repetir');
  TrocaStringsDoDelphi(@SMsgDlgIgnore, '&Ignorar');
  TrocaStringsDoDelphi(@SMsgDlgAll, '&Todos(as)');
  TrocaStringsDoDelphi(@SMsgDlgNoToAll, 'N�o para todos(as)');
  TrocaStringsDoDelphi(@SMsgDlgYesToAll, 'Sim para todos(as)');

  // erros com mask edit
  TrocaStringsDoDelphi(@SMaskEditErr, 'Valor digitado inv�lido! Use a tecla ESC para descartar as mudan�as feitas.');
  TrocaStringsDoDelphi(@SMaskErr, 'Valor digitado inv�lido.');

  // erros com o banco de dados (Data.DBConsts.pas)
  TrocaStringsDoDelphi(@SInvalidIntegerValue, '''%s'' n�o � um valor inteiro v�lido para o campo ''%s''');
  TrocaStringsDoDelphi(@SInvalidBoolValue, '''%s'' n�o � um valor booleano v�lido para o campo ''%s''');
  TrocaStringsDoDelphi(@SInvalidFloatValue, '''%s'' n�o � um valor decimal v�lido para o campo ''%s''');
  TrocaStringsDoDelphi(@SFieldRequired, 'O campo ''%s'' deve possuir um valor');
  TrocaStringsDoDelphi(@SDataSetClosed, 'N�o � poss�vel realizar esta opera��o em um banco de dados fechado');
  TrocaStringsDoDelphi(@SDeleteRecordQuestion, 'Apagar registro selecionado?');
end.

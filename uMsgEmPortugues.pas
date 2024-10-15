unit uMsgEmPortugues;

interface

implementation

uses
  Windows, Consts, DBConsts;

// Troca todas as strings especificadas, na inicialização do aplicativo
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
  TrocaStringsDoDelphi(@SMsgDlgInformation, 'Informação');
  TrocaStringsDoDelphi(@SMsgDlgConfirm, 'Confirmação');
  TrocaStringsDoDelphi(@SMsgDlgYes, '&Sim');
  TrocaStringsDoDelphi(@SMsgDlgNo, '&Não');
  TrocaStringsDoDelphi(@SMsgDlgOK, 'OK');
  TrocaStringsDoDelphi(@SMsgDlgCancel, 'Cancelar');
  TrocaStringsDoDelphi(@SMsgDlgHelp, '&Ajuda');
  TrocaStringsDoDelphi(@SMsgDlgHelpNone, 'Ajuda não localizada');
  TrocaStringsDoDelphi(@SMsgDlgHelpHelp, 'Ajuda');
  TrocaStringsDoDelphi(@SMsgDlgAbort, '&Abortar');
  TrocaStringsDoDelphi(@SMsgDlgRetry, '&Repetir');
  TrocaStringsDoDelphi(@SMsgDlgIgnore, '&Ignorar');
  TrocaStringsDoDelphi(@SMsgDlgAll, '&Todos(as)');
  TrocaStringsDoDelphi(@SMsgDlgNoToAll, 'Não para todos(as)');
  TrocaStringsDoDelphi(@SMsgDlgYesToAll, 'Sim para todos(as)');

  // erros com mask edit
  TrocaStringsDoDelphi(@SMaskEditErr, 'Valor digitado inválido! Use a tecla ESC para descartar as mudanças feitas.');
  TrocaStringsDoDelphi(@SMaskErr, 'Valor digitado inválido.');

  // erros com o banco de dados (Data.DBConsts.pas)
  TrocaStringsDoDelphi(@SInvalidIntegerValue, '''%s'' não é um valor inteiro válido para o campo ''%s''');
  TrocaStringsDoDelphi(@SInvalidBoolValue, '''%s'' não é um valor booleano válido para o campo ''%s''');
  TrocaStringsDoDelphi(@SInvalidFloatValue, '''%s'' não é um valor decimal válido para o campo ''%s''');
  TrocaStringsDoDelphi(@SFieldRequired, 'O campo ''%s'' deve possuir um valor');
  TrocaStringsDoDelphi(@SDataSetClosed, 'Não é possível realizar esta operação em um banco de dados fechado');
  TrocaStringsDoDelphi(@SDeleteRecordQuestion, 'Apagar registro selecionado?');
end.

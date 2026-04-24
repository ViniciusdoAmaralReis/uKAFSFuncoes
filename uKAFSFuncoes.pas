unit uKAFSFuncoes;

interface

uses
  System.Classes, System.IniFiles, System.IOUtils, System.Math,        System.StrUtils,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient,
  System.NetEncoding, System.SysUtils, System.Threading, System.Types,
  IdIPWatch, IdStack
  {$IFNDEF CONSOLE}
  , FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Media, FMX.Platform, System.Skia
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  , Winapi.ShellAPI, Winapi.Windows
  {$ENDIF}
  {$IFDEF ANDROID}
  , Androidapi.Helpers, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os, Androidapi.JNIBridge
  {$ENDIF}
  ;

  function NomeProjeto: String;
  {$IFNDEF CONSOLE}
  function ResolucaoNativa: TPoint;
  function AnguloRotacao(const _centroorigem, _centroalvo: TPointF): Single;
  function Distancia(const _centroorigem, _centroalvo: TPointF): Single;
  procedure AbrirNavegador(const _url: String);
  procedure Vibrar(const _duracao: Int64);
  function RecursoParaBmp(const _recurso: String): FMX.Graphics.TBitmap;
  function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
  function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
  function BmpParaSkImage(const _bmp: FMX.Graphics.TBitmap): ISkImage;
  function RecursoParaAudio(_nome: String): TMediaPlayer;
  {$ENDIF}

  function TamanhoArquivo(_arquivo: String): Int64;
  function ContemNoArrayInteger(const _valor: Integer; const _array: array of Integer): Boolean;
  function DateTimeToUnixMS: Int64;
  function SegundosParaString(_valor: Int64): string;
  function VelocidadeParaDuracao(_velocidade: Single; const _inicio, _fim: TPointF): Single;
  function ProgressoBarra(_progresso: Single; const _total, _tamanhobarra: Single): Single;
  function TextoParaBase64(const _texto: String): String;
  function Base64ParaTexto(const _base64: String): String;
  procedure SalvarIni(const _codificar: Boolean; const _arquivo: String; _secao, _campo, _valor: String);
  function LerIni(const _codificar: Boolean; const _arquivo: String; _secao, _campo: String): String;
  function IPPrivado: String;
  function IPPublico: String;

implementation

function NomeProjeto: String;
begin
  Result := TPath.GetFileNameWithoutExtension(ParamStr(0));
end;

{$IFNDEF CONSOLE}
function ResolucaoNativa: TPoint;
begin
  var ScreenService: IFMXScreenService;

  // Tenta obter o serviço de tela
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
  begin
    Result := TPoint.Create(
      Round(ScreenService.GetScreenSize.X),
      Round(ScreenService.GetScreenSize.Y));
  end
  else
  begin
    // Fallback para Screen.Size
    Result := TPoint.Create(
      Round(Screen.Size.Width),
      Round(Screen.Size.Height));
  end;
end;

function AnguloRotacao(const _centroorigem, _centroalvo: TPointF): Single;
begin
  var AnguloRad := ArcTan2(_centroalvo.Y - _centroorigem.Y, _centroalvo.X - _centroorigem.X);

  Result := AnguloRad * (180 / Pi) + 90;
end;
function Distancia(const _centroorigem, _centroalvo: TPointF): Single;
begin
  Result := Sqrt(Sqr(_centroalvo.X - _centroorigem.X) + Sqr(_centroalvo.Y - _centroorigem.Y));
end;

procedure AbrirNavegador(const _url: String);
begin
  // Abre o navegador padrão do sistema
  {$IFDEF MSWINDOWS}
  ShellExecute(0, 'open', PChar(_url), nil, nil, SW_SHOWNORMAL);
  {$ENDIF}

  {$IFDEF LINUX}
  _system(PAnsiChar('xdg-open ' + AnsiString(_url)));
  {$ENDIF}

  {$IFDEF ANDROID}
  // Converte a string URL para Uri Java
  var Uri := StrToJURI(_url);

  // Cria um Intent para abrir a URL
  var Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW, Uri);

  // Abre o navegador
  TAndroidHelper.Activity.startActivity(Intent);
  {$ENDIF}

  {$IFDEF IOS}
  // Para iOS - usa SharedApplication
  var URL := TNSURL.Wrap(TNSURL.OCClass.URLWithString(StrToNSStr(_url)));
  if SharedApplication.canOpenURL(URL) then
    SharedApplication.openURL(URL);
  {$ENDIF}

  {$IFDEF MACOS}
  // Para macOS - usa openURL
  var Workspace := TNSWorkspace.Wrap(TNSWorkspace.OCClass.sharedWorkspace);
  var URL := TNSURL.Wrap(TNSURL.OCClass.URLWithString(StrToNSStr(_url)));
  Workspace.openURL(URL);
  {$ENDIF}
end;
procedure Vibrar(const _duracao: Int64);
begin
  {$IFDEF ANDROID}
  try
    // Verifica se o dispositivo suporta vibração
    var VibratorService := SharedActivityContext.getSystemService(TJContext.JavaClass.VIBRATOR_SERVICE);
    if VibratorService <> nil then
    begin
      var Vibrator := TJVibrator.Wrap((VibratorService as ILocalObject).GetObjectID);
      if (Vibrator <> nil) and
         (Vibrator.hasVibrator) then  // Verifica se tem permissão/vibrador
        Vibrator.vibrate(_duracao);
    end;
  except
    on E: Exception do
      // Log silencioso - vibração não é crítica
      ;
  end;
  {$ENDIF}

  {$IFDEF IOS}
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  {$ENDIF}
end;

function RecursoParaBmp(const _recurso: String): FMX.Graphics.TBitmap;
begin
  Result := nil;
  var Stream: TResourceStream := nil;
  try
    try
      // Tenta criar o stream do recurso
      Stream := TResourceStream.Create(HInstance, _recurso, RT_RCDATA);

      // Cria o bitmap depois que o stream foi criado com sucesso
      Result := FMX.Graphics.TBitmap.Create;
      Result.LoadFromStream(Stream);
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    FreeAndNil(Stream);
  end;
end;
function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
begin
  Result := nil;

  var _httpclient := THTTPClient.Create;
  var _stream := TMemoryStream.Create;
  try
    try
      // Baixa a imagem
      _httpclient.Get(_url, _stream);
      _stream.Position := 0;

      // Cria e carrega o bitmap a partir do stream
      Result := FMX.Graphics.TBitmap.Create;
      Result.LoadFromStream(_stream);
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    FreeAndNil(_stream);
    FreeAndNil(_httpclient);
  end;
end;
function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
begin
  Result := nil;

  var _inputstream := TStringStream.Create(_img);
  var _stream := TMemoryStream.Create;
  try
    try
      // Decodifica Base64 para stream binário
      TNetEncoding.Base64.Decode(_inputstream, _stream);
      _stream.Position := 0;

      // Cria e carrega o bitmap a partir do stream
      Result := FMX.Graphics.TBitmap.Create;
      Result.LoadFromStream(_stream);
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    FreeAndNil(_stream);
    FreeAndNil(_inputstream);
  end;
end;
function BmpParaSkImage(const _bmp: FMX.Graphics.TBitmap): ISkImage;
begin
  Result := nil;

  var _data: TBitmapData;
  if _bmp.Map(TMapAccess.Read, _data) then
  try
    var _info := TSkImageInfo.Create(_bmp.Width, _bmp.Height);
    Result := TSkImage.MakeRasterCopy(_info, _data.Data, _data.Pitch);
  finally
    _bmp.Unmap(_data);
  end;
end;
function RecursoParaAudio(_nome: String): TMediaPlayer;
begin
  var _diretorio := System.IOUtils.TPath.GetDocumentsPath + PathDelim + 'audio';
  if not TDirectory.Exists(_diretorio) then
    ForceDirectories(_diretorio);
  var _arquivo := System.IOUtils.TPath.Combine(_diretorio, _nome+'.mp3');

  if not TFile.Exists(_arquivo) then
  begin
    var ResStream := TResourceStream.Create(HInstance, PChar(_nome), RT_RCDATA);
    try
      ResStream.SaveToFile(_arquivo);
    finally
      ResStream.Free;
    end;
  end;

  var MediaPlayer := TMediaPlayer.Create(nil);
  MediaPlayer.FileName := _arquivo;
  Result := MediaPlayer;
end;
{$ENDIF}

function  TamanhoArquivo(_arquivo: String): Int64;
begin

  Result := TFile.GetSize(_arquivo);

end;
function ContemNoArrayInteger(const _valor: Integer; const _array: array of Integer): Boolean;
begin
  for var I := Low(_array) to High(_array) do
    if _array[I] = _valor then
      Exit(True);

  Result := False;
end;
function DateTimeToUnixMS: Int64;
begin
  Result := Round((Now - UnixDateDelta) * MSecsPerDay);
end;
function SegundosParaString(_valor: Int64): string;
begin

  if _valor < 0 then _valor := 0;

  var _dias     := _valor div 86400;
  _valor        := _valor mod 86400;
  var _horas    := _valor div 3600;
  _valor        := _valor mod 3600;
  var _minutos  := _valor div 60;
  var _segundos := _valor mod 60;

  // Formata a string no padrão: 99 D, 99:99:99
  if         _dias > 0 then Result := Format('%d d, %.2d:%.2d:%.2d', [_dias, _horas, _minutos, _segundos])
  else if   _horas > 0 then Result := Format('%.2d:%.2d:%.2d', [_horas, _minutos, _segundos])
  else if _minutos > 0 then Result := Format('%.2d:%.2d', [_minutos, _segundos])
  else                      Result := Format('%.2d', [_segundos]);

end;
function VelocidadeParaDuracao(_velocidade: Single; const _inicio, _fim: TPointF): Single;
begin
  if _velocidade <= 0 then
    _velocidade := 1;

  Result := _inicio.Distance(_fim) / _velocidade;
end;
function ProgressoBarra(_progresso: Single; const _total, _tamanhobarra: Single): Single;
begin
  // Casos especiais
  if (_total <= 0) or
     (_tamanhobarra <= 0) then
    Exit(0);

  // Limita valor entre 0 e Total
  if _progresso < 0 then
    _progresso := 0;
  if _progresso > _total then
    _progresso := _total;

  // Calcula progresso
  Result := (_progresso / _total) * _tamanhobarra;
end;
function TextoParaBase64(const _texto: String): String;
begin
  // Substitui caracteres especiais para arquivos INI
  Result := TNetEncoding.Base64.Encode(_texto)
    .Replace('+', '-')
    .Replace('/', '!')
    .Replace('=', '');
end;
function Base64ParaTexto(const _base64: String): String;
begin
  // Substitui caracteres especiais para arquivos INI
  var TextoBase64 := _base64
    .Replace('-', '+')
    .Replace('!', '/');

  // Restaura padding para múltiplo de 4
  var Padding := Length(TextoBase64) mod 4;
  if Padding > 0 then
    TextoBase64 := TextoBase64 + StringOfChar('=', 4 - Padding);

  Result := TNetEncoding.Base64.Decode(TextoBase64);
end;

procedure SalvarIni(const _codificar: Boolean; const _arquivo: String; _secao, _campo, _valor: String);
begin
  // Codifica as strings
  if _codificar then
  begin
    _secao := TextoParaBase64(_secao);
    _campo := TextoParaBase64(_campo);
    _valor := TextoParaBase64(_valor);
  end;

  // Determina o caminho e cria uma pasta caso não exista
  {$IF defined(MSWINDOWS) or defined(LINUX)}
  var _caminho := ExtractFilePath(ParamStr(0));
  {$ENDIF}
  {$IFDEF ANDROID}
  var _caminho := TPath.GetHomePath;
  {$ENDIF}
  if not TDirectory.Exists(_caminho) then
    ForceDirectories(_caminho);

  // Cria e salva o arquivo INI
  var _ini := TIniFile.Create(System.IOUtils.TPath.Combine(_caminho, _arquivo + '.ini'));
  try
    _ini.WriteString(_secao, _campo, _valor);
  finally
    FreeAndNil(_ini);
  end;
end;
function LerIni(const _codificar: Boolean; const _arquivo: String; _secao, _campo: String): String;
begin
  Result := '';

  // Decodifica as strings
  if _codificar then
  begin
    _secao := TextoParaBase64(_secao);
    _campo := TextoParaBase64(_campo);
  end;

  // Determina o caminho de documentos e sua pasta
  {$IF defined(MSWINDOWS) or defined(LINUX)}
  var _caminho := ExtractFilePath(ParamStr(0));
  {$ENDIF}
  {$IFDEF ANDROID}
  var _caminho := TPath.GetHomePath;
  {$ENDIF}

  // Cria e lê o arquivo INI
  var _ini := TIniFile.Create(System.IOUtils.TPath.Combine(_caminho, _arquivo + '.ini'));
  try
    var _valor := _ini.ReadString(_secao, _campo, '');

    // Decodifica caso não seja vazio
    if _valor <> '' then
      if _codificar then
        Result := Base64ParaTexto(_valor)
      else
        Result := _valor;
  finally
    FreeAndNil(_ini);
  end;
end;

function IPPrivado: String;
begin
  {$IFDEF MSWINDOWS}
  var _ipwatch := TIdIPWatch.Create(nil);
  try
    Result := _ipwatch.LocalIP;
  finally
    FreeAndNil(_ipwatch);
  end;
  {$ENDIF}

  {$IFDEF LINUX}
  Result := '';
  try
    var Stack := GStack;
    Result := Stack.LocalAddress;

    if (Result = '127.0.0.1') or (Result = '::1') then
      Result := '';
  except
    Result := '';
  end;
  {$ENDIF}
end;
function IPPublico: String;
begin
  Result := '';

  var _httpclient := TNetHTTPClient.Create(nil);
  try
    // O código para até receber a resposta
    _httpclient.Asynchronous := False;

    var Response := _httpclient.Get('http://api.ipify.org');
    if Response.StatusCode = 200 then
      Result := Response.ContentAsString;
  finally
    FreeAndNil(_httpclient);
  end;
end;

end.


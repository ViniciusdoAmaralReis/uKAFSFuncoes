unit uKAFSFuncoes;

interface

uses
  System.Classes, System.IniFiles, System.IOUtils, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.URLClient, System.NetEncoding,
  System.SysUtils, System.Types,
  IdIPWatch, IdStack
  {$IFDEF FMX}
  , FMX.Forms, FMX.Graphics, FMX.Platform
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
  {$IFDEF FMX}
  function ResolucaoNativa: TPoint;
  procedure AbrirNavegador(const _url: String);
  procedure Vibrar;
  function CacheParaBmp(const _nome: String): FMX.Graphics.TBitmap;
  function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
  function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
  {$ENDIF}
  function BarraProgresso(const _valor, _total, _barra: Single): Single;
  function Codificar(const _texto: String): String;
  function Decodificar(const _texto: String): String;
  procedure SalvarIni(const _arquivo: String; _secao, _campo, _valor: String);
  function LerIni(const _arquivo: String; _secao, _campo: String): String;
  function IPPrivado: String;
  function IPPublico: String;

implementation

function NomeProjeto: String;
begin
  Result := TPath.GetFileNameWithoutExtension(ParamStr(0));
end;

{$IFDEF FMX}
function ResolucaoNativa: TPoint;
begin
  var ScreenService: IFMXScreenService;

  // Tenta obter o servi�o de tela
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
  begin
    Result := TPoint.Create(
      Round(ScreenService.GetScreenSize.X),
      Round(ScreenService.GetScreenSize.Y)
    );
  end
  else
  begin
    // Fallback para Screen.Size
    Result := TPoint.Create(
      Round(Screen.Size.Width),
      Round(Screen.Size.Height)
    );
  end;
end;

procedure AbrirNavegador(const _url: String);
begin
  // Abre o navegador padr�o do sistema
  {$IFDEF MSWINDOWS}
  ShellExecute(0, 'open', PChar(_url), nil, nil, SW_SHOWNORMAL);
  {$ENDIF}

  {$IFDEF ANDROID}
  // Converte a string URL para Uri Java
  var Uri := StrToJURI(_url);

  // Cria um Intent para abrir a URL
  var Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW, Uri);

  // Abre o navegador
  TAndroidHelper.Activity.startActivity(Intent);
  {$ENDIF}
end;

procedure Vibrar;
begin
  {$IFDEF ANDROID}
  var _vibrar := TJVibrator.Wrap((SharedActivityContext.getSystemService(tjcontext.JavaClass.VIBRATOR_SERVICE) as ILocalObject).GetObjectID);
  _vibrar.vibrate(25);
  {$ENDIF}
end;

function CacheParaBmp(const _nome: String): FMX.Graphics.TBitmap;
begin
  // Carrega recurso embutido no sistema
  var _stream := TResourceStream.Create(HInstance, _nome, RT_RCDATA);
  try

    Result := FMX.Graphics.TBitmap.Create;
    Result.LoadFromStream(_stream);

  finally
    FreeAndNil(_stream);
  end;
end;
function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
begin
  Result := nil;

  var _httpclient := THTTPClient.Create;
  var _stream := TMemoryStream.Create;
  try

    // Baixa a imagem da URL
    _httpclient.Get(_url, _stream);
    _stream.Position := 0;

    // Cria e carrega o bitmap
    Result := FMX.Graphics.TBitmap.Create;
    Result.LoadFromStream(_stream);

  finally
    FreeAndNil(_stream);
    FreeAndNil(_httpclient);
  end;
end;
function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
begin
  Result := FMX.Graphics.TBitmap.Create;

  var _inputstream := TStringStream.Create(_img);
  var _outputstream := TMemoryStream.Create;
  try

    // Decodifica Base64 para stream bin�rio
    TNetEncoding.Base64.Decode(_inputstream, _outputstream);

    // Volta ao in�cio do stream para leitura
    _outputstream.Position := 0;

    // Carrega o bitmap a partir do stream
    Result.LoadFromStream(_outputstream);

  finally
    FreeAndNil(_inputstream);
    FreeAndNil(_outputstream);
  end;
end;
{$ENDIF}

function BarraProgresso(const _valor, _total, _barra: Single): Single;
begin
  // Calcula o valor do progresso
  if (_total <= 0) or
     (_valor <= 0) then
    Result := 0
  else
    Result := (_valor / _total) * _barra;
end;

function Codificar(const _texto: String): String;
begin
  var Base64 := TBase64Encoding.Create(0, ''); // 0 = Sem quebra de linha
  try

    // Substitui caracteres especiais para arquivos INI
    Result := Base64.Encode(_texto)
      .Replace('+', '-')
      .Replace('/', '!')
      .Replace('=', '$');

  finally
    FreeAndNil(Base64);
  end;
end;
function Decodificar(const _texto: String): String;
begin
  // Substitui caracteres especiais para arquivos INI
  Result := TNetEncoding.Base64.Decode(
    _texto.Replace('-', '+')
          .Replace('!', '/')
          .Replace('$', '='));
end;

procedure SalvarIni(const _arquivo: String; _secao, _campo, _valor: String);
begin
  // Codifica as strings
  _secao := Codificar(_secao);
  _campo := Codificar(_campo);
  _valor := Codificar(_valor);

  // Determina o caminho e cria uma pasta caso n�o exista
  var _caminho := ExtractFilePath(ParamStr(0));
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
function LerIni(const _arquivo: String; _secao, _campo: String): String;
begin
  Result := '';

  // Codifica as strings
  _secao := Codificar(_secao);
  _campo := Codificar(_campo);

  // Determina o caminho de documentos e sua pasta
  var _caminho := ExtractFilePath(ParamStr(0));

  // Cria e l� o arquivo INI
  var _ini := TIniFile.Create(System.IOUtils.TPath.Combine(_caminho, _arquivo + '.ini'));
  try

    var _valor := _ini.ReadString(_secao, _campo, '');

    // Decodifica caso n�o seja vazio
    if _valor <> '' then
      Result := Decodificar(_valor);

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

    // O c�digo para at� receber a resposta
    _httpclient.Asynchronous := False;

    var Response := _httpclient.Get('http://api.ipify.org');
    if Response.StatusCode = 200 then
      Result := Response.ContentAsString;

  finally
    FreeAndNil(_httpclient);
  end;
end;

end.

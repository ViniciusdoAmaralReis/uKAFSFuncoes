unit uKAFSFuncoes;

interface

uses
  System.Classes, System.IniFiles, System.IOUtils, System.Math,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient,
  System.NetEncoding, System.SysUtils, System.Types,
  IdIPWatch, IdStack
  {$IFNDEF CONSOLE}
  , FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Platform
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
  function ComponenteRectF(const _componente: TControl): TRectF;
  function PontoCentral(_componente: TControl): TPointF;
  function Colisao(_rect1, _rect2: TRectF): Boolean;
  function AnguloRotacao(const _componente: TControl; const _alvoX, _alvoY: Single): Single;
  function Distancia(const _componente1, _component2: TControl): Single;
  procedure AbrirNavegador(const _url: String);
  procedure Vibrar;
  function CacheParaBmp(const _nome: String): FMX.Graphics.TBitmap;
  function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
  function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
  {$ENDIF}
  function VelocidadeParaDuracao(const _velociade: Single; const _inicioX, _inicioY, _fimX, _fimY: Single): Single;
  function BarraProgresso(const _valor, _total, _barra: Single): Single;
  function TextoParaBase64(const _texto: String): String;
  function Base64ParaTexto(const _base64: String): String;
  procedure SalvarIni(const _arquivo: String; _secao, _campo, _valor: String);
  function LerIni(const _arquivo: String; _secao, _campo: String): String;
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
// Verificar, trocar TCOntrol por posições somente
function ComponenteRectF(const _componente: TControl): TRectF;
begin
  Result := RectF(_componente.Position.X,
                  _componente.Position.Y,
                  _componente.Position.X + _componente.Width,
                  _componente.Position.Y + _componente.Height);
end;
function PontoCentral(_componente: TControl): TPointF;
begin
  Result := TPointF.Create(_componente.Position.X + (_componente.Width / 2), _componente.Position.Y + (_componente.Height / 2));
end;
function Colisao(_rect1, _rect2: TRectF): Boolean;
begin
  Result := _rect1.IntersectsWith(_rect2);
  //Result := _componente1.BoundsRect.IntersectsWith(_componente2.BoundsRect);
end;
function AnguloRotacao(const _componente: TControl; const _alvoX, _alvoY: Single): Single;
begin
  var _centrocomponente := PontoCentral(_componente);
  var _angulo := ArcTan2(_alvoY - _centrocomponente.Y, _alvoX - _centrocomponente.X);

  _angulo := _angulo * (180 / Pi) + 90; // +90 para frente apontar para destino

  Result := _angulo;
end;
function Distancia(const _componente1, _component2: TControl): Single;
begin
  var CentroA := PontoCentral(_componente1);
  var CentroB := PontoCentral(_component2);

  var DeltaX := CentroB.X - CentroA.X;
  var DeltaY := CentroB.Y - CentroA.Y;

  Result := Sqrt(DeltaX * DeltaX + DeltaY * DeltaY);
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
    // Decodifica Base64 para stream binário
    TNetEncoding.Base64.Decode(_inputstream, _outputstream);

    // Volta ao início do stream para leitura
    _outputstream.Position := 0;

    // Carrega o bitmap a partir do stream
    Result.LoadFromStream(_outputstream);
  finally
    FreeAndNil(_inputstream);
    FreeAndNil(_outputstream);
  end;
end;
{$ENDIF}

function VelocidadeParaDuracao(const _velociade: Single; const _inicioX, _inicioY, _fimX, _fimY: Single): Single;
begin
  var _distanciaX := Abs(_fimX - _inicioX);
  var _distanciaY := Abs(_fimY - _inicioY);

  Result := Sqrt(Sqr(_distanciaX) + Sqr(_distanciaY)) / _velociade;
end;
function BarraProgresso(const _valor, _total, _barra: Single): Single;
begin
  // Calcula o valor do progresso
  if (_total <= 0) or
     (_valor <= 0) then
    Result := 0
  else
    Result := (_valor / _total) * _barra;
end;

function TextoParaBase64(const _texto: String): String;
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
function Base64ParaTexto(const _base64: String): String;
begin
  // Substitui caracteres especiais para arquivos INI
  Result := TNetEncoding.Base64.Decode(
    _base64.Replace('-', '+')
           .Replace('!', '/')
           .Replace('$', '='));
end;

procedure SalvarIni(const _arquivo: String; _secao, _campo, _valor: String);
begin
  // Codifica as strings
  _secao := TextoParaBase64(_secao);
  _campo := TextoParaBase64(_campo);
  _valor := TextoParaBase64(_valor);

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
function LerIni(const _arquivo: String; _secao, _campo: String): String;
begin
  Result := '';

  // Codifica as strings
  _secao := Base64ParaTexto(_secao);
  _campo := Base64ParaTexto(_campo);

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
      Result := Base64ParaTexto(_valor);
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

<div align="center">
<img width="188" height="200" alt="image" src="https://github.com/user-attachments/assets/60d8a531-d1b0-4282-a91c-0d24467ffd8b" /></div><p>

# <div align="center"><strong>uKAFSFuncoes</strong></div> 

<div align="center">
Biblioteca Delphi/FireMonkey de funções utilitárias com suporte multiplataforma para Windows, Linux e Android.
<br></p>

[![Delphi](https://img.shields.io/badge/Delphi-10.3+-B22222?logo=delphi)](https://www.embarcadero.com/products/delphi)
[![Multiplatform](https://img.shields.io/badge/Multiplatform-Windows/Linux/macOS/Android/IOS-8250DF)]([https://www.embarcadero.com/products/delphi/cross-platform](https://docwiki.embarcadero.com/RADStudio/Athens/en/Developing_Multi-Device_Applications))
[![License](https://img.shields.io/badge/License-GPLv3-blue)](LICENSE)
</div><br>

## ⚡ Funcionalidades
```pascal
function NomeProjeto: String;
function ResolucaoNativa: TPoint;
function AnguloRotacao(const _centroorigem, _centroalvo: TPointF): Single;
function Distancia(const _centroorigem, _centroalvo: TPointF): Single;
procedure AbrirNavegador(const _url: String);
procedure Vibrar(const _duracao: Int64);
function RecursoParaBmp(const _recurso: String): FMX.Graphics.TBitmap;
function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
function VelocidadeParaDuracao(_velocidade: Single; const _inicio, _fim: TPointF): Single;
function ProgressoBarra(_progresso: Single; const _total, _tamanhobarra: Single): Single;
function TextoParaBase64(const _texto: String): String;
function Base64ParaTexto(const _base64: String): String;
procedure SalvarIni(const _arquivo: String; _secao, _campo, _valor: String);
function LerIni(const _arquivo: String; _secao, _campo: String): String;
function IPPrivado: String;
function IPPublico: String;
```
<div></div><br><br>


---
**Nota**: Esta unit é parte do ecossistema KAFS e fornece funcionalidades utilitárias essenciais para aplicações Delphi multiplataforma. Cada função tem sua própria lista de compatibilidade com os SOs.

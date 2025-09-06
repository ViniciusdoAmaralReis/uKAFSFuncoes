# 🧩 uKAFSFuncoes

Biblioteca Delphi/FireMonkey de funções utilitárias com suporte multiplataforma para Windows, Linux e Android.

## 💡 Funcionalidades
```pascal
  function NomeProjeto: String;
  function ResolucaoNativa: TPoint;
  procedure AbrirNavegador(const _url: String);
  procedure Vibrar;
  function CacheParaBmp(const _nome: String): FMX.Graphics.TBitmap;
  function URLParaBmp(const _url: String): FMX.Graphics.TBitmap;
  function Base64ParaBmp(const _img: String): FMX.Graphics.TBitmap;
  function BarraProgresso(const _valor, _total, _barra: Single): Single;
  function Codificar(const _texto: String): String;
  function Decodificar(const _texto: String): String;
  procedure SalvarIni(const _arquivo: String; _secao, _campo, _valor: String);
  function LerIni(const _arquivo: String; _secao, _campo: String): String;
  function IPPrivado: String;
  function IPPublico: String;
```

## 🏛️ Status de compatibilidade

| Funções         | Terminal | FMX | Windows |  Linux  | Android |
|-----------------|----------|-----|---------|---------|---------|
| NomeProjeto     | ✅       | ✅  | ✅     | ✅      | ✅      |
| ResolucaoNativa | ❌       | ✅  | ✅     | ✅      | ✅      |
| AbrirNavegador  | ❌       | ✅  | ✅     | ❌      | ✅      |
| Vibrar          | ❌       | ✅  | ❌     | ❌      | ✅      |
| CacheParaBmp    | ❌       | ✅  | ✅     | ✅      | ✅      |
| URLParaBmp      | ❌       | ✅  | ✅     | ✅      | ✅      |
| Base64ParaBmp   | ❌       | ✅  | ✅     | ✅      | ✅      |
| BarraProgresso  | ✅       | ✅  | ✅     | ✅      | ✅      |
| Codificar       | ✅       | ✅  | ✅     | ✅      | ✅      |
| Decodificar     | ✅       | ✅  | ✅     | ✅      | ✅      |
| SalvarIni       | ✅       | ✅  | ✅     | ✅      | ✅      |
| LerIni          | ✅       | ✅  | ✅     | ✅      | ✅      |
| IPPrivado       | ✅       | ✅  | ✅     | ✅      | ❌      |
| IPPublico       | ✅       | ✅  | ✅     | ✅      | ✅      |

| IDE             | Versão mínima       | Observações                           |
|-----------------|---------------------|---------------------------------------|
| **Delphi**      | ✅ **10.4**         | Suporte a multiplataforma FireMonkey  |

---

**Nota**: Esta unit é parte do ecossistema KAFS e fornece funcionalidades utilitárias essenciais para aplicações Delphi multiplataforma.

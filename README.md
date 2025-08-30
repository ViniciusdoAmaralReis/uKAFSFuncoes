# 🧩 uKAFSFuncoes

Biblioteca Delphi/FireMonkey de funções utilitárias com suporte multiplataforma para Windows e Android.

## 💡 Funcionalidades
```pascal
function NomeProjeto: String; 
function ResolucaoNativa: TPoint; 
procedure AbrirNavegador(const _url: String); 
procedure Vibrar; // Android apenas
function BarraProgresso(const _valor, _total, _barra: Single): Single; 
function Codificar(const _texto: String): String; 
function Decodificar(const _texto: String): String; 
procedure SalvarIni(const _arquivo, _secao, _campo, _valor: String);
function LerIni(const _arquivo, _secao, _campo: String): String;
function IPlocal: String; // Windows apenas
function IPInternet: String; 
function CacheParaBmp(const _nome: String): TBitmap; 
function URLParaBmp(const _url: String): TBitmap; 
function Base64ParaBmp(const _img: String): TBitmap; 
```

## 🏛️ Status de compatibilidade

| Sistema operacional | Status               | Observações                           |
|-----------------|----------------------|---------------------------------------|
| **Windows**     | ✅ **Parcial**       | ❌ Vibrar                            |
| **Android**     | ✅ **Parcial**       | ❌ IPlocal                           |
| **Linux/macOS** | ❌ **Não testado**   | Limitações nas funções específicas   |

| IDE             | Versão mínima       | Observações                           |
|-----------------|---------------------|---------------------------------------|
| **Delphi**      | ✅ **10.4**         | Suporte a multiplataforma FireMonkey  |

---

**Nota**: Esta unit é parte do ecossistema KAFS e fornece funcionalidades utilitárias essenciais para aplicações Delphi multiplataforma. Algumas funções possuem implementações específicas por plataforma (Windows/Android).

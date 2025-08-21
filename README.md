# 🛠️ UntKAFSFuncoes

Unit Delphi/FireMonkey com funções utilitárias multiplataforma para Windows e Android.

## 📋 Descrição

Unit contendo diversas funções utilitárias para desenvolvimento em Delphi/FireMonkey, com suporte para Windows e Android, incluindo manipulação de arquivos, rede, imagens e recursos do sistema.

## ✨ Características

- ✅ Funções multiplataforma (Windows e Android)
- ✅ Manipulação de arquivos INI com codificação
- ✅ Operações de rede (IP local e internet)
- ✅ Manipulação de imagens (cache, URL, Base64)
- ✅ Controle de vibração (Android)
- ✅ Abertura de navegador padrão
- ✅ Codificação/decodificação Base64 segura

## 🧩 Funções Disponíveis

### 🔧 Utilitários do Sistema
| Função | Descrição |
|--------|-----------|
| `NomeProjeto` | Retorna o nome do executável sem extensão |
| `ResolucaoNativa` | Retorna a resolução nativa da tela |
| `Vibrar` | Ativa vibração do dispositivo (Android) |

### 🌐 Funções de Rede
| Função | Descrição |
|--------|-----------|
| `AbrirNavegador` | Abre URL no navegador padrão |
| `IPlocal` | Retorna o IP local da máquina |
| `IPInternet` | Retorna o IP público da internet |

### 💾 Manipulação de Arquivos
| Função | Descrição |
|--------|-----------|
| `SalvarIni` | Salva valor codificado em arquivo INI |
| `LerIni` | Lê valor decodificado de arquivo INI |
| `Codificar` | Codifica texto em Base64 seguro |
| `Decodificar` | Decodifica texto de Base64 seguro |

### 🖼️ Manipulação de Imagens
| Função | Descrição |
|--------|-----------|
| `CacheParaBmp` | Carrega bitmap de recursos embutidos |
| `URLParaBmp` | Baixa e carrega bitmap de URL |
| `Base64ParaBmp` | Converte string Base64 para bitmap |

### 📊 Utilitários
| Função | Descrição |
|--------|-----------|
| `BarraProgresso` | Calcula progresso para barras de carregamento |

## 🛠️ Como Usar

### Exemplo Básico
```pascal
uses UntKAFSFuncoes;

// Salvar configuração
SalvarIni('config', 'conexao', 'servidor', '192.168.1.100');

// Ler configuração
var Servidor := LerIni('config', 'conexao', 'servidor');

// Abrir navegador
AbrirNavegador('https://www.google.com');

// Obter IP público
var MeuIP := IPInternet;
```

### Manipulação de Imagens
```pascal
// Carregar imagem de recurso
var Bmp1 := CacheParaBmp('IMAGEM_EMBUTIDA');

// Baixar imagem da web
var Bmp2 := URLParaBmp('https://exemplo.com/imagem.jpg');

// Converter Base64 para bitmap
var Bmp3 := Base64ParaBmp('data:image/png;base64,...');
```

## 📁 Estrutura de Arquivos

Os arquivos INI são salvos em:
```
Documents/NomeDoProjeto/arquivo.ini
```

### Formato dos Dados
Os valores são codificados em Base64 modificado:
- `+` → `-`
- `/` → `!`
- `=` → `$`

## 🌍 Suporte Multiplataforma

### Windows
- ✅ ShellExecute para abrir navegador
- ✅ TIdIPWatch para IP local
- ✅ Recursos nativos do Windows

### Android
- ✅ Intent para abrir navegador
- ✅ Vibrator service para vibração
- ✅ Contexto de atividade Android

## ⚙️ Dependências

- `System.Classes`
- `System.IniFiles`
- `System.IOUtils`
- `System.Net.HttpClient`
- `System.Net.URLClient`
- `System.NetEncoding`
- `System.SysUtils`
- `System.Types`
- `FMX.Forms`
- `FMX.Graphics`
- `IdIPWatch`

---

**Nota:** Esta unit requer a componente Indy para `TIdIPWatch` nas plataformas Windows.

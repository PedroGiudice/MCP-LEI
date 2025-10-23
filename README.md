# MCP-LEI - Servidor de Busca de Citações Legais

Servidor MCP (Model Context Protocol) para busca e normalização de citações de leis brasileiras em arquivos de texto locais.

## 📋 Descrição

Este servidor MCP permite que o Claude Desktop acesse e busque citações de leis em seus arquivos de texto locais, facilitando a pesquisa e análise de documentos jurídicos.

### Funcionalidades

- **listar_arquivos_lei**: Lista todos os arquivos .txt disponíveis no diretório de leis
- **search_citacao_lei**: Busca citações por padrão/estrutura em todos os arquivos
- **extrair_citacoes**: Busca citações em um arquivo específico

### Leis Suportadas

- CF/88 (Constituição Federal)
- CPC (Código de Processo Civil)
- CC (Código Civil)
- CPP (Código de Processo Penal)
- CP (Código Penal)
- CLT (Consolidação das Leis do Trabalho)
- CDC (Código de Defesa do Consumidor)
- ECA (Estatuto da Criança e do Adolescente)
- Leis específicas (ex: Lei 8.112/90)

## 🚀 Instalação

### Pré-requisitos

- **Node.js** (versão 14 ou superior) - [Download](https://nodejs.org/)
- **Claude Desktop** instalado
- Arquivos .txt de leis no diretório `C:\Users\pedro\CÓDIGOS`

### Instalação Automática (Recomendado)

1. Clone ou baixe este repositório
2. Abra o PowerShell como Administrador
3. Navegue até o diretório do repositório:
   ```powershell
   cd caminho\para\MCP-LEI
   ```
4. Execute o script de instalação:
   ```powershell
   .\install.ps1
   ```
5. Siga as instruções na tela

O script irá:
- Verificar se o Node.js está instalado
- Criar o diretório de instalação em `C:\Users\pedro\mcp-lei`
- Verificar/criar o diretório de leis em `C:\Users\pedro\CÓDIGOS`
- Copiar os arquivos necessários
- Instalar as dependências do Node.js

### Instalação Manual

Se preferir instalar manualmente:

1. Copie os arquivos para `C:\Users\pedro\mcp-lei`:
   ```powershell
   New-Item -ItemType Directory -Path "C:\Users\pedro\mcp-lei" -Force
   Copy-Item -Path .\* -Destination "C:\Users\pedro\mcp-lei\" -Recurse
   ```

2. Instale as dependências:
   ```powershell
   cd C:\Users\pedro\mcp-lei
   npm install
   ```

3. Verifique se o diretório de leis existe:
   ```powershell
   New-Item -ItemType Directory -Path "C:\Users\pedro\CÓDIGOS" -Force
   ```

## ⚙️ Configuração do Claude Desktop

Após a instalação, configure o servidor no Claude Desktop:

1. Localize o arquivo de configuração:
   - Windows: `%APPDATA%\Claude\claude_desktop_config.json`
   - Ou acesse: `C:\Users\pedro\AppData\Roaming\Claude\claude_desktop_config.json`

2. Adicione a configuração do servidor MCP-LEI:

```json
{
  "mcpServers": {
    "mcp-lei": {
      "command": "node",
      "args": ["C:\\Users\\pedro\\mcp-lei\\index.js"]
    }
  }
}
```

3. Reinicie o Claude Desktop

## 📁 Estrutura de Arquivos

Certifique-se de que seus arquivos de leis estão organizados assim:

```
C:\Users\pedro\CÓDIGOS\
├── CF-88.txt
├── CPC.txt
├── CC.txt
├── CPP.txt
├── CP.txt
├── CLT.txt
├── CDC.txt
└── ... (outros arquivos .txt)
```

## 🔍 Como Usar

Após configurar, você pode usar os seguintes comandos no Claude Desktop:

### Listar Arquivos Disponíveis
```
Liste os arquivos de leis disponíveis
```

### Buscar Citações Específicas
```
Busque citações do artigo 37 da CF/88
```

### Buscar com Parâmetros Avançados
```
Busque citações de artigos 186 e 927 do CC
```

### Extrair Citações de um Arquivo Específico
```
Extraia todas as citações do arquivo CPC.txt
```

## 🧪 Testar o Servidor

Para testar se o servidor está funcionando corretamente:

```powershell
cd C:\Users\pedro\mcp-lei
npm start
```

O servidor deve iniciar sem erros. Pressione `Ctrl+C` para parar.

## 📝 Notas Importantes

- Os arquivos de leis devem estar em formato `.txt` e codificados em UTF-8
- O servidor busca citações usando expressões regulares otimizadas
- Citações são normalizadas automaticamente (lei, artigo, parágrafo, inciso)
- Máximo padrão de 500 resultados por busca (configurável)

## 🔧 Solução de Problemas

### Erro: "Node.js não encontrado"
- Instale o Node.js de [nodejs.org](https://nodejs.org/)
- Reinicie o PowerShell após a instalação

### Erro: "Diretório de leis não encontrado"
- Verifique se o diretório `C:\Users\pedro\CÓDIGOS` existe
- Coloque seus arquivos .txt neste diretório

### Servidor não aparece no Claude Desktop
- Verifique se o `claude_desktop_config.json` está correto
- Reinicie o Claude Desktop
- Verifique os logs do Claude Desktop para erros

### Problemas com acentos nos arquivos
- Certifique-se de que seus arquivos .txt estão salvos em UTF-8
- Use um editor como VS Code ou Notepad++ para converter

## 📄 Licença

MIT License - Pedro Giudice Rodrigues

## 🤝 Contribuições

Sugestões e melhorias são bem-vindas!

## 📞 Suporte

Para problemas ou dúvidas, abra uma issue no repositório do GitHub.

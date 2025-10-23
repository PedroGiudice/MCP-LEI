# Script de Instalação do MCP-LEI
# Servidor MCP para busca de citações de lei
# Autor: Pedro Giudice Rodrigues

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Instalador do Servidor MCP-LEI" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Diretórios de instalação
$INSTALL_DIR = "C:\Users\pedro\mcp-lei"
$LEIS_DIR = "C:\Users\pedro\CÓDIGOS"

# Passo 1: Verificar se Node.js está instalado
Write-Host "[1/6] Verificando instalação do Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Node.js encontrado: $nodeVersion" -ForegroundColor Green
    } else {
        throw "Node.js não encontrado"
    }
} catch {
    Write-Host "  ✗ Node.js não está instalado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, instale o Node.js antes de continuar:" -ForegroundColor Yellow
    Write-Host "  https://nodejs.org/" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Passo 2: Verificar se npm está disponível
Write-Host "[2/6] Verificando instalação do npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ npm encontrado: $npmVersion" -ForegroundColor Green
    } else {
        throw "npm não encontrado"
    }
} catch {
    Write-Host "  ✗ npm não está instalado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "npm geralmente vem com o Node.js. Reinstale o Node.js." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Passo 3: Criar diretório de instalação
Write-Host "[3/6] Criando diretório de instalação..." -ForegroundColor Yellow
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Write-Host "  ✓ Diretório criado: $INSTALL_DIR" -ForegroundColor Green
} else {
    Write-Host "  ✓ Diretório já existe: $INSTALL_DIR" -ForegroundColor Green
}

# Passo 4: Verificar diretório de leis
Write-Host "[4/6] Verificando diretório de leis..." -ForegroundColor Yellow
if (-not (Test-Path $LEIS_DIR)) {
    Write-Host "  ⚠ Diretório de leis não encontrado: $LEIS_DIR" -ForegroundColor Yellow
    Write-Host "  Criando diretório..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $LEIS_DIR -Force | Out-Null
    Write-Host "  ✓ Diretório criado: $LEIS_DIR" -ForegroundColor Green
    Write-Host ""
    Write-Host "  IMPORTANTE: Coloque seus arquivos .txt de leis neste diretório!" -ForegroundColor Cyan
    Write-Host ""
} else {
    $txtFiles = Get-ChildItem -Path $LEIS_DIR -Filter "*.txt" -ErrorAction SilentlyContinue
    $count = ($txtFiles | Measure-Object).Count
    Write-Host "  ✓ Diretório encontrado: $LEIS_DIR" -ForegroundColor Green
    Write-Host "  ✓ Arquivos .txt encontrados: $count" -ForegroundColor Green
}

# Passo 5: Copiar arquivos do servidor
Write-Host "[5/6] Copiando arquivos do servidor..." -ForegroundColor Yellow
$currentDir = $PSScriptRoot
$filesToCopy = @("index.js", "package.json", "manifest.json", "README.md")

foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $currentDir $file
    $destPath = Join-Path $INSTALL_DIR $file

    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ Copiado: $file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Arquivo não encontrado: $file" -ForegroundColor Yellow
    }
}

# Passo 6: Instalar dependências
Write-Host "[6/6] Instalando dependências do Node.js..." -ForegroundColor Yellow
Push-Location $INSTALL_DIR
try {
    Write-Host ""
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "  ✓ Dependências instaladas com sucesso!" -ForegroundColor Green
    } else {
        throw "Erro ao instalar dependências"
    }
} catch {
    Write-Host ""
    Write-Host "  ✗ Erro ao instalar dependências!" -ForegroundColor Red
    Pop-Location
    Read-Host "Pressione Enter para sair"
    exit 1
} finally {
    Pop-Location
}

# Finalização
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✓ Instalação concluída com sucesso!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Certifique-se de que seus arquivos .txt de leis estão em:" -ForegroundColor White
Write-Host "   $LEIS_DIR" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Configure o servidor no Claude Desktop:" -ForegroundColor White
Write-Host "   - Abra o arquivo de configuração do Claude Desktop" -ForegroundColor Gray
Write-Host "   - No Windows: %APPDATA%\Claude\claude_desktop_config.json" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Adicione a seguinte configuração:" -ForegroundColor White
Write-Host ""
Write-Host '   {' -ForegroundColor Gray
Write-Host '     "mcpServers": {' -ForegroundColor Gray
Write-Host '       "mcp-lei": {' -ForegroundColor Gray
Write-Host '         "command": "node",' -ForegroundColor Gray
Write-Host "         `"args`": [`"$INSTALL_DIR\index.js`"]" -ForegroundColor Gray
Write-Host '       }' -ForegroundColor Gray
Write-Host '     }' -ForegroundColor Gray
Write-Host '   }' -ForegroundColor Gray
Write-Host ""
Write-Host "4. Reinicie o Claude Desktop para aplicar as alterações" -ForegroundColor White
Write-Host ""
Write-Host "Para testar o servidor manualmente:" -ForegroundColor Cyan
Write-Host "   cd $INSTALL_DIR" -ForegroundColor Yellow
Write-Host "   npm start" -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione Enter para sair"

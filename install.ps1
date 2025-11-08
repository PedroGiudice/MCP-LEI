# Script de Instalacao do MCP-LEI
# Servidor MCP para busca de citacoes de lei
# Autor: Pedro Giudice Rodrigues

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Instalador do Servidor MCP-LEI" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Diretorios de instalacao
$INSTALL_DIR = "C:\Users\pedro\mcp-lei"
$LEIS_DIR = "C:\Users\pedro\CODIGOS"

# Passo 1: Verificar se Node.js esta instalado
Write-Host "[1/6] Verificando instalacao do Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK Node.js encontrado: $nodeVersion" -ForegroundColor Green
    } else {
        throw "Node.js nao encontrado"
    }
} catch {
    Write-Host "  ERRO Node.js nao esta instalado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, instale o Node.js antes de continuar:" -ForegroundColor Yellow
    Write-Host "  https://nodejs.org/" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Passo 2: Verificar se npm esta disponivel
Write-Host "[2/6] Verificando instalacao do npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK npm encontrado: $npmVersion" -ForegroundColor Green
    } else {
        throw "npm nao encontrado"
    }
} catch {
    Write-Host "  ERRO npm nao esta instalado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "npm geralmente vem com o Node.js. Reinstale o Node.js." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Passo 3: Criar diretorio de instalacao
Write-Host "[3/6] Criando diretorio de instalacao..." -ForegroundColor Yellow
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Write-Host "  OK Diretorio criado: $INSTALL_DIR" -ForegroundColor Green
} else {
    Write-Host "  OK Diretorio ja existe: $INSTALL_DIR" -ForegroundColor Green
}

# Passo 4: Verificar diretorio de leis
Write-Host "[4/6] Verificando diretorio de leis..." -ForegroundColor Yellow
if (-not (Test-Path $LEIS_DIR)) {
    Write-Host "  AVISO Diretorio de leis nao encontrado: $LEIS_DIR" -ForegroundColor Yellow
    Write-Host "  Criando diretorio..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $LEIS_DIR -Force | Out-Null
    Write-Host "  OK Diretorio criado: $LEIS_DIR" -ForegroundColor Green
    Write-Host ""
    Write-Host "  IMPORTANTE: Coloque seus arquivos .txt de leis neste diretorio!" -ForegroundColor Cyan
    Write-Host ""
} else {
    $txtFiles = Get-ChildItem -Path $LEIS_DIR -Filter "*.txt" -ErrorAction SilentlyContinue
    $count = ($txtFiles | Measure-Object).Count
    Write-Host "  OK Diretorio encontrado: $LEIS_DIR" -ForegroundColor Green
    Write-Host "  OK Arquivos .txt encontrados: $count" -ForegroundColor Green
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
        Write-Host "  OK Copiado: $file" -ForegroundColor Green
    } else {
        Write-Host "  AVISO Arquivo nao encontrado: $file" -ForegroundColor Yellow
    }
}

# Passo 6: Instalar dependencias
Write-Host "[6/6] Instalando dependencias do Node.js..." -ForegroundColor Yellow
Push-Location $INSTALL_DIR
try {
    Write-Host ""
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "  OK Dependencias instaladas com sucesso!" -ForegroundColor Green
    } else {
        throw "Erro ao instalar dependencias"
    }
} catch {
    Write-Host ""
    Write-Host "  ERRO ao instalar dependencias!" -ForegroundColor Red
    Pop-Location
    Read-Host "Pressione Enter para sair"
    exit 1
} finally {
    Pop-Location
}

# Finalizacao
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  OK Instalacao concluida com sucesso!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Certifique-se de que seus arquivos .txt de leis estao em:" -ForegroundColor White
Write-Host "   $LEIS_DIR" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Configure o servidor no Claude Desktop:" -ForegroundColor White
Write-Host "   - Abra o arquivo de configuracao do Claude Desktop" -ForegroundColor Gray
Write-Host "   - No Windows: %APPDATA%\Claude\claude_desktop_config.json" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Adicione a seguinte configuracao:" -ForegroundColor White
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
Write-Host "4. Reinicie o Claude Desktop para aplicar as alteracoes" -ForegroundColor White
Write-Host ""
Write-Host "Para testar o servidor manualmente:" -ForegroundColor Cyan
Write-Host "   cd $INSTALL_DIR" -ForegroundColor Yellow
Write-Host "   npm start" -ForegroundColor Yellow
Write-Host ""
Read-Host "Pressione Enter para sair"

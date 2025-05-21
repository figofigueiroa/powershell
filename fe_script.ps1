# Função fe aprimorada para abrir arquivos com o editor padrão
function Invoke-FuzzyEdit {
    param([string]$Query = "")
    
    # Verificar se bat está instalado
    $hasBat = $null -ne (Get-Command bat -ErrorAction SilentlyContinue)
    
    # Preparar o comando de preview baseado na disponibilidade do bat
    $previewCmd = if ($hasBat) {
        "if (Test-Path -PathType Leaf '{}') { bat --color=always --style=numbers --line-range=:500 '{}' } else { Write-Output 'Diretório: {}'; Get-ChildItem '{}' | Format-Table -AutoSize }"
    } else {
        "if (Test-Path -PathType Leaf '{}') { Get-Content -Path '{}' -TotalCount 100 } else { Write-Output 'Diretório: {}'; Get-ChildItem '{}' | Format-Table -AutoSize }"
    }
    
    # Configurar argumentos do fzf
    $fzfArgs = @{
        Multi = $true
        Query = $Query
        Select1 = $true
        Exit0 = $true
        Height = "70%"  # Define altura como 70% da tela
        Preview = $previewCmd
        PreviewWindow = "right:60%"  # Ajusta a janela de preview para 60% à direita
    }
    
    # Invocar fzf com os argumentos configurados
    $files = Get-ChildItem -Recurse -File | 
             Select-Object -ExpandProperty FullName |
             Invoke-Fzf @fzfArgs
    
    if ($files) {
        # Determinar o editor a ser usado
        $editor = if ($env:EDITOR) { $env:EDITOR } else { "notepad" }
        
        # Processar cada arquivo selecionado
        foreach ($file in $files) {
            # Verificar se é um path válido
            if (Test-Path -Path $file -PathType Leaf) {
                Write-Host "Abrindo: $file" -ForegroundColor Cyan
                
                # Abrir o arquivo no editor
                try {
                    & $editor $file
                }
                catch {
                    Write-Error "Erro ao abrir o arquivo com $editor`: $_"
                    # Fallback para notepad se o editor padrão falhar
                    if ($editor -ne "notepad") {
                        Write-Host "Tentando abrir com notepad..." -ForegroundColor Yellow
                        notepad $file
                    }
                }
            }
            else {
                Write-Warning "Arquivo não encontrado: $file"
            }
        }
    }
    else {
        Write-Host "Nenhum arquivo selecionado." -ForegroundColor Yellow
    }
}

# Criar um alias para a função fe
Set-Alias -Name fe -Value Invoke-FuzzyEdit -Option AllScope -Force
# Opcional: configurar a variável de ambiente EDITOR se não estiver definida
if (-not $env:EDITOR) {
    $env:EDITOR = "notepad"
}

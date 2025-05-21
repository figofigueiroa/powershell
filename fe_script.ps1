# Função fe para abrir arquivos com o editor padrão
function Invoke-FuzzyEdit {
    param([string]$Query = "")
    
    $files = Invoke-Fzf -Multi -Query $Query -Select1 -Exit0 -Preview "
        if (Test-Path -PathType Leaf '{}') {
            if (Get-Command bat -ErrorAction SilentlyContinue) {
                bat --color=always '{}'
            } else {
                Get-Content '{}'
            }
        } else {
            Write-Output 'Diretório: {}'
            Get-ChildItem '{}' | Format-Table -AutoSize
        }
    "
    
    if ($files) {
        $editor = $env:EDITOR
        if (-not $editor) {
            $editor = "notepad"
        }
        
        # Abrir arquivos no editor
        foreach ($file in $files) {
            & $editor $file
        }
    }
}

# Criar um alias para a função fe
Set-Alias -Name fe -Value Invoke-FuzzyEdit -Option AllScope -Force

# Opcional: configurar a variável de ambiente EDITOR se não estiver definida
if (-not $env:EDITOR) {
    $env:EDITOR = "notepad"
}

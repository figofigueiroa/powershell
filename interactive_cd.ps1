# Importar o módulo PSFzf
Import-Module PSFzf

# Função cd interativa
function Invoke-InteractiveCD {
    param([string]$Path)
    
    if ($Path) {
        Set-Location $Path
        return
    }
    
    while ($true) {
        # Obter diretórios incluindo ".."
        $directories = @("..")
        $directories += Get-ChildItem -Directory | Select-Object -ExpandProperty Name
        
        # Usar fzf para seleção interativa
        $selectedDir = $directories | 
            Invoke-Fzf -Reverse -Preview "
                `$previewPath = Join-Path -Path (Get-Location) -ChildPath '{}'
                if ('{}' -eq '..') {
                    `$previewPath = Split-Path -Parent -Path (Get-Location)
                }
                Write-Output `$previewPath
                Write-Output ''
                Get-ChildItem -Path `$previewPath -Force | Format-Table -AutoSize
            "
        
        if (-not $selectedDir) {
            return
        }
        
        Set-Location $selectedDir -ErrorAction SilentlyContinue
    }
}
# Sobrescrever o comando cd
Set-Alias -Name cd -Value Invoke-InteractiveCD -Option AllScope -Force

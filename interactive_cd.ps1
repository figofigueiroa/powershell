function Invoke-InteractiveCD {
    param([string]$Path)
    
    if ($Path) {
        Set-Location $Path
        return
    }
    
    # Define a altura como 50% da tela
    $height = "50%"
    
    # Use uma única chamada ao fzf e processe a saída
    $selectedDir = $null
    while ($true) {
        # Obter diretórios incluindo ".."
        $directories = @("..")
        $directories += Get-ChildItem -Directory | Select-Object -ExpandProperty Name
        
        # Chama fzf com a opção de altura e sem sair após a seleção
        $selectedDir = $directories | 
            Invoke-Fzf -Reverse -Height $height -Preview "
                `$previewPath = Join-Path -Path (Get-Location) -ChildPath '{}'
                if ('{}' -eq '..') {
                    `$previewPath = Split-Path -Parent -Path (Get-Location)
                }
                Write-Output `$previewPath
                Write-Output ''
                Get-ChildItem -Path `$previewPath -Force | Format-Table -AutoSize
            "
        
        # Se não houver seleção, saia da função
        if (-not $selectedDir) {
            return
        }
        
        # Muda para o diretório selecionado silenciosamente
        $previousLocation = Get-Location
        Set-Location $selectedDir -ErrorAction SilentlyContinue
        
        # Verifica se o diretório mudou realmente (para evitar erros)
        $currentLocation = Get-Location
        if ($currentLocation.Path -eq $previousLocation.Path) {
            # Se não conseguiu mudar o diretório, saia do loop
            Write-Host "Não foi possível mudar para o diretório: $selectedDir" -ForegroundColor Red
            return
        }
    }
}

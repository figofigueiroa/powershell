# Importar o módulo PSFzf
Import-Module PSFzf

function Set-LocationInteractive {
    param([Parameter(ValueFromRemainingArguments=$true)]$Path)
    
    # If arguments are provided, use the standard cd behavior
    if ($Path) {
        Set-Location $Path
        return
    }
    
    # Interactive directory navigation using FZF
    while ($true) {
        # Get parent directory and all subdirectories
        $parentDir = ".."
        $subDirs = Get-ChildItem -Directory | Select-Object -ExpandProperty Name
        $allDirs = @($parentDir) + $subDirs
        
        # Create a preview script
        $previewCmd = [System.IO.Path]::GetTempFileName() + ".ps1"
        @"
param(`$dir)
`$currentPath = (Get-Location).Path
if (`$dir -eq "..") {
    `$fullPath = (Get-Item `$currentPath).Parent.FullName
} else {
    `$fullPath = Join-Path `$currentPath `$dir
}
Write-Output `$fullPath
Write-Output ""
Get-ChildItem -Path `$fullPath | Format-Table Name, LastWriteTime -AutoSize
"@ | Set-Content -Path $previewCmd
        
        # Use FZF to let the user select a directory
        $selectedDir = $allDirs | Out-String | fzf --reverse --preview "powershell -NoProfile -File $previewCmd {}"
        
        # Clean up
        Remove-Item -Path $previewCmd -Force
        
        $selectedDir = $selectedDir.Trim()
        
        # Exit if no directory was selected
        if ([string]::IsNullOrEmpty($selectedDir)) {
            return
        }
        
        # Change to the selected directory
        Set-Location $selectedDir
    }
}

# To use this function by typing 'cd', add this line:
Set-Alias -Name cd -Value Set-LocationInteractive -Force -Option AllScope

function cd {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Path
    )
    if ($Path.Count -gt 0) {
        Set-Location @Path
        return
    }
    while ($true) {
        $dirs = @("..") + (Get-ChildItem -Directory | Select-Object -ExpandProperty Name)
        $dir = $dirs | fzf --reverse --preview {
            param($selection)
            $fullPath = Join-Path (Get-Location) $selection
            Write-Host $fullPath
            Write-Host
            Get-ChildItem -Path $fullPath | Format-Wide -Column 1
        }
        if (-not $dir) { return }
        Set-Location $dir
    }
}

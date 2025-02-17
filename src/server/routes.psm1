class Route {
    [string]$Path
    [boolean]$Wildcard
    [string]$ContentType
    [ScriptBlock]$Get
    
    Route([string]$path, [string]$contentType, [ScriptBlock]$get) {
        $this.Get = $get
        $this.ContentType = $contentType
        $this.Path = $path
        $this.Wildcard = $false
        
        if ($path.EndsWith("/*")) {
            $this.Path = $path.Replace("/*", "")
            $this.Wildcard = $true
        }
    }
}

function Get-RootFactory {
    return [Route]::new("/", "text/html", {
        return Get-Content -Path ..\www\index.html
    })
}

function Get-InfoFactory {
    return [Route]::new("/info", "text/html", {
        return "<h2>This info was just served by my PowerShell Server</h2>"
    })
}

function Get-StaticFactory {
    return [Route]::new("/static/*", "text/plain", {
        param([string]$file)
        
        if ($file.Contains("..") -or $file.Contains("%2E%2E")) {
            return $null
        }
        
        return Get-Content -Path ("..\www\$file")
    })
}

Export-ModuleMember -Type Class -Value Route
Export-ModuleMember -Function Get-RootFactory
Export-ModuleMember -Function Get-InfoFactory
Export-ModuleMember -Function Get-StaticFactory
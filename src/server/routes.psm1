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

function Get-BlogFactory {
    return [Route]::new("/blog", "text/html", {
        return Get-Content -Path ..\www\blog.html
    })
}

function Get-PostsFactory {
    return [Route]::new("/posts", "text/html", {
        $posts = (ConvertFrom-Json -InputObject (
            Get-Content -Path "../blog/blog.json" -Raw
        )).posts
        
        [string]$rendered = ""
        
        foreach ($post in $posts) {
            $rendered += "<div><h3><a href=`"/post/$($post.path)`">$($post.title)</a></h3><p>$($post.description)</p><div class=`"dashedline`">&nbsp;</div></div>"
        }
        
        return $rendered
    })
}

function Get-PostFactory {
    return [Route]::new("/post/*", "text/html", {
        param([string]$post)

        if ($post.Contains("..") -or $post.Contains("%2E%2E"))
        {
            return $null
        }
        
        return (Get-Content -Path ..\www\post.html) -f (Get-Content -Path ("..\blog\static\$post"))
    })
}

Export-ModuleMember -Type Class -Value Route
Export-ModuleMember -Function Get-RootFactory
Export-ModuleMember -Function Get-InfoFactory
Export-ModuleMember -Function Get-StaticFactory
Export-ModuleMember -Function Get-PostsFactory
Export-ModuleMember -Function Get-BlogFactory
Export-ModuleMember -Function Get-PostFactory
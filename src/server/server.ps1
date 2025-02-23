using module .\routes.psm1
[System.Net.HttpListener]$Http = New-Object System.Net.HttpListener

function Get-ResourceNotFoundFactory {
    return [Route]::new("/404", "text/html", {
        return "<center>404 Resource Not Found</center>"
    })
}

$RouteFactories = @((Get-ResourceNotFoundFactory),
    (Get-RootFactory),
    (Get-InfoFactory),
    (Get-StaticFactory),
    (Get-PostsFactory),
    (Get-BlogFactory) ,
    (Get-PostFactory)
)
[hashtable]$Routes = @{}

foreach ($route in $RouteFactories) {
    $Routes[$route.Path] = $route
}

function Initialize-HttpServer {
    param([int]$Port)
    $Http.Prefixes.Add("http://+:${Port}/")
}

function Get-HttpServerJob {
    return {
        param([System.Net.HttpListener]$Http, [hashtable]$Routes)
        
        while ($Http.IsListening) {
            [System.Net.HttpListenerContext]$Context = $Http.GetContext()
            Write-Output "$($Context.Request.HttpMethod) $($Context.Request.UserHostAddress) => $($Context.Request.Url)" -ForegroundColor "mag"
            
            if ($Context.Request.HttpMethod -eq "GET") {
                [string]$url = $Context.Request.Url.AbsolutePath
                [string]$argument = $null
                $Context.Response.StatusCode = 200
                
                if (-not $Routes.ContainsKey($url)) {
                    # Check wildcards
                    [int]$end = $url.IndexOf("/", 1)
                    
                    if ($end -eq -1) {
                        $Context.Response.StatusCode = 404
                        $url = "/404"
                    }
                    
                    [string]$start = $url.Substring(0, $end)

                    if ($Routes.ContainsKey($start)) {
                        $argument = $url.Substring($end + 1)
                        $url = $start
                    }
                }
                
                [string]$res = $Routes[$url].Get.Invoke($argument)
                
                if (res -eq $null) {
                    $res = $Routes["/404"].Get.Invoke()
                    $Context.Response.StatusCode = 404
                }
                
                [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($res)
                
                $Context.Response.ContentType = $res.ContentType
                $Context.Response.ContentLength64 = $buffer.Length
                
                $Context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                $Context.Response.OutputStream.Flush()
                $Context.Response.OutputStream.Close()
                $Context.Response.Close()
            }
            
            else {
                # TODO: Return the 404 html page
                $Context.Response.StatusCode = 404
                $Context.Response.Close()
            }
        }
    }
}

function Start-HttpServer {
    $Http.Start()
    Write-Host "Listening on $($Http.Prefixes)"
    Write-Host "Press 'q' to quit"

    return Start-ThreadJob -Name "ServerHost" -ScriptBlock (Get-HttpServerJob) -ArgumentList $Http, $Routes
}

function Start-HttpServerMonitor {
    param([System.Management.Automation.Job]$ServerJob)

    while ($true) {
        [string]$UserInput = Read-Host
        
        if ($UserInput -ieq "q") {
            $Http.Stop()
            Stop-Job $ServerJob
            Remove-Job $ServerJob
            Remove-Module -Name routes
            break
        }
        
        Start-Sleep -Milliseconds 100
    }
}

Initialize-HttpServer -Port 7738
$ServerJob = Start-HttpServer
Get-Job -id $ServerJob.Id
Start-HttpServerMonitor -ServerJob $ServerJob
# My Website
An experiment of building a website with the revolutionary and
blazing-fast PowerHTMX tech stack (Powershell + HTMX).

## How does it work
in `src` there are two directories, `server` and `www`. All the
Powershell code goes into `server` and all the public-facing files
go in the `www` folder. From the public, you can access files in
the `www` by going to the `static/(file)` endpoint. However, commonly
used endpoints should be defined. For example, `www/index.html` is
mapped to `/`.


`server.ps1` is the workhorse of the server, this is the entrypoint
script that handles all HTTP requests. `routes.psm1` is the where
the `Route` class is defined and where all route factories are also
defined.


## How to run it
Ensure you have the `ThreadJob` module installed as `server.ps1`
relies on `ThreadJob` to host the listener. On my machine it came
installed with PowerShell.

Then set your directory to `src\server` and run `.\server.ps1`.
This will likely fail the first time, this is because I actually
don't know how to use modules. Just run it twice. And like magic
you now have the server running. It listens on all interfaces, so
just head to `http://localhost:7738`.

## Plans for this project
I do actually want to rewrite my website using this tech stack.
Why? I don't know. But besides this I do actually plan to create
this into a real PowerShell module with a nice API and interface.

PowerShell actually isn't a horrible language for this, once you
are writing the actual route handlers. Do I expect this to be used
anywhere? No. But maybe some sysadmin somewhere wants to write
a quick HTTP server with a few endpoints and now they can do it
within the terminal they are already using.

## Why?
As stated previously, I don't know. But also, I love PowerShell and
abusing it's .NET capabilites. I also wanted to try out HTMX and
felt bored going with Python, Go, or JavaScript as the server. Perfect
excuse to mess around in PowerShell.

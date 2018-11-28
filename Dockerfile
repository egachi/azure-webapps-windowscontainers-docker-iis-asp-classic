# escape=`
FROM microsoft/iis
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; $VerbosePreference = 'Continue'; "]

RUN Install-WindowsFeature Web-ASP; `
    Install-WindowsFeature Web-CGI; `
    Install-WindowsFeature Web-ISAPI-Ext; `
    Install-WindowsFeature Web-ISAPI-Filter; `
    Install-WindowsFeature Web-Includes; `
    Install-WindowsFeature Web-HTTP-Errors; `
    Install-WindowsFeature Web-Common-HTTP; `
    Install-WindowsFeature Web-Performance; `
    Install-WindowsFeature WAS; `
    Import-Module IISAdministration;

RUN & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/asp; `
    & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/handlers; `
    & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/modules; `
    & c:\windows\system32\inetsrv\appcmd.exe set config -section:system.webServer/httpErrors -errorMode:Detailed; `
    & c:\windows\system32\inetsrv\appcmd.exe set config -section:asp -scriptErrorSentToBrowser:true

RUN Remove-Item 'C:\inetpub\wwwroot\*' -Recurse -Force
RUN Import-module WebAdministration; `
    Get-IISConfigSection -SectionPath system.webServer/defaultDocument | Get-IISConfigCollection -CollectionName files | New-IISConfigCollectionElement -ConfigAttribute @{'Value' = 'index.asp'};

WORKDIR C:\inetpub\wwwroot\

COPY app/ .
EXPOSE 80



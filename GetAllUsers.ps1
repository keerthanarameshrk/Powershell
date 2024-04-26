#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Set Variables for Site URL
$SiteURL= "https://slftest.sharepoint.com/sites/LNDB2/Utopia"
 
#Setup Credentials to connect
$Cred = Get-Credential
$Cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
 
$FilePath="E:\Process.txt"
Try {

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = $Cred
 
    #Get all Groups
    $Groups=$Ctx.Web.SiteGroups
    $Ctx.Load($Groups)
    $Ctx.ExecuteQuery()
 
    #Get Each member from the Group
    Foreach($Group in $Groups)
    {
        Write-Host "--- $($Group.Title) --- "
 
        #Getting the members
        $SiteUsers=$Group.Users
        $Ctx.Load($SiteUsers)
        $Ctx.ExecuteQuery()
        Foreach($User in $SiteUsers)
        {
            
            "$($User.Title), $($User.Id), $($User.LoginName)" | Out-File -FilePath $FilePath -Append

            Write-Host "$($User.Title), $($User.Email), $($User.LoginName)"
        }
        #Get-Process | Out-File -FilePath .\Process.txt
    }
}
Catch {
    write-host -f Red "Error getting groups and users!" $_.Exception.Message
}


#Read more: https://www.sharepointdiary.com/2016/10/get-all-users-and-groups-in-sharepoint-online-powershell-csom.html#ixzz7Q92Jwp69
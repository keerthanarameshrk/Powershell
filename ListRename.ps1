#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
    
#Config Parameters
$SiteURL= "https://slftest.sharepoint.com/sites/LNDB2/Utopia"
$ListName="ArchiveHistoricalEmails"
$NewListURL="ArchiveHistoricalEmails"
 
#Setup Credentials to connect
$Cred = Get-Credential
$Cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
   
Try {
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = $Cred
     
    #Get the List
    $List=$Ctx.web.Lists.GetByTitle($ListName)
    $Ctx.Load($List)
  
    #sharepoint online change library url powershell  
    $List.Rootfolder.MoveTo($NewListURL)
    $Ctx.ExecuteQuery()
 
    #Keep the List name as is
    $List.Title=$ListName
    $List.Update()
    $Ctx.ExecuteQuery()
  
    Write-host -f Green "List URL has been changed!"
}
Catch {
    write-host -f Red "Error changing List URL!" $_.Exception.Message
}


#Read more: https://www.sharepointdiary.com/2017/09/sharepoint-online-change-list-document-library-url-using-powershell.html#ixzz7P5ckafBU
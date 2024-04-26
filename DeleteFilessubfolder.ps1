#download https://www.nuget.org/packages/Microsoft.SharePointOnline.CSOM/16.1.7723.1200 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.dll") 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll") 

#download https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/2.29.0 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.identitymodel.clients.activedirectory.2.29.0\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll") 

#download https://www.nuget.org/packages/SharePointPnPCoreOnline/2.26.1805.1 

[System.Reflection.Assembly]::LoadFile("D:\New folder\sharepointpnpcoreonline.2.26.1805.1\lib\net45\OfficeDevPnP.Core.dll") 

Function Remove-SPOFile()
{
  param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [string] $FileRelativeURL
    )
    Try {
        #Get Credentials to connect
        $authmgr = New-Object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $authmgr.GetWebLoginClientContext($SiteURL)
        #Get the file to delete
        $File = $Ctx.Web.GetFileByServerRelativeUrl($FileRelativeURL)
        $Ctx.Load($File)
        $Ctx.ExecuteQuery()
                 
        #Delete the file
        $File.Recycle()
        $Ctx.ExecuteQuery()
        write-host -f Green "File has been deleted successfully!"
     }
    Catch {
        write-host -f Red "Error deleting file !" $_.Exception.Message
    }
}
  
#Set parameter values
$SiteURL="https://5ydm6t.sharepoint.com/sites/TestSite"
$FileRelativeURL="/sites/TestSite/Shared Documents/newfolder/index.aspx"
#Call the function
Remove-SPOFile -SiteURL $SiteURL -FileRelativeURL $FileRelativeURL

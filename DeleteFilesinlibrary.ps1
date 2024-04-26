#download https://www.nuget.org/packages/Microsoft.SharePointOnline.CSOM/16.1.7723.1200 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.dll") 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll") 

#download https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/2.29.0 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.identitymodel.clients.activedirectory.2.29.0\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll") 

#download https://www.nuget.org/packages/SharePointPnPCoreOnline/2.26.1805.1 

[System.Reflection.Assembly]::LoadFile("D:\New folder\sharepointpnpcoreonline.2.26.1805.1\lib\net45\OfficeDevPnP.Core.dll") 
# Parameters
$SiteURL = "https://5ydm6t.sharepoint.com/sites/TestSite"
$LibraryName = "Documents"
$NewFolderName = "newfolder"

# Setup the Context
$authmgr = New-Object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $authmgr.GetWebLoginClientContext($SiteURL)

try {
    # Get the document library
    $Library = $Ctx.Web.Lists.GetByTitle($LibraryName)
    $Ctx.Load($Library)
    $Ctx.ExecuteQuery()
    
    Write-Host "Library title: $($Library.Title)"

    # Construct the Server Relative URL for the new folder
    $WebServerRelativeUrl = $Ctx.Web.ServerRelativeUrl
    $LibraryServerRelativeUrl = $Library.RootFolder.ServerRelativeUrl
    $NewFolderUrl = "$WebServerRelativeUrl$LibraryServerRelativeUrl/$NewFolderName"
    Write-Host "Constructed Server Relative URL: $NewFolderUrl"

    $NewFolder = $Ctx.Web.GetFolderByServerRelativeUrl($NewFolderUrl)
    $Ctx.Load($NewFolder)
    $Ctx.ExecuteQuery()

    if ($NewFolder -ne $null) {
        # Get all files within "newfolder"
        $Files = $NewFolder.Files
        $Ctx.Load($Files)
        $Ctx.ExecuteQuery()

        # Check if there are files to delete
        if ($Files.Count -gt 0) {
            # Iterate through each file and delete it
            foreach ($File in $Files) {
                $Ctx.Load($File)  # Load the file object
                $Ctx.ExecuteQuery()

                Write-Host "Deleting file: $($File.Name)"
                $File.Recycle()
            }
            # Execute deletion queries
            $Ctx.ExecuteQuery()
            Write-Host "All files in 'newfolder' deleted successfully."
        }
        else {
            Write-Host "No files found in 'newfolder'."
        }
    }
    else {
        Write-Host "The folder 'newfolder' does not exist."
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
}

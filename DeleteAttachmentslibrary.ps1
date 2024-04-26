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
$RefIdColumnName = "RefId"
$CsvFilePath = "C:\Users\keerthana_r\Downloads\ForminvRefId.csv"

# Setup the Context
$authmgr = New-Object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $authmgr.GetWebLoginClientContext($SiteURL)

# Get the document library
$Library = $Ctx.Web.Lists.GetByTitle($LibraryName)
$Ctx.Load($Library)
$Ctx.ExecuteQuery()

# Load CSV file
$CsvFile = Import-Csv $CsvFilePath -Encoding UTF8

# Get the "newfolder" directory
$NewFolderUrl = $Library.RootFolder.ServerRelativeUrl + "/" + $NewFolderName
try {
    $NewFolder = $Ctx.Web.GetFolderByServerRelativeUrl($NewFolderUrl)
    $Ctx.Load($NewFolder)
    $Ctx.ExecuteQuery()

    # Get all folders within "newfolder"
    $Folders = $NewFolder.Folders
    $Ctx.Load($Folders)
    $Ctx.ExecuteQuery()

    # Iterate through each folder
    foreach ($Folder in $Folders) {
        $Ctx.Load($Folder)  # Load the folder object
        $Ctx.ExecuteQuery()

        $RefId = $Folder.Name
        # Check if the folder name matches any RefId from the CSV file
        $shouldDelete = $CsvFile | Where-Object { $_.$RefIdColumnName -eq $RefId }

        if ($shouldDelete) {
            Write-Host "Deleting folder with RefId: $RefId"
            $Folder.DeleteObject()
        }
    }
    # Execute deletion queries
    $Ctx.ExecuteQuery()
}
catch {
    Write-Host "Error: $_.Exception.Message"
}

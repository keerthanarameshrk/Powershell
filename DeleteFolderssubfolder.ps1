#download https://www.nuget.org/packages/Microsoft.SharePointOnline.CSOM/16.1.7723.1200 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.dll") 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll") 

#download https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/2.29.0 

[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.identitymodel.clients.activedirectory.2.29.0\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll") 

#download https://www.nuget.org/packages/SharePointPnPCoreOnline/2.26.1805.1 

[System.Reflection.Assembly]::LoadFile("D:\New folder\sharepointpnpcoreonline.2.26.1805.1\lib\net45\OfficeDevPnP.Core.dll") 

# Function to remove a folder from SharePoint Online document library
Function Remove-SPOFolder {
    param(
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [string] $FolderRelativeURL,
         [Parameter(Mandatory=$true)] [string] $RefIdColumnName,
        [Parameter(Mandatory=$true)] [string] $CsvFilePath
    )
    Try {
        # Get Credentials to connect
        $authmgr = New-Object OfficeDevPnP.Core.AuthenticationManager
        $Ctx = $authmgr.GetWebLoginClientContext($SiteURL)

        # Get the folder to delete
        $RelFolder = $Ctx.Web.GetFolderByServerRelativeUrl($FolderRelativeURL)
        $Ctx.Load($RelFolder)
        $Ctx.ExecuteQuery()
        
        Write-Host "s1"

        $Folders = $RelFolder.Folders
        $Ctx.Load($Folders)  # Load the folder object
        $Ctx.ExecuteQuery()
        

        foreach ($Fold in $Folders) {
        $Ctx.Load($Fold)  # Load the folder object
        $Ctx.ExecuteQuery()

        Write-Host "s2"

        $RefId = $Fold.Name
        Write-Host "Folder name: $RefId"

         $shouldDelete = $CsvFile | Where-Object { $_.$RefIdColumnName -eq $FSI_Ref_ID }
          
        if ($shouldDelete) {
            Write-Host "Deleting folder with RefId: $RefId"
       
        # Delete the folder
        $Fold.Recycle()
        $Ctx.ExecuteQuery()
         Write-Host -ForegroundColor Green "Folder has been deleted successfully!"
        }
        }
       
    }
    Catch {
        Write-Host -ForegroundColor Red "Error deleting folder: $($_.Exception)"
    }
}

# Set parameter values
$SiteURL = "https://5ydm6t.sharepoint.com/sites/TestSite"
$FolderRelativeURL = "/sites/TestSite/Shared Documents/newfolder"
$RefIdColumnName = "RefId"
$CsvFilePath = "C:\Users\keerthana_r\Downloads\ForminvRefId.csv"
$CsvFile = Import-Csv $CsvFilePath -Encoding UTF8

# Call the function to remove the folder
Remove-SPOFolder -SiteURL $SiteURL -FolderRelativeURL $FolderRelativeURL -RefIdColumnName $RefIdColumnName -CsvFilePath $CsvFilePath
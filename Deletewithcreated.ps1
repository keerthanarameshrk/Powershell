# Load assemblies
[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.dll")
[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll")
[System.Reflection.Assembly]::LoadFile("D:\New folder\microsoft.identitymodel.clients.activedirectory.2.29.0\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
[System.Reflection.Assembly]::LoadFile("D:\New folder\sharepointpnpcoreonline.2.26.1805.1\lib\net45\OfficeDevPnP.Core.dll")

# Parameters
$SiteURL = "https://maargasystems007.sharepoint.com/sites/SunlifeFormServiceInventory"
$ListName = "FSI_Form_Inventory"
$BatchSize = 1000
$DeletionCount = 0

# Setup the Context
$authmgr = New-Object OfficeDevPnp.Core.AuthenticationManager
$Ctx = $authmgr.GetWebLoginClientContext($SiteURL)

# Load CSV File
$CsvFile = Import-Csv "C:\Users\keerthana_r\Downloads\Dups.csv" -Encoding UTF8

# Get the List
$List = $Ctx.Web.Lists.GetByTitle($ListName)
$Ctx.Load($List)
$Ctx.ExecuteQuery()

# Define the target date
$TargetDate = Get-Date "19/04/2024"

# SharePoint Online PowerShell CAML batch delete
$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
$Query.ViewXml = @"
    <View Scope='RecursiveAll'>  
        <Query>  
             <OrderBy><FieldRef Name='ID' Ascending='TRUE'/></OrderBy> 
        </Query> 
        <RowLimit>$BatchSize</RowLimit> 
    </View>
"@

# Get List Items in Batches
Do {
    # Get List Items
    $ListItems = $List.GetItems($Query)
    $Ctx.Load($ListItems)
    $Ctx.ExecuteQuery()

    # Update Position of the ListItemCollectionPosition
    $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition

    If ($ListItems.Count -eq 0) { Break }

    for ($i = $ListItems.Count - 1; $i -ge 0; $i--) {
        $Item = $ListItems[$i]
        # Check if the item should be deleted based on CSV data and creation date
        $shouldDelete = $CsvFile | Where-Object { $_.UNID -eq $Item["DocumentUNID"] -and $Item["Created"] -lt "2024-04-19" }

        if ($shouldDelete) {
            Write-Host "Deleting item with Ref Id:" $Item["DocumentUNID"]
            $Item.Recycle()
            $Ctx.ExecuteQuery()
            $DeletionCount++
        }
    }
} While ($Query.ListItemCollectionPosition -ne $null)

# Display total documents deleted
Write-Host "Total documents deleted: $DeletionCount"

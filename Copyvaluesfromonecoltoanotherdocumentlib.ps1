Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$siteUrl = "https://maargasystems007.sharepoint.com/sites/MahleGPR_Dev"
$username = "keerthana_r@maargasystems.com"
$password = "Ramcsk@2128"

$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, (ConvertTo-SecureString $password -AsPlainText -Force))
$ctx.Credentials = $credentials

$libraryTitle = "PRFormAttachments"
$sourceColumnName = "Name"
$destinationColumnName = "RefId"

$library = $ctx.Web.Lists.GetByTitle($libraryTitle)
$fields = $library.Fields
$ctx.Load($fields)
$ctx.ExecuteQuery()

$sourceColumn = $fields.GetByInternalNameOrTitle($sourceColumnName)
$destinationColumn = $fields.GetByInternalNameOrTitle($destinationColumnName)
$ctx.Load($sourceColumn)
$ctx.Load($destinationColumn)
$ctx.ExecuteQuery()
Write-Host "Copied"

$items = $library.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$ctx.Load($items)
$ctx.ExecuteQuery()

foreach ($item in $items) {
    $item[$destinationColumn.InternalName] = $item[$sourceColumn.InternalName]
    $item.Update()
    Write-Host $items
}

$ctx.ExecuteQuery()



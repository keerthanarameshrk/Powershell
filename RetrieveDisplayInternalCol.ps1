Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$siteUrl = "https://maargasystems007.sharepoint.com/sites/MahleGPR_Dev"
$username = "keerthana_r@maargasystems.com"
$password = "Ramcsk@2128"
$listTitle = "PRForm"
$outputPath = "D:\output.csv"

$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, (ConvertTo-SecureString $password -AsPlainText -Force))
$ctx.Credentials = $credentials

$web = $ctx.Web
$ctx.Load($web)
$ctx.ExecuteQuery()

$list = $web.Lists.GetByTitle($listTitle)
$fields = $list.Fields
$ctx.Load($fields)
$ctx.ExecuteQuery()

$fieldInfo = @()

foreach ($field in $fields) {
    $fieldInfo += New-Object PSObject -Property @{
        "InternalName" = $field.InternalName
        "DisplayName" = $field.Title
    }
}

$fieldInfo | Export-Csv -Path $outputPath -NoTypeInformation

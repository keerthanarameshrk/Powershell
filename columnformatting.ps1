#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
#Set Variables
$SiteURL = "https://maargasystems007.sharepoint.com/sites/site_1"  
$ListName="Documented"
$FieldName="ItemId" #Internal Name
$JsonFormat = @"
{
   "`$schema": "https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json",
   "elmType": "a",
   "txtContent": "Open",
   "attributes": {
      "target": "_self",
      "href": "='/sites/LNDB2/MFSU/SitePages/Index.aspx#/software/form/Document/' + @currentField",
"class":"ms-Nav-link"
   }
}
"@
 
#Get Credentials to connect
$Cred= Get-Credential
  
#Setup the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
  
#Get the List
$List= $Ctx.Web.Lists.GetByTitle($ListName)
  
#Get the Field
$Field=$List.Fields.GetByInternalNameOrTitle($FieldName)
$Ctx.Load($Field)
$Ctx.ExecuteQuery()
 
#Apply Column Formatting to the field
$Field.CustomFormatter= $JsonFormat
$Field.Update()
$Ctx.ExecuteQuery()
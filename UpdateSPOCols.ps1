#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Variables for Processing
$SiteUrl = "https://maargasystems007.sharepoint.com/sites/site_1"
$ListName="MahleTest (1) - Copy"
 
$UserName="keerthana_r@maargasystems.com"
$Password ="Ramcsk@2128"
  
#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Context.Credentials = $credentials
 
try{
   
    #Filter and Get the List Items using CAML
    $List = $Context.web.Lists.GetByTitle($ListName)
 
    #Get List Item by ID
    $ListItem = $List.GetItemById(1) 
 
    #Update List Item title
    $ListItem["Gender"] = "" 
    $ListItem.Update() 
 
    $Context.ExecuteQuery()
    write-host "Item Updated!"  -foregroundcolor Green 
}
catch{ 
    write-host "$($_.Exception.Message)" -foregroundcolor red 
} 


#Read more: https://www.sharepointdiary.com/2015/07/sharepoint-online-update-list-items-using-powershell.html#ixzz7QLAbBC7W
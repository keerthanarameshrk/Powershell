#download https://www.nuget.org/packages/Microsoft.SharePointOnline.CSOM/16.1.7723.1200
[System.Reflection.Assembly]::LoadFile("C:\Users\manivannan_b\Documents\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.dll")
[System.Reflection.Assembly]::LoadFile("C:\Users\manivannan_b\Documents\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll")
#[System.Reflection.Assembly]::LoadFile("C:\Users\manivannan_b\Documents\New folder\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Taxonomy.dll")
#download https://www.nuget.org/packages/Microsoft.IdentityModel.Clients.ActiveDirectory/2.29.0
[System.Reflection.Assembly]::LoadFile("C:\Users\manivannan_b\Documents\New folder\microsoft.identitymodel.clients.activedirectory.2.29.0\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
#download https://www.nuget.org/packages/SharePointPnPCoreOnline/2.26.1805.1
[System.Reflection.Assembly]::LoadFile("C:\Users\manivannan_b\Documents\New folder\sharepointpnpcoreonline.2.26.1805.1\lib\net45\OfficeDevPnP.Core.dll")
  
#Variables
$SiteURL="https://maargasystems007.sharepoint.com/sites/POManagementDev"
$ListName="PO Details"


$username = "manivannan_b@maargasystems.com"
write-host "$($username)"
   
$password = [String] "Mani12!@"
Write-Host  $password.Trim()
$BatchSize= 2000

$DestListName="PO Details Sample (Destination)"


$ColArray=@("SNo","ItemCodeNo_HSN_SAC_Code","ItemDescription","UOM","Quantity","Rate","Amount","PPRLink","RepeatPOs","DeliveryReqDate","PartDesc1","PartDesc2","PartDesc3")
 
Try {


$SecurePassword = $password.Trim() | ConvertTo-SecureString -AsPlainText -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  
$adminUrl = "https://lindegroup-admin.sharepoint.com"
#$siteUrl=https://lindegroup.sharepoint.com
#Connect-SPOService -Url $adminUrl
$authManager = new-object OfficeDevPnP.Core.AuthenticationManager;
$Ctx = $authManager.GetWebLoginClientContext($SiteURL);
#testing CSOM calls
$Ctx.Load($Ctx.Web)
$Ctx.ExecuteQuery();
Write-Host $Ctx.Web.Title




    #Get the List   
    $List = $Ctx.Web.Lists.GetByTitle($ListName)
    $Ctx.Load($List)
    $Ctx.ExecuteQuery()

    $DestList = $Ctx.Web.Lists.GetByTitle($DestListName)
    $Ctx.Load($DestList)
    $Ctx.ExecuteQuery()

 
    #Get All List items
$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
    $Query.ViewXml = @"
    <View Scope='RecursiveAll'>
        <Query>
            <OrderBy><FieldRef Name='ID' Ascending='TRUE'/></OrderBy>
        </Query>
        <RowLimit Paged="TRUE">$BatchSize</RowLimit>
    </View>
"@

Do
{
    $listItems = $List.GetItems($Query)
    $Ctx.Load($ListItems)
    $Ctx.ExecuteQuery()

    $ListItems.count
    $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition
 
    Write-host "Total Items Found:"$List.ItemCount
    #Iterate through each item and update
    Foreach ($ListItem in $listItems)
    {
        #Set New value for List column


        if($ListItem["ID"] -le 300)
        {
        continue
        }


        Write-Host "rev : " $ListItem["PODATA_Text"]

        if($ListItem["Quantity"] -ne $null -and $ListItem["PODATA_Text"] -ne ""){

        $qty = $ListItem["PODATA_Text"].Split("~")

        $lenght = $qty.Length
        }
        else{

        $lenght = 1
        }

        Write-Host $lenght


$Ctx.Load($List.Fields)
$Ctx.ExecuteQuery()


for($i=0;$i -lt $lenght;$i++){

    $ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
    $DestListItem = $DestList.AddItem($ListItemInfo)
     

#Iterate through each field in the list
Foreach ($Field in $List.Fields)
{  
    #Skip System Fields
    if(($Field.ReadOnlyField -eq $False) -and ($Field.Hidden -eq $False) -and $Field.CanBeDeleted)
    {
       #get internal name of sharepoint online list column powershell
       Write-Host $Field.Title : $Field.InternalName "value : " $List[$Field.InternalName]

       if($ListItem[$Field.InternalName] -ne "" -and  $ListItem[$Field.InternalName] -ne $null){

       if($ColArray -contains $Field.InternalName){

       $DestListItem[$Field.InternalName] = $ListItem[$Field.InternalName].split(",")[$i]
       $DestListItem.Update()
        $Ctx.ExecuteQuery()

        Write-Host $Field.Title : $Field.InternalName "Updated"

       }
       else{

        $DestListItem[$Field.InternalName] = $ListItem[$Field.InternalName]
        $DestListItem.Update()
        $Ctx.ExecuteQuery()

        Write-Host $Field.Title : $Field.InternalName "Updated"
       }
       }
    }
}

        $DestListItem["PoRefId"] = $ListItem["ID"]
        $DestListItem.Update()
        $Ctx.ExecuteQuery()

}



        <#
        if($rev -ne "" -and $rev -ne $null){

        Write-Host $ListItem["Revisions"].split(",")[-1]

       $modified = $ListItem["Revisions"].split(",")[-1]
       
       Write-Host $urldecode

        #$ListItem["Modified_notes"] = $modified.replace("&#58;",":");
        #$ListItem.Update()
        #$Ctx.ExecuteQuery()
         }#>
    }
$ListItems.count
        $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition
    }
    While($Query.ListItemCollectionPosition -ne $null)
 



     
    Write-host "All Items in the List: $ListName Updated Successfully!" -ForegroundColor Green 
}
Catch {
    write-host -f Red "Error Updating List Items!" $_.Exception
}

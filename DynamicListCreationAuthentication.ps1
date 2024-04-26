[System.Reflection.Assembly]::LoadFile("C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\SPComponents\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.dll")
[System.Reflection.Assembly]::LoadFile("C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\SPComponents\microsoft.sharepointonline.csom.16.1.7723.1200\lib\net45\Microsoft.SharePoint.Client.Runtime.dll")
[System.Reflection.Assembly]::LoadFile("C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\SPComponents\microsoft.identitymodel.clients.activedirectory.2.29.0\lib\net45\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
[System.Reflection.Assembly]::LoadFile("C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\SPComponents\sharepointpnpcoreonline.2.26.1805.1\lib\net45\OfficeDevPnP.Core.dll")

function CreateListWithColumnValue {

	Param(
		[Parameter(Mandatory=$True)][String]$configfile,
        [Parameter(Mandatory=$True)][String]$LogPath
	)
try{
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12	



Logger -LogPath $LogPath -LogContent "Started ^ CreateSiteCollection @ Script"

	
	$Properties=ReadPropertyFile -PropertyFilePath $configfile

	
    $siteURL=$Properties.SiteURL
    write-host "$($siteURL)"
    Logger -LogPath $LogPath -LogContent "$($siteURL)"
    
    $listTitle=""
	$ListOfCol = New-Object System.Collections.Generic.List[string]

    
	$CsvFile = Import-Csv $Properties.listcsvpath.Trim() -Encoding UTF8

Write-Host $listTitle
Logger -LogPath $LogPath -LogContent "$listTitle"
            ForEach ($key in $CsvFile){

            $ExistList = $True
          
                    if($listTitle -ne $key.ListName){
                     $AuthenticationManager = new-object OfficeDevPnP.Core.AuthenticationManager
$context = $AuthenticationManager.GetWebLoginClientContext($siteURL)
$context.Load($context.Web)
$context.ExecuteQuery()

                    <#$SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $SecurePassword)
					$context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
					$context.credentials = $SPOCredentials#>
					
					$listTemplate = 100
					$ExistList = $False
                    
                   
                     
                    }
                
                    $listTitle=$key.ListName.Trim()
					$columnName=$key.ColumnName.Trim()
					$columnType=$key.ColumnType.Trim()
                    $columnDisplayName=$key.ColumnDisplayName.Trim()
                    $Required=$key.Required
                    $format=$key.Format
                    $choices=$key.Choices
                    $default=$key.Default
                    $showInNewForm=$key.ShowInNewForm
                    $showInDisplayForm=$key.ShowInDisplayForm
                    $showInEditForm=$key.ShowInEditForm
                    $readOnly=$key.ReadOnly
					
					Write-Host "List Title is :: $($listTitle)"
                    Logger -LogPath $LogPath -LogContent "List Title is :: $($listTitle)"
                    Write-Host "length of col name :: $($columnName.length)"
<#if($columnName.length -gt 32)
{
$columnName= $ColumnName.Substring(0,31)
Write-Host "Modified column name is :: $($ColumnName)"
}#>
					

      
    
    if(!$ExistList){
        $lci = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        $lci.title = $listTitle
        $lci.TemplateType = $listTemplate
        $lists = $context.web.lists.add($lci)
        $context.load($lists)
        $context.executeQuery()

        $list = $context.Web.Lists.GetByTitle($listTitle)

        $context.Load($list.Fields)  
        $context.ExecuteQuery()  

        Write-Host "List Created : " $listTitle
        Logger -LogPath $LogPath -LogContent "List Created :  $listTitle"
       
    }
	
    $isFieldExist = $False
	
    $Fields = $list.Fields
    $context.Load($list)
    $context.Load($Fields)
    $context.ExecuteQuery()
 
    $Field = $Fields | where{$_.Title -eq $columnName}
    if($Field)  { $isFieldExist =  $true } else { $isFieldExist = $false}


    if(!$isFieldExist){

    if($columnType -eq "Lookup"){
   
    $fieldXML="<Field Type='UserMulti' DisplayName='" + $columnDisplayName + "' Name='" + $columnName + "' UserSelectionMode='PeopleOnly' UserSelectionScope='0' Mult='TRUE' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'/>"
    
    }
    <# for single people picker#>
    <#elseif($columnType -eq "User"){
   
    $fieldXML="<Field Type='"+$columnType+"' DisplayName='" + $columnDisplayName + "' Name='" + $columnName + "' UserSelectionMode='PeopleOnly' UserSelectionScope='0' Mult='FALSE' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'/>"
    
    }#>
    elseif($columnType -eq "Choice"){
    
    $fieldXML="<Field Type='"+$columnType+"' DisplayName='"+$columnDisplayName+"' Name='"+$columnName+"' Format='"+$format+"' Required='"+$Required+"' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'><Default>"+$default+"</Default><CHOICES>"+$choices+"</CHOICES></Field>"
    }
    elseif($columnType -eq "DateTime"){
    
    $fieldXML="<Field Type='"+$columnType+"' DisplayName='"+$columnDisplayName+"' Name='"+$columnName+"' Format='"+$format+"' Required='"+$Required+"' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'></Field>"
    }
    elseif($columnType -eq "RichText"){
    $fieldXML="<Field Type='Note' DisplayName='"+$columnDisplayName+"' RichText='TRUE' RichTextMode='FullHtml' Name='"+$columnName+"' Format='"+$format+"' Required='"+$Required+"' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'>$default</Field>"
    }
    elseif($columnType -eq "MultiChoice"){
    $fieldXML="<Field Type='MultiChoice' DisplayName='"+$columnDisplayName+"' Name='"+$columnName+"' Format='"+$format+"' Required='"+$Required+"' FillInChoice='TRUE' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'><Default>"+$default+"</Default><CHOICES>"+$choices+"</CHOICES></Field>"
    }
   <# elseif($columnType -eq "User"){
    $fieldXML="<Field Type='User' DisplayName='"+$columnDisplayName+"' Name='"+$columnName+"' Format='"+$format+"' Required='"+$Required+"' FillInChoice='TRUE' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'>$default</Field>"
    }#>
    else{
    
    $fieldXML="<Field Type='"+$columnType+"' DisplayName='"+$columnDisplayName+"' Name='"+$columnName+"' Required='"+$Required+"' ShowInNewForm='"+$showInNewForm+"' ShowInDisplayForm='"+$showInDisplayForm+"' ShowInEditForm='"+$showInEditForm+"' ReadOnly='"+$readOnly+"'/>"
    }
    Write-Host "fieldxml: $($fieldXML)"
    Logger -LogPath $LogPath -LogContent "fieldXML: $($fieldXML)"
	$list.Fields.AddFieldAsXml($fieldXML,$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint)
	$list.Update()
	
    $context.Load($list)
    $context.ExecuteQuery()

    $ListOfCol.Add($columnName)

    Write-Host "Column Added : $($columnName)"
    Logger -LogPath $LogPath -LogContent "Column Added : $($columnName)"
    }
   
   	
}
}
catch{
		$ErrorMessage = "$($_.Exception.Message)"
		write-host -foregroundcolor red "$($ErrorMessage)"
 Logger -LogPath $LogPath -LogContent "$($ErrorMessage)"
	}

Logger -LogPath $LogPath -LogContent "End of the program"
}

Function isListPresent(){

Param(
		[Parameter(Mandatory=$True)][Microsoft.SharePoint.Client.ClientContext]$context,
         [Parameter(Mandatory=$True)][System.Collections.Generic.List[string]]$listTitle
        
	)


    $Existlist = $false
    $listcoll=$context.Web.Lists
    $context.Load($listcoll)
    $context.ExecuteQuery()
    
    if($listcoll -ne $null){
   
    foreach ($List in $listcoll) {   
 
    $context.Load($List)
    $context.ExecuteQuery()

    #Write-Host "List Name : " $List.title

    if($List.title -eq $listTitle){

    $Existlist = $true 
   
    write-host "$($listTitle) List is Already Exist" -foregroundcolor red
    Logger -LogPath $LogPath -LogContent "$($listTitle) List is Already Exist"
    }

    }
    }

    return $Existlist
}




Function Logger() {
	Param(
	[Parameter(Mandatory=$False)] [String]$LogPath,
	[Parameter(Mandatory=$False)] [String]$LogContent
	)
	try{
        #if(!$LogPath){
        #    $LogPath='C:\logfile.log'
        #}
        $LogTime = Get-Date -Format "dd-MMM-yyyy HH:mm:ss"
        #$LogTime = Get-Date -Format "dd-MMM-yyyy hh:mm:ss tt zzz" #datestamp with timezone
        $content= " [ $($LogTime) ] ~"+ $LogContent

        if(!(Test-Path $LogPath)){
            " [ $($LogTime) ] ~Log file created successfully in $($LogPath)" | Out-File -Encoding utf8 -FilePath $LogPath -Append
            write-host "Log File Created in the specified path : $($LogPath)"
        }

        $content | Out-File -Encoding utf8 -FilePath $LogPath -Append
        
	}catch{
		$ErrorMessage = "$($_.Exception.Message)"
		write-host -foregroundcolor red "$($ErrorMessage)"
 Logger -LogPath $LogPath -LogContent "$($ErrorMessage)"
	}
}


Function ReadPropertyFile(){

    Param(
    [Parameter(Mandatory=$False)][String]$PropertyFilePath
	)

    try{
        if(Test-Path $PropertyFilePath){
            $fileContents = get-content $PropertyFilePath
            $properties = @{}
            foreach($line in $fileContents){
                 if($line.Split("=").Count -gt 1){
                     #write-host "$($line)"
                     $words = $line.Split('=',2)# ,2 tells split to return two substrings (a single split) per line
                     $properties.add($words[0].Trim(), $words[1].Trim())
                 }
            }
            return $properties
        }else{
            write-host -foregroundcolor red "File does not exists in the specified path"
            Logger -LogPath $LogPath -LogContent "File does not exists in the specified path"
            return $null
        }
    }catch{
        write-host -foregroundcolor red "$($_.Exception.Message)"
        Logger -LogPath $LogPath -LogContent "$($_.Exception.Message)"
        
        Logger -LogPath $ErrorLogPath -LogContent "$($_.Exception.Message)"
        Logger -LogPath $ErrorLogPath -LogContent "$($_.Exception)"
        Logger -LogPath $LogPath -LogContent "$($_.Exception)"
        return $null
    }
 }

 
Function PasswordEncryption(){

    Param(
    [Parameter(Mandatory=$False)][String]$PropertyFilePath
	)

    try{
        Write-Host "PasswordEncryption Started"
        $Properties = ReadPropertyFile -PropertyFilePath $PropertyFilePath
      
	    $plain_password = $Properties.plain_password.Trim()
        $encrypt_password = $Properties.encrypt_password.Trim()
        #Write-Host "$($plain_password)"
        #Write-Host "$($encrypt_password)"
        $key = Set-Key "AGoodKeyThatNoOneElseWillKnow"
        if($plain_password.length -gt 1){
            $encrypt_password = Set-EncryptedData -key $key -plainText $plain_password
            $Properties.encrypt_password = $encrypt_password
            $Properties.plain_password = ""
            <#foreach($prop in $Properties.keys){
                Write-Host "$($prop)"
                Write-Host "$($Properties[$prop])"
            }#>
            WritePropertyFile -PropertyFilePath $PropertyFilePath -properties $Properties
            #Write-Host "$($plain_password)"
            Write-Host "PasswordEncryption Ended"
            Logger -LogPath $LogPath -LogContent "PasswordEncryption Ended"
            return $plain_password
        }else{
            $plain_password = Get-EncryptedData -data $encrypt_password -key $key
            #Write-Host "$($plain_password)"
            Write-Host "PasswordEncryption Ended"
            Logger -LogPath $LogPath -LogContent "PasswordEncryption Ended"
            return $plain_password
        }

        <#$plainText = $Properties.plain_password.Trim()
        
        $encryptedTextThatIcouldSaveToFile = 

        $DecryptedText = Get-EncryptedData -data $encryptedTextThatIcouldSaveToFile -key $key#>


    }catch{
        write-host -foregroundcolor red "$($_.Exception.Message)"
        Logger -LogPath $LogPath -LogContent "$($_.Exception.Message)"
    }

}

 Function WritePropertyFile(){

    Param(
    [Parameter(Mandatory=$False)][String]$PropertyFilePath,
    $properties
	)

    try{
        if(Test-Path $PropertyFilePath){
            $Content=""
            foreach($prop in $properties.keys){
                $Content += "$($prop)=$($Properties[$prop])`n"
                #Write-Host "$($prop)"
                #Write-Host "$($Properties[$prop])"
            }
            Write-Host "PasswordEncryption Inprogress"
            Logger -LogPath $LogPath -LogContent "PasswordEncryption Inprogress"
            $Content | Out-File $PropertyFilePath -Force ascii
            #Set-Content -Value $Content -Path $PropertyFilePath  
            Write-Host "PasswordEncryption Inprogress"
            Logger -LogPath $LogPath -LogContent "PasswordEncryption Inprogress"
        }else{
            write-host -foregroundcolor red "File does not exists in the specified path"
       Logger -LogPath $LogPath -LogContent "File does not exists in the specified path"
            return $null
        }
    }catch{
        write-host -foregroundcolor red "$($_.Exception.Message)"
    Logger -LogPath $LogPath -LogContent "$($_.Exception.Message)"
        return $null
    }
 }


 function Set-Key {
param([string]$string)
$length = $string.length
$pad = 32-$length
if (($length -lt 16) -or ($length -gt 32)) {Throw "String must be between 16 and 32 characters"}
$encoding = New-Object System.Text.ASCIIEncoding
$bytes = $encoding.GetBytes($string + "0" * $pad)
return $bytes
}


function Set-EncryptedData {
param($key,[string]$plainText)
$securestring = new-object System.Security.SecureString
$chars = $plainText.toCharArray()
foreach ($char in $chars) {$secureString.AppendChar($char)}
$encryptedData = ConvertFrom-SecureString -SecureString $secureString -Key $key
return $encryptedData
}

function Get-EncryptedData {
param($key,$data)
$data | ConvertTo-SecureString -key $key |
ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
}


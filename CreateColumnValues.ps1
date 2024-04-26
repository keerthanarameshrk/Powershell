Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

Function addColumnValues(){

Param(
		[Parameter(Mandatory=$True)][String]$configfile,
        [Parameter(Mandatory=$True)][String]$LogPath
	)

    $siteURL = "https://lindegroup.sharepoint.com/sites/LGEMEADokumentnummernTest"
    
	
	Logger -LogPath $LogPath -LogContent "Started ^ CreateSiteCollection @ Script"
	
	$Properties=ReadPropertyFile -PropertyFilePath $configfile

	$username = $Properties.username.Trim()
	write-host "$($username)"
    Logger -LogPath $LogPath -LogContent "$($username)"
    $password = PasswordEncryption -PropertyFilePath "$($configfile)"
	#$password = $Properties.password.Trim()
    $password = [String] $password
    Write-Host  $password.Trim()

    $SecurePassword = $password.Trim() | ConvertTo-SecureString -AsPlainText -Force
	#$adminSiteUrl = $Properties.adminSiteUrl.Trim()
    $listTitle=""
	$ListOfCol = New-Object System.Collections.Generic.List[string]

    $columncsvpath = $Properties.columncsvpath.Trim()

    
    $columncsCsvFile = Import-Csv $columncsvpath
    
    $ListOfCol = New-Object System.Collections.Generic.List[string]


     ForEach ($key in $columncsCsvFile){

          
                    if($listTitle -ne $key.ListName){

                    $ListOfCol.Clear()

                    $SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $SecurePassword)
					$context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
					$context.credentials = $SPOCredentials
					
					$listTemplate = 100
					$ExistList = $False
    
                    $list = $context.Web.Lists.GetByTitle($key.ListName)

                    $context.Load($list)  
                    $context.ExecuteQuery()  
                    
                    $ExistList = $false

                    
                    $Fields = $list.Fields
                    $context.Load($Fields)
                    $context.ExecuteQuery()

                    
			        foreach($Field in $Fields){

                            $context.Load($Field)
                            $context.ExecuteQuery()
                            
                          
                            if(!$Field.Hidden){
                            $ListOfCol.Add($Field.Title)
                            
                             }
                         }

                     
                    }
                
                    
                    $listTitle=$key.ListName
					
					 
                    $ListItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
	                $NewListItem = $list.AddItem($ListItemCreationInformation)

                 
                             
                           
                         for($i=0;$i -lt $ListOfCol.Count; $i++)
                            {  
                             
                             $colnam = $ListOfCol[$i]
                             $ColValue=$key.$colnam


                             if($ColValue -ne "" -and $ColValue -ne $null)
                            {
                             if($ColValue.Contains("onmicrosoft.com")){
                                                           
                              [Microsoft.SharePoint.Client.User]$newUser = $context.Web.EnsureUser($ColValue)
                              $context.Load($newUser)  
                              $context.ExecuteQuery()  

                              $ColValue = "{0};#{1}" -f $newUser.Id, $newUser.LoginName.Tostring()

                             }
                       
                             write-host "info: value added .... $($ColValue)"

					         $NewListItem[$colnam] = $ColValue
                             $NewListItem.Update()                    
					         $context.ExecuteQuery()
                                   }
                           
                           }
					}

                  
                    
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
            return $plain_password
        }else{
            $plain_password = Get-EncryptedData -data $encrypt_password -key $key
            #Write-Host "$($plain_password)"
            Write-Host "PasswordEncryption Ended"
            return $plain_password
        }

        <#$plainText = $Properties.plain_password.Trim()
        
        $encryptedTextThatIcouldSaveToFile = 

        $DecryptedText = Get-EncryptedData -data $encryptedTextThatIcouldSaveToFile -key $key#>


    }catch{
        write-host -foregroundcolor red "$($_.Exception.Message)"
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
            $Content | Out-File $PropertyFilePath -Force ascii
            #Set-Content -Value $Content -Path $PropertyFilePath  
            Write-Host "PasswordEncryption Inprogress"
        }else{
            write-host -foregroundcolor red "File does not exists in the specified path"
       
            return $null
        }
    }catch{
        write-host -foregroundcolor red "$($_.Exception.Message)"
    
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
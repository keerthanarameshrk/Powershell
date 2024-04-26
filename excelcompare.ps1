$CsvFile = Import-Csv 'C:\Users\keerthana_r\Desktop\prdunid400.csv'
$CsvFile1= Import-Csv 'C:\Users\keerthana_r\Desktop\prdunid.csv' 

#Write-Host $listTitle

           <# ForEach ($key in $CsvFile){

            #$ExistList = $True
            $fistkey= $key
          
                  #Write-Host $key
                  }  
                   ForEach ($key1 in $CsvFile1){

            #$ExistList = $True
            $secondkey=$key1
          
                  #Write-Host $key
                  }  
                 $props1 = $CsvFile | gm -MemberType NoteProperty | select -expand Name | sort | % {"$_"}
                   $props2 = $CsvFile1 | gm -MemberType NoteProperty | select -expand Name | sort | % {"$_"}

                   if(Compare-Object $props1 $props2) {

    # Check that properties match

    throw "Properties are not the same! [$props1] [$props2]"

} else {

    # Pass properties list to Compare-Object

    "Checking $props1"

    Compare-Object $CsvFile $CsvFile1 -Property $props1

}#>
#$props1| Export-Csv -Path .Downloads\newfolder.csv 
$matchCounter=0
foreach ( $file1 in $CsvFile){
    $matched = $false

    foreach ($file2 in $CsvFile1){
        
        #if(($file1.'ColumnName' ) -eq ($file2.'ColumnName') )
        if(($file1.'DocumentUNID' ) -eq ($file2.'DocumentUNID') ){
            $matchCounter++
            #Write-Host "match" "$matchCounter"
            $matched = $true
            $break
        }
        }
        if(-not $matched)
        {
        Write-Host "if executed"
            $obj=""|select "DocumentUNID"
            #$obj = "" | select "ListName","ColumnName","ColumnDisplayName","ColumnType","AlterField","Type"
            <#$obj.'ListName' = $file1.'ListName'
            $obj.'ColumnName' = $file1.'ColumnName'
            $obj.'ColumnDisplayName' = $file1.'ColumnDisplayName'
            $obj.'ColumnType' = $file1.'ColumnType'
            $obj.'AlterField' = $file1.'AlterField'
            $obj.'Type' = $file1.'Type'
            Write-Host "Match Found Orders " "$matchCounter"#>
           $obj.'DocumentUNID'=$file1.'DocumentUNID'
            Write-Host "Match Found Orders " "$matchCounter"
            
            Write-Host $obj.DocumentUNID
            $obj | Export-Csv -Path C:\Users\keerthana_r\Desktop\prdcheck.csv
        }
        }


               
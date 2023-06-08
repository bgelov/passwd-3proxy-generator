# Passwords generator for 3proxy
function gen-password() {
    $UAlpha = "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
    $LAlpha = "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
    $Num = "1","2","3","4","5","6","7","8","9","0"

    $ReqPassLenght = 15

    $x = 0
    $Pass1 = $Pass2 = $Pass3 = $Shuffle = $OutputPassword = $PassOut = $upass = $upass2 = $null

    do
    {
    $U = $null
    if ($x -ne $ReqPassLenght){ 
    $U = Get-Random $UAlpha 
    [array]$Pass1 = $Pass1 + $U
    $x = $x + 1
    }

    $L = $null
    if ($x -ne $ReqPassLenght){ 
    $L = Get-Random $LAlpha 
    [array]$Pass2 = $Pass2 + $L
    $x = $x + 1
    }

    $N = $null
    if ($x -ne $ReqPassLenght){ 
    $N = Get-Random $Num 
    [array]$Pass3 = $Pass3 + $N
    $x = $x + 1
    }

    }
    until ($x -eq $ReqPassLenght)

    $PassOut = $Pass1 + $Pass2 + $Pass3

    $Shuffle = $PassOut | Sort-Object {Get-Random}
    # Write-Host "AppuPass = $PassOut"
    $JoiningPwd = $Shuffle -split " "

    ForEach ($Pwd in $JoiningPwd) {
    $OutputPassword += $Pwd 
    }

    return $OutputPassword
}

$path = '\\fileserver\files\proxy'
$upass = $upass2 = $null

#Доступ только для включённых учётных записей
$user = (Get-ADGroupMember CompanyUsers -Recursive | select samaccountname).samaccountname

    $result = foreach ($u in $user) {
        $us = Get-ADUser $u -Properties enabled, extensionAttribute6
        if (($us.enabled)) {
            $u   
        }
        $us = $null
    }
    $result | sort > "$path\proxyusers.txt"

$csv = gc "$path\proxyusers.csv"

$upass = "login;pass;
"

foreach ($proxyuser in (gc "$path\proxyusers.txt")) {

    $str = $csv | Select-String $proxyuser

        if ($str) { 
            $loginpass = $str[0].ToString()

            $upass = $upass + $loginpass + "
"
            $loginpass = ($loginpass.TrimEnd(";")).Replace(";",":CL:")

            $upass2 = $upass2 + $loginpass + "
"
            
        } else { 
        
            $upass += "$proxyuser;"+(gen-password)+";
"        
            $upass2 += $proxyuser+":CL:"+(gen-password)+"
"
        }

}


$curDate = Get-Date -format "MM-dd-yyyy"

$upass | Out-File "$path\proxyusers.csv" -Encoding utf8
$upass | Out-File "$path\backup\proxyusers_$curDate.csv" -Encoding utf8
$upass2 | Out-File "$path\passwd" -Encoding utf8
$upass2 | Out-File "$path\backup\passwd_$curDate" -Encoding utf8
$upass2 | Out-File "\\MyServer\c$\Program Files\3proxy\bin\passwd" -Encoding utf8

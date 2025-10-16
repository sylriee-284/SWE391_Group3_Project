$p = 'd:\test github\SWE391_Group3_Project\src\main\java\vn\group3\marketplace\service\WalletTransactionService.java'
$b = [System.IO.File]::ReadAllBytes($p)
if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) {
    $b = $b[3..($b.Length-1)]
    [System.IO.File]::WriteAllBytes($p,$b)
    Write-Host 'removed utf8 bom'
} else {
    Write-Host 'no bom found'
}
Write-Host 'file length:' $b.Length
# print first 3 bytes
for ($i=0; $i -lt [Math]::Min(20,$b.Length); $i++) { Write-Host "$i : $($b[$i])" }
Write-Host '--- file content preview ---'
[System.Text.Encoding]::UTF8.GetString($b) | Write-Host

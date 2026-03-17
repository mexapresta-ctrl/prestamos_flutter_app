$html = Get-Content "C:\Users\LESLY\Downloads\APP MEXA\LOGIN.html" -Raw
$pattern = 'src="data:image/png;base64,([^"]+)"'
$matches = [regex]::Matches($html, $pattern)
$logo = $matches[0].Groups[1].Value
$admin = $matches[1].Groups[1].Value
$cobrador = $matches[2].Groups[1].Value
$asesor = $matches[3].Groups[1].Value

$code = @"
class LoginAssets {
  static const String logoBase64 = '$logo';
  static const String adminBase64 = '$admin';
  static const String cobradorBase64 = '$cobrador';
  static const String asesorBase64 = '$asesor';
}
"@
Set-Content "c:\Users\LESLY\Downloads\prestamos_app\lib\screens\auth\login_assets.dart" $code

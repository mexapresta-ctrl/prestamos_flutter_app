import re

with open(r'c:\Users\LESLY\Downloads\APP MEXA\LOGIN.html', 'r', encoding='utf-8') as f:
    text = f.read()

images = re.findall(r'src=\"data:image/png;base64,(.*?)\"', text)
names = ['logo', 'admin', 'cobrador', 'asesor']

out = "class LoginAssets {\n"
for i, img in enumerate(images):
    out += f"  static const String {names[i]}Base64 = '{img}';\n"
out += "}"

with open(r'c:\Users\LESLY\Downloads\prestamos_app\lib\screens\auth\login_assets.dart', 'w', encoding='utf-8') as f:
    f.write(out)
print('Assets extracted successfully!')

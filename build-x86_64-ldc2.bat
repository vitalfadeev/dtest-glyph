@ECHO OFF

set PATH=C:\D\ldc2-1.24.0-windows-multilib\bin;%PATH%

dub build --arch=x86_64  --compiler=ldc2.exe  --build=release

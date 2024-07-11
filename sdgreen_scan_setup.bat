@echo off
setlocal

set "stepCount=3"

:: PowerShell�� ����Ͽ� ����ũž ���� ��θ� �����ͼ� ������ ����
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "[Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)"`) do set desktopPath=%%i

:: FTP Setting
set "ftpUser=a"
set "ftpPass=a"
set "ftpRootFolderName=��ĵ"
set "ftpRootPath=%desktopPath%\%ftpRootFolderName%"

:: FTP Process location
set "programPath=C:\Program Files (x86)\KONICA MINOLTA\FTP Utility\KMFtp.exe"

:: Generate unique folder name
:uniqLoop
set "installerFolder=%tmp%\bat~%RANDOM%.tmp"
if exist "%installerFolder%" goto :uniqLoop

mkdir %installerFolder%
set "installerZipFile=%installerFolder%\FTPUtility.zip"
set "installerFile=%installerFolder%\FTPUtilitySetup.exe"
set "installerIss=%installerFolder%\FTPUtilitySetup.iss"

echo [1/%stepCount%] FTP Utility ��ġ

if exist "%programPath%" (
	echo �̹� FTP Utility�� ��ġ�Ǿ����ϴ�.
) else (
    :: Download the file
    echo Downloading the file...
    powershell -command "Invoke-WebRequest -Uri 'https://konica-minolta-ftp-utility.software.informer.com/download/?ca68e2e' -OutFile '%installerZipFile%'"
    powershell -command "Expand-Archive -LiteralPath '%installerZipFile%' -DestinationPath '%installerFolder%'"
    ( 
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-DlgOrder]
        echo Dlg0={A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SprintfBox-0
        echo Count=2
        echo Dlg1={A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SdSetupCompleteError-12060
        echo Dlg2={A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-AskPath-0
        echo Dlg3={A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-AskOptions-0
        echo Dlg4={A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SdFinish-0
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SdWelcome-0]
        echo Result=1
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SdLicense-0]
        echo Result=1
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-AskPath-0]
        echo szPath=C:\Program Files ^(x86^)\KONICA MINOLTA\FTP Utility\
        echo Result=1
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-AskOptions-0]
        echo Result=1
        echo Sel-0=1
        echo Sel-1=1
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SdFinish-0]
        echo Result=1
        echo bOpt1=0
        echo bOpt2=0
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SprintfBox-0]
        echo Result=6
        echo [{A5EC243A-AAB4-4AF0-85A5-07F9F4618353}-SdSetupCompleteError-12060]
        echo Result=1
    ) > %installerIss%
    
	start /wait %installerFile% /s /f1"%installerIss%"
    del %installerIss%
	echo FTP Utility ��ġ �Ϸ�
)
echo.

echo [2/%stepCount%] ��ĵ���� ����
if not exist "%ftpRootPath%" (
    mkdir "%ftpRootPath%"
    echo ���� "%ftpRootFolderName%"�� ����ȭ�鿡 �����Ǿ����ϴ�.
) else (
    echo ���� "%ftpRootFolderName%"�� �̹� �����մϴ�.
)
echo.

echo [3/%stepCount%] FTP Setting ������Ʈ�� ���
taskkill /IM KMFtp.exe /F
reg add "HKCU\Software\KONICA MINOLTA\KMFTP" /v Anonymous /t REG_DWORD /d "0" /f
reg add "HKCU\Software\KONICA MINOLTA\KMFTP" /v User /t REG_SZ /d "29467C" /f
reg add "HKCU\Software\KONICA MINOLTA\KMFTP" /v Pass /t REG_SZ /d "29467C" /f
reg add "HKCU\Software\KONICA MINOLTA\KMFTP" /v RootFolder /t REG_SZ /d "%ftpRootPath%" /f
start "" "%programPath%"
echo.

rmdir %installerFolder% /S /Q
endlocal
pause
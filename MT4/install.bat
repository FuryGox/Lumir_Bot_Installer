@echo off
setlocal enabledelayedexpansion

set "base=%APPDATA%\MetaQuotes\Terminal"
set index=0

:: === COPY FILE ===
set "botFile=setup\LumirMT4_v2.ex4"
echo "%botFile%"
if not exist "%botFile%" (
  echo [LOI] Khong tim thay file bot: "%botFile%" !
  pause
  exit /b
)

echo ==== DANH SACH INSTANCE MT4 ====
echo.
for /d %%F in ("%base%\*") do (
  set /a index+=1
  set "instance!index!=%%F"
  set "foldername=%%~nF"
  rem Bỏ qua 3 folder mặc định
  if /I "!foldername!"=="Common"  (
    rem skip
    ) else if /I "!foldername!"=="Community" (
    rem skip
    ) else if /I "!foldername!"=="Help" (
    rem skip
    ) else (
    if exist "%%F\origin.txt" (
      echo +-------------------------- [Instance !index!] --------------------------+
      type "%%F\origin.txt"
      echo.
      echo +------------------------------------------------------------------+
      ) else (
      echo origin.txt khong ton tai
    )
    echo.
    
    
  )
)

if !index!==0 (
  echo Khong tim thay instance MT4 nao!
  pause
  exit /b
)

echo.
set /p choice="Chon so instance de sua HistoryPeriod: "

set "selected=!instance%choice%!"
if not defined selected (
  echo Lua chon khong hop le
  pause
  exit /b
)

set "configFile=%selected%\config\terminal.ini"

if not exist "%configFile%" (
  echo Khong tim thay terminal.ini
  pause
  exit /b
)

echo Dang sua HistoryPeriod tai:
echo %configFile%
echo.

set "tempFile=%configFile%.tmp"
set found=0

(
for /f "usebackq delims=" %%A in ("%configFile%") do (
  set "line=%%A"
  if "!line:~0,14!"=="HistoryPeriod=" (
    echo HistoryPeriod=7
    set found=1
    ) else (
    echo !line!
  )
)
) > "%tempFile%"

if "!found!"=="0" (
  echo HistoryPeriod=7>>"%tempFile%"
)

echo Da sua thanh cong HistoryPeriod=7

move /y "%tempFile%" "%configFile%" >nul

echo === FILE BOT ===
set "targetExperts=!selected!\MQL4\Experts"

if not exist "!targetExperts!" (
  echo [Thong bao] Tao thu muc Experts: "!targetExperts!"
  md "!targetExperts!"
)

copy /y "%botFile%" "!targetExperts!" >nul
echo Da copy bot thanh cong toi: "!targetExperts!"
echo.




echo === Config === 
set "sourceFile=setup\experts.ini"
if not exist "!sourceFile!" (
    echo [LOI] Khong tim thay file config: "!sourceFile!" !
    pause
    exit /b
)

rem Dùng biến !selected! để xác định thư mục đích
set "targetConfig=!selected!\config"

rem Tao thu muc config neu chua ton tai
if not exist "!targetConfig!" (
    md "!targetConfig!"
)

rem Xoa file experts.ini cu
set "fileToDelete=experts.ini"
if exist "!targetConfig!\!fileToDelete!" (
    del /f /q "!targetConfig!\!fileToDelete!"
)

rem Copy file experts.ini moi
if exist "!sourceFile!" (
    copy /y "!sourceFile!" "!targetConfig!\" >nul
)


:: ==============================

pause

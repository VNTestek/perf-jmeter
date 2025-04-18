@echo off
 setlocal
 REM Set the folder to search. You can change this to the folder you want.
 set "folder=D:\Tools\apache-jmeter-5.6.2\apache-jmeter-5.6.2\res\POD4\SavingDashboard\20240806"

 for /f "tokens=1-4 delims=/-. " %%A in ('date /t') do (
   set "day=%%B"
   set "month=%%C"
   set "year=%%D"
 )
 for /f "tokens=1-4 delims=:. " %%A in ('time /t') do (
   set "hour=%%A"
   set "minute=%%B"
   set "second=%%D"
 )
 if "%hour:~1,1%"=="" set "hour=0%hour%"
 set "timestamp=%year%%month%%day%-%hour%%minute%%second%"

 echo Searching for .jtl files in %folder% and its subfolders...
 REM Use the 'for /r' command to find all .doc and .docx files
 for /r "%folder%" %%f in (*.jtl) do (
   rem echo %%f
   for %%A in ("%%f") do (
     rem  File Name: %%~nxA
     rem echo Folder: %%~dpA
     call D:\Tools\apache-jmeter-5.6.2\apache-jmeter-5.6.2\bin\JMeterPluginsCMD.bat --generate-csv "%timestamp%-res-convert/%%~nxA.csv" --input-jtl "%%f" --plugin-type AggregateReport
   )
   rem call D:\Tools\apache-jmeter-5.6.2\apache-jmeter-5.6.2\bin\JMeterPluginsCMD.bat --generate-csv tesst.csv --input-jtl "D:\Tools\apache-jmeter-5.6.2\apache-jmeter-5.6.2\res\STech\Transfer-SameBank\20240805\202408051804_Transfer-SameBank_40C5R8S15D_02.jtl" --plugin-type AggregateReport
 )
 call java -jar TestekExportAggregateReport.jar "%timestamp%-res-convert"

 endlocal
 pause
rem Ziel: Liste alle Dateien eines Ordners und aller Unterordner beliebiger Tiefe mit Angabe der Lage in der ordnerstruktur und der Dateigröße

rem Verwendung: 
rem 	Kopiere diese Datei in den zu untersuchenden Ordner
rem 	Doppelklicke diese Datei
rem 	Finde die Auflistung der Dateinamen und Größen in der unter "myOutputFileName" definierten Textdatei

rem ####################################### Beginn des Skriptes
rem Veraendere den Zeichensatz um auch Umlaute und Sonderzeichen in Verzeichnisnamen und Dateinamen korrekt zu verwenden
CHCP 1252
rem Ermoegliche die Auswertung von Variablen zur Laufzeit [Übersetzung > Ausführung]
setlocal enabledelayedexpansion
rem Reduziere den Output des "echo"-Befehls
@echo off
rem Definiere Ausgabedatei
set myOutputFileName=fileList.txt
rem Definiere einen Umrechnungsfaktor um von Byte auf die ebenfalls anzugebende Einheit umzurechnen
rem Ausgegeben wird DateigrößeInByte / myScalingFactor
set myScalingFactor=1
set myUnit=Byte
rem Speichere den absoluten Pfad des Hauptverzeichnisses
set myMainDirectory=%cd%
rem Speichere den Namen des Hauptverzeichnisses
for %%* in (.) do set myMainDirectoryName=%%~nx*
rem Speichere den absoluten Pfad zur Ausgabedatei
set myOutputFile=%myMainDirectory%\%myOutputFileName%
rem Loesche den bisherigen Inhalt der Ausgabedatei und gebe absoluten Pfad des Hauptverzeichnisses aus
echo Das Verzeichnis / The directory >"%myOutputFile%"
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
echo %myMainDirectory% >>%myOutputFile%
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
echo enthaelt die folgende Dateistruktur und Dateien / contains the following structure and files: >>%myOutputFile%
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
rem Starte den rekursiven Aufruf des "treeProcesses"
rem Vielen Dank an: Aacini from Mexico City http://stackoverflow.com/questions/8397674/windows-batch-file-looping-through-directories-to-process-files 
call :treeProcess
rem Stop Interpreting of treeProcess is finished
goto :eof


:treeProcess
rem Speichere den absoluten Pfad des aktuellen Verzeichnisses
set myDiretory=%cd%
rem Erstelle einen relativen Pfad des aktuellen Verzeichnisses zum Hauptverzeichnis
set myDiretoryRelative=!myDiretory:%myMainDirectory%=.!
rem Gib den relativen Pfad des aktuellen Verzeichnisses aus
echo #!myDiretoryRelative! >>%myOutputFile%
rem Durchlaufe alle Dateien im Verzeichnis
for /f "delims=" %%B in ('dir /b /a-d /one') do (
	rem Speichere den aktuellen Dateinamen
	set myFile=%%B
	rem Bestimme die Größe der aktuellen Datei in Byte
	for /f "usebackq delims=" %%C in ('%%B') do (
		rem echo %%C >>%myMainDirectory%\%myOutputFile%
		set myFileSize=%%~zC
		rem Rechne die Dateigröße gemäß des Skalierungsfaktors um
		set /A myFileSizeScaled=!myFileSize!/%myScalingFactor%
	)
	rem Gebe den aktuellen Dateinamen und die Dateigröße aus
	echo !myFile!    !myFileSizeScaled! %myUnit% >>%myOutputFile%
	rem Lösche die Variable mit der Dateigröße
	set myFileSizeScaled=
)
rem Durchlaufe alle Verzeichnisse im Verzeichnis
for /D %%A in (*) do (
	rem Gebe eine Leerzeile aus
	echo. >>%myOutputFile%
	rem Wechsle in das aktuell betrachtete Verzeichnis
	cd %%A
	rem Rufe den TreeProcess rekursiv auf
	call :treeProcess
	rem Nach Beendigung des TreeProcesses wechsle in das naechsthoehere Verzeichnis
	cd ..
)
rem Beende den TreeProcess und kehre zum aufrufenen Skriptbereich zurueck
exit /b

rem Schwachstellen dieses Skriptes: 
rem 1. Wenn die Dateigröße durch einen ScalingFactor von 1024 in MByte umgerechnet wird, dann kommt es (vermutlich rundungsbedingt) zu eienr Abweichung zur angezeigten Dateigröße im Windows Explorer

rem Anmerkungen bitte an
rem julian.bauer@enercon.de bzw. bauer.julian@gmx.de

rem Ziel: Liste alle Dateien eines Ordners und aller Unterordner beliebiger Tiefe mit Angabe der Lage in der ordnerstruktur und der Dateigröße

rem Verwendung: 
rem 	Kopiere diese Datei in den zu untersuchenden Ordner
rem 	Doppelklicke diese Datei
rem 	Finde die Auflistung der Dateinamen und Größen in der unter "myOutputFile" definierten Textdatei

rem ####################################### Beginn des Skriptes
rem Veraendere den Zeichensatz um auch Umlaute und Sonderzeichen in Verzeichnisnamen und Dateinamen korrekt zu verwenden
CHCP 1252
rem Ermoegliche die Auswertung von Variablen zur Laufzeit [Übersetzung > Ausführung]
setlocal enabledelayedexpansion
rem Reduziere den Output des "echo"-Befehls
@echo off

rem #Definiere Ausgabedatei
set myOutputFile=fileList.txt
rem #Definiere einen Umrechnungsfaktor um von Byte auf die ebenfalls anzugebende Einheit umzurechnen
rem  Ausgegeben wird DateigrößeInByte / myScalingFactor
set myScalingFactor=1
set myUnit=Byte

rem #Speichere den absoluten Pfad des Hauptverzeichnisses
set myWorkingDirectory=%cd%
rem #Loesche den bisherigen Inhalt der Ausgabedatei und gebe absoluten Pfad des Hauptverzeichnisses aus
echo Das Verzeichnis / The directory >"%myOutputFile%"
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
echo %myWorkingDirectory% >>%myOutputFile%
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
echo enthaelt die folgende Dateistruktur und Dateien / contains the following structure and files: >>%myOutputFile%
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%
rem Gebe eine Leerzeile aus
echo. >>%myOutputFile%

rem Schreibe den Namen des Hauptverzeichnisses ohne Pfadangabe aus:
for %%D in (.) do (
	echo #%%~nxD >>%myOutputFile%
)

rem #Durchlaufe alle Dateien im Hauptverzeichnis
for /f "delims=" %%B in ('dir "%myWorkingDirectory%" /b /a-d /one') do (
	rem Speichere den aktuellen Dateinamen
	set myFile=%%B
	rem ###Bestimme die Größe der aktuellen Datei in Byte
	for /f "usebackq delims=" %%C in ('%%B') do (
		rem echo %%C >>%myOutputFile%
		set myFileSize=%%~zC
		rem Rechne die Dateigröße gemäß des Skalierungsfaktors um
		set /A myFileSizeScaled=!myFileSize!/%myScalingFactor%
	)
	rem Gebe den aktuellen Dateinamen und die Dateigröße aus
	echo !myFile!    !myFileSizeScaled! %myUnit% >>%myOutputFile%
	rem #Lösche die Variable mit der Dateigröße
	set myFileSizeScaled=
)

rem #Durchlaufe alle Verzeichnisse im Hauptverzeichnis
for /f "delims=" %%A in ('dir /b /s /ad /one') do (
	rem Gebe eine Leerzeile aus
	echo. >>%myOutputFile%

	rem ##Speichere den absoluten Pfad der aktuellen Verzeichnisses
	set myDiretory=%%A
	set myDiretoryRelative=!myDiretory:%myWorkingDirectory%=...!
	echo #!myDiretoryRelative! >>%myOutputFile%
	
	rem ## Durchlaufe alle Dateien im aktuellen Unter/Unter/...Verzeichnis
	for /f "delims=" %%B in ('dir "%%A" /b /a-d /one') do (
		rem Speichere den aktuellen Dateinamen
		set myFile=%%B
		rem ###Bestimme die Größe der aktuellen Datei in Byte
		for /f "usebackq delims=" %%C in ('%%A\%%B') do (
			rem echo %%C >>%myOutputFile%
			set myFileSize=%%~zC
			rem Rechne die Dateigröße gemäß des Skalierungsfaktors um
			set /A myFileSizeScaled=!myFileSize!/%myScalingFactor%
		)
		rem Gebe den aktuellen Dateinamen und die Dateigröße aus
		echo !myFile!    !myFileSizeScaled! %myUnit% >>%myOutputFile%
		rem #Lösche die Variable mit der Dateigröße
		set myFileSizeScaled=
	)
)
rem Schwachstellen diese Skripte: 
rem 1. Die Bestimmung der Dateien und ihrer Größen ist redundant implementiert. Einmal für das Hauptverzeichnis und einmal für alle anderen Verzeichnisse. Zwischen beiden Skriptteilen bestehen kleine Unterschiede (For Loop Bestimmung Dateigröße)
rem 		Mögliche Lösungen: 	Führe Funktionen und entsprechende Übergabeparameter ein
rem 							Füge das Hauptverzeichnis in die Liste der zu durchsuchenden Verzeichnisse hinzu und mache eine Fallunterscheidung an den Stellen des redundanten Codes, der unterschiedlich ist (For Loop Bestimmung Dateigröße)
rem 2. Wenn die Dateigröße durch einen ScalingFactor von 1024 in MByte umgerechnet wird, dann kommt es (vermutlich rundungsbedingt) zu eienr Abweichung zur angezeigten Dateigröße im Windows Explorer
rem 3. Es geht sicherlich eleganter.

rem Anmerkungen bitte an
rem julian.bauer@enercon.de bzw. bauer.julian@gmx.de
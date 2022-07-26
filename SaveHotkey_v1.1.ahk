
;!!Warning: Extracting an older save and Loading it without closing the game, leads to a doubling of the savefile

#NoEnv  ;Recommended for performance and compatibility with future AutoHotkey releases.

Script_Folder = %a_scriptdir% ;automatically finds the Script's current folder
global Input_Folder = ""
global Output_Folder = ""
global GameTitle = ""   

exe7z := Script_Folder "/7za.exe" ;location of 7za
SoundEffect_Save := Script_Folder "/Saved.wav"
SoundEffect_Load := Script_Folder "/Loaded.wav"
;----------------------------

parsePathTxt(){
    FileRead, TempPath, SavefilePaths.txt
    
    ;--------------------------------
    ;--Grabs the User defined paths--
    ;--------------------------------
    TempPath2 :="" 
    Loop, read, SavefilePaths.txt
    {
        TempPath2 := A_LoopReadLine 
        IfInString, TempPath2, SavefilePath ;Searches for a specific substring inside another string
        {
            ;MsgBox %TempPath2%
            ;RegExMatch(TempPath2, ".:[\\\/].*", Input_Folder) ;Matches DriveLetter + : + any series of Back or Forward Slashes, but has no cutoff point
            ;Tester: https://regex101.com/r/sR1sS1/2
            
            RegExMatch(TempPath2, """(.*?)""", Input_Folder) ;Captures everything within quotes + quotes; To escape the quote requires another quote
            Input_Folder := SubStr(Input_Folder, 2, StrLen(Input_Folder)-2) ;Remove quotes
            ;MsgBox %Input_Folder% 
        } 
        IfInString, TempPath2, ArchivePath
        { 
            RegExMatch(TempPath2, """(.*?)""", Output_Folder)  
            Output_Folder := SubStr(Output_Folder, 2, StrLen(Output_Folder)-2)
            ;MsgBox %Output_Folder% 
        } 
        IfInString, TempPath2, GameTitleID
        { 
            RegExMatch(TempPath2, """(.*?)""", GameTitle)  
            GameTitle := SubStr(GameTitle, 2, StrLen(GameTitle)-2)
            ;MsgBox %Input_Folder% `n %Output_Folder%  `n %GameTitle% 
        } 
    } 
}
/*
Ctrl & End::
                parsePathTxt()
                ExitApp
return
*/
;/*
Ctrl & Ins::                       
                parsePathTxt()

                ;-----------------------
                ;--Create Archive name--
                ;-----------------------
                FormatTime, TimeString, %A_Now%, yyyy-MM-dd_HH-mm-ss  

                TempArchiveName = %GameTitle%_%TimeString%  
;/*
                ;--Compress--
                command="%exe7z%" a "%Output_Folder%\%TempArchiveName%.zip" "%Input_Folder%" -tzip   
                RunWait, %command%,, Hide
;*/
                ;----------------------------------------------------------------
                ;--Updates the external file name after the Compression process--
                ;----------------------------------------------------------------
                TempFile = %Script_Folder%\MostRecentSavefile
                file := FileOpen(TempFile, "w")
                file.Write(TempArchiveName)
                file.Close()

                ;--Sound Effect for Confirmation--
                ;SoundPlay, SoundEffect_Save   ;Script won't play the sound file
                SoundPlay, *16

                ;--Testing-- 
                ;There is an important difference between Variables vs Functions. Variables interpret everything not in quotes as a variable | Functions interpret everything not in % % as literal
                /*
                IfExist, %Script_Folder%\MostRecentSavefile
                MsgBox Exist
                Else
                IfNotExist, %Script_Folder%\MostRecentSavefile
                MsgBox File doesn't exist
                */

                ;MsgBox %MostRecentSavefile%
Return 
;*/
;/*
Ctrl & Del::    
                parsePathTxt() 

                FileRead, TempArchiveName, MostRecentSavefile ;MostRecentSavefile must be completely empty except for the savefile name

                ;-----------------------------------------------------------------
                ;--Retrieve file matched by {FileRead + the Loop's string match}--
                ;-----------------------------------------------------------------
                ;Allows compatibility with any filename that has string changes after what is specified in TempArchiveName ex: WDLegion_2022-07-05_01-23-57 Pre-LikeClockworkCompletetion.zip is successfully matched    
                TempArchiveName2 :=""
                Loop, Files, % Output_Folder "\" TempArchiveName "*.zip" 
                {
                    TempArchiveName2 := A_LoopFileFullPath
                    break
                }                
            
                ;-----------------------
                ;--Extract Most Recent--
                ;------------------------
                command="%exe7z%" x "%TempArchiveName2%" -aoa -o"%Output_Folder%    ;aoa: always overwrite all without prompt  
                RunWait, %command%,, Hide
                ;MsgBox %TempArchiveName%                 

                SoundPlay, *16

                ;IfExist, %Output_Folder%\%TempArchiveName%*.zip
                ;MsgBox Exist     
                ;MsgBox %TempArchiveName%

                ;ExitApp ;Closes AutoHotkey script after running
Return
;*/
;---------------------------------
;[Steps]
;--Track archive names or iterate to the next 1
;--Create new archive
;--Place a folder into the archive
;--Play soundeffect
;--Add recent archive name to an external file
;--Extract most recent archive
;--For Extraction, use a wildcard to make filename recognition more recognizable 
;--Switch the time hour format to military time

;[Further]
;Auto delete old files
;Auto delete ignore manually named files
;A First Run GUI to insert an initial Input and Output Input_Folder
;GUI independent exe
;GUI customizable hotkey
;(unimportant)!?When activating Compress, check if the save folder is empty | Check size
;   Verified: If the Compressed file is empty, Extracting won't delete the current saves
;Database implementation
;Autosave ex: every 10min
;Fix soundeffect
;--Create a callable Method "Grabs the User definied paths"
;Refresh Button to find the latest Archive and update MostRecentSavefile
;Regex, quote-delimited string
;Automatically set GameTitleID by identifying the active window
;Error Catching
;   -Failed to Compress or Extract
;   -Invalid or empty file path
;---------------------------------

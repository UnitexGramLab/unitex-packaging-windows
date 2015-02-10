# Java Runtime Environment Dynamic Installer Version 1.1.0
# @source http://nsis.sourceforge.net/Java_Runtime_Environment_Dynamic_Installer
# Cristian Martinez : string customization, manual, automatic or skip install modes,
# silent execution option, openLinkNewWindow.

!ifndef JRE_SETUP_INCLUDED
!define JRE_SETUP_INCLUDED

!include "WordFunc.nsh"

!macro CUSTOM_PAGE_JREINFO
		Page custom CUSTOM_PAGE_JREINFO CUSTOM_PAGE_JREINFOLeave
!macroend

!ifndef JRE_VERSION
  !error "JRE_VERSION must be defined"
!endif

!ifndef JRE_INSTALLER
  !error "JRE_INSTALLER must be defined"
!endif

# @source http://nsis.sourceforge.net/Open_link_in_new_browser_window
Function openLinkNewWindow
  Push $3
  Exch
  Push $2
  Exch
  Push $1
  Exch
  Push $0
  Exch
 
  ReadRegStr $0 HKCR "http\shell\open\command" ""
# Get browser path
  DetailPrint $0
  StrCpy $2 '"'
  StrCpy $1 $0 1
  StrCmp $1 $2 +2 # if path is not enclosed in " look for space as final char
  StrCpy $2 ' '
  StrCpy $3 1
  loop:
    StrCpy $1 $0 1 $3
    DetailPrint $1
    StrCmp $1 $2 found
    StrCmp $1 "" found
    IntOp $3 $3 + 1
    Goto loop
 
  found:
    StrCpy $1 $0 $3
    StrCmp $2 " " +2
    StrCpy $1 '$1"'
 
  Pop $0
  Exec '$1 $0'
  Pop $0
  Pop $1
  Pop $2
  Pop $3
FunctionEnd
 
!macro _OpenURL URL
Push "${URL}"
Call openLinkNewWindow
!macroend

!define OpenURL '!insertmacro "_OpenURL"'

;;;;;;;;;;;;;;;;;;;;;
;  Custom panel
;;;;;;;;;;;;;;;;;;;;;

var JRE_SETUP_HIDE_INFO_PAGE

; store the HWND
var RB_Ar3
var RB_Ar3_State
var RB_Ar4    
var RB_Ar4_State
var RB_Ar5
var RB_Ar5_State


Function CUSTOM_PAGE_JREINFO

  push $0
  push $1
  push $2
 
  IntCmp $JRE_SETUP_HIDE_INFO_PAGE 1 exit
  
  Push "${JRE_VERSION}"
  Call DetectJRE
  Pop $0
  Pop $1
  StrCmp $0 "OK" exit

  
  nsDialogs::create /NOUNLOAD 1018
  pop $1

  StrCmp $0 "0"  NoFound
  StrCmp $0 "-1" FoundOld


NoFound:
  ; ${NSD_Create*} x y width height text
  !insertmacro MUI_HEADER_TEXT "JRE Installation Required" "${PRETTYAPPNAME} Visual Integrated Environment requires Java ${JRE_VERSION} or higher"
  ${NSD_CreateLabel} 0 0 100% 30u "${PRETTYAPPNAME} Visual Integrated Environment requires a present installation of the Java Runtime Environment (JRE).\
  You could manually install it or try to automatically download during the setup process."
  pop $1
  goto ShowOptions

FoundOld:
  !insertmacro MUI_HEADER_TEXT "JRE Update Required" "${PRETTYAPPNAME} Visual Integrated Environment requires Java ${JRE_VERSION} or higher"
  ${NSD_CreateLabel} 0 0 100% 30u  "${PRETTYAPPNAME} Visual Integrated Environment requires a more recent version of the Java Runtime Environment (JRE).\
  You could manually update it or try to automatically download during the setup process."
  pop $1
  goto ShowOptions

ShowOptions:
  ; GroupBox 2    
  ${NSD_CreateGroupBox} 0 40u 100% 60u "What do you want to do?"
  Pop $1

  ; RadioButton 3    
  ${NSD_CreateRadioButton} 3% 51u 90% 10u "Visit the JRE &download page and manually download and install it."
  Pop $RB_Ar3
  ${NSD_SetState} $RB_Ar3 $RB_Ar3_State
  ;${NSD_Check} $RB_Ar3      ; Check it by default
  ${NSD_AddStyle} $RB_Ar3 ${WS_GROUP}

  ; RadioButton 4    
  ${NSD_CreateRadioButton} 3% 66u 90% 10u "Try to automatically download and install a &JRE during the setup process."
  Pop $RB_Ar4            
  ${NSD_SetState} $RB_Ar4 $RB_Ar4_State
  ;${NSD_Uncheck} $RB_Ar4    ; Uncheck it by default
  
  ; RadioButton 5    
  ${NSD_CreateRadioButton} 3% 81u 90% 10u "&Skip this step and proceed without JRE installation."
  Pop $RB_Ar5            
  ${NSD_SetState} $RB_Ar5 $RB_Ar5_State
  ;${NSD_Uncheck} $RB_Ar5    ; Uncheck it by default
    
  goto ShowDialog

ShowDialog:

  nsDialogs::Show

exit:


  pop $2
  pop $1
  pop $0

FunctionEnd

Function CUSTOM_PAGE_JREINFOLeave
   ${NSD_GetState} $RB_Ar3 $RB_Ar3_State
   ${NSD_GetState} $RB_Ar4 $RB_Ar4_State
   ${NSD_GetState} $RB_Ar5 $RB_Ar5_State
   
   ${If} $RB_Ar3_State == 1
    HideWindow
    MessageBox MB_ICONEXCLAMATION|MB_OKCANCEL "You will be redirected to JRE download page. After you completed the JRE installation, you need to relaunch the installation wizard."  IDCANCEL jre_download_page_cancel
    ${OpenURL} "${JRE_DOWNLOAD}"
    Quit
    jre_download_page_cancel:
    ShowWindow $HWNDPARENT ${SW_SHOW}
    Abort
   ${EndIf} 
FunctionEnd

; Checks to ensure that the installed version of the JRE (if any) is at least that of
; the JRE_VERSION variable.  The JRE will be downloaded and installed if necessary
; The full path of java.exe will be returned on the stack

var jre_install_cmd

Function DownloadAndInstallJREIfNecessary
  Push $0
  Push $1
  
  DetailPrint "Detecting JRE Version"
  Push "${JRE_VERSION}"
  Call DetectJRE
  Pop $0	; Get return value from stack
  Pop $1	; get JRE path (or error message)
  DetailPrint "JRE Version detection completed ($1)"


  strcmp $0 "OK" End downloadJRE

downloadJRE:
  ${If} $RB_Ar5_State == 1
    DetailPrint "Skipping JRE download..."
    goto End
  ${EndIf} 

  DetailPrint "About to download JRE from ${JRE_INSTALLER}"
  Inetc::get "${JRE_INSTALLER}" "$TEMP\jre_Setup.exe" /END
  Pop $0 # return value = exit code, "OK" if OK
  DetailPrint "Download result = $0"

  strcmp $0 "OK" downloadsuccessful
  
  MessageBox MB_OK "There was a problem downloading the JRE installer. Please, \
                    check your Internet connection. Error: $0"
  abort
  
  
downloadsuccessful:

  DetailPrint "Launching JRE setup"
  
  !define JRE_INSTALL_CMD_SILENT '"$TEMP\jre_setup.exe" /s REBOOT=Suppress JAVAUPDATE=0 WEBSTARTICON=0 /L \"$TEMP\jre_setup.log\"'
  !define JRE_INSTALL_CMD_NORMAL '"$TEMP\jre_setup.exe" /passive REBOOT=Suppress JAVAUPDATE=0 WEBSTARTICON=0 /L \"$TEMP\jre_setup.log\"'
  
  IfSilent define_silent_command define_normal_or_silent_command
  
define_silent_command:
  DetailPrint "Executing JRE setup in silent mode"
  StrCpy $jre_install_cmd '${JRE_INSTALL_CMD_SILENT}'
  goto execute_command
  
define_normal_or_silent_command:  
    
  !ifdef FORCE_JRE_SILENT_INSTALL  
    DetailPrint "Executing JRE setup in silent mode"
    StrCpy $jre_install_cmd '${JRE_INSTALL_CMD_SILENT}'
  !else
    DetailPrint "Executing JRE setup in not silent mode"
    StrCpy $jre_install_cmd '${JRE_INSTALL_CMD_NORMAL}'
  !endif
  
execute_command:

  ExecWait $jre_install_cmd $0
  
  ; jreSetupFinished:
  DetailPrint "JRE Setup finished"
  Delete "$TEMP\jre_setup.exe"
  StrCmp $0 "0" InstallVerif 0
  Push "The JRE setup has been abnormally interrupted - return code $0"
  Goto ExitInstallJRE
 
InstallVerif:
  DetailPrint "Checking the JRE Setup's outcome"
  Push "${JRE_VERSION}"
  Call DetectJRE  
  Pop $0	  ; DetectJRE's return value
  Pop $1	  ; JRE home (or error message if compatible JRE could not be found)
  StrCmp $0 "OK" 0 JavaVerStillWrong
  Goto JREPathStorage
JavaVerStillWrong:
  Push "Unable to find JRE with version above ${JRE_VERSION}, \
        even when JRE setup launching was successful. \
        Did you cancel the JRE installation process ?. \
        If not, please try to start again and skip the JRE installation step.$\n$\n\
        Error status : $1"
  Goto ExitInstallJRE
 
JREPathStorage:
  push $0	; => rv, r1, r0
  exch 2	; => r0, r1, rv
  exch		; => r1, r0, rv
  Goto End
 
ExitInstallJRE:
  Pop $1
  MessageBox MB_OK "Unable to install Java - Setup will be aborted$\n$\n$1"
  Pop $1 	; Restore $1
  Pop $0 	; Restore $0
  Abort
End:
  Pop $1	; Restore $1
  Pop $0	; Restore $0

FunctionEnd


; DetectJRE
; Inputs:  Minimum JRE version requested on stack (this value will be overwritten)
; Outputs: Returns two values on the stack: 
;     First value (rv0):  0 - JRE not found. -1 - JRE found but too old. OK - JRE found and meets version criteria
;     Second value (rv1):  Problem description.  Otherwise - Path to the java runtime (javaw.exe will be at .\bin\java.exe relative to this path)
 
Function DetectJRE

  Exch $0	; Get version requested  
		; Now the previous value of $0 is on the stack, and the asked for version of JDK is in $0
  Push $1	; $1 = Java version string (ie 1.5.0)
  Push $2	; $2 = Javahome
  Push $3	; $3 = holds the version comparison result

		; stack is now:  r3, r2, r1, r0

  ; first, check for an installed JRE
  ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
  StrCmp $1 "" DetectTry2
  ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$1" "JavaHome"
  StrCmp $2 "" DetectTry2
  Goto GetJRE
 
DetectTry2:
  ; next, check for an installed JDK
  ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
  StrCmp $1 "" NoFound
  ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Development Kit\$1" "JavaHome"
  StrCmp $2 "" NoFound
 
GetJRE:
  ; ok, we found a JRE, let's compare it's version and make sure it is new enough
; $0 = version requested. $1 = version found. $2 = javaHome
  IfFileExists "$2\bin\java.exe" 0 NoFound

  ${VersionCompare} $0 $1 $3 ; $3 now contains the result of the comparison
  DetailPrint "Comparing version $0 to $1 results in $3"
  intcmp $3 1 FoundOld
  goto FoundNew
 
NoFound:
  ; No JRE found
  strcpy $0 "0"
  strcpy $1 "No JRE Found"
  Goto DetectJREEnd
 
FoundOld:
  ; An old JRE was found
  strcpy $0 "-1"
  strcpy $1 "Old JRE found"
  Goto DetectJREEnd  
FoundNew:
  ; A suitable JRE was found 
  strcpy $0 "OK"
  strcpy $1 $2
  Goto DetectJREEnd

DetectJREEnd:
	; at this stage, $0 contains rv0, $1 contains rv1
	; now, straighten the stack out and recover original values for r0, r1, r2 and r3
	; there are two return values: rv0 = -1, 0, OK and rv1 = JRE path or problem description
	; stack looks like this: 
          ;    r3,r2,r1,r0
	Pop $3	; => r2,r1,r0
	Pop $2	; => r1,r0
	Push $0 ; => rv0, r1, r0
	Exch 2	; => r0, r1, rv0
	Push $1 ; => rv1, r0, r1, rv0
	Exch 2	; => r1, r0, rv1, rv0
	Pop $1	; => r0, rv1, rv0
	Pop $0	; => rv1, rv0	
	Exch	  ; => rv0, rv1
FunctionEnd
!endif # JRE_SETUP_INCLUDED

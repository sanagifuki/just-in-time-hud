Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1Path = fso.BuildPath(scriptDir, "JustInTimeHud.ps1")

command = "pwsh.exe -ExecutionPolicy Bypass -File """ & ps1Path & """"
shell.Run command, 0, False

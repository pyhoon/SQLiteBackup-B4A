﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Macros
#Macro: Title, Export, ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip
#Macro: Title, GitHub Desktop, ide://run?file=%COMSPEC%&Args=/c&Args=github&Args=..\..\
#End Region

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private	SQL1 As SQL
	Private FileHandler1 As FileHandler
	Private LblMessage As B4XView
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("1")
	FileHandler1.Initialize
	If File.Exists(File.DirInternal, "data.db") = False Then
		File.Copy(File.DirAssets, "sample.db", File.DirInternal, "data.db")
	End If
	SQL1.Initialize(File.DirInternal, "data.db", False)
End Sub

Private Sub BtnBackup_Click
	DateTime.DateFormat = "yyyy-MM-dd HH:mm:ss"
	SQL1.ExecNonQuery2("UPDATE info SET modified = ?", Array As String(DateTime.Date(DateTime.Now)))
	
	If File.Exists(File.DirInternal, "backup.db") Then File.Delete(File.DirInternal, "backup.db")
	Dim BackupFilePath As String = File.Combine(File.DirInternal, "backup.db")
	SQL1.ExecNonQuery2("VACUUM INTO ?", Array As String(BackupFilePath))
	
	DateTime.DateFormat = "yyyyMMddHHmmss"
	Dim timestamps As String = DateTime.Date(DateTime.Now)
	Dim sf As Object = FileHandler1.SaveAs(File.OpenInput(File.DirInternal, "backup.db"), "application/vnd.sqlite3", timestamps & ".db")
	Wait For (sf) Complete (Success As Boolean)
	If Success Then LblMessage.Text = "File saved successfully" Else LblMessage.Text = "File failed to save"
End Sub
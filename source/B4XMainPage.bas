B4A=true
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
	Private TxtText As B4XView
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("1")
	B4XPages.SetTitle(Me, "Backup & Restore")
	FileHandler1.Initialize
	If File.Exists(File.DirInternal, "data.db") = False Then
		File.Copy(File.DirAssets, "sample.db", File.DirInternal, "data.db")
	End If
	SQL1.Initialize(File.DirInternal, "data.db", False)
	ReadTextFromDB
End Sub

Private Sub BtnUpdate_Click
	SQL1.ExecNonQuery2("UPDATE info SET text = ?, modified = datetime('now')", Array As String(TxtText.Text.Trim))
	ReadTextFromDB
End Sub

Private Sub BtnBackup_Click
	If File.Exists(File.DirInternal, "backup.db") Then
		File.Delete(File.DirInternal, "backup.db")
	End If
	Dim BackupFilePath As String = File.Combine(File.DirInternal, "backup.db")
	SQL1.ExecNonQuery2("VACUUM INTO ?", Array As String(BackupFilePath))
	
	DateTime.DateFormat = "yyyyMMddHHmmss"
	Dim timestamps As String = DateTime.Date(DateTime.Now)
	Dim sf As Object = FileHandler1.SaveAs(File.OpenInput(File.DirInternal, "backup.db"), "application/vnd.sqlite3", timestamps & ".db")
	Wait For (sf) Complete (Success As Boolean)
	If Success Then LblMessage.Text = "File saved successfully" Else LblMessage.Text = "File failed to save"
End Sub

Private Sub BtnRestore_Click
	Wait For (FileHandler1.Load) Complete (Result As LoadResult)
	HandleLoadResult(Result)
End Sub

Private Sub HandleLoadResult (Result As LoadResult)
	If Result.Success Then
		Try
			'If File.Exists(Result.Dir, Result.FileName) = False Then
			'	MsgboxAsync(Result.FileName & " not found", "Restore Data")
			'	Return
			'End If
			SQL1.Close
			If File.Exists(File.DirInternal, "data.db") Then
				File.Delete(File.DirInternal, "data.db")
			End If
			File.Copy(Result.Dir, Result.FileName, File.DirInternal, "data.db")
			LblMessage.Text = "File restored successfully"
			SQL1.Initialize(File.DirInternal, "data.db", False)
			ReadTextFromDB
		Catch
			LblMessage.Text = "File failed to restore"
			Log(LastException)
		End Try
	End If
End Sub

Private Sub ReadTextFromDB
	Dim res As ResultSet = SQL1.ExecQuery("SELECT * FROM info")
	Do While res.NextRow
		TxtText.Text = res.GetString("text")
		LblMessage.Text = "Data modified on " & res.GetString("modified")
	Loop
	res.Close
End Sub
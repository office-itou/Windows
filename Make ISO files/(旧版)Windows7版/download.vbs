	Option Explicit

	Dim objWshNamed, strFuncName, strTimeZone
	Set objWshNamed = WScript.Arguments.Named
	strFuncName = objWshNamed.Item("function")
	strTimeZone = objWshNamed.Item("timezone")
	Set objWshNamed = Nothing

	If strFuncName = "" Then
		WScript.Echo "/function:関数名 をセットして下さい。"
	Else
		Dim objFunction
		Set objFunction = GetRef(strFuncName)
		If Err.Number = 0 Then
			Call objFunction()
		Else
			WScript.Echo strFuncName & " 関数を取得できませんでした。"
		End If
		Set objFunction = Nothing
	End If

	WScript.Quit

'******************************************************************************
'   機能概要    :   fncDownload
'                   指定したリストファイルのダウンロードを実行する。
'
'   入出力 I/F
'       INPUT   :                   なし
'       OUTPUT  :                   なし
'******************************************************************************
Sub fncDownload()
	Dim objWshNamed, strBinaryFolder, strListFileName, strUpdateFolder
	Set objWshNamed = WScript.Arguments.Named
	strBinaryFolder = objWshNamed.Item("winsppm")
	strListFileName = objWshNamed.Item("list")
	strUpdateFolder = objWshNamed.Item("update")
	Set objWshNamed = Nothing

	If strBinaryFolder = "" Then
		WScript.Echo "/winsppm:フォルダー名 をセットして下さい。"
		Exit Sub
	End If

	If strListFileName = "" Then
		WScript.Echo "/list:ファイル名 をセットして下さい。"
		Exit Sub
	End If

	If strUpdateFolder = "" Then
		WScript.Echo "/update:フォルダー名 をセットして下さい。"
		Exit Sub
	End If

	Dim strDownloadExec, strDownloadList, strLogListFile
	strDownloadExec = fncJoinFullName(strBinaryFolder, "download.exe")
	strDownloadList = fncJoinFullName(strBinaryFolder, "download.lst")
	strLogListFile = fncJoinFullName(strBinaryFolder, "download.log")

	If fncFileExists(strDownloadExec) = False Then
		WScript.Echo "download.exe がありません。"
		Exit Sub
	End If

	If fncFileExists(strListFileName) = False Then
		WScript.Echo "リストファイルがありません。"
		Exit Sub
	End If

	'*** リストファイル準備 ***************************************************
	Dim objCnv
	Set objCnv = CreateObject("Scripting.Dictionary")
	'=== リスト情報読込 =======================================================
	Dim objGet
	Set objGet = CreateObject("Scripting.Dictionary")

	Call fncGetIniInfo(objGet, strListFileName)
	'=== リスト情報変換 =======================================================
	Dim strCnvSection, objKey
	'--- ヘッダー部登録 -------------------------------------------------------
	strCnvSection = "[Download]"
	Set objKey = CreateObject("Scripting.Dictionary")
	objCnv.Add strCnvSection, objKey
	Set objKey = Nothing

	objCnv.Item(strCnvSection).Add "ListVersion", "0.40"
	objCnv.Item(strCnvSection).Add "ListCount", "0"
	'--- リスト部登録 ---------------------------------------------------------
	Dim i, intCount, strGetSection, strString, strRename
	intCount = 0
	For i = 0 To objGet.Item("[LIST]").Item("COUNT") - 1
		strGetSection = "[" & objGet.Item("[LIST]").Item(CStr(i + 1)) & "]"
		strString = Right(objGet.Item(strGetSection).Item("FILE"), Len(objGet.Item(strGetSection).Item("FILE")) - InStrRev(objGet.Item(strGetSection).Item("FILE"), "/"))

		If fncSplitFileName(objGet.Item(strGetSection).Item("RENAME")) <> "" Then
			strString = fncSplitFileName(objGet.Item(strGetSection).Item("RENAME"))
		End If

		If fncSplitFolderName(objGet.Item(strGetSection).Item("RENAME")) = "" Then
			strRename = fncJoinFullName(strUpdateFolder, strString)
		Else
'			strRename = fncJoinFullName(Replace(objGet.Item(strGetSection).Item("RENAME"), "<UpdateFolder>", strUpdateFolder), strString)
			strRename = Replace(objGet.Item(strGetSection).Item("RENAME"), "<UpdateFolder>", strUpdateFolder)
		End If

		If CDbl(fncFileSize(strRename)) <> CDbl(objGet.Item(strGetSection).Item("SIZE")) Then
			strCnvSection = "[Item" & CStr(intCount) & "]"

			Set objKey = CreateObject("Scripting.Dictionary")
			objCnv.Add strCnvSection, objKey
			Set objKey = Nothing

			objCnv.Item(strCnvSection).Add "Title", objGet.Item(strGetSection).Item("TITLE")
			objCnv.Item(strCnvSection).Add "URL", objGet.Item(strGetSection).Item("FILE")
			objCnv.Item(strCnvSection).Add "File", strRename
			intCount = intCount + 1
		End If
	Next
	objCnv.Item("[Download]").Item("ListCount") = intCount
	'--- フッター部登録 -------------------------------------------------------
	strCnvSection = "[Result]"
	Set objKey = CreateObject("Scripting.Dictionary")
	objCnv.Add strCnvSection, objKey
	Set objKey = Nothing

	objCnv.Item(strCnvSection).Add "ExitCode", "1"

	Set objGet = Nothing
	'=== リスト情報書込 =======================================================
	If intCount > 0 Then
		Call fncPutIniInfo(objCnv, strDownloadList)
	End If
	Set objCnv = Nothing
	If intCount = 0 Then
		Exit Sub
	End If
	'*** 外部プログラムの起動 *************************************************
	Dim strShellExec, objShell, objExec
	strShellExec = """" & strDownloadExec & """" & " /quiet /must /keep=0 /list=" & """" & strDownloadList & """" & " /log=" & """" & strLogListFile & """"
	Set objShell = CreateObject("WScript.Shell")
	Set objExec = objShell.Exec(strShellExec)

	Do While objExec.Status = 0
		WScript.Sleep 100
	Loop

	Set objExec = Nothing
	Set objShell = Nothing
	'*** タイムスタンプの更新 *************************************************
	Dim objLog
	Set objLog = CreateObject("Scripting.Dictionary")
	Call fncGetIniInfo(objLog, strLogListFile)
	Call fncSetLastWriteTime4Log(objLog)
	Set objLog = Nothing
End Sub

'******************************************************************************
'   機能概要    :   fncGetIniInfo
'                   指定したアップデートリストファイルからリスト情報を取得する。
'
'   入出力 I/F
'       INPUT   :   objDic          取得したリスト情報
'                   strFileName     取得先アップデートリストファイル名
'       OUTPUT  :                   なし
'******************************************************************************
Function fncGetIniInfo(objDic, strFileName)
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")

	fncGetIniInfo = False

	If objFSO.FileExists(strFileName) = True Then
		Set objText = objFSO.OpenTextFile(strFileName)
		objDic.RemoveAll

		Dim objText, strLine, aryElements, strKey, objKey, strString, strSection
		Do While Not objText.AtEndOfStream
			strLine = Trim(objText.ReadLine)
			If Left(strLine, 1) = "[" And Right(strLine, 1) = "]" Then
				strSection = strLine
				Set objKey = CreateObject("Scripting.Dictionary")
				objDic.Add strSection, objKey
				Set objKey = Nothing
			Else
				If objDic.Exists(strSection) = True Then
					aryElements = Split(strLine, "=")
					If UBound(aryElements) >= 0 Then
						Set objKey = objDic.Item(strSection)
						strKey = Trim(aryElements(0))
						strString = Trim(Mid(Join(aryElements, "="), Len(aryElements(0)) + 2))
						objKey.Add strKey, strString
						Set objDic.Item(strSection) = objKey
						Set objKey = Nothing
					End If
				End If
			End If
		Loop

		objText.Close
		Set objText = Nothing

		fncGetIniInfo = True
	End If

	Set objFSO = Nothing
End Function

'******************************************************************************
'   機能概要    :   fncPutIniInfo
'                   指定したダウンロードリストファイルへリスト情報を登録する。
'
'   入出力 I/F
'       INPUT   :   objDic          登録するリスト情報
'                   strFileName     登録先ダウンロードリストファイル名
'       OUTPUT  :                   なし
'******************************************************************************
Sub fncPutIniInfo(objDic, strFileName)
	Dim objFSO, objText
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objText = objFSO.CreateTextFile(strFileName)

	Dim strSection, strKey
	For Each strSection In objDic.Keys
		objText.WriteLine(strSection)
		For Each strKey In objDic.Item(strSection).Keys
			objText.WriteLine(strKey & " = " & objDic.Item(strSection).Item(strKey))
		Next
		objText.WriteLine("")
	Next

	objText.Close
	Set objText = Nothing
	Set objFSO = Nothing
End Sub

'******************************************************************************
'   機能概要    :   fncSetLastWriteTime4Log
'                   指定したログ情報から取得したファイル名の更新日時を設定する。
'
'   入出力 I/F
'       INPUT   :   objDic          取得したログ情報
'       OUTPUT  :                   なし
'******************************************************************************
Sub fncSetLastWriteTime4Log(objDic)
	Dim i, strDateTime, strSection, objKey, aryElements
	For i = 0 To objDic.Item("[Result]").Item("ItemCount") - 1
		strSection = "[Item" & CStr(i) & "]"
		If objDic.Exists(strSection) = True Then
			Set objKey = objDic.Item(strSection)
			If objKey.Item("StatusCode") = "200" And objKey.Item("Result") = "1" Then
				'objKey.Item("FileName")
				'objKey.Item("StatusCode")
				'objKey.Item("ContentLen")
				'objKey.Item("LastModified")
				'objKey.Item("FileSize")
				'objKey.Item("TransferRate")
				'objKey.Item("Result")
				aryElements = Split(objKey.Item("LastModified"), " ")
				If UBound(aryElements) = 2 Then
					strDateTime = aryElements(0) & " " & aryElements(1)
					If UCase(aryElements(2)) = "UTC" And IsDate(strDateTime) = True Then
						If Ucase(strTimeZone) = "UTC" Then
							Call fncSetLastWriteTime(objKey.Item("FileName"), strDateTime)
						Else
							Call fncSetLastWriteTime(objKey.Item("FileName"), fncGetLocalTime(CDate(strDateTime)))
						End If
					Else
						WScript.Echo "Error : " & objKey.Item("LastModified") & " : " & objKey.Item("FileName")
					End If
				End If
			Else
				WScript.Echo "Error: " & objKey.Item("FileName")
			End If
			Set objKey = Nothing
		End If
	Next
End Sub

'******************************************************************************
'   機能概要    :   fncGetLocalTime
'                   指定したUTC日時からローカル日時を取得する。
'
'   入出力 I/F
'       INPUT   :   strUTC          UTC日時
'       OUTPUT  :                   変換した日時
'******************************************************************************
Function fncGetLocalTime(strUTC)
	Const strRegistry = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias"

	fncGetLocalTime = Null

	If IsDate(strUTC) = True Then
		Dim objShell
		Set objShell = CreateObject("WScript.Shell")
		fncGetLocalTime = DateAdd("n", -(objShell.RegRead(strRegistry)), CDate(strUTC))
		Set objShell = Nothing
	End If
End Function

'******************************************************************************
'   機能概要    :   fncSetLastWriteTime
'                   指定したファイルの更新日時を設定する。
'
'   入出力 I/F
'       INPUT   :   strFileName     設定するファイル名
'                   strDateTime     設定する更新日時
'       OUTPUT  :                   実行結果
'******************************************************************************
Function fncSetLastWriteTime(strTargetFileName, strDateTime)
	fncSetLastWriteTime = False

	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")

	If objFSO.FileExists(strTargetFileName) = True Then
		Dim strFolderName, strFileName
		strFolderName = objFSO.GetParentFolderName(strTargetFileName)
		strFileName = objFSO.GetFileName(strTargetFileName)

		Dim objShell, objFolder, objFile
		Set objShell = CreateObject("Shell.Application")
		Set objFolder = objShell.NameSpace(strFolderName)
		Set objFile = objFolder.ParseName(strFileName)

		objFile.ModifyDate = CDate(strDateTime)

		If Err.Number = 0 Then
			fncSetLastWriteTime = True
		End If

		Set objFile = Nothing
		Set objFolder = Nothing
		Set objShell = Nothing
	End If

	Set objFSO = Nothing
End Function

'******************************************************************************
'   機能概要    :   fnvRemoveDoubleQuotation
'                   文字列から両端のダブルクォーテーションを削除する。
'
'   入出力 I/F
'       INPUT   :   strString       入力文字列
'       OUTPUT  :                   出力文字列
'******************************************************************************
Function fnvRemoveDoubleQuotation(strString)
	If Left(strString, 1) = """ And Right(strString, 1) = """ Then
		fnvRemoveDoubleQuotation = Mid(strString, 2, Len(strString) - 2)
	Else
		fnvRemoveDoubleQuotation = strString
	End If
End Function

'******************************************************************************
'   機能概要    :   fncSplitFolderName
'                   文字列からフォルダー名を取得する。
'
'   入出力 I/F
'       INPUT   :   strFullName     入力文字列
'       OUTPUT  :                   出力文字列
'******************************************************************************
Function fncSplitFolderName(strFullName)
	Dim strString
	strString = fnvRemoveDoubleQuotation(strFullName)
	fncSplitFolderName = Left(strString, InStrRev(strString, "\"))
End Function

'******************************************************************************
'   機能概要    :   fncSplitFileName
'                   文字列からファイル名を取得する。
'
'   入出力 I/F
'       INPUT   :   strFullName     入力文字列
'       OUTPUT  :                   出力文字列
'******************************************************************************
Function fncSplitFileName(strFullName)
	Dim strString
	strString = fnvRemoveDoubleQuotation(strFullName)
	fncSplitFileName = Right(strString, Len(strString) - InStrRev(strString, "\"))
End Function

'******************************************************************************
'   機能概要    :   fncJoinFullName
'                   フォルダー名とファイル名を合体させフルパス名を取得する。
'
'   入出力 I/F
'       INPUT   :   strFolderName   フォルダー名
'                   strFileName     ファイル名
'       OUTPUT  :                   出力文字列
'******************************************************************************
Function fncJoinFullName(strFolderName, strFileName)
	Dim strStringFolder, strStringFile

	strStringFolder = fnvRemoveDoubleQuotation(strFolderName)
	strStringFile = fnvRemoveDoubleQuotation(strFileName)

	If Right(strStringFolder, 1) = "\" Then
		strStringFolder = Left(strStringFolder, Len(strStringFolder) - 1)
	End If

	If Left(strStringFile, 1) = "\" Then
		strStringFile = Right(strStringFile, Len(strStringFile) - 1)
	End If

	If strStringFolder = "" Or strStringFile = "" Then
		fncJoinFullName = ""
	Else
		fncJoinFullName = strStringFolder & "\" & strStringFile
	End If
End Function

'******************************************************************************
'   機能概要    :   fncFileExists
'                   指定したファイルが存在するか確認する。
'
'   入出力 I/F
'       INPUT   :   strFileName     ファイル名
'       OUTPUT  :                   確認結果
'******************************************************************************
Function fncFileExists(strFileName)
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	fncFileExists = objFSO.FileExists(strFileName)
	Set objFSO = Nothing
End Function

'******************************************************************************
'   機能概要    :   fncFolderExists
'                   指定したフォルダーが存在するか確認する。
'
'   入出力 I/F
'       INPUT   :   strFolderName   フォルダー名
'       OUTPUT  :                   確認結果
'******************************************************************************
Function fncFolderExists(strFileName)
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	fncFolderExists = objFSO.FolderExists(strFileName)
	Set objFSO = Nothing
End Function

'******************************************************************************
'   機能概要    :   fncFileSize
'                   指定したファイルのサイズを取得する。
'
'   入出力 I/F
'       INPUT   :   strFileName     ファイル名
'       OUTPUT  :                   取得結果(-1:ファイルがない / ≧0:ファイルサイズ)
'******************************************************************************
Function fncFileSize(strFileName)
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	If objFSO.FileExists(strFileName) = True Then
		Dim objFile
		Set objFile = objFSO.GetFile(strFileName)
		fncFileSize = objFile.Size
		Set objFile = Nothing
	Else
		fncFileSize = -1
	End If
	Set objFSO = Nothing
End Function

'=== EOF ======================================================================

	Option Explicit

	Dim objWshNamed, strFuncName, strTimeZone
	Set objWshNamed = WScript.Arguments.Named
	strFuncName = objWshNamed.Item("function")
	strTimeZone = objWshNamed.Item("timezone")
	Set objWshNamed = Nothing

	If strFuncName = "" Then
		WScript.Echo "/function:�֐��� ���Z�b�g���ĉ������B"
	Else
		Dim objFunction
		Set objFunction = GetRef(strFuncName)
		If Err.Number = 0 Then
			Call objFunction()
		Else
			WScript.Echo strFuncName & " �֐����擾�ł��܂���ł����B"
		End If
		Set objFunction = Nothing
	End If

	WScript.Quit

'******************************************************************************
'   �@�\�T�v    :   fncDownload
'                   �w�肵�����X�g�t�@�C���̃_�E�����[�h�����s����B
'
'   ���o�� I/F
'       INPUT   :                   �Ȃ�
'       OUTPUT  :                   �Ȃ�
'******************************************************************************
Sub fncDownload()
	Dim objWshNamed, strBinaryFolder, strListFileName, strUpdateFolder
	Set objWshNamed = WScript.Arguments.Named
	strBinaryFolder = objWshNamed.Item("winsppm")
	strListFileName = objWshNamed.Item("list")
	strUpdateFolder = objWshNamed.Item("update")
	Set objWshNamed = Nothing

	If strBinaryFolder = "" Then
		WScript.Echo "/winsppm:�t�H���_�[�� ���Z�b�g���ĉ������B"
		Exit Sub
	End If

	If strListFileName = "" Then
		WScript.Echo "/list:�t�@�C���� ���Z�b�g���ĉ������B"
		Exit Sub
	End If

	If strUpdateFolder = "" Then
		WScript.Echo "/update:�t�H���_�[�� ���Z�b�g���ĉ������B"
		Exit Sub
	End If

	Dim strDownloadExec, strDownloadList, strLogListFile
	strDownloadExec = fncJoinFullName(strBinaryFolder, "download.exe")
	strDownloadList = fncJoinFullName(strBinaryFolder, "download.lst")
	strLogListFile = fncJoinFullName(strBinaryFolder, "download.log")

	If fncFileExists(strDownloadExec) = False Then
		WScript.Echo "download.exe ������܂���B"
		Exit Sub
	End If

	If fncFileExists(strListFileName) = False Then
		WScript.Echo "���X�g�t�@�C��������܂���B"
		Exit Sub
	End If

	'*** ���X�g�t�@�C������ ***************************************************
	Dim objCnv
	Set objCnv = CreateObject("Scripting.Dictionary")
	'=== ���X�g���Ǎ� =======================================================
	Dim objGet
	Set objGet = CreateObject("Scripting.Dictionary")

	Call fncGetIniInfo(objGet, strListFileName)
	'=== ���X�g���ϊ� =======================================================
	Dim strCnvSection, objKey
	'--- �w�b�_�[���o�^ -------------------------------------------------------
	strCnvSection = "[Download]"
	Set objKey = CreateObject("Scripting.Dictionary")
	objCnv.Add strCnvSection, objKey
	Set objKey = Nothing

	objCnv.Item(strCnvSection).Add "ListVersion", "0.40"
	objCnv.Item(strCnvSection).Add "ListCount", "0"
	'--- ���X�g���o�^ ---------------------------------------------------------
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
	'--- �t�b�^�[���o�^ -------------------------------------------------------
	strCnvSection = "[Result]"
	Set objKey = CreateObject("Scripting.Dictionary")
	objCnv.Add strCnvSection, objKey
	Set objKey = Nothing

	objCnv.Item(strCnvSection).Add "ExitCode", "1"

	Set objGet = Nothing
	'=== ���X�g��񏑍� =======================================================
	If intCount > 0 Then
		Call fncPutIniInfo(objCnv, strDownloadList)
	End If
	Set objCnv = Nothing
	If intCount = 0 Then
		Exit Sub
	End If
	'*** �O���v���O�����̋N�� *************************************************
	Dim strShellExec, objShell, objExec
	strShellExec = """" & strDownloadExec & """" & " /quiet /must /keep=0 /list=" & """" & strDownloadList & """" & " /log=" & """" & strLogListFile & """"
	Set objShell = CreateObject("WScript.Shell")
	Set objExec = objShell.Exec(strShellExec)

	Do While objExec.Status = 0
		WScript.Sleep 100
	Loop

	Set objExec = Nothing
	Set objShell = Nothing
	'*** �^�C���X�^���v�̍X�V *************************************************
	Dim objLog
	Set objLog = CreateObject("Scripting.Dictionary")
	Call fncGetIniInfo(objLog, strLogListFile)
	Call fncSetLastWriteTime4Log(objLog)
	Set objLog = Nothing
End Sub

'******************************************************************************
'   �@�\�T�v    :   fncGetIniInfo
'                   �w�肵���A�b�v�f�[�g���X�g�t�@�C�����烊�X�g�����擾����B
'
'   ���o�� I/F
'       INPUT   :   objDic          �擾�������X�g���
'                   strFileName     �擾��A�b�v�f�[�g���X�g�t�@�C����
'       OUTPUT  :                   �Ȃ�
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
'   �@�\�T�v    :   fncPutIniInfo
'                   �w�肵���_�E�����[�h���X�g�t�@�C���փ��X�g����o�^����B
'
'   ���o�� I/F
'       INPUT   :   objDic          �o�^���郊�X�g���
'                   strFileName     �o�^��_�E�����[�h���X�g�t�@�C����
'       OUTPUT  :                   �Ȃ�
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
'   �@�\�T�v    :   fncSetLastWriteTime4Log
'                   �w�肵�����O��񂩂�擾�����t�@�C�����̍X�V������ݒ肷��B
'
'   ���o�� I/F
'       INPUT   :   objDic          �擾�������O���
'       OUTPUT  :                   �Ȃ�
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
'   �@�\�T�v    :   fncGetLocalTime
'                   �w�肵��UTC�������烍�[�J���������擾����B
'
'   ���o�� I/F
'       INPUT   :   strUTC          UTC����
'       OUTPUT  :                   �ϊ���������
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
'   �@�\�T�v    :   fncSetLastWriteTime
'                   �w�肵���t�@�C���̍X�V������ݒ肷��B
'
'   ���o�� I/F
'       INPUT   :   strFileName     �ݒ肷��t�@�C����
'                   strDateTime     �ݒ肷��X�V����
'       OUTPUT  :                   ���s����
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
'   �@�\�T�v    :   fnvRemoveDoubleQuotation
'                   �����񂩂痼�[�̃_�u���N�H�[�e�[�V�������폜����B
'
'   ���o�� I/F
'       INPUT   :   strString       ���͕�����
'       OUTPUT  :                   �o�͕�����
'******************************************************************************
Function fnvRemoveDoubleQuotation(strString)
	If Left(strString, 1) = """ And Right(strString, 1) = """ Then
		fnvRemoveDoubleQuotation = Mid(strString, 2, Len(strString) - 2)
	Else
		fnvRemoveDoubleQuotation = strString
	End If
End Function

'******************************************************************************
'   �@�\�T�v    :   fncSplitFolderName
'                   �����񂩂�t�H���_�[�����擾����B
'
'   ���o�� I/F
'       INPUT   :   strFullName     ���͕�����
'       OUTPUT  :                   �o�͕�����
'******************************************************************************
Function fncSplitFolderName(strFullName)
	Dim strString
	strString = fnvRemoveDoubleQuotation(strFullName)
	fncSplitFolderName = Left(strString, InStrRev(strString, "\"))
End Function

'******************************************************************************
'   �@�\�T�v    :   fncSplitFileName
'                   �����񂩂�t�@�C�������擾����B
'
'   ���o�� I/F
'       INPUT   :   strFullName     ���͕�����
'       OUTPUT  :                   �o�͕�����
'******************************************************************************
Function fncSplitFileName(strFullName)
	Dim strString
	strString = fnvRemoveDoubleQuotation(strFullName)
	fncSplitFileName = Right(strString, Len(strString) - InStrRev(strString, "\"))
End Function

'******************************************************************************
'   �@�\�T�v    :   fncJoinFullName
'                   �t�H���_�[���ƃt�@�C���������̂����t���p�X�����擾����B
'
'   ���o�� I/F
'       INPUT   :   strFolderName   �t�H���_�[��
'                   strFileName     �t�@�C����
'       OUTPUT  :                   �o�͕�����
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
'   �@�\�T�v    :   fncFileExists
'                   �w�肵���t�@�C�������݂��邩�m�F����B
'
'   ���o�� I/F
'       INPUT   :   strFileName     �t�@�C����
'       OUTPUT  :                   �m�F����
'******************************************************************************
Function fncFileExists(strFileName)
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	fncFileExists = objFSO.FileExists(strFileName)
	Set objFSO = Nothing
End Function

'******************************************************************************
'   �@�\�T�v    :   fncFolderExists
'                   �w�肵���t�H���_�[�����݂��邩�m�F����B
'
'   ���o�� I/F
'       INPUT   :   strFolderName   �t�H���_�[��
'       OUTPUT  :                   �m�F����
'******************************************************************************
Function fncFolderExists(strFileName)
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	fncFolderExists = objFSO.FolderExists(strFileName)
	Set objFSO = Nothing
End Function

'******************************************************************************
'   �@�\�T�v    :   fncFileSize
'                   �w�肵���t�@�C���̃T�C�Y���擾����B
'
'   ���o�� I/F
'       INPUT   :   strFileName     �t�@�C����
'       OUTPUT  :                   �擾����(-1:�t�@�C�����Ȃ� / ��0:�t�@�C���T�C�Y)
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

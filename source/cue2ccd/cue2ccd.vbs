Rem ---------------------------------------------------------------------------
Rem cue→ccd変換
Rem
Rem CScript cue2ccd.vbs "変換先フォルダー名"
Rem 変換先フォルダーとそのサブフォルダーのcueファイルをccdファイルに変換する。
Rem Virtual CloneDrive v5.5.2.0 でマウントできる事を確認。
Rem ---------------------------------------------------------------------------
Option Explicit

    Dim I

    Dim objArguments
    Set objArguments = WScript.Arguments

    For I = 0 To objArguments.Count - 1
        MakeStartFoldersCCDFiles objArguments(I)
    Next

    Set objArguments = Nothing

Rem ---------------------------------------------------------------------------
Sub MakeStartFoldersCCDFiles(objStartFolder)
    Dim objFSO
    Dim objFolder
    Dim colFiles
    Dim objFile

Rem ---------------------------------------------------------------------------
    Set objFSO = CreateObject("Scripting.FileSystemObject")

    Set objFolder = objFSO.GetFolder(objStartFolder)
    Set colFiles = objFolder.Files
    For Each objFile in colFiles
        If UCase(objFSO.GetExtensionName(objFile.Name)) = "CUE" Then
            MakeCCDFile objFolder.Path & "\" & objFile.Name
        End If
    Next
    MakeSubFoldersCCDFiles objFSO.GetFolder(objStartFolder)

    Set objFSO = Nothing
End Sub

Rem ---------------------------------------------------------------------------
Sub MakeSubFoldersCCDFiles(Folder)
    Dim Subfolder
    Dim objFSO
    Dim objFolder
    Dim colFiles
    Dim objFile

    Set objFSO = CreateObject("Scripting.FileSystemObject")

    Set objFolder = objFSO.GetFolder(Folder)
    For Each Subfolder in Folder.SubFolders
        Set objFolder = objFSO.GetFolder(Subfolder.Path)
        Set colFiles = objFolder.Files
        For Each objFile in colFiles
            If UCase(objFSO.GetExtensionName(objFile.Name)) = "CUE" Then
                MakeCCDFile Subfolder.Path & "\" & objFile.Name
            End If
        Next
        MakeSubFoldersCCDFiles Subfolder
    Next

    Set objFSO = Nothing
End Sub

Rem ---------------------------------------------------------------------------
Sub MakeCCDFile(File)
    Dim InpFileName                     Rem 入力ファイル名 (cue)
    Dim InpLine                         Rem 入力データー
    Dim InpCount                        Rem 入力カウンタ
    Dim InpArray                        Rem 入力配列データー

    Dim OutFileName                     Rem 出力ファイル名 (ccd)
    Dim OutLine                         Rem 出力データー
    Dim OutArray                        Rem 出力配列データー

    Dim ImgFileName                     Rem イメージ・ファイル名
    Dim ImgFileSize                     Rem イメージ・ファイル・サイズ

    Dim TrackNumber                     Rem トラック番号
    Dim TrackData(4, 103)               Rem トラック・データー (01 AUDIO 01 00:00:00)

    Dim PMin
    Dim PSec
    Dim PFrame
    Dim PLBA

    Dim Ret
    Dim I
    Dim J
    Dim K

    Dim objFso
    Dim objFile

    Wscript.Echo File

    InpFileName = File
    OutFileName = Replace(InpFileName, ".cue", ".ccd")
    ImgFileName = Replace(InpFileName, ".cue", ".img")

Rem --- get image file size ---------------------------------------------------
    Set objFso = CreateObject("Scripting.FileSystemObject")
    If objFso.FileExists(ImgFileName) Then
        Set objFile = objFso.GetFile(ImgFileName)
        ImgFileSize = objFile.Size
        Set objFile = Nothing
    Else
        Set objFso = Nothing
        Set objArguments = Nothing
        Ret = MsgBox("not exist: " & ImgFileName, vbOKOnly)
        WScript.Quit -1
    End If
    Set objFso = Nothing

Rem --- read .cue file --------------------------------------------------------
    With CreateObject("ADODB.Stream")
        .Charset = "SJIS"
        .LineSeparator = 10
        .Open
        .LoadFromFile InpFileName
        Do Until .EOS
            InpLine = Trim(.ReadText(-2))
            InpArray = Split(InpLine, " ")
            If InpArray(0) = "FILE" Then
                InpCount = 0
                TrackNumber = 0
            ElseIf InpArray(0) = "TRACK" Then
                TrackNumber = CInt(InpArray(1))
                TrackData(0, TrackNumber) = InpArray(1)
                TrackData(1, TrackNumber) = InpArray(2)
            ElseIf InpArray(0) = "INDEX" Then
                TrackData(2, TrackNumber) = InpArray(1)
                TrackData(3, TrackNumber) = InpArray(2)
                InpCount = InpCount + 1
            End If
        Loop
        .Close
    End With

Rem --- write .ccd file -------------------------------------------------------
    With CreateObject("ADODB.Stream")
        .Charset = "SJIS"
        .Open
        .WriteText "[CloneCD]", 1
        .WriteText "Version=3", 1
        .WriteText "", 1
        .WriteText "[Disc]", 1
        .WriteText "TocEntries=" & (TrackNumber + 3),1
        .WriteText "Sessions=1", 1
        .WriteText "DataTracksScrambled=0", 1
        .WriteText "CDTextLength=0", 1
        .WriteText "", 1
        .WriteText "[Session 1]", 1
        .WriteText "PreGapMode=1", 1
        .WriteText "PreGapSubC=0", 1
        .WriteText "", 1

        PMin = 1                        Rem First Track num
        PSec = 0
        PFrame = 0
        .WriteText "[Entry 0]", 1
        .WriteText "Session=1", 1
        .WriteText "Point=0xa0", 1
        .WriteText "ADR=0x01", 1
        .WriteText "Control=0x00", 1
        .WriteText "TrackNo=0", 1
        .WriteText "AMin=0", 1
        .WriteText "ASec=0", 1
        .WriteText "AFrame=0", 1
        .WriteText "ALBA=-150", 1
        .WriteText "Zero=0", 1
        .WriteText "PMin=" & PMin, 1
        .WriteText "PSec=" & PSec, 1
        .WriteText "PFrame=" & PFrame, 1
        If PMin < 90 Then
            .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -150), 1
        Else
            .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -450150), 1
        End If
        .WriteText "", 1

        PMin = TrackNumber              Rem Last Track num
        PSec = 0
        PFrame = 0
        .WriteText "[Entry 1]", 1
        .WriteText "Session=1", 1
        .WriteText "Point=0xa1", 1
        .WriteText "ADR=0x01", 1
        .WriteText "Control=0x00", 1
        .WriteText "TrackNo=0", 1
        .WriteText "AMin=0", 1
        .WriteText "ASec=0", 1
        .WriteText "AFrame=0", 1
        .WriteText "ALBA=-150", 1
        .WriteText "Zero=0", 1
        .WriteText "PMin=" & PMin, 1
        .WriteText "PSec=" & PSec, 1
        .WriteText "PFrame=" & PFrame, 1
        If PMin < 90 Then
            .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -150), 1
        Else
            .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -450150), 1
        End If
        .WriteText "", 1

        PLBA = ImgFileSize / 2352
        If PLBA >= -150 And PLBA <= 404849 Then
            PMin = Int((PLBA + 150) / (60 * 75))
            PSec = Int((PLBA + 150 - (PMin * 60 * 75)) / 75)
            PFrame = Int(PLBA + 150 - (PMin * 60 * 75) - (PSec * 75))
        ElseIf PLBA >= -450150 And PLBA <= -151 Then
            PMin = Int((PLBA + 450150) / (60 * 75))
            PSec = Int((PLBA + 450150 - (PMin * 60 * 75)) / 75)
            PFrame = Int(PLBA + 450150 - (PMin * 60 * 75) - (PSec * 75))
        Else
            PMin = 0
            PSec = 0
            PFrame = 0
        End If
        .WriteText "[Entry 2]", 1
        .WriteText "Session=1", 1
        .WriteText "Point=0xa2", 1
        .WriteText "ADR=0x01", 1
        .WriteText "Control=0x00", 1
        .WriteText "TrackNo=0", 1
        .WriteText "AMin=0", 1
        .WriteText "ASec=0", 1
        .WriteText "AFrame=0", 1
        .WriteText "ALBA=-150", 1
        .WriteText "Zero=0", 1
        .WriteText "PMin=" & PMin, 1
        .WriteText "PSec=" & PSec, 1
        .WriteText "PFrame=" & PFrame, 1
        If PMin < 90 Then
            .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -150), 1
        Else
            .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -450150), 1
        End If
        .WriteText "", 1

        For J = 1 To TrackNumber
            OutArray = Split(TrackData(3, J), ":")
            PLBA = CInt(OutArray(0)) * 60 * 75 + CInt(OutArray(1)) * 75 + OutArray(2)
            If PLBA >= -150 And PLBA <= 404849 Then
                PMin = Int((PLBA + 150) / (60 * 75))
                PSec = Int((PLBA + 150 - (PMin * 60 * 75)) / 75)
                PFrame = Int(PLBA + 150 - (PMin * 60 * 75) - (PSec * 75))
            ElseIf PLBA >= -450150 And PLBA <= -151 Then
                PMin = Int((PLBA + 450150) / (60 * 75))
                PSec = Int((PLBA + 450150 - (PMin * 60 * 75)) / 75)
                PFrame = Int(PLBA + 450150 - (PMin * 60 * 75) - (PSec * 75))
            Else
                PMin = 0
                PSec = 0
                PFrame = 0
            End If
            .WriteText "[Entry " & (J + 2) & "]", 1
            .WriteText "Session=1", 1
            .WriteText "Point=0x" & Right("0" & LCase(Hex(J)), 2), 1
            .WriteText "ADR=0x01", 1
            .WriteText "Control=0x00", 1
            .WriteText "TrackNo=0", 1
            .WriteText "AMin=0", 1
            .WriteText "ASec=0", 1
            .WriteText "AFrame=0", 1
            .WriteText "ALBA=-150", 1
            .WriteText "Zero=0", 1
            .WriteText "PMin=" & PMin, 1
            .WriteText "PSec=" & PSec, 1
            .WriteText "PFrame=" & PFrame, 1
            If PMin < 90 Then
                .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -150), 1
            Else
                .WriteText "PLBA=" & ((PMin * 60 + PSec) * 75 + PFrame -450150), 1
            End If
            .WriteText "", 1
        Next

        For J = 1 To TrackNumber
            OutArray = Split(TrackData(3, J), ":")
            PLBA = CInt(OutArray(0)) * 60 * 75 + CInt(OutArray(1)) * 75 + OutArray(2)
            If PLBA >= -150 And PLBA <= 404849 Then
                PMin = Int((PLBA + 150) / (60 * 75))
                PSec = Int((PLBA + 150 - (PMin * 60 * 75)) / 75)
                PFrame = Int(PLBA + 150 - (PMin * 60 * 75) - (PSec * 75))
            ElseIf PLBA >= -450150 And PLBA <= -151 Then
                PMin = Int((PLBA + 450150) / (60 * 75))
                PSec = Int((PLBA + 450150 - (PMin * 60 * 75)) / 75)
                PFrame = Int(PLBA + 450150 - (PMin * 60 * 75) - (PSec * 75))
            Else
                PMin = 0
                PSec = 0
                PFrame = 0
            End If
            .WriteText "[TRACK " & J & "]", 1
            .WriteText "MODE=0", 1
            If PMin < 90 Then
                .WriteText "INDEX 1=" & ((PMin * 60 + PSec) * 75 + PFrame -150), 1
            Else
                .WriteText "INDEX 1=" & ((PMin * 60 + PSec) * 75 + PFrame -450150), 1
            End If
            .WriteText "", 1
        Next

        .SaveToFile OutFileName, 2
        .Close
    End With
End Sub

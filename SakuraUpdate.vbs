' サクラエディタ本体の更新処理
'
Option Explicit

Dim vbCrLf '= Chr(13) & Chr(10)
Dim vbLf '= Chr(10)

vbCrLf = Chr(13) & Chr(10)
vbLf = Chr(10)

Dim Tools

Sub Main()

    Dim WSC_PATH

    WSC_PATH = Plugin.GetPluginDir() & "\Tools.wsc"
    Set Tools = GetObject("script:" & WSC_PATH)
    Set Tools.Editor = Editor
    Set Tools.Plugin = Plugin
    Tools.Init
    
	Editor.ActivateWinOutput

    Tools.log "サクラエディタ本体を最新バージョンに更新します。", 0

    Dim wos, wosver, wosbit
    Tools.GetOSInfo wos, wosver, wosbit
    'Tools.log "wos=" & wos, 2
    Tools.log "wosver=" & wosver, 2
    'Tools.log "wosbit=" & wosbit, 2

    Dim wurl
    Dim wlink
    Dim wcurver
    Dim wnewver
    wcurver = Editor.ExpandParameter("$V")
    
    Select Case Plugin.GetOption("サクラエディタ", "SITEPRIORITY")
    Case "0"
        wurl = Plugin.GetOption("サクラエディタ", "GITHUBURL")
    Case "1"
        wurl = Plugin.GetOption("サクラエディタ", "SFRSSURL")
    Case "2"
        wurl = Plugin.GetOption("サクラエディタ", "CUSTOMURL")
    End Select

	If Instr(wurl,"sourceforge.net")>0 then
        wnewver = Tools.GetSFRSS(wurl, "sakura2")
	ElseIf Instr(wurl,"github.com")>0 then
        wnewver = Tools.GetGitHub(wurl)
    End If
	'wnewver = "2.3.2.0"
    If wnewver = "" then
        Tools.log "最新版を確認できませんでした。", 0
        Exit Sub
    End If
    
    Tools.log "現在のサクラエディタのバージョン:" & wcurver, 0
    Tools.log "最新のサクラエディタのバージョン:" & wnewver, 0

    if wnewver <= wcurver Then
        If Tools.WSH.Popup("すでに最新版ですが、更新しますか?", 0, "ソフトウェアの更新", 4) = 7 Then
        'If  MessageBox("すでに最新版ですが、更新しますか?",4) = 7 then 
	        Exit Sub
	    End if
    End If

    ' サクラエディタのzipダウンロード

    Dim wcmd
    Dim wzipfile
    
    wzipfile = Tools.WorkDir & "\sakura.zip"
    
	If Instr(wurl,"sourceforge.net")>0 then
	    wlink = wurl
        'Tools.log "ダウンロードリンクを確認します。", 1
        'wlink = GetSFLink(wurl)
        'if wlink = "" then
        '    Tools.log "ダウンロードリンクを取得できませんでした。", 1
        '    exit sub
        'End If
	ElseIf Instr(wurl,"github.com")>0 then
        wlink = wurl
    End If
    
    Tools.log "サクラエディタをダウンロードします.. " & wlink, 0
    
    'wcmd = "bitsadmin.exe /TRANSFER sakura2 " & wurl & " " & wzipfile
    wcmd = Tools.CurlExe & " -L """ & wlink & """ -o " & wzipfile
    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, True '

	If Not Tools.FS.FileExists(wzipfile) then
	    Tools.log "ダウンロードできませんでした。", 0
		Exit Sub
	End If
	
	Tools.log "ダウンロードファイルを展開します。", 0
    
    'zip展開
    'wcmd = UnzipExe & " -o -j " & wzipfile & " */sakura.exe -d " & Tools.WorkDir
    wcmd = Tools.UnzipExe & " e -aoa " & wzipfile & " */sakura.exe -o" & Tools.WorkDir
    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, False
    
    Sleep 500
    If Not Tools.FS.FileExists(Tools.WorkDir & "\sakura.exe") then
	    Tools.log Tools.WorkDir & "\sakura.exeがダウンロードファイルにありませんでした。", 0
		Exit Sub
	End If

	If Tools.WSH.Popup("sakura.exeを更新します。" & vbCrLf & "すべてのsakura.exeを強制終了後、上書きします。",0,"ソフトウェアの更新",1) = 2 Then
        Exit sub
    End If

    ' exe上書き処理
    '    更新スクリプトを作成し、他プロセスで実行
    '    実行後サクラエディタを終了する。
    '    スクリプトは、サクラエディタ上書きが出来るまで待機する。
    '    C:\program files\sakuraの場合はセキュリティ警告がでる。
    Dim wcmdfile
    Dim wcmdparam
    Dim programfiles
    programfiles = "C:\Program Files"
    
    wcmd     = "set srcfolder=" & Tools.WorkDir & vbCrLf & _
	           "set targetfolder=" & Tools.SakuraDir & vbCrLf & _
	           "set targetfile=sakura.exe" & vbCrLf

	If (left(wosver,2) = "6." or left(wosver,3) = "10.") and left(Tools.SakuraDir, Len(programfiles)) = programfiles Then
        wcmd = wcmd & "set _runas=-Verb runas"
    End If
    
    wcmdfile = Tools.WorkDir & "\_setenv.bat"
	Tools.SaveText wcmd, wcmdfile, "Shift_JIS"
	
    wcmd = """" & Tools.PluginDir & "\mainupdate.bat"""
'	wcmdparam = "Start-Process -File " & wcmdfile
'	If (left(wosver,2) = "6." or left(wosver,3) = "10.") and left(Tools.SakuraDir, Len(programfiles)) = programfiles Then
'	    '管理者モードでコピー
'	    wcmdparam = wcmdparam + " -Verb runas" ' -Wait
'       'wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command ""Start-Process PowerShell -ArgumentList " & wcmdparam & """"
'        wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command """ & wcmdparam & """"
'        '-NoNewWindow -PassThru
'    Else
'        wcmd = wcmdfile
'	End If

    If false Then
	'   workdir + "/_temp.ps1" に、
	'   plugindir + "/fileupdate.ps1" + パラメータ1, 2, 3
	'   を呼ぶ処理を保存して、_temp.ps1を、start-process -Verb runasで呼ぶ
	    wcmdfile = """" & Tools.PluginDir & "\fileupdate.ps1"""
	    wcmd     = "& " & wcmdfile & " " & _
	                Tools.WorkDir  & " " & _
	                """" & Tools.SakuraDir & """ " & _
	                "sakura.exe" + vbCrLf

	    wcmdfile = Tools.WorkDir & "\_fileupdate.ps1"
	    Tools.SaveText wcmd, wcmdfile, "Shift_JIS"
	    
	    wcmdparam = "Start-Process PowerShell -ArgumentList " & wcmdfile & " "
	    If left(Tools.SakuraDir, Len(programfiles)) = programfiles Then
	        '管理者モードでコピー
	        wcmdparam = wcmdparam + " -Verb runas" ' -Wait
	    End If

	    'wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command ""Start-Process PowerShell -ArgumentList " & wcmdparam & """"
	    wcmd = "powershell -NoProfile -ExecutionPolicy unrestricted -Command """ & wcmdparam & """"
	    '-NoNewWindow -PassThru
    End If
    
    'If Tools.DebugLvl >= 1 Then
	'	If Tools.WSH.Popup("サクラエディタを終了しますか。",0,"ソフトウェアの更新",1) = 1 Then
	'	
	'    End If
	'End If

    Tools.log ">" & wcmd, 1
    'Tools.DoCmd wcmd, ""
    Tools.WSH.Run wcmd, 7, false

    Editor.ExitAll
    
End Sub


Call Main()

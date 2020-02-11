**Windows統合ISO作成用バッチ**  
  
　ダウンロード可能なWindows UpdateとChrome版Edgeを統合したISOファイル作成のバッチファイルです。  
　・[Windows7/10統合用](https://github.com/office-itou/Windows/blob/master/Make_ISO_files)  
  
**VMXのカスタマイズ用バッチファイル**  
  
　新規作成したVMwareのゲスト環境(vmx)を一括して追記するバッチファイルです。  
　Linuxコンソール画面低解像度問題やパフォーマンス改善のパラメータを同一形式の記述でvmxファイルに追加させます。  
　・[setup_vmx.cmd](https://github.com/office-itou/Windows/blob/master/Command/setup_vmx.cmd?ts=4)  
  
**ATI2020のカスタマイズ用バッチファイル**  
  
　ATI2020にモジュールやドライバーを追加するバッチファイルです。  
　デスクトップにAcronisBootablePEMedia x64.wimを作成して作業して下さい。  
　・[MkWinPE_ATI.cmd](https://github.com/office-itou/Windows/blob/master/Make%20WinPE/MkWinPE_ATI.cmd?ts=4)  
  
　※WinPE起動後のnet useがエラーする時は以下の記述を試してみて下さい。  
　　net use * \\computername\sharename /user:username *  
　　(WinPE ver 10.0.17134.1にて確認)  
　　![ATI操作画面1](https://github.com/office-itou/Windows/blob/master/Make%20WinPE/ATI-01.png)  

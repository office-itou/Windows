ダウンロード可能なWindows UpdateとChrome版Edgeを統合したISOファイル作成のバッチファイルです。  
USB3.0とRSTのドライバーも統合しています。  
NVMeは未検証のためコメントアウトしています。(VMware上でフリーズするので検証できませんでした)  
  
１．以下の物を予め用意して下さい。  
　・Windows 10 Pro [Version 10.0.18363.592]  
　・[Windows ADK for Windows 10](https://docs.microsoft.com/ja-jp/windows-hardware/get-started/adk-install)  
　・[Mk1st.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make%20ISO%20files/Mk1st.cmd)  
　・2011/05/12  00:00     3,322,757,120 ja_windows_7_ultimate_with_sp1_x64_dvd_u_677372.iso  
　・2011/05/12  00:00     2,554,019,840 ja_windows_7_ultimate_with_sp1_x86_dvd_u_677445.iso  
  
２．”Mk1st.cmd”を実行し必要なファイルを取得して下さい。  
　参照：★Mk1st.cmd実行  
  
３．”MkWindows7_ISO_files_Custom.cmd”を実行しISOファイルを作成して下さい。  
　参照：★MkWindows7_ISO_files_Custom.cmd実行  
  
<注意点>  
　文字化けしたらcmdファイルの文字コードをSJIS、改行コードをCRLFで保存して下さい。  
　動作がおかしい時は改行コードを確認して下さい。  
　GitHub上ではLFで管理されているようです。  
　CRLFに変換してお使いください。  
　　例)More < Mk1st.cmd > Mk1st.txt && Move Mk1st.txt Mk1st.cmd  
  
★Mk1st.cmd実行  
![導入設定：準備画面](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/01-01.%E5%B0%8E%E5%85%A5%E8%A8%AD%E5%AE%9A.jpg)  
![導入設定：開始画面](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/01-02.%E5%B0%8E%E5%85%A5%E8%A8%AD%E5%AE%9A.jpg)  
![導入設定：終了画面](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/01-03.%E5%B0%8E%E5%85%A5%E8%A8%AD%E5%AE%9A.jpg)  
★MkWindows7_ISO_files_Custom.cmd実行  
![統合処理：開始画面](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/02-01.%E7%B5%B1%E5%90%88%E5%87%A6%E7%90%86.jpg)  
![統合処理：終了画面](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/02-02.%E7%B5%B1%E5%90%88%E5%87%A6%E7%90%86.jpg)  
★インストール中及びWindows Update画面  
![インスト：未統合分](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/03-01.%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88.png)  
![インスト：統合一部](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/03-02.%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88.png)  
![インスト：統合一部](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/03-03.%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88.png)  
![インスト：更新履歴](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/03-04.%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88.png)  
![インスト：統合確認](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/03-05.%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88.png)  

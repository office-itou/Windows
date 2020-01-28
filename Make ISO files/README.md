ダウンロード可能なWindows UpdateとChrome版Edgeを統合したISOファイル作成のバッチファイルです。  
・USB3.0とRSTのドライバーも統合しています。  
・NVMeは未検証のためコメントアウトしています。(VMware上でフリーズするので検証できませんでした)  
  
１．以下の物を予め用意して下さい。  
　・[Windows 10](https://www.microsoft.com/ja-jp/software-download/windows10)  
　・[Windows ADK for Windows 10](https://docs.microsoft.com/ja-jp/windows-hardware/get-started/adk-install)  
　・[Mk1st4w7.cmd](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files/source/Mk1st4w7.cmd)  
　・2011/05/12  00:00     3,322,757,120 ja_windows_7_ultimate_with_sp1_x64_dvd_u_677372.iso  
　・2011/05/12  00:00     2,554,019,840 ja_windows_7_ultimate_with_sp1_x86_dvd_u_677445.iso  
  
２．”C:\WimWK\w7\bin\Mk1st4w7.cmd”を実行し必要なファイルを取得して下さい。  
　参照：★Mk1st4w7.cmd実行  
  
３．”C:\WimWK\w7\bin\MkWindows7_ISO_files_Custom.cmd”を管理者権限で実行しISOファイルを作成して下さい。  
　参照：★MkWindows7_ISO_files_Custom.cmd実行  
  
<注意点>  
　文字化けや動作がおかしい時は文字コードをSJIS、改行コードをCRLFで保存し直して下さい。  
  

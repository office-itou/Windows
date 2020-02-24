**Windows Update統合ISO作成用バッチ**  
  
【事前準備】  
  
・開発環境  
　**Microsoft Windows 10 Pro 1909 [Version 10.0.18363.628]**  
  
・原版となるISOファイル
  
| タイムスタンプ   | ファイルサイズ | ファイル名                                          |  
|:----------------:| --------------:|:--------------------------------------------------- |  
| 2011/05/12 00:00 |  3,322,757,120 | ja_windows_7_ultimate_with_sp1_x64_dvd_u_677372.iso |  
| 2011/05/12 00:00 |  2,554,019,840 | ja_windows_7_ultimate_with_sp1_x86_dvd_u_677445.iso |  
| 2015/04/07  19:33|  3,257,376,768 | Win8.1_Japanese_x32.iso                             |  
| 2016/07/09  00:50|  4,392,620,032 | Win8.1_Japanese_x64.iso                             |  
| 2019/10/09 04:34 |  3,874,082,816 | Win10_1909_Japanese_x32.iso                         |  
| 2019/10/09 06:13 |  5,376,456,704 | Win10_1909_Japanese_x64.iso                         |  
  
・必要となるサイズの参考値
  
| フォルダー または ファイル                 |  サイズ  |  
|:------------------------------------------ | --------:|  
| 導入直後のC:\WimWKフォルダー               |  12.8GB  |  
| 原版 ISO ファイル合計                      |  21.2GB  |  
| windows_7_x64_dvd_custom_6.1.7601.iso      |   5.29GB |  
| windows_7_x86_dvd_custom_6.1.7601.iso      |   3.83GB |  
| windows_8.1_x64_dvd_custom_6.3.9600.iso    |   6.43GB |  
| windows_8.1_x86_dvd_custom_6.3.9600.iso    |   4.51GB |  
| windows_10_x64_dvd_custom_10.0.18362.iso   |   6.06GB |  
| windows_10_x86_dvd_custom_10.0.18362.iso   |   4.30GB |  
| windows_7_x64_dvd_dynabook_6.1.7601.iso    |   5.41GB |  
| windows_10_x64_dvd_dynabook_10.0.18362.iso |   6.16GB |  
| windows_10_x64_dvd_skylake_10.0.18362.iso  |   6.10GB |  
  
　install.wimの展開に1作業あたり20GB程度必要
  
　＜参考＞  
　　Windows 7/8.1/10 x86/x64 の統合作業を同時に行った時のOS込みの使用量は130GB程度。  
　　これに出力されるISOファイル分を加算した容量が最低限必要となる。  
  
【Windows Update統合ISOでインストール後の注意】  
  
　以下のフォルダーに使用したメディアのコピーがありますので管理者権限で削除願います。  
　　**C:\Windows\ConfigSetRoot**　（環境変数 %configsetroot% と同等）  
  
【ダウンロード用コピペ】  
  
```text
curl -L -# -R -S -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Initial-Downloader.cmd"
```
  
【初期導入作業用】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Initial-Downloader.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Initial-Downloader.cmd)         | 初期導入用バッチファイル                    |
| [Initial-Downloader.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Initial-Downloader.lst)         | 初期導入用ダウンロードリストファイル        |
  
【Windows Update 統合作業用】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [MakeIsoFile.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MakeIsoFile.cmd)                | 統合作業用バッチファイル                    |
| [MakeUsbStick.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MakeUsbStick.cmd)               | インストール用USBメモリー作成バッチファイル |
  
【Unattendファイル】  
  
| ファイル名                      | 機能                                        |
| ------------------------------- | ------------------------------------------- |
| [autounattend-windows7-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows7-x86.xml)   | Windows  7 32bit用                          |
| [autounattend-windows7-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows7-x64.xml)   | Windows  7 64bit用                          |
| [autounattend-windows8.1-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows8.1-x86.xml) | Windows  8.1 32bit用                        |
| [autounattend-windows8.1-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows8.1-x64.xml) | Windows  8.1 64bit用                        |
| [autounattend-windows10-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows10-x86.xml)  | Windows 10 32bit用                          |
| [autounattend-windows10-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows10-x64.xml)  | Windows 10 64bit用                          |
  
【ショートカット】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [MicrosoftUpdateCatalog.url](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MicrosoftUpdateCatalog.url)     | Microsoft Update Catalog URL                |
  
【ダウンロードリストファイル：Windows 7用】  
  
| ファイル名                      | 機能                                        |
| ------------------------------- | ------------------------------------------- |
| [Windows7adk_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7adk_Rollup_202001.lst)   | ADK                                         |
| [Windows7bin_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7bin_Rollup_202001.lst)   | バイナリーファイル                          |
| [Windows7x86_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7x86_Rollup_202002.lst)   | Windows Update 32bit                        |
| [Windows7x64_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7x64_Rollup_202002.lst)   | Windows Update 64bit                        |
  
【ダウンロードリストファイル：Windows 8.1用】  
  
| ファイル名                       | 機能                                        |
| -------------------------------- | ------------------------------------------- |
| [Windows8.1adk_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1adk_Rollup_202002.lst)  | ADK                                         |
| [Windows8.1bin_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1bin_Rollup_202002.lst)  | バイナリーファイル                          |
| [Windows8.1x86_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1x86_Rollup_202002.lst)  | Windows Update 32bit                        |
| [Windows8.1x64_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1x64_Rollup_202002.lst)  | Windows Update 64bit                        |
  
【ダウンロードリストファイル：Windows 10用】  
  
| ファイル名                      | 機能                                        |
| ------------------------------- | ------------------------------------------- |
| [Windows10adk_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10adk_Rollup_202001.lst)  | ADK                                         |
| [Windows10bin_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10bin_Rollup_202001.lst)  | バイナリーファイル                          |
| [Windows10x86_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10x86_Rollup_202002.lst)  | Windows Update 32bit                        |
| [Windows10x64_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10x64_Rollup_202002.lst)  | Windows Update 64bit                        |
  
[【ダウンロードリストファイル：dynabook SS N12シリーズ用ドライバー】](https://github.com/office-itou/Windows/tree/master/Make_ISO_files/source/dynabook_SS_N12)  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Windows7drv_dynabook.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/Windows7drv_dynabook.lst)       | Win7版           |
| [Windows10drv_dynabook.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/Windows10drv_dynabook.lst)       |  Win10版         |
| [options.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/options.cmd)                    | サンプルファイル |
  
[【ダウンロードリストファイル：H170-PRO用ドライバー】](https://github.com/office-itou/Windows/tree/master/Make_ISO_files/source/h170pro)  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Windows7drv_h170pro.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/h170pro/Windows7drv_h170pro.lst)       | Win7版           |
| [Windows10drv_h170pro.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/h170pro/Windows10drv_h170pro.lst)       |  Win10版         |
  
[【ダウンロードリストファイル：Intel 製マイクロコードの更新プログラム】](https://github.com/office-itou/Windows/tree/master/Make_ISO_files/source/skylake)  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Windows10x86_skylake_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/skylake/Windows10x86_skylake_202001.lst)       | Win10 32bit版  |
| [Windows10x64_skylake_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/skylake/Windows10x64_skylake_202001.lst)       | Win10 64bit版  |
  
【初期導入作業画面】  
  
| 作業内容                       | スクリーンショット                          |
| ------------------------------ | ------------------------------------------- |
| 導入作業01                     | ![導入作業01](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/01.Initial-Downloader.01.jpg) |
| 導入作業02                     | ![導入作業02](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/01.Initial-Downloader.02.jpg) |
  
【統合作業画面：Windows 10の場合】  
  
| 作業内容                       | スクリーンショット                          |
| ------------------------------ | ------------------------------------------- |
| 統合作業01                     | ![統合作業01](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/02.%E7%B5%B1%E5%90%88%E4%BD%9C%E6%A5%AD.01.jpg) |
| 統合作業02                     | ![統合作業02](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/02.%E7%B5%B1%E5%90%88%E4%BD%9C%E6%A5%AD.02.jpg) |
| 統合作業03                     | ![統合作業03](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/02.%E7%B5%B1%E5%90%88%E4%BD%9C%E6%A5%AD.03.jpg) |
| 統合作業04                     | ![統合作業04](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/02.%E7%B5%B1%E5%90%88%E4%BD%9C%E6%A5%AD.04.jpg) |
| 統合作業05                     | ![統合作業05](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/02.%E7%B5%B1%E5%90%88%E4%BD%9C%E6%A5%AD.05.jpg) |
  
【インストール用USBメモリー作成作業画面】  
  
| 作業内容                       | スクリーンショット                          |
| ------------------------------ | ------------------------------------------- |
| 媒体作成01                     | ![媒体作成01](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/03.%E5%AA%92%E4%BD%93%E4%BD%9C%E6%88%90.01.jpg) |
| 媒体作成02                     | ![媒体作成02](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/03.%E5%AA%92%E4%BD%93%E4%BD%9C%E6%88%90.02.jpg) |
| 媒体作成03                     | ![媒体作成03](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/03.%E5%AA%92%E4%BD%93%E4%BD%9C%E6%88%90.03.jpg) |
| 媒体作成04                     | ![媒体作成04](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/03.%E5%AA%92%E4%BD%93%E4%BD%9C%E6%88%90.04.jpg) |
  

**Windows Update統合ISO作成用バッチ**  
  
【事前準備】  
  
・開発環境  
　**Microsoft Windows 10 Pro 1909 [Version 10.0.18363.628]**  
  
・原版となるISOファイル
  
| タイムスタンプ   | ファイルサイズ | ファイル名                                          |  
|:----------------:| --------------:|:--------------------------------------------------- |  
| 2011/05/12 00:00 |  3,322,757,120 | ja_windows_7_ultimate_with_sp1_x64_dvd_u_677372.iso |  
| 2011/05/12 00:00 |  2,554,019,840 | ja_windows_7_ultimate_with_sp1_x86_dvd_u_677445.iso |  
| 2019/10/09 04:34 |  3,874,082,816 | Win10_1909_Japanese_x32.iso                         |  
| 2019/10/09 06:13 |  5,376,456,704 | Win10_1909_Japanese_x64.iso                         |  
  
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
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [autounattend-windows7-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows7-x86.xml)  | Windows  7 32bit用                          |
| [autounattend-windows7-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows7-x64.xml)  | Windows  7 64bit用                          |
| [autounattend-windows10-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows10-x86.xml) | Windows 10 32bit用                          |
| [autounattend-windows10-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows10-x64.xml) | Windows 10 64bit用                          |
  
【ショートカット】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [MicrosoftUpdateCatalog.url](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MicrosoftUpdateCatalog.url)     | Microsoft Update Catalog URL                |
  
【ダウンロードリストファイル：Windows 7用】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Windows7adk_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7adk_Rollup_202001.lst)  | ADK                                         |
| [Windows7bin_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7bin_Rollup_202001.lst)  | バイナリーファイル                          |
| [Windows7drv_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7drv_Rollup_202001.lst)  | ドライバー                                  |
| [Windows7x86_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7x86_Rollup_202001.lst)  | Windows Update 32bit                        |
| [Windows7x64_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7x64_Rollup_202001.lst)  | Windows Update 64bit                        |
  
【ダウンロードリストファイル：Windows 10用】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Windows10adk_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10adk_Rollup_202001.lst) | ADK                                         |
| [Windows10bin_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10bin_Rollup_202001.lst) | バイナリーファイル                          |
| [Windows10drv_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10drv_Rollup_202001.lst) | ドライバー                                  |
| [Windows10x86_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10x86_Rollup_202001.lst) | Windows Update 32bit                        |
| [Windows10x64_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10x64_Rollup_202001.lst) | Windows Update 64bit                        |
  
【ダウンロードリストファイル：dynabook SS N12 Windows 7用】  
  
| ファイル名                     | 機能                                        |
| ------------------------------ | ------------------------------------------- |
| [Windows7drv_dynabook.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/Windows7drv_dynabook.lst)       | dynabook SS N12シリーズ ドライバー          |
| [options.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/options.cmd)                    | dynabook SS N12シリーズ 用 サンプルファイル |
  
【初期導入作業画面】  
  
| 作業内容                       | スクリーンショット                          |
| ------------------------------ | ------------------------------------------- |
| 導入作業01                     | ![導入作業01](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/01.Initial-Downloader.01.jpg) |
| 導入作業02                     | ![導入作業02](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/picture/01.Initial-Downloader.02.jpg) |
  
【統合作業画面】  
  
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
  
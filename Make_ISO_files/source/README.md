**Windows Update統合ISO作成用バッチ**  
  
　各フォルダーに入れて下さい。
  
【作業用ファイル一覧】  
  
| フォルダー名 | ファイル名                     | OSバージョン | 機能                               |
| :----------: | ------------------------------ | :----------: | ---------------------------------- |
| 任意         | [Initial-Downloader.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Initial-Downloader.cmd)                           | 共通        | 初期導入用バッチファイル                    |
| C:\WimWK\bin | [MakeIsoFile.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MakeIsoFile.cmd)                                         |             | 統合作業用バッチファイル                    |
|              | [MakeUsbStick.cmd](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MakeUsbStick.cmd)                                       |             | インストール用USBメモリー作成バッチファイル |
|              | [MicrosoftUpdateCatalog.url](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/MicrosoftUpdateCatalog.url)                   |             | Microsoft Update Catalog URL                |
| C:\WimWK\cfg | [autounattend-windows7-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows7-x86.xml)             | Windows 7   | 32bit用 Unattendファイル                    |
|              | [autounattend-windows7-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows7-x64.xml)             |             | 64bit用   〃                                |
|              | [autounattend-windows8.1-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows8.1-x86.xml)         | Windows 8.1 | 32bit用   〃                                |
|              | [autounattend-windows8.1-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows8.1-x64.xml)         |             | 64bit用   〃                                |
|              | [autounattend-windows10-x86.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows10-x86.xml)           | Windows 10  | 32bit用   〃                                |
|              | [autounattend-windows10-x64.xml](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/autounattend-windows10-x64.xml)           |             | 64bit用   〃                                |
| C:\WimWK\lst | [Initial-Downloader.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Initial-Downloader.lst)                           | 共通        | 初期導入用ダウンロードリストファイル        |
|              | [Windows7adk_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7adk_Rollup_202001.lst)             | Windows 7   | ADK                                         |
|              | [Windows7bin_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7bin_Rollup_202001.lst)             |             | バイナリーファイル                          |
|              | [Windows7x86_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7x86_Rollup_202002.lst)             |             | 32bit用 Windows Update                      |
|              | [Windows7x64_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows7x64_Rollup_202002.lst)             |             | 64bit用   〃                                |
|              | [Windows8.1adk_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1adk_Rollup_202002.lst)         | Windows 8.1 | ADK                                         |
|              | [Windows8.1bin_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1bin_Rollup_202002.lst)         |             | バイナリーファイル                          |
|              | [Windows8.1x86_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1x86_Rollup_202002.lst)         |             | 32bit用 Windows Update                      |
|              | [Windows8.1x64_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows8.1x64_Rollup_202002.lst)         |             | 64bit用   〃                                |
|              | [Windows10adk_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10adk_Rollup_202001.lst)           | Windows 10  | ADK                                         |
|              | [Windows10bin_Rollup_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10bin_Rollup_202001.lst)           |             | バイナリーファイル                          |
|              | [Windows10x86_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10x86_Rollup_202002.lst)           |             | 32bit用 Windows Update                      |
|              | [Windows10x64_Rollup_202002.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Windows10x64_Rollup_202002.lst)           |             | 64bit用   〃                                |
|              | [Windows10x86_skylake_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/skylake/Windows10x86_skylake_202001.lst) | Windows 10  | 32bit用 Intel 製マイクロコード              |
|              | [Windows10x64_skylake_202001.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/skylake/Windows10x64_skylake_202001.lst) |             | 64bit用   〃                                |
|              | [Windows7drv_h170pro.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/h170pro/Windows7drv_h170pro.lst)                 | Windows  7  | H170-PROドライバー                          |
|              | [Windows10drv_h170pro.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/h170pro/Windows10drv_h170pro.lst)               | Windows 10  |   〃                                        |
|              | [Windows7drv_dynabook.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/Windows7drv_dynabook.lst)       | Windows  7  | dynabook SS N12ドライバー                   |
|              | [Windows10drv_dynabook.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/dynabook_SS_N12/Windows10drv_dynabook.lst)     | Windows 10  |   〃                                        |
  

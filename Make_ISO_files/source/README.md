**Windows Update統合ISO作成用バッチ**  
  
　各フォルダーに入れて下さい。  
　[フォルダー構成](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/WimWK-tree.txt)  
  
【ダウンロード用コピペ】  
  
```text
curl -L -# -R -S -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Initial-Downloader.cmd"
```
  
【作業用ファイル一覧】  
  
| フォルダー名 | ファイル名                     | Windows | 機能                               |  
| :----------: | ------------------------------ | :-----: | ---------------------------------- |  
| 任意         | [Initial-Downloader.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Initial-Downloader.cmd)                           | 共通 | 初期導入用バッチファイル                    |  
| C:\WimWK\bin | [MakeAll.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/MakeAll.cmd)                                                 |      |                                             |  
|              | [MakeIsoFile.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/MakeIsoFile.cmd)                                         |      | 統合作業用バッチファイル                    |  
|              | [MakeUsbStick.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/MakeUsbStick.cmd)                                       |      | インストール用USBメモリー作成バッチファイル |  
|              | [Remove.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Remove.cmd)                                                   |      |                                             |  
|              | [Unmount.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Unmount.cmd)                                                 |      |                                             |  
|              | [MicrosoftUpdateCatalog.url](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/MicrosoftUpdateCatalog.url)                   |      | Microsoft Update Catalog URL                |  
| C:\WimWK\cfg | [autounattend-windows7-x86.xml](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/autounattend-windows7-x86.xml)             |  7   | 32bit用 Unattendファイル                    |  
|              | [autounattend-windows7-x64.xml](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/autounattend-windows7-x64.xml)             |      | 64bit用   〃                                |  
|              | [autounattend-windows8.1-x86.xml](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/autounattend-windows8.1-x86.xml)         |  8.1 | 32bit用   〃                                |  
|              | [autounattend-windows8.1-x64.xml](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/autounattend-windows8.1-x64.xml)         |      | 64bit用   〃                                |  
|              | [autounattend-windows10-x86.xml](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/autounattend-windows10-x86.xml)           |  10  | 32bit用   〃                                |  
|              | [autounattend-windows10-x64.xml](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/autounattend-windows10-x64.xml)           |      | 64bit用   〃                                |  
| C:\WimWK\lst | [Initial-Downloader.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/Initial-Downloader.lst)                                     | 共通 | 初期導入用ダウンロードリストファイル        |  
|              | [Windows7adk_Rollup_202011.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows7adk_Rollup_202011.lst)             |  7   | ADK                                         |  
|              | [Windows7bin_Rollup_202012.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows7bin_Rollup_202012.lst)             |      | バイナリーファイル                          |  
|              | [Windows7x86_Rollup_202012.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows7x86_Rollup_202012.lst)             |      | 32bit用 Windows Update                      |  
|              | [Windows7x64_Rollup_202012.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows7x64_Rollup_202012.lst)             |      | 64bit用   〃                                |  
|              | [Windows8.1adk_Rollup_202011.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows8.1adk_Rollup_202011.lst)         |  8.1 | ADK                                         |  
|              | [Windows8.1bin_Rollup_202012.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows8.1bin_Rollup_202012.lst)         |      | バイナリーファイル                          |  
|              | [Windows8.1x86_Rollup_202012.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows8.1x86_Rollup_202012.lst)         |      | 32bit用 Windows Update                      |  
|              | [Windows8.1x64_Rollup_202012.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows8.1x64_Rollup_202012.lst)         |      | 64bit用   〃                                |  
|              | [Windows10adk_Rollup_202011.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows10adk_Rollup_202011.lst)           |  10  | ADK                                         |  
|              | [Windows10bin_Rollup_202102.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows10bin_Rollup_202102.lst)           |      | バイナリーファイル                          |  
|              | [Windows10x86_Rollup_202103.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows10x86_Rollup_202103.lst)           |      | 32bit用 Windows Update                      |  
|              | [Windows10x64_Rollup_202103.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/Windows10x64_Rollup_202103.lst)           |      | 64bit用   〃                                |  
|              | [Windows10x86_skylake_202011.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/skylake/Windows10x86_skylake_202011.lst) |  10  | 32bit用 Intel 製マイクロコード              |  
|              | [Windows10x64_skylake_202011.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/skylake/Windows10x64_skylake_202011.lst) |      | 64bit用   〃                                |  
|              | [Windows7drv_dynabook.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/dynabook_SS_N12/Windows7drv_dynabook.lst)       |   7  | dynabook SS N12ドライバー                   |  
|              | [Windows10drv_dynabook.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/dynabook_SS_N12/Windows10drv_dynabook.lst)     |  10  |   〃                                        |  
|              | [Windows7drv_h170pro.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/h170pro/Windows7drv_h170pro.lst)                 |   7  | H170-PROドライバー                          |  
|              | [Windows10drv_h170pro.lst](https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source/h170pro/Windows10drv_h170pro.lst)               |  10  |   〃                                        |  
   

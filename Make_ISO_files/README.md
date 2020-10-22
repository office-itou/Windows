**Windows Update統合ISO作成用バッチ**  
|  
【事前準備】  
  
・開発環境  
　**Microsoft Windows 10 Pro 1909 [Version 10.0.18363.628]**  
  
・原版となるISOファイル
  
| タイムスタンプ   | ファイルサイズ | ファイル名                                          |  
|:----------------:|:--------------:| --------------------------------------------------- |  
| 2011/05/12 00:00 |  3,322,757,120 | ja_windows_7_ultimate_with_sp1_x64_dvd_u_677372.iso |  
| 2011/05/12 00:00 |  2,554,019,840 | ja_windows_7_ultimate_with_sp1_x86_dvd_u_677445.iso |  
| 2015/04/07 19:33 |  3,257,376,768 | Win8.1_Japanese_x32.iso                             |  
| 2016/07/09 00:50 |  4,392,620,032 | Win8.1_Japanese_x64.iso                             |  
| 2020/09/28 12:18 |  4,412,211,200 | Win10_20H2_Japanese_x32.iso                         |  
| 2020/09/28 12:36 |  5,983,848,448 | Win10_20H2_Japanese_x64.iso                         |  
  
・作業した統合ファイル例一覧  
  
| ファイルサイズ | ファイル名                                          | Windows | 機能                             |  
|:--------------:| --------------------------------------------------- | :-----: | -------------------------------- |  
|  3,950,579,712 | windows_7_x86_dvd_custom_6.1.7601.iso               |    7    | 32bit版 Windows Updateのみ適用   |  
|  5,489,448,960 | windows_7_x64_dvd_custom_6.1.7601.iso               |         | 64bit版 〃                       |  
|  5,623,959,552 | windows_7_x64_dvd_dynabook_6.1.7601.iso             |         | 64bit版 dynabook用ドライバー適用 |  
|  5,489,448,960 | windows_7_x64_dvd_h170pro_6.1.7601.iso              |         | 64bit版 H170-PRO用ドライバー適用 |  
|  6,917,240,832 | windows_8.1_x64_dvd_custom_6.3.9600.iso             |   8.1   | 32bit版 Windows Updateのみ適用   |  
|  4,858,468,352 | windows_8.1_x86_dvd_custom_6.3.9600.iso             |         | 64bit版 〃                       |  
|  5,059,889,152 | windows_10_x86_dvd_custom_10.0.19041.iso            |   10    | 32bit版 Windows Updateのみ適用   |  
|  7,099,236,352 | windows_10_x64_dvd_custom_10.0.19041.iso            |         | 64bit版 〃                       |  
|  7,231,662,080 | windows_10_x64_dvd_dynabook_10.0.19041.iso          |         | 64bit版 dynabook用ドライバー適用 |  
|  9,610,385,408 | windows_10_x64_dvd_h170pro_10.0.19041.iso           |         | 64bit版 H170-PRO用ドライバー適用 |  
|  6,568,263,680 | windows_10_x64_dvd_skylake_10.0.18362.iso           |         | 64bit版 マイクロコードパッチ適用 |  
  
　＜参考＞  
　　Windows 7/8.1/10 x86/x64 の統合作業を同時に行った時のOS込みの使用量は130GB程度。  
　　install.wimの展開に1作業あたり20GB程度必要。  
　　これに出力されるISOファイル分を加算した容量が最低限必要となる。  
  
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
  
【Windows Update統合ISOでインストール後の注意】  
  
　以下のフォルダーに使用したメディアのコピーがありますので管理者権限で削除願います。  
　　**C:\Windows\ConfigSetRoot**　（環境変数 %configsetroot% と同等）  
  

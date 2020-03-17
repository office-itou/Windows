**応用：SP+メーカー**  
  
【SP+メーカー】  
  
　1.SP+メーカーをインストールする。  
　2.”ファイル→設定のインポート”で[winsppm.ini](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/source/winsppm.ini)をインポートする。  
　3.[windows10x64.lst](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/source/windows10x64.lst)を”C:\winsppm\list”にコピーする。  
　4.”C:\winsppm”の下に”out、upd、wrk”の各サブフォルダーを作成する。  
　5.SP+メーカーを起動しコンボボックスで”Windows 8.1 x64”を選択する。  
　6.”高度な設定→全てチェック→OK”で導入モジュールを選択する。  
　7.”作成”で一時停止するまで処理をさせる。  
　8.”C:\winsppm\wrk\makeiso\cd-rom”に移動し”WIN63、WIN63AP”を”WIN100、WIN100AP”にリネームする。  
　9.一時停止を解除しISOファイルを作成する。  
  
【Windows Updateインストール：USBメモリー編】  
  
　1.”C:\winsppm\wrk\makeiso\cd-rom”の下をUSBメモリーにコピーする。  
　2.インストールするWindows10のPCにUSBメモリーを挿す。  
　3.エクスプローラーで”コントロール パネル\ユーザー アカウント\ユーザー アカウント”に移動する。  
　4.”ユーザーアカウント制御設定の変更”で”通知を受け取るタイミング”を”通知しない”に変更する。  
　5.USBメモリー内の”SETUP.CMD”をダブルクリックしインストールを開始する。  
　6.画面に従い操作をし終了したら”ユーザーアカウント制御設定”の変更を元に戻す。  
　7.オンラインのWindows Updateで不足分を取り込む。  
  
| スクリーンショット |  
| --- |  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss001.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss002.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss003.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss004.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss005.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss006.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss007.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss008.jpg)|  
|![リストファイル編集](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss009.jpg)|  
|![ＳＰ＋メーカー設定](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss010.jpg)|  
|![ＳＰ＋メーカー設定](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss011.jpg)|  
|![ＳＰ＋メーカー設定](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss012.jpg)|  
|![ＳＰ＋メーカー設定](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss013.jpg)|  
|![ＳＰ＋メーカー設定](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss014.jpg)|  
|![ＳＰ＋メーカー設定](https://github.com/office-itou/Windows/blob/master/Make_ISO_files/source/SP%2B%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC/picture/ss015.jpg)|  
  

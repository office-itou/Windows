Windows10のISOファイルにWindows UpdateとChrome版Edgeを一つにまとめます。  
wimファイルは未変更なので全エディション共通の動作となります。  
事前にISOファイルを準備して下さい。  

以下のファイルで確認を行いました。
  2019/10/09  04:34     3,874,082,816 Win10_1909_Japanese_x32.iso
  2019/10/09  06:13     5,376,456,704 Win10_1909_Japanese_x64.iso

[Windows 10 のダウンロード](https://www.microsoft.com/ja-jp/software-download/windows10)から入手。
（Windowsのブラウザーだとツールのリンクしか出ないのでLinuxで入手するのがいいかも）  
  
【簡易手順説明】
・[Mk1st4w10.cmd](https://raw.githubusercontent.com/office-itou/Windows/master/Make%20ISO%20files%20for%20Window%2010/Mk1st4w10.cmd) を”名前を付けて保存”し実行して下さい。  
・必要なファイルをMk1st4w10.cmdと同じフォルダーにダウンロードしC:\WimWKに展開します。  
・ISOファイルをエクスプローラーでマウントします。  
・C:\WimWK\bin\MkWindows10_ISO_files_Custom.cmdを実行し画面に従って処理していきます。  
・C:\WimWK\w10にwindows_10_x[64または86]_dvd_custom_[wimのバージョン].isoができます。  
  
【USBメモリー転送】  
・転送したいISOファイルをマウントします。  
・消去していいUSBメモリーをPCに認識させます。(8GB～32GB)  
・C:\WimWK\bin\MkWindows10_USB_Custom.cmdを起動します。  
・画面に従いマウントしたドライブとUSBメモリーのドライブ名を入力します。  
・USBメモリーのインデックス番号を確認し入力します。  
・diskpartのパラメーターを確認し実行します。(間違うと他のディスクが破壊されるので要注意)  
・エラーが無い事を確認し作業を終了します。  
  
【マウント確認画面】
![準備画面](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/common-01.jpg)  
【処理実行中画面】
![x64 開始](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/win10x64-01.jpg)  
![x64 終了](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/win10x64-02.jpg)  
【起動後インストール確認画面】
![x64確認1](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/win10x64-03.png)  
![x64確認2](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/win10x64-04.png)  
【USBメモリー転送作業】
![USB準備1](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/usb-01.jpg)  
![USB準備2](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/usb-02.jpg)  
![USB 開始](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/usb-03.jpg)  
![USB確認1](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/usb-04.jpg)  
![USB 終了](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/usb-05.jpg)  
![USB確認2](https://github.com/office-itou/Windows/blob/master/Make%20ISO%20files%20for%20Window%2010/picture/usb-06.jpg)  

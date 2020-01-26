@echo off
:TOP
    cls

:START
    echo.
    echo メニューから処理を選択してください。
    echo.
    echo 1. Acronis True Image を起動する
    echo 2. メニューを終了し、コマンドプロンプトを表示する
    echo 3. 次のメニューへ
    echo.

    set choice=
    set /p choice="実行する処理 >> "

    if "%choice%" == "1" goto RunATI
    if "%choice%" == "2" goto SHELL
    if "%choice%" == "3" goto NEXT

    echo "%choice%" ：正しい値が選択がされていません。
    echo.
    goto START

:RunATI
    rem True Image の実行
    call ati -c
    echo True Image を終了しました。

:NEXT
    echo.
    echo メニューから処理を選択してください。
    echo.
    echo 1. 電源を切る
    echo 2. 再起動する
    echo 3. 前のメニューに戻る
    echo.

    set choice=
    set /p choice="実行する処理 >> "

    if "%choice%" == "1" call shutdown -s
    if "%choice%" == "2" call shutdown -r
    if "%choice%" == "3" goto TOP

    echo "%choice%" ：正しい値が選択がされていません。
    echo.
    goto NEXT

:SHELL
    rem コマンドプロンプト
    echo メニューを終了しました。
    echo 再度メニューを呼び出すときには menuti と入力してください。
    echo 電源を切るときには shutdown -s と入力してください。

:DONE

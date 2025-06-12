@echo off
chcp 65001 >nul
title ファイル圧縮ツール - PowerShell版
color 0A
mode con: cols=80 lines=25
setlocal enabledelayedexpansion

echo ========================================
echo           ファイル圧縮ツール
echo ========================================
echo.

echo このバッチファイルは、PowerShellを使用して7-Zipを実行します。
echo.

rem 引数チェック
if "%~1"=="" (
    echo ファイルまたはフォルダのパスを入力してください:
    set /p "str_file=パス: "
    if "!str_file!"=="" (
        echo パスが入力されていません。
        echo.
        echo 何かキーを押すと終了します...
        pause
        exit /b 1
    )
) else (
    set "str_file=%~1"
)

echo 指定されたパス: "!str_file!"
echo.

rem パスが存在するかチェック
if not exist "!str_file!" (
    echo エラー: 指定されたパスが存在しません
    echo パス: "!str_file!"
    echo.
    echo 何かキーを押すと終了します...
    pause
    exit /b 1
)

rem ファイルかフォルダかを判定
if exist "!str_file!\*" (
    echo タイプ: フォルダ
) else (
    echo タイプ: ファイル
)
echo.

rem 7-Zipのパスを設定
set "7z_exe="
if exist "C:\Program Files\7-Zip\7z.exe" (
    set "7z_exe=C:\Program Files\7-Zip\7z.exe"
    echo ✓ 7-Zip found: !7z_exe!
) else if exist "C:\Program Files (x86)\7-Zip\7z.exe" (
    set "7z_exe=C:\Program Files (x86)\7-Zip\7z.exe"
    echo ✓ 7-Zip found: !7z_exe!
) else if exist "%USERPROFILE%\AppData\Local\Programs\7-Zip\7z.exe" (
    set "7z_exe=%USERPROFILE%\AppData\Local\Programs\7-Zip\7z.exe"
    echo ✓ 7-Zip found: !7z_exe!
) else (
    echo ✗ 7-Zipが見つかりません
    echo.
    echo 何かキーを押すと終了します...
    pause
    exit /b 1
)

echo.
echo 7-Zipパス: "!7z_exe!"
echo.

rem 圧縮後のファイル名接尾子を設定
:INPUT_CHECK
set "input_ext="
set /P "input_ext=圧縮後のファイル名接尾子を入力してください（例: v1.7.0）: "
if "!input_ext!"=="" (
    echo 接尾子を入力してください。
    goto :INPUT_CHECK
)

echo.
echo 圧縮を開始します...

rem ファイル名から拡張子を除去してベース名を取得
for %%i in ("!str_file!") do set "base_name=%%~ni"

echo ベース名: !base_name!
echo 接尾子: !input_ext!
echo.

echo デバッグ情報:
echo - 7z_exe: "!7z_exe!"
echo - str_file: "!str_file!"
echo - base_name: "!base_name!"
echo - input_ext: "!input_ext!"
echo.

rem PowerShellを使用して7-Zipを実行（デバッグ版）
echo [1/3] 7-Zipでzip圧縮中...
echo 実行コマンド: powershell -Command "& '!7z_exe!' a '!base_name!_!input_ext!.zip' '!str_file!'"
powershell -Command "& '!7z_exe!' a '!base_name!_!input_ext!.zip' '!str_file!'"
if !errorlevel! equ 0 (
    echo ✓ zip圧縮完了: !base_name!_!input_ext!.zip
) else (
    echo ✗ zip圧縮に失敗しました
)

echo [2/3] 7-Zipで7z圧縮中...
echo 実行コマンド: powershell -Command "& '!7z_exe!' a '!base_name!_!input_ext!.7z' '!str_file!'"
powershell -Command "& '!7z_exe!' a '!base_name!_!input_ext!.7z' '!str_file!'"
if !errorlevel! equ 0 (
    echo ✓ 7z圧縮完了: !base_name!_!input_ext!.7z
) else (
    echo ✗ 7z圧縮に失敗しました
)

echo [3/3] 7-Zipでtar.gz圧縮中...
echo 実行コマンド: powershell -Command "& '!7z_exe!' a -ttar '!base_name!_!input_ext!.tar' '!str_file!'"
powershell -Command "& '!7z_exe!' a -ttar '!base_name!_!input_ext!.tar' '!str_file!'"
if !errorlevel! equ 0 (
    echo ✓ tar圧縮完了: !base_name!_!input_ext!.tar
    echo 実行コマンド: powershell -Command "& '!7z_exe!' a -tgzip '!base_name!_!input_ext!.tar.gz' '!base_name!_!input_ext!.tar'"
    powershell -Command "& '!7z_exe!' a -tgzip '!base_name!_!input_ext!.tar.gz' '!base_name!_!input_ext!.tar'"
    if !errorlevel! equ 0 (
        echo ✓ tar.gz圧縮完了: !base_name!_!input_ext!.tar.gz
        rem 一時的なtarファイルを削除
        if exist "!base_name!_!input_ext!.tar" del "!base_name!_!input_ext!.tar"
    ) else (
        echo ✗ tar.gz圧縮に失敗しました
    )
) else (
    echo ✗ tar圧縮に失敗しました
)

echo.
echo ========================================
echo 圧縮処理が完了しました
echo ========================================
echo 作成されたファイル:
if exist "!base_name!_!input_ext!.zip" echo ✓ !base_name!_!input_ext!.zip
if exist "!base_name!_!input_ext!.7z" echo ✓ !base_name!_!input_ext!.7z
if exist "!base_name!_!input_ext!.tar.gz" echo ✓ !base_name!_!input_ext!.tar.gz
echo.

endlocal
echo 何かキーを押すと終了します...
pause

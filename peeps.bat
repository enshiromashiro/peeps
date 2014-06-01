@echo off
@setlocal ENABLEDELAYEDEXPANSION


@rem 内部設定いろいろ

@rem Twitterクライアントのパス
set PEEPS_TW_PATH=C:\TweetConsole
@rem Twitterクライアントの引数（最後につぶやき文字列が連結される）
set PEEPS_TW_CMD=twtcnsl.exe /t
@rem つぶやきテンプレート
set PEEPS_TWEET_TEMPLATE=dateの成果：num文字



@rem 初期化とか
set SELF_PATH="%~dp0"
set TARGET_PATH=%~1

@rem 引数のチェック
if %1str equ str (
   echo 引数を設定してください
   echo 使い方: peeps [文字数カウントしたいフォルダ]
   goto :eof
)

@rem フォルダ名正規化と存在チェック
set TMP_PATH=%TARGET_PATH:"=%\+
set TMP_PATH=%TMP_PATH:\\+=\%
set TARGET_PATH="%TMP_PATH:\+=\%"
if not exist %TARGET_PATH% (
   echo そんなフォルダは存在しません
   echo カウント対象フォルダ: %TARGET_PATH%
   goto :eof
)

echo カウント対象フォルダ:%TARGET_PATH%

@rem 合計計算
set SUM=0
for /R %TARGET_PATH% %%f in (*.txt) do @(
    call :filesize "%%f"
    set FSIZE=!ERRORLEVEL!
    set /A SUM=SUM+FSIZE
)
@rem charnum(cp932) = filesize / 2
set /A SUM="SUM/2"

@rem 前回との差分計算
set DIFF=0
call :genfpath %TARGET_PATH%

call :readstat %FPATH%
set PREV=%ERRORLEVEL%

call :updatestat %FPATH% %SUM%
set /A DIFF=SUM-PREV

echo 今回合計:%SUM% 、前回合計:%PREV% 、差:%DIFF%


@rem つぶやく(前回実行時の文字数なし(%PREV%が-1)でないとき)
set TWEET=!PEEPS_TWEET_TEMPLATE:num=%DIFF%!
set TWEET=!TWEET:date=%DATE%!
if -1 == %PREV% (
  echo ディレクトリ %TARGET_PATH% の文字数は前回カウントされていません。
  echo なのでツイートしません。
) else (
  echo %TWEET%
  %PEEPS_TW_PATH%\%PEEPS_TW_CMD% %TWEET%
)

goto :eof


@rem サブルーチン（笑）
@rem ファイルサイズ
:filesize
@rem echo %1 %~z1
exit /b %~z1

@rem ファイル名生成
:genfpath
set FPATH=%~1
set FPATH=%FPATH:\=_%
set FPATH=%FPATH::=_%
set FPATH=%FPATH: =_%
set FPATH="%SELF_PATH:"=%\stats\%FPATH%"
@rem echo %FPATH%
exit /b

@rem 前回実行時の文字数の更新
:updatestat
echo %2 > %1
exit /b

@rem 前回実行時の文字数の探索
:readstat
set NUM=-1
if exist %~1 @(
   for /F %%n in (%~1) do @(
      set NUM=%%n
   )
)
exit /b %NUM%


:eof

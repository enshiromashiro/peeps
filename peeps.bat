@echo off
@setlocal ENABLEDELAYEDEXPANSION


@rem �����ݒ肢�낢��

@rem Twitter�N���C�A���g�̃p�X
set PEEPS_TW_PATH=C:\TweetConsole
@rem Twitter�N���C�A���g�̈����i�Ō�ɂԂ₫�����񂪘A�������j
set PEEPS_TW_CMD=twtcnsl.exe /t
@rem �Ԃ₫�e���v���[�g
set PEEPS_TWEET_TEMPLATE=date�̐��ʁFnum����



@rem �������Ƃ�
set SELF_PATH="%~dp0"
set TARGET_PATH=%~1

@rem �����̃`�F�b�N
if %1str equ str (
   echo ������ݒ肵�Ă�������
   echo �g����: peeps [�������J�E���g�������t�H���_]
   goto :eof
)

@rem �t�H���_�����K���Ƒ��݃`�F�b�N
set TMP_PATH=%TARGET_PATH:"=%\+
set TMP_PATH=%TMP_PATH:\\+=\%
set TARGET_PATH="%TMP_PATH:\+=\%"
if not exist %TARGET_PATH% (
   echo ����ȃt�H���_�͑��݂��܂���
   echo �J�E���g�Ώۃt�H���_: %TARGET_PATH%
   goto :eof
)

echo �J�E���g�Ώۃt�H���_:%TARGET_PATH%

@rem ���v�v�Z
set SUM=0
for /R %TARGET_PATH% %%f in (*.txt) do @(
    call :filesize "%%f"
    set FSIZE=!ERRORLEVEL!
    set /A SUM=SUM+FSIZE
)
@rem charnum(cp932) = filesize / 2
set /A SUM="SUM/2"

@rem �O��Ƃ̍����v�Z
set DIFF=0
call :genfpath %TARGET_PATH%

call :readstat %FPATH%
set PREV=%ERRORLEVEL%

call :updatestat %FPATH% %SUM%
set /A DIFF=SUM-PREV

echo ���񍇌v:%SUM% �A�O�񍇌v:%PREV% �A��:%DIFF%


@rem �Ԃ₭(�O����s���̕������Ȃ�(%PREV%��-1)�łȂ��Ƃ�)
set TWEET=!PEEPS_TWEET_TEMPLATE:num=%DIFF%!
set TWEET=!TWEET:date=%DATE%!
if -1 == %PREV% (
  echo �f�B���N�g�� %TARGET_PATH% �̕������͑O��J�E���g����Ă��܂���B
  echo �Ȃ̂Ńc�C�[�g���܂���B
) else (
  echo %TWEET%
  %PEEPS_TW_PATH%\%PEEPS_TW_CMD% %TWEET%
)

goto :eof


@rem �T�u���[�`���i�΁j
@rem �t�@�C���T�C�Y
:filesize
@rem echo %1 %~z1
exit /b %~z1

@rem �t�@�C��������
:genfpath
set FPATH=%~1
set FPATH=%FPATH:\=_%
set FPATH=%FPATH::=_%
set FPATH=%FPATH: =_%
set FPATH="%SELF_PATH:"=%\stats\%FPATH%"
@rem echo %FPATH%
exit /b

@rem �O����s���̕������̍X�V
:updatestat
echo %2 > %1
exit /b

@rem �O����s���̕������̒T��
:readstat
set NUM=-1
if exist %~1 @(
   for /F %%n in (%~1) do @(
      set NUM=%%n
   )
)
exit /b %NUM%


:eof

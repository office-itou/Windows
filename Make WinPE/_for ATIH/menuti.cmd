@echo off
:TOP
    cls

:START
    echo.
    echo ���j���[���珈����I�����Ă��������B
    echo.
    echo 1. Acronis True Image ���N������
    echo 2. ���j���[���I�����A�R�}���h�v�����v�g��\������
    echo 3. ���̃��j���[��
    echo.

    set choice=
    set /p choice="���s���鏈�� >> "

    if "%choice%" == "1" goto RunATI
    if "%choice%" == "2" goto SHELL
    if "%choice%" == "3" goto NEXT

    echo "%choice%" �F�������l���I��������Ă��܂���B
    echo.
    goto START

:RunATI
    rem True Image �̎��s
    call ati -c
    echo True Image ���I�����܂����B

:NEXT
    echo.
    echo ���j���[���珈����I�����Ă��������B
    echo.
    echo 1. �d����؂�
    echo 2. �ċN������
    echo 3. �O�̃��j���[�ɖ߂�
    echo.

    set choice=
    set /p choice="���s���鏈�� >> "

    if "%choice%" == "1" call shutdown -s
    if "%choice%" == "2" call shutdown -r
    if "%choice%" == "3" goto TOP

    echo "%choice%" �F�������l���I��������Ă��܂���B
    echo.
    goto NEXT

:SHELL
    rem �R�}���h�v�����v�g
    echo ���j���[���I�����܂����B
    echo �ēx���j���[���Ăяo���Ƃ��ɂ� menuti �Ɠ��͂��Ă��������B
    echo �d����؂�Ƃ��ɂ� shutdown -s �Ɠ��͂��Ă��������B

:DONE

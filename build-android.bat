@echo off
echo ========================================
echo    IPTV Player - Build Android
echo ========================================

cd android

echo Limpando build anterior...
call gradlew clean

echo Verificando dependencias...
call gradlew dependencies

echo Compilando versao debug...
call gradlew assembleDebug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build concluido com sucesso!
    echo APK localizado em: app\build\outputs\apk\debug\
    echo ========================================
    
    echo Deseja instalar no dispositivo conectado? (s/n)
    set /p install=
    if /i "%install%"=="s" (
        echo Instalando no dispositivo...
        adb install -r app\build\outputs\apk\debug\app-debug.apk
        if %ERRORLEVEL% EQU 0 (
            echo App instalado com sucesso!
            echo Iniciando app...
            adb shell am start -n com.iptv.player/.MainActivity
        ) else (
            echo Erro na instalacao. Verifique se o dispositivo esta conectado.
        )
    )
) else (
    echo.
    echo ========================================
    echo Erro no build! Verifique os logs acima.
    echo ========================================
)

pause
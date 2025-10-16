@echo off
echo ========================================
echo    IPTV Player - Build Release
echo ========================================

cd android

echo Limpando build anterior...
call gradlew clean

echo Verificando configuracao de release...
if not exist "app\release-key.keystore" (
    echo.
    echo AVISO: Keystore nao encontrado!
    echo Gerando keystore para release...
    echo.
    keytool -genkey -v -keystore app\release-key.keystore -alias iptv-player -keyalg RSA -keysize 2048 -validity 10000
)

echo Compilando versao release...
call gradlew assembleRelease

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build release concluido com sucesso!
    echo APK localizado em: app\build\outputs\apk\release\
    echo ========================================
    
    echo Gerando informacoes do APK...
    call gradlew app:assembleRelease --info | findstr "APK"
    
    echo.
    echo Deseja gerar AAB para Google Play? (s/n)
    set /p bundle=
    if /i "%bundle%"=="s" (
        echo Gerando Android App Bundle...
        call gradlew bundleRelease
        if %ERRORLEVEL% EQU 0 (
            echo AAB gerado em: app\build\outputs\bundle\release\
        )
    )
) else (
    echo.
    echo ========================================
    echo Erro no build release! Verifique:
    echo 1. Keystore configurado corretamente
    echo 2. Senhas no gradle.properties
    echo 3. Configuracao de signing no build.gradle
    echo ========================================
)

pause
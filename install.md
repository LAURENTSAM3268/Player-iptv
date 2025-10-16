# Guia de Instalação - IPTV Player

## Pré-requisitos

### Android
- Android Studio 4.0 ou superior
- JDK 8 ou superior
- Android SDK API 21+ (Android 5.0)
- Gradle 7.0+

### iOS
- Xcode 12.0 ou superior
- iOS 12.0 ou superior
- Conta de desenvolvedor Apple (para dispositivos físicos)
- macOS 10.15+

## Instalação Android

### 1. Configuração do Ambiente
```bash
# Verificar Java
java -version

# Verificar Android SDK
echo $ANDROID_HOME

# Instalar dependências
cd android
./gradlew build
```

### 2. Build Debug
```bash
cd android
./gradlew assembleDebug
```

### 3. Instalação no Dispositivo
```bash
# Via ADB
adb install app/build/outputs/apk/debug/app-debug.apk

# Ou via Android Studio
# File → Open → Selecionar pasta android/
# Run → Run 'app'
```

### 4. Build Release
```bash
# Gerar keystore (primeira vez)
keytool -genkey -v -keystore release-key.keystore -alias iptv-player -keyalg RSA -keysize 2048 -validity 10000

# Build release
./gradlew assembleRelease
```

## Instalação iOS

### 1. Abrir Projeto
```bash
# Abrir no Xcode
open ios/IPTVPlayer.xcodeproj
```

### 2. Configurar Signing
1. Selecionar projeto IPTVPlayer
2. Target → IPTVPlayer
3. Signing & Capabilities
4. Selecionar Team (conta desenvolvedor)
5. Bundle Identifier único

### 3. Build e Run
```bash
# Via Xcode
⌘ + R (Build & Run)

# Via linha de comando
xcodebuild -project IPTVPlayer.xcodeproj -scheme IPTVPlayer -destination 'platform=iOS Simulator,name=iPhone 12' build
```

### 4. Distribuição TestFlight
1. Archive → Product → Archive
2. Distribute App → App Store Connect
3. Upload para TestFlight

## Configuração de Desenvolvimento

### Android - Debugging
```bash
# Logs em tempo real
adb logcat | grep IPTV

# Limpar logs
adb logcat -c

# Instalar e executar
adb install -r app-debug.apk && adb shell am start -n com.iptv.player/.MainActivity
```

### iOS - Debugging
```bash
# Console logs
xcrun simctl spawn booted log stream --predicate 'subsystem contains "com.iptv.player"'

# Crash logs
~/Library/Logs/DiagnosticReports/
```

## Troubleshooting

### Problemas Comuns Android

**Gradle Build Failed:**
```bash
# Limpar cache
./gradlew clean

# Atualizar Gradle Wrapper
./gradlew wrapper --gradle-version 7.5
```

**ExoPlayer não funciona:**
- Verificar permissões INTERNET no manifest
- Testar com URL HTTP simples primeiro
- Verificar ProGuard rules para release

**Room Database erro:**
```bash
# Adicionar annotation processor
annotationProcessor 'androidx.room:room-compiler:2.5.0'
```

### Problemas Comuns iOS

**Build Failed:**
- Verificar iOS Deployment Target (12.0+)
- Limpar build folder: ⌘ + Shift + K
- Verificar signing certificates

**AVPlayer não reproduz:**
- Verificar Info.plist NSAppTransportSecurity
- Testar com URL HTTPS
- Verificar permissões de rede

**Background Audio não funciona:**
- Verificar UIBackgroundModes no Info.plist
- Configurar AVAudioSession corretamente

## Otimizações de Performance

### Android
```gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### iOS
```swift
// Otimizar build settings
SWIFT_COMPILATION_MODE = wholemodule
SWIFT_OPTIMIZATION_LEVEL = -O
```

## Testes

### Android - Testes Unitários
```bash
./gradlew test
```

### Android - Testes UI
```bash
./gradlew connectedAndroidTest
```

### iOS - Testes
```bash
xcodebuild test -project IPTVPlayer.xcodeproj -scheme IPTVPlayer -destination 'platform=iOS Simulator,name=iPhone 12'
```

## Distribuição

### Android - Google Play
1. Build release APK/AAB
2. Upload para Play Console
3. Configurar store listing
4. Submeter para revisão

### iOS - App Store
1. Archive no Xcode
2. Upload para App Store Connect
3. Configurar metadata
4. Submeter para revisão

## Configurações Adicionais

### Proxy para Desenvolvimento
```bash
# Android - usar proxy local
adb shell settings put global http_proxy 192.168.1.100:8080

# iOS - configurar proxy no simulador
Simulator → Device → Network → Configure Proxy
```

### Certificados SSL Personalizados
- Android: Adicionar em res/raw/
- iOS: Adicionar no bundle e configurar NSURLSession

### Logs de Produção
- Android: Firebase Crashlytics
- iOS: Firebase Crashlytics ou Xcode Organizer
# Configuração do IPTV Player

## Configurações de Streaming

### Buffer Settings (Android)
```kotlin
// Em PlaybackService.kt
DefaultLoadControl.Builder()
    .setBufferDurationsMs(
        15000,  // Min buffer (15s)
        50000,  // Max buffer (50s)
        1000,   // Buffer for playback (1s)
        5000    // Buffer for rebuffer (5s)
    )
```

### Timeout Settings
```kotlin
// HTTP timeouts
setConnectTimeoutMs(10000)  // 10s conexão
setReadTimeoutMs(10000)     // 10s leitura
```

### iOS Buffer Settings
```swift
// Em PlayerViewController.swift
let preferredForwardBufferDuration: TimeInterval = 30.0
player.automaticallyWaitsToMinimizeStalling = true
```

## Configurações de Proxy

### Formato de URL de Proxy
```
http://proxy.exemplo.com:8080/
https://proxy.exemplo.com:8443/
socks5://proxy.exemplo.com:1080/
```

### Configuração no App
1. Abrir Configurações
2. Inserir URL do proxy
3. Testar conexão
4. Aplicar a todos os streams

## Formatos M3U Suportados

### M3U Básico
```
#EXTM3U
#EXTINF:-1,Canal 1
http://stream.exemplo.com/canal1.m3u8
#EXTINF:-1,Canal 2
http://stream.exemplo.com/canal2.ts
```

### M3U Plus (Estendido)
```
#EXTM3U
#EXTINF:-1 group-title="Esportes" tvg-logo="http://logo.com/espn.png" tvg-id="espn",ESPN
http://stream.exemplo.com/espn.m3u8
#EXTINF:-1 group-title="Filmes" tvg-logo="http://logo.com/hbo.png",HBO
http://stream.exemplo.com/hbo.m3u8
```

### Atributos Suportados
- `group-title`: Categoria do canal
- `tvg-logo`: URL do logo
- `tvg-id`: ID único do canal
- `tvg-name`: Nome alternativo
- `radio`: Indica se é rádio (true/false)

## Configurações de Rede

### User-Agent Personalizado
```
Android: IPTVPlayer/1.0 (Android)
iOS: IPTVPlayer/1.0 (iOS)
```

### Headers HTTP Customizados
```kotlin
// Android
dataSourceFactory.setDefaultRequestProperties(mapOf(
    "User-Agent" to "IPTVPlayer/1.0",
    "Referer" to "https://exemplo.com"
))
```

```swift
// iOS
var request = URLRequest(url: url)
request.setValue("IPTVPlayer/1.0", forHTTPHeaderField: "User-Agent")
```

## Configurações de Interface

### Tema Escuro (Android)
```xml
<!-- Em styles.xml -->
<style name="AppTheme.Dark" parent="Theme.AppCompat">
    <item name="colorPrimary">#424242</item>
    <item name="colorPrimaryDark">#212121</item>
    <item name="android:windowBackground">#303030</item>
</style>
```

### Cores Personalizadas
```xml
<color name="primary_color">#2196F3</color>
<color name="accent_color">#FF4081</color>
<color name="background_dark">#303030</color>
<color name="text_primary_dark">#FFFFFF</color>
```

## Configurações de Performance

### Android ProGuard Rules
```proguard
# ExoPlayer
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Room
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
```

### iOS Optimization
```swift
// Otimizar reprodução
player.automaticallyWaitsToMinimizeStalling = false
player.playbackBufferEmpty = true
```

## Configurações de Debug

### Android Logging
```kotlin
// Habilitar logs detalhados
if (BuildConfig.DEBUG) {
    Log.d("IPTV", "Stream URL: $url")
    Log.d("IPTV", "Buffer status: ${player.bufferedPercentage}%")
}
```

### iOS Logging
```swift
// Console logging
#if DEBUG
print("IPTV: Stream URL: \(url)")
print("IPTV: Player status: \(player.status)")
#endif
```

## Configurações de Segurança

### Certificados SSL
```kotlin
// Android - aceitar certificados personalizados
val trustManager = object : X509TrustManager {
    override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {}
    override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
}
```

### Whitelist de Domínios
```kotlin
val allowedDomains = listOf(
    "stream.exemplo.com",
    "iptv.exemplo.com",
    "cdn.exemplo.com"
)
```

## Configurações de Backup

### Exportar Configurações
```json
{
    "version": "1.0",
    "playlists": [...],
    "favorites": [...],
    "settings": {
        "proxy_url": "",
        "buffer_size": 30,
        "dark_theme": true
    }
}
```

### Importar Configurações
1. Selecionar arquivo JSON
2. Validar formato
3. Aplicar configurações
4. Reiniciar app se necessário

## Configurações Avançadas

### Reconexão Automática
```kotlin
// Tentativas de reconexão
private val maxRetries = 3
private val retryDelayMs = 3000L

// Backoff exponencial
private fun calculateRetryDelay(attempt: Int): Long {
    return retryDelayMs * (2.0.pow(attempt.toDouble())).toLong()
}
```

### Cache de Metadados
```kotlin
// Cache de informações de canais
private val cacheSize = 100 * 1024 * 1024 // 100MB
private val cache = LruCache<String, Channel>(cacheSize)
```

### Configurações de Qualidade
```kotlin
// Seleção automática de qualidade
trackSelector.setParameters(
    trackSelector.buildUponParameters()
        .setMaxVideoSizeSd()
        .setPreferredAudioLanguage("pt")
)
```
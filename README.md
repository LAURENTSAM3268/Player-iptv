# IPTV Player Nativo

Um player IPTV avançado para Android e iOS que reproduz listas M3U/M3U Plus e streams HLS usando players nativos do sistema.

## Características

### Funcionalidades Principais
- ✅ Reprodução de listas IPTV (M3U/M3U Plus)
- ✅ Suporte a streams HLS (.m3u8/.ts)
- ✅ Players nativos (ExoPlayer/AVPlayer)
- ✅ Reprodução em background
- ✅ Picture-in-Picture (PiP)
- ✅ Controles básicos (play, pause, stop, volume)
- ✅ Gerenciamento de favoritos
- ✅ Histórico de reprodução
- ✅ Reconexão automática
- ✅ Suporte a proxy
- ✅ Exportar/Importar listas M3U
- ✅ Tema escuro
- ✅ Log de erros e debug

### Tecnologias Utilizadas

#### Android
- **Linguagem**: Kotlin
- **Player**: ExoPlayer 2.19.1
- **Database**: Room
- **Networking**: OkHttp
- **UI**: Material Design
- **Minimum SDK**: 21 (Android 5.0)

#### iOS
- **Linguagem**: Swift
- **Player**: AVPlayer/AVKit
- **Persistência**: UserDefaults + JSON
- **UI**: UIKit
- **Minimum iOS**: 12.0

## Instalação

### Android

1. **Pré-requisitos**
   - Android Studio 4.0+
   - JDK 8+
   - Android SDK 21+

2. **Build**
   ```bash
   cd android
   ./gradlew assembleDebug
   ```

3. **Instalação**
   ```bash
   adb install app/build/outputs/apk/debug/app-debug.apk
   ```

### iOS

1. **Pré-requisitos**
   - Xcode 12.0+
   - iOS 12.0+
   - Conta de desenvolvedor Apple

2. **Build**
   - Abrir `ios/IPTVPlayer.xcodeproj` no Xcode
   - Selecionar dispositivo/simulador
   - Build & Run (⌘+R)

## Configuração

### Carregando Playlists

1. **URL Remota**
   - Digite a URL da playlist M3U
   - Toque em "Carregar Playlist"
   - Os canais serão listados por categoria

2. **Arquivo Local** (Android)
   - Coloque o arquivo .m3u na pasta Downloads
   - Use file:// URL no campo de entrada

### Configurações de Proxy

Para usar proxy com streams:

1. Acesse Configurações
2. Digite a URL do proxy
3. Formato: `http://proxy.exemplo.com:8080/`
4. O proxy será aplicado automaticamente

### Exportar/Importar Listas

**Exportar:**
- Menu → Exportar → Selecionar canais
- Arquivo salvo em Downloads/playlist.m3u

**Importar:**
- Menu → Importar → Selecionar arquivo .m3u

## Uso

### Reprodução Básica

1. Carregue uma playlist M3U
2. Selecione categoria (opcional)
3. Toque no canal desejado
4. Player abrirá automaticamente

### Controles do Player

- **Toque na tela**: Mostrar/ocultar controles
- **Play/Pause**: Controlar reprodução
- **Stop**: Parar e voltar à lista
- **Volume**: Ajustar volume
- **PiP**: Picture-in-Picture (Android 8+/iOS 14+)

### Favoritos

- Toque longo no canal → Adicionar aos favoritos
- Filtrar por favoritos no menu principal

### Histórico

- Acesso automático aos últimos 50 canais reproduzidos
- Menu → Histórico

## Estrutura do Projeto

```
Player/
├── android/                 # Projeto Android
│   ├── app/src/main/java/com/iptv/
│   │   ├── Channel.kt       # Modelos de dados
│   │   ├── M3UParser.kt     # Parser M3U
│   │   ├── MainActivity.kt  # Tela principal
│   │   ├── PlayerActivity.kt # Player
│   │   ├── ChannelAdapter.kt # Lista de canais
│   │   ├── database/        # Room database
│   │   └── service/         # Serviço de reprodução
│   └── app/src/main/res/    # Resources Android
├── ios/                     # Projeto iOS
│   └── IPTVPlayer/
│       ├── Models/          # Modelos Swift
│       ├── Views/           # Storyboards
│       └── Controllers/     # View Controllers
├── shared/                  # Código compartilhado
└── docs/                   # Documentação
```

## Formatos Suportados

### Playlists
- M3U (.m3u)
- M3U Plus (.m3u8) com metadados estendidos

### Streams
- HLS (.m3u8)
- Transport Stream (.ts)
- HTTP/HTTPS streams
- RTMP (limitado)

### Metadados M3U Plus
```
#EXTINF:-1 group-title="Esportes" tvg-logo="logo.png",Canal Esporte
http://stream.exemplo.com/esporte.m3u8
```

## Troubleshooting

### Problemas Comuns

**Stream não carrega:**
- Verificar conectividade
- Testar URL em navegador
- Verificar se precisa de proxy

**Buffering excessivo:**
- Verificar velocidade da internet
- Ajustar configurações de buffer (Android)

**PiP não funciona:**
- Android: Verificar se está habilitado nas configurações
- iOS: Requer iOS 14+ e stream compatível

**Erro de CORS:**
- Usar proxy HTTP
- Players nativos ignoram CORS automaticamente

### Logs de Debug

**Android:**
```bash
adb logcat | grep IPTV
```

**iOS:**
- Console do Xcode durante desenvolvimento
- Crash logs em Configurações → Privacidade

## Performance

### Otimizações Implementadas

- **Buffer adaptativo**: Ajuste automático baseado na conexão
- **Reconexão inteligente**: Retry automático em falhas
- **Cache de metadados**: Informações de canais persistidas
- **Lazy loading**: Carregamento sob demanda
- **Memory management**: Limpeza automática de recursos

### Configurações Recomendadas

- **Buffer mínimo**: 15s
- **Buffer máximo**: 50s
- **Timeout conexão**: 10s
- **Retry attempts**: 3x com backoff

## Contribuição

1. Fork o projeto
2. Crie branch para feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para branch (`git push origin feature/nova-funcionalidade`)
5. Abra Pull Request

## Licença

Este projeto está licenciado sob MIT License - veja [LICENSE](LICENSE) para detalhes.

## Suporte

Para suporte e dúvidas:
- Abra uma issue no GitHub
- Email: suporte@iptvplayer.com

## Changelog

### v1.0.0
- Lançamento inicial
- Suporte M3U/HLS
- Players nativos
- PiP e background playback
- Favoritos e histórico
- Reconexão automática
- Suporte a proxy
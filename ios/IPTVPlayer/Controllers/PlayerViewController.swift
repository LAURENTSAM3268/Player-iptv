import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var pipButton: UIButton!
    
    var channel: Channel?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var controlsTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayer()
        
        if let channel = channel {
            playChannel(channel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupPlayer()
    }
    
    private func setupUI() {
        channelNameLabel.text = channel?.name ?? "Canal"
        statusLabel.text = "Carregando..."
        
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)
        pipButton.addTarget(self, action: #selector(pipTapped), for: .touchUpInside)
        
        // Gesture para mostrar/ocultar controles
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped))
        playerView.addGestureRecognizer(tapGesture)
        
        // Configurar volume inicial
        volumeSlider.value = 0.5
        
        // Verificar suporte PiP
        if #available(iOS 14.0, *) {
            pipButton.isHidden = false
        } else {
            pipButton.isHidden = true
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            playerView.layer.addSublayer(playerLayer)
        }
        
        // Observer para status do player
        player?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
        
        // Observer para tempo de reprodução
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            // Atualizar UI se necessário
        }
        
        // Configurar sessão de áudio para background
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Erro ao configurar sessão de áudio: \(error)")
        }
    }
    
    private func playChannel(_ channel: Channel) {
        guard let url = URL(string: channel.url) else {
            statusLabel.text = "URL inválida"
            return
        }
        
        statusLabel.text = "Conectando..."
        
        let playerItem = AVPlayerItem(url: url)
        
        // Observer para erros
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemFailedToPlay),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem
        )
        
        // Observer para fim da reprodução
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        player?.replaceCurrentItem(with: playerItem)
        player?.volume = volumeSlider.value
        player?.play()
        
        updatePlayPauseButton()
    }
    
    @objc private func playPauseTapped() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
        
        updatePlayPauseButton()
    }
    
    @objc private func stopTapped() {
        player?.pause()
        dismiss(animated: true)
    }
    
    @objc private func volumeChanged() {
        player?.volume = volumeSlider.value
    }
    
    @objc private func pipTapped() {
        if #available(iOS 14.0, *) {
            // Implementar PiP se disponível
        }
    }
    
    @objc private func playerViewTapped() {
        toggleControls()
    }
    
    private func toggleControls() {
        let isHidden = controlsView.alpha == 0
        
        UIView.animate(withDuration: 0.3) {
            self.controlsView.alpha = isHidden ? 1.0 : 0.0
        }
        
        if isHidden {
            startControlsTimer()
        } else {
            stopControlsTimer()
        }
    }
    
    private func startControlsTimer() {
        stopControlsTimer()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.controlsView.alpha = 0.0
            }
        }
    }
    
    private func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
    
    private func updatePlayPauseButton() {
        let isPlaying = player?.timeControlStatus == .playing
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func playerItemFailedToPlay() {
        statusLabel.text = "Erro na reprodução"
        
        // Tentar reconectar após 3 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if let channel = self?.channel {
                self?.playChannel(channel)
            }
        }
    }
    
    @objc private func playerItemDidReachEnd() {
        statusLabel.text = "Reprodução finalizada"
        updatePlayPauseButton()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            if let player = player {
                switch player.status {
                case .readyToPlay:
                    statusLabel.text = "Reproduzindo"
                case .failed:
                    statusLabel.text = "Erro na reprodução"
                case .unknown:
                    statusLabel.text = "Carregando..."
                @unknown default:
                    break
                }
            }
        } else if keyPath == "timeControlStatus" {
            if let player = player {
                switch player.timeControlStatus {
                case .playing:
                    statusLabel.text = "Reproduzindo"
                case .paused:
                    statusLabel.text = "Pausado"
                case .waitingToPlayAtSpecifiedRate:
                    statusLabel.text = "Carregando..."
                @unknown default:
                    break
                }
                updatePlayPauseButton()
            }
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        
        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        
        NotificationCenter.default.removeObserver(self)
        
        stopControlsTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerView.bounds
    }
}
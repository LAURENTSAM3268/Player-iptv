import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var channelsTableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    private var channels: [Channel] = []
    private var filteredChannels: [Channel] = []
    private var categories: [String] = []
    private let parser = M3UParser()
    private let dataManager = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadChannels()
    }
    
    private func setupUI() {
        title = "IPTV Player"
        
        channelsTableView.delegate = self
        channelsTableView.dataSource = self
        channelsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChannelCell")
        
        loadButton.addTarget(self, action: #selector(loadPlaylistTapped), for: .touchUpInside)
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        
        statusLabel.text = "Pronto"
    }
    
    @objc private func loadPlaylistTapped() {
        guard let urlString = urlTextField.text, !urlString.isEmpty,
              let url = URL(string: urlString) else {
            showAlert(message: "URL inválida")
            return
        }
        
        statusLabel.text = "Carregando playlist..."
        loadButton.isEnabled = false
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.loadButton.isEnabled = true
                
                if let error = error {
                    self?.statusLabel.text = "Erro ao carregar"
                    self?.showAlert(message: "Erro: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data,
                      let content = String(data: data, encoding: .utf8) else {
                    self?.statusLabel.text = "Erro ao processar dados"
                    return
                }
                
                self?.processPlaylist(content: content)
            }
        }.resume()
    }
    
    private func processPlaylist(content: String) {
        let parsedChannels = parser.parseM3U(content: content)
        
        channels = parsedChannels
        dataManager.saveChannels(channels)
        
        updateCategories()
        filterChannels()
        
        statusLabel.text = "Carregados \(channels.count) canais"
        channelsTableView.reloadData()
    }
    
    private func loadChannels() {
        channels = dataManager.loadChannels()
        updateCategories()
        filterChannels()
        channelsTableView.reloadData()
    }
    
    private func updateCategories() {
        categories = Array(Set(channels.map { $0.category })).sorted()
        
        categorySegmentedControl.removeAllSegments()
        categorySegmentedControl.insertSegment(withTitle: "Todas", at: 0, animated: false)
        
        for (index, category) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category, at: index + 1, animated: false)
        }
        
        categorySegmentedControl.selectedSegmentIndex = 0
    }
    
    @objc private func categoryChanged() {
        filterChannels()
        channelsTableView.reloadData()
    }
    
    private func filterChannels() {
        let selectedIndex = categorySegmentedControl.selectedSegmentIndex
        
        if selectedIndex == 0 {
            filteredChannels = channels
        } else if selectedIndex > 0 && selectedIndex <= categories.count {
            let selectedCategory = categories[selectedIndex - 1]
            filteredChannels = channels.filter { $0.category == selectedCategory }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChannels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath)
        let channel = filteredChannels[indexPath.row]
        
        cell.textLabel?.text = channel.name
        cell.detailTextLabel?.text = channel.category
        cell.accessoryType = channel.isFavorite ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = filteredChannels[indexPath.row]
        playChannel(channel)
    }
    
    private func playChannel(_ channel: Channel) {
        // Salvar no histórico
        let history = PlaybackHistory(channelId: channel.id, channelName: channel.name)
        dataManager.addToHistory(history)
        
        // Abrir PlayerViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
            playerVC.channel = channel
            present(playerVC, animated: true)
        }
    }
}
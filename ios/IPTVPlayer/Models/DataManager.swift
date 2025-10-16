import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let channelsKey = "SavedChannels"
    private let playlistsKey = "SavedPlaylists"
    private let historyKey = "PlaybackHistory"
    private let favoritesKey = "FavoriteChannels"
    
    private init() {}
    
    // MARK: - Channels
    func saveChannels(_ channels: [Channel]) {
        if let data = try? JSONEncoder().encode(channels) {
            UserDefaults.standard.set(data, forKey: channelsKey)
        }
    }
    
    func loadChannels() -> [Channel] {
        guard let data = UserDefaults.standard.data(forKey: channelsKey),
              let channels = try? JSONDecoder().decode([Channel].self, from: data) else {
            return []
        }
        return channels
    }
    
    // MARK: - Playlists
    func savePlaylists(_ playlists: [Playlist]) {
        if let data = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(data, forKey: playlistsKey)
        }
    }
    
    func loadPlaylists() -> [Playlist] {
        guard let data = UserDefaults.standard.data(forKey: playlistsKey),
              let playlists = try? JSONDecoder().decode([Playlist].self, from: data) else {
            return []
        }
        return playlists
    }
    
    func addPlaylist(_ playlist: Playlist) {
        var playlists = loadPlaylists()
        playlists.append(playlist)
        savePlaylists(playlists)
    }
    
    func removePlaylist(_ playlist: Playlist) {
        var playlists = loadPlaylists()
        playlists.removeAll { $0.id == playlist.id }
        savePlaylists(playlists)
    }
    
    // MARK: - History
    func addToHistory(_ history: PlaybackHistory) {
        var historyList = loadHistory()
        
        // Remover entrada anterior do mesmo canal se existir
        historyList.removeAll { $0.channelId == history.channelId }
        
        // Adicionar no início
        historyList.insert(history, at: 0)
        
        // Manter apenas os últimos 50 itens
        if historyList.count > 50 {
            historyList = Array(historyList.prefix(50))
        }
        
        saveHistory(historyList)
    }
    
    func loadHistory() -> [PlaybackHistory] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([PlaybackHistory].self, from: data) else {
            return []
        }
        return history
    }
    
    private func saveHistory(_ history: [PlaybackHistory]) {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
    
    // MARK: - Favorites
    func toggleFavorite(channelId: UUID) {
        var favorites = loadFavorites()
        
        if favorites.contains(channelId) {
            favorites.removeAll { $0 == channelId }
        } else {
            favorites.append(channelId)
        }
        
        saveFavorites(favorites)
    }
    
    func isFavorite(channelId: UUID) -> Bool {
        let favorites = loadFavorites()
        return favorites.contains(channelId)
    }
    
    func loadFavorites() -> [UUID] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return favorites
    }
    
    private func saveFavorites(_ favorites: [UUID]) {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    // MARK: - M3U Export/Import
    func exportM3U(channels: [Channel]) -> String {
        let parser = M3UParser()
        return parser.generateM3U(channels: channels)
    }
    
    func importM3U(content: String) -> [Channel] {
        let parser = M3UParser()
        return parser.parseM3U(content: content)
    }
    
    // MARK: - Settings
    func saveSetting<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadSetting<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let value = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        return value
    }
    
    // MARK: - Proxy Settings
    func saveProxyURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "ProxyURL")
    }
    
    func loadProxyURL() -> String? {
        return UserDefaults.standard.string(forKey: "ProxyURL")
    }
}
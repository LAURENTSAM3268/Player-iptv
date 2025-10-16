import Foundation

struct Channel: Codable, Identifiable {
    let id = UUID()
    let name: String
    let url: String
    let category: String
    let logo: String
    var isFavorite: Bool = false
    var lastPlayed: Date?
    
    init(name: String, url: String, category: String = "", logo: String = "") {
        self.name = name
        self.url = url
        self.category = category
        self.logo = logo
    }
}

struct Playlist: Codable, Identifiable {
    let id = UUID()
    let name: String
    let url: String
    let isLocal: Bool
    let lastUpdated: Date
    
    init(name: String, url: String, isLocal: Bool = false) {
        self.name = name
        self.url = url
        self.isLocal = isLocal
        self.lastUpdated = Date()
    }
}

struct PlaybackHistory: Codable, Identifiable {
    let id = UUID()
    let channelId: UUID
    let channelName: String
    let playedAt: Date
    let duration: TimeInterval
    
    init(channelId: UUID, channelName: String, duration: TimeInterval = 0) {
        self.channelId = channelId
        self.channelName = channelName
        self.playedAt = Date()
        self.duration = duration
    }
}
import Foundation

class M3UParser {
    
    func parseM3U(content: String) -> [Channel] {
        var channels: [Channel] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentChannel: Channel?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.hasPrefix("#EXTINF:") {
                currentChannel = parseExtInf(line: trimmedLine)
            } else if trimmedLine.hasPrefix("http") && currentChannel != nil {
                if var channel = currentChannel {
                    let finalChannel = Channel(
                        name: channel.name,
                        url: trimmedLine,
                        category: channel.category,
                        logo: channel.logo
                    )
                    channels.append(finalChannel)
                }
                currentChannel = nil
            }
        }
        
        return channels
    }
    
    private func parseExtInf(line: String) -> Channel {
        var name = "Canal Desconhecido"
        var category = "Geral"
        var logo = ""
        
        // Extrair nome do canal
        if let nameRange = line.range(of: ",") {
            name = String(line[nameRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Extrair categoria
        if let categoryMatch = line.range(of: "group-title=\"") {
            let startIndex = categoryMatch.upperBound
            if let endIndex = line[startIndex...].range(of: "\"")?.lowerBound {
                category = String(line[startIndex..<endIndex])
            }
        }
        
        // Extrair logo
        if let logoMatch = line.range(of: "tvg-logo=\"") {
            let startIndex = logoMatch.upperBound
            if let endIndex = line[startIndex...].range(of: "\"")?.lowerBound {
                logo = String(line[startIndex..<endIndex])
            }
        }
        
        return Channel(name: name, url: "", category: category, logo: logo)
    }
    
    func generateM3U(channels: [Channel]) -> String {
        var content = "#EXTM3U\n"
        
        for channel in channels {
            content += "#EXTINF:-1 group-title=\"\(channel.category)\" tvg-logo=\"\(channel.logo)\",\(channel.name)\n"
            content += "\(channel.url)\n"
        }
        
        return content
    }
}
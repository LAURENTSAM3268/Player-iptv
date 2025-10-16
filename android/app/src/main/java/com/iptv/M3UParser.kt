package com.iptv

import java.io.BufferedReader
import java.io.StringReader

class M3UParser {
    
    fun parseM3U(content: String): List<Channel> {
        val channels = mutableListOf<Channel>()
        val reader = BufferedReader(StringReader(content))
        
        var line: String?
        var currentChannel: Channel? = null
        
        while (reader.readLine().also { line = it } != null) {
            line?.let { currentLine ->
                when {
                    currentLine.startsWith("#EXTINF:") -> {
                        currentChannel = parseExtInf(currentLine)
                    }
                    currentLine.startsWith("http") && currentChannel != null -> {
                        currentChannel?.let { channel ->
                            channels.add(channel.copy(url = currentLine.trim()))
                        }
                        currentChannel = null
                    }
                }
            }
        }
        
        return channels
    }
    
    private fun parseExtInf(line: String): Channel {
        var name = ""
        var category = ""
        var logo = ""
        
        // Extrair nome do canal
        val nameMatch = Regex(",(.+)$").find(line)
        name = nameMatch?.groupValues?.get(1)?.trim() ?: "Canal Desconhecido"
        
        // Extrair categoria
        val categoryMatch = Regex("group-title=\"([^\"]+)\"").find(line)
        category = categoryMatch?.groupValues?.get(1) ?: "Geral"
        
        // Extrair logo
        val logoMatch = Regex("tvg-logo=\"([^\"]+)\"").find(line)
        logo = logoMatch?.groupValues?.get(1) ?: ""
        
        return Channel(
            name = name,
            url = "",
            category = category,
            logo = logo
        )
    }
    
    fun generateM3U(channels: List<Channel>): String {
        val builder = StringBuilder()
        builder.appendLine("#EXTM3U")
        
        channels.forEach { channel ->
            builder.appendLine("#EXTINF:-1 group-title=\"${channel.category}\" tvg-logo=\"${channel.logo}\",${channel.name}")
            builder.appendLine(channel.url)
        }
        
        return builder.toString()
    }
}
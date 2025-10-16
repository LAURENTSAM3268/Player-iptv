package com.iptv.database

import androidx.room.*
import androidx.room.Database
import com.iptv.Channel
import com.iptv.Playlist
import com.iptv.PlaybackHistory

@Dao
interface ChannelDao {
    @Query("SELECT * FROM channels ORDER BY name ASC")
    suspend fun getAllChannels(): List<Channel>
    
    @Query("SELECT * FROM channels WHERE category = :category ORDER BY name ASC")
    suspend fun getChannelsByCategory(category: String): List<Channel>
    
    @Query("SELECT * FROM channels WHERE isFavorite = 1 ORDER BY name ASC")
    suspend fun getFavoriteChannels(): List<Channel>
    
    @Query("SELECT DISTINCT category FROM channels ORDER BY category ASC")
    suspend fun getCategories(): List<String>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertChannels(channels: List<Channel>)
    
    @Update
    suspend fun updateChannel(channel: Channel)
    
    @Query("DELETE FROM channels")
    suspend fun deleteAllChannels()
}

@Dao
interface PlaylistDao {
    @Query("SELECT * FROM playlists ORDER BY name ASC")
    suspend fun getAllPlaylists(): List<Playlist>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertPlaylist(playlist: Playlist): Long
    
    @Delete
    suspend fun deletePlaylist(playlist: Playlist)
}

@Dao
interface HistoryDao {
    @Query("SELECT * FROM playback_history ORDER BY playedAt DESC LIMIT 50")
    suspend fun getRecentHistory(): List<PlaybackHistory>
    
    @Insert
    suspend fun insertHistory(history: PlaybackHistory)
    
    @Query("DELETE FROM playback_history WHERE playedAt < :timestamp")
    suspend fun deleteOldHistory(timestamp: Long)
}

@Database(
    entities = [Channel::class, Playlist::class, PlaybackHistory::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun channelDao(): ChannelDao
    abstract fun playlistDao(): PlaylistDao
    abstract fun historyDao(): HistoryDao
    
    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        fun getDatabase(context: android.content.Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "iptv_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
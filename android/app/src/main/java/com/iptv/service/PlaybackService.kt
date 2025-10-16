package com.iptv.service

import android.app.*
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import com.iptv.Channel
import com.iptv.R

class PlaybackService : Service() {
    
    private val binder = PlaybackBinder()
    private var exoPlayer: ExoPlayer? = null
    private var currentChannel: Channel? = null
    private var playbackListener: PlaybackListener? = null
    
    interface PlaybackListener {
        fun onPlaybackStateChanged(isPlaying: Boolean)
        fun onError(error: String)
        fun onBuffering(isBuffering: Boolean)
    }
    
    inner class PlaybackBinder : Binder() {
        fun getService(): PlaybackService = this@PlaybackService
    }
    
    override fun onCreate() {
        super.onCreate()
        initializePlayer()
        createNotificationChannel()
    }
    
    private fun initializePlayer() {
        exoPlayer = ExoPlayer.Builder(this)
            .setLoadControl(
                DefaultLoadControl.Builder()
                    .setBufferDurationsMs(15000, 50000, 1000, 5000)
                    .build()
            )
            .build()
            
        exoPlayer?.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(playbackState: Int) {
                when (playbackState) {
                    Player.STATE_BUFFERING -> playbackListener?.onBuffering(true)
                    Player.STATE_READY -> {
                        playbackListener?.onBuffering(false)
                        playbackListener?.onPlaybackStateChanged(exoPlayer?.isPlaying == true)
                    }
                    Player.STATE_ENDED -> playbackListener?.onPlaybackStateChanged(false)
                }
            }
            
            override fun onPlayerError(error: PlaybackException) {
                playbackListener?.onError("Erro de reprodução: ${error.message}")
                // Tentar reconectar após 3 segundos
                android.os.Handler(mainLooper).postDelayed({
                    currentChannel?.let { retryPlayback(it) }
                }, 3000)
            }
        })
    }
    
    fun playChannel(channel: Channel, proxyUrl: String? = null) {
        currentChannel = channel
        
        val dataSourceFactory = DefaultHttpDataSource.Factory().apply {
            setUserAgent("IPTVPlayer/1.0")
            setConnectTimeoutMs(10000)
            setReadTimeoutMs(10000)
        }
        
        val finalUrl = if (proxyUrl != null && proxyUrl.isNotEmpty()) {
            "$proxyUrl${channel.url}"
        } else {
            channel.url
        }
        
        val mediaSource = when {
            finalUrl.contains(".m3u8") -> {
                HlsMediaSource.Factory(dataSourceFactory)
                    .createMediaSource(MediaItem.fromUri(finalUrl))
            }
            else -> {
                com.google.android.exoplayer2.source.ProgressiveMediaSource.Factory(dataSourceFactory)
                    .createMediaSource(MediaItem.fromUri(finalUrl))
            }
        }
        
        exoPlayer?.apply {
            setMediaSource(mediaSource)
            prepare()
            play()
        }
        
        showNotification(channel)
    }
    
    private fun retryPlayback(channel: Channel) {
        playChannel(channel)
    }
    
    fun pause() {
        exoPlayer?.pause()
    }
    
    fun resume() {
        exoPlayer?.play()
    }
    
    fun stop() {
        exoPlayer?.stop()
        stopForeground(true)
    }
    
    fun setVolume(volume: Float) {
        exoPlayer?.volume = volume
    }
    
    fun isPlaying(): Boolean = exoPlayer?.isPlaying == true
    
    fun setPlaybackListener(listener: PlaybackListener) {
        this.playbackListener = listener
    }
    
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            "PLAYBACK_CHANNEL",
            "Reprodução IPTV",
            NotificationManager.IMPORTANCE_LOW
        )
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }
    
    private fun showNotification(channel: Channel) {
        val notification = NotificationCompat.Builder(this, "PLAYBACK_CHANNEL")
            .setContentTitle("Reproduzindo")
            .setContentText(channel.name)
            .setSmallIcon(R.drawable.ic_play)
            .setOngoing(true)
            .build()
            
        startForeground(1, notification)
    }
    
    override fun onBind(intent: Intent?): IBinder = binder
    
    override fun onDestroy() {
        super.onDestroy()
        exoPlayer?.release()
    }
}
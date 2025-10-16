package com.iptv

import android.app.PictureInPictureParams
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Rational
import android.view.View
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.iptv.service.PlaybackService

class PlayerActivity : AppCompatActivity() {
    
    private lateinit var playerView: StyledPlayerView
    private lateinit var controlsLayout: LinearLayout
    private lateinit var playPauseButton: ImageButton
    private lateinit var stopButton: ImageButton
    private lateinit var volumeSeekBar: SeekBar
    private lateinit var pipButton: ImageButton
    private lateinit var channelNameText: TextView
    private lateinit var statusText: TextView
    
    private var playbackService: PlaybackService? = null
    private var serviceBound = false
    private var channelName = ""
    
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as PlaybackService.PlaybackBinder
            playbackService = binder.getService()
            serviceBound = true
            
            playbackService?.let { service ->
                playerView.player = service.exoPlayer
                updatePlayPauseButton(service.isPlaying())
            }
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            playbackService = null
            serviceBound = false
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_player)
        
        channelName = intent.getStringExtra("channel_name") ?: ""
        
        initViews()
        setupControls()
        
        // Bind to service
        Intent(this, PlaybackService::class.java).also { intent ->
            bindService(intent, serviceConnection, BIND_AUTO_CREATE)
        }
    }
    
    private fun initViews() {
        playerView = findViewById(R.id.playerView)
        controlsLayout = findViewById(R.id.controlsLayout)
        playPauseButton = findViewById(R.id.playPauseButton)
        stopButton = findViewById(R.id.stopButton)
        volumeSeekBar = findViewById(R.id.volumeSeekBar)
        pipButton = findViewById(R.id.pipButton)
        channelNameText = findViewById(R.id.channelNameText)
        statusText = findViewById(R.id.statusText)
        
        channelNameText.text = channelName
        
        // Ocultar controles após 3 segundos
        playerView.setOnClickListener {
            toggleControlsVisibility()
        }
    }
    
    private fun setupControls() {
        playPauseButton.setOnClickListener {
            playbackService?.let { service ->
                if (service.isPlaying()) {
                    service.pause()
                } else {
                    service.resume()
                }
                updatePlayPauseButton(service.isPlaying())
            }
        }
        
        stopButton.setOnClickListener {
            playbackService?.stop()
            finish()
        }
        
        volumeSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) {
                    val volume = progress / 100f
                    playbackService?.setVolume(volume)
                }
            }
            
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        
        pipButton.setOnClickListener {
            enterPictureInPictureMode()
        }
        
        // Configurar PiP para Android 8+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            pipButton.visibility = View.VISIBLE
        } else {
            pipButton.visibility = View.GONE
        }
    }
    
    private fun updatePlayPauseButton(isPlaying: Boolean) {
        playPauseButton.setImageResource(
            if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
        )
    }
    
    private fun toggleControlsVisibility() {
        controlsLayout.visibility = if (controlsLayout.visibility == View.VISIBLE) {
            View.GONE
        } else {
            View.VISIBLE
        }
        
        // Auto-hide após 3 segundos
        if (controlsLayout.visibility == View.VISIBLE) {
            controlsLayout.postDelayed({
                controlsLayout.visibility = View.GONE
            }, 3000)
        }
    }
    
    private fun enterPictureInPictureMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .build()
            enterPictureInPictureMode(params)
        }
    }
    
    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        
        if (isInPictureInPictureMode) {
            controlsLayout.visibility = View.GONE
            supportActionBar?.hide()
        } else {
            controlsLayout.visibility = View.VISIBLE
            supportActionBar?.show()
        }
    }
    
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && playbackService?.isPlaying() == true) {
            enterPictureInPictureMode()
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (serviceBound) {
            unbindService(serviceConnection)
            serviceBound = false
        }
    }
}
package com.iptv

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.iptv.database.AppDatabase
import com.iptv.service.PlaybackService
import kotlinx.coroutines.launch
import okhttp3.*
import java.io.IOException

class MainActivity : AppCompatActivity() {
    
    private lateinit var database: AppDatabase
    private lateinit var channelAdapter: ChannelAdapter
    private lateinit var categorySpinner: Spinner
    private lateinit var urlInput: EditText
    private lateinit var loadButton: Button
    private lateinit var channelsList: RecyclerView
    private lateinit var statusText: TextView
    
    private var playbackService: PlaybackService? = null
    private var serviceBound = false
    
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as PlaybackService.PlaybackBinder
            playbackService = binder.getService()
            serviceBound = true
            
            playbackService?.setPlaybackListener(object : PlaybackService.PlaybackListener {
                override fun onPlaybackStateChanged(isPlaying: Boolean) {
                    runOnUiThread {
                        statusText.text = if (isPlaying) "Reproduzindo" else "Pausado"
                    }
                }
                
                override fun onError(error: String) {
                    runOnUiThread {
                        statusText.text = "Erro: $error"
                        Toast.makeText(this@MainActivity, error, Toast.LENGTH_LONG).show()
                    }
                }
                
                override fun onBuffering(isBuffering: Boolean) {
                    runOnUiThread {
                        statusText.text = if (isBuffering) "Carregando..." else "Pronto"
                    }
                }
            })
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            playbackService = null
            serviceBound = false
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        database = AppDatabase.getDatabase(this)
        initViews()
        setupRecyclerView()
        loadChannels()
        
        // Bind to service
        Intent(this, PlaybackService::class.java).also { intent ->
            bindService(intent, serviceConnection, BIND_AUTO_CREATE)
        }
    }
    
    private fun initViews() {
        urlInput = findViewById(R.id.urlInput)
        loadButton = findViewById(R.id.loadButton)
        channelsList = findViewById(R.id.channelsList)
        categorySpinner = findViewById(R.id.categorySpinner)
        statusText = findViewById(R.id.statusText)
        
        loadButton.setOnClickListener {
            val url = urlInput.text.toString().trim()
            if (url.isNotEmpty()) {
                loadPlaylist(url)
            }
        }
    }
    
    private fun setupRecyclerView() {
        channelAdapter = ChannelAdapter { channel ->
            playChannel(channel)
        }
        
        channelsList.apply {
            layoutManager = LinearLayoutManager(this@MainActivity)
            adapter = channelAdapter
        }
    }
    
    private fun loadPlaylist(url: String) {
        statusText.text = "Carregando playlist..."
        
        val client = OkHttpClient()
        val request = Request.Builder().url(url).build()
        
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    statusText.text = "Erro ao carregar playlist"
                    Toast.makeText(this@MainActivity, "Erro: ${e.message}", Toast.LENGTH_LONG).show()
                }
            }
            
            override fun onResponse(call: Call, response: Response) {
                response.body?.string()?.let { content ->
                    val parser = M3UParser()
                    val channels = parser.parseM3U(content)
                    
                    lifecycleScope.launch {
                        database.channelDao().deleteAllChannels()
                        database.channelDao().insertChannels(channels)
                        loadChannels()
                        
                        runOnUiThread {
                            statusText.text = "Carregados ${channels.size} canais"
                        }
                    }
                }
            }
        })
    }
    
    private fun loadChannels() {
        lifecycleScope.launch {
            val channels = database.channelDao().getAllChannels()
            val categories = database.channelDao().getCategories()
            
            runOnUiThread {
                channelAdapter.updateChannels(channels)
                setupCategorySpinner(categories)
            }
        }
    }
    
    private fun setupCategorySpinner(categories: List<String>) {
        val allCategories = listOf("Todas") + categories
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, allCategories)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        categorySpinner.adapter = adapter
        
        categorySpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: android.view.View?, position: Int, id: Long) {
                val selectedCategory = allCategories[position]
                filterChannels(selectedCategory)
            }
            
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }
    
    private fun filterChannels(category: String) {
        lifecycleScope.launch {
            val channels = if (category == "Todas") {
                database.channelDao().getAllChannels()
            } else {
                database.channelDao().getChannelsByCategory(category)
            }
            
            runOnUiThread {
                channelAdapter.updateChannels(channels)
            }
        }
    }
    
    private fun playChannel(channel: Channel) {
        if (serviceBound) {
            playbackService?.playChannel(channel)
            
            // Salvar no histórico
            lifecycleScope.launch {
                database.historyDao().insertHistory(
                    PlaybackHistory(
                        channelId = channel.id,
                        channelName = channel.name
                    )
                )
            }
            
            // Abrir PlayerActivity
            val intent = Intent(this, PlayerActivity::class.java)
            intent.putExtra("channel_name", channel.name)
            startActivity(intent)
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
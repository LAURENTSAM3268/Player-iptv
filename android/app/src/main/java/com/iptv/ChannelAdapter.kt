package com.iptv

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class ChannelAdapter(
    private val onChannelClick: (Channel) -> Unit
) : RecyclerView.Adapter<ChannelAdapter.ChannelViewHolder>() {
    
    private var channels = listOf<Channel>()
    
    fun updateChannels(newChannels: List<Channel>) {
        channels = newChannels
        notifyDataSetChanged()
    }
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ChannelViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_channel, parent, false)
        return ChannelViewHolder(view)
    }
    
    override fun onBindViewHolder(holder: ChannelViewHolder, position: Int) {
        holder.bind(channels[position])
    }
    
    override fun getItemCount(): Int = channels.size
    
    inner class ChannelViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val nameText: TextView = itemView.findViewById(R.id.channelName)
        private val categoryText: TextView = itemView.findViewById(R.id.channelCategory)
        private val favoriteIcon: ImageView = itemView.findViewById(R.id.favoriteIcon)
        
        fun bind(channel: Channel) {
            nameText.text = channel.name
            categoryText.text = channel.category
            favoriteIcon.visibility = if (channel.isFavorite) View.VISIBLE else View.GONE
            
            itemView.setOnClickListener {
                onChannelClick(channel)
            }
        }
    }
}
package com.example.mimi_app

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject

class PackingWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return PackingWidgetFactory(applicationContext)
    }
}

class PackingWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var items = JSONArray()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val data = prefs.getString("packing_items", "[]")
        items = JSONArray(data)
    }

    override fun onDestroy() {}

    override fun getCount(): Int = items.length()

    override fun getViewAt(position: Int): RemoteViews {
        val item = items.getJSONObject(position)
        val views = RemoteViews(context.packageName, R.layout.widget_packing_item)
        views.setTextViewText(R.id.item_text, item.getString("item"))
        
        val isPacked = item.getBoolean("isPacked")
        views.setImageViewResource(R.id.item_status, if (isPacked) R.drawable.ic_check_circle else R.drawable.ic_circle)
        
        val toggleIntent = Intent().apply {
            putExtra("id", item.getString("_id"))
            putExtra("isPacked", isPacked)
            putExtra("item_action", "TOGGLE")
        }
        views.setOnClickFillInIntent(R.id.item_status, toggleIntent)
        
        val openIntent = Intent().apply {
            putExtra("id", item.getString("_id"))
            putExtra("item_action", "OPEN")
        }
        views.setOnClickFillInIntent(R.id.item_text, openIntent)
        
        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}

class ItineraryWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return ItineraryWidgetFactory(applicationContext)
    }
}

class ItineraryWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var items = JSONArray()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val data = prefs.getString("itinerary_items", "[]")
        items = JSONArray(data)
    }

    override fun onDestroy() {}

    override fun getCount(): Int = items.length()

    override fun getViewAt(position: Int): RemoteViews {
        val item = items.getJSONObject(position)
        val views = RemoteViews(context.packageName, R.layout.widget_itinerary_item)
        views.setTextViewText(R.id.item_day, item.getString("day"))
        views.setTextViewText(R.id.item_title, item.getString("title"))
        
        val fillInIntent = Intent().apply {
            putExtra("id", item.getString("_id"))
            putExtra("action", "itinerary")
        }
        views.setOnClickFillInIntent(R.id.item_root, fillInIntent)
        
        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}

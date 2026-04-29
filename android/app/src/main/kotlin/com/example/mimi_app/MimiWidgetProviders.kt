package com.example.mimi_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class UsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_us).apply {
                setTextViewText(R.id.widget_days, widgetData.getString("us_days", "---"))
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class CountdownWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_countdown).apply {
                setTextViewText(R.id.widget_countdown, widgetData.getString("countdown_days", "---"))
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class MemoryWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_memory).apply {
                val imagePath = widgetData.getString("memory_image_path", null)
                if (imagePath != null) {
                    setImageViewUri(R.id.widget_image, Uri.parse(imagePath))
                }
                setTextViewText(R.id.widget_caption, widgetData.getString("memory_caption", "Memory Lane"))
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

class PackingWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, PackingWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            
            // PendingIntent for clicks
            val clickIntent = Intent(context, PackingWidgetProvider::class.java).apply {
                action = "TOGGLE_PACKING"
            }
            val clickPendingIntent = PendingIntent.getBroadcast(
                context, 0, clickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )

            val views = RemoteViews(context.packageName, R.layout.widget_packing).apply {
                setRemoteAdapter(R.id.widget_list, intent)
                setEmptyView(R.id.widget_list, R.id.widget_empty)
                setPendingIntentTemplate(R.id.widget_list, clickPendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "TOGGLE_PACKING") {
            val id = intent.getStringExtra("id")
            val isPacked = intent.getBooleanExtra("isPacked", false)
            val itemAction = intent.getStringExtra("item_action")
            
            if (id != null) {
                val uri = Uri.parse("homeWidget://toggle_packing?id=$id&isPacked=$isPacked")
                
                if (itemAction == "TOGGLE") {
                    // Background Toggle Only
                    val backgroundIntent = Intent(context, es.antonborri.home_widget.HomeWidgetBackgroundReceiver::class.java).apply {
                        action = "es.antonborri.home_widget.action.BACKGROUND"
                        data = uri
                    }
                    context.sendBroadcast(backgroundIntent)
                } else {
                    // Launch App to specific page (for OPEN or default)
                    val launchIntent = Intent(context, MainActivity::class.java).apply {
                        action = "es.antonborri.home_widget.action.LAUNCH"
                        data = uri
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    context.startActivity(launchIntent)
                }
            }
        }
        super.onReceive(context, intent)
    }
}

class ItineraryWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, ItineraryWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            val views = RemoteViews(context.packageName, R.layout.widget_itinerary).apply {
                setRemoteAdapter(R.id.widget_list, intent)

                // PendingIntent for clicks
                val clickIntent = Intent(context, ItineraryWidgetProvider::class.java).apply {
                    action = "OPEN_ITINERARY"
                }
                val clickPendingIntent = PendingIntent.getBroadcast(
                    context, 0, clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )
                setPendingIntentTemplate(R.id.widget_list, clickPendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "OPEN_ITINERARY") {
            val id = intent.getStringExtra("id")
            val uri = Uri.parse("homeWidget://itinerary?id=$id")
            
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
                data = uri
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(launchIntent)
        }
        super.onReceive(context, intent)
    }
}

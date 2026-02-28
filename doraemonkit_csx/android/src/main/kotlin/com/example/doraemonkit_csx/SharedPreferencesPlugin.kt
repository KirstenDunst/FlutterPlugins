
package com.example.doraemonkit_csx

import android.content.Context
import android.content.SharedPreferences
import android.os.AsyncTask
import android.util.Base64
import java.io.*
import java.math.BigInteger

object SharedPreferencesPlugin {

    private const val SHARED_PREFERENCES_NAME = "FlutterSharedPreferences"

    // Base64("This is the prefix for a list.")
    private const val LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"
    private const val BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy"
    private const val DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"

    /**
     * 异步写入 SharedPreferences
     */
    fun setUserDefault(context: Context, map: HashMap<String, *>) {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        for ((key, value) in map) {
            commitAsync(preferences.edit().putString(key, value.toString()))
        }
    }

    /**
     * 异步 commit 提交
     */
    private fun commitAsync(editor: SharedPreferences.Editor) {
        object : AsyncTask<Void, Void, Boolean>() {
            override fun doInBackground(vararg voids: Void?): Boolean {
                return editor.commit()
            }
        }.execute()
    }

    /**
     * 将 Base64 编码的列表解码为 List<String>
     */
    @Throws(IOException::class)
    private fun decodeList(encodedList: String): List<String> {
        ObjectInputStream(ByteArrayInputStream(Base64.decode(encodedList, 0))).use { stream ->
            return try {
                @Suppress("UNCHECKED_CAST")
                stream.readObject() as List<String>
            } catch (e: ClassNotFoundException) {
                throw IOException(e)
            }
        }
    }

    /**
     * 将 List<String> 编码为 Base64 字符串
     */
    @Throws(IOException::class)
    private fun encodeList(list: List<String>): String {
        val byteStream = ByteArrayOutputStream()
        ObjectOutputStream(byteStream).use { stream ->
            stream.writeObject(list)
            stream.flush()
        }
        return Base64.encodeToString(byteStream.toByteArray(), 0)
    }

    /**
     * 获取 FlutterSharedPreferences 存储的全部键值
     * 并自动处理旧版迁移、List/BigInteger/Double 格式转换
     */
    @Throws(IOException::class)
    fun getUserDefaults(context: Context): Map<String, String> {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val allPrefs = preferences.all
        val filteredPrefs = mutableMapOf<String, String>()

        for ((key, rawValue) in allPrefs) {
            if (!key.startsWith("flutter.")) continue

            var value: Any? = rawValue

            if (value is String) {
                when {
                    value.startsWith(LIST_IDENTIFIER) -> {
                        value = decodeList(value.substring(LIST_IDENTIFIER.length))
                    }
                    value.startsWith(BIG_INTEGER_PREFIX) -> {
                        val encoded = value.substring(BIG_INTEGER_PREFIX.length)
                        value = BigInteger(encoded, Character.MAX_RADIX)
                    }
                    value.startsWith(DOUBLE_PREFIX) -> {
                        val doubleStr = value.substring(DOUBLE_PREFIX.length)
                        value = doubleStr.toDoubleOrNull()
                    }
                }
            } else if (value is Set<*>) {
                // 将旧版 Set<String> 转为 List<String>
                val listValue = ArrayList(value.filterIsInstance<String>())
                val success = preferences.edit()
                    .remove(key)
                    .putString(key, LIST_IDENTIFIER + encodeList(listValue))
                    .commit()
                if (!success) {
                    throw IOException("Could not migrate set to list")
                }
                value = listValue
            }

            filteredPrefs[key] = value.toString()
        }

        return filteredPrefs
    }
}

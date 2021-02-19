// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package cn.brainco.doraemonkit_csx;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.util.Base64;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

class SharedPreferencesPlugin {

    private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

    // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
    private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
    private static final String BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy";
    private static final String DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu";


    public static void setUserDefault(Context context, HashMap<String, ?> map) {
        android.content.SharedPreferences preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        Iterator it = map.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            String key = entry.getKey().toString();
            String value = entry.getValue().toString();
            commitAsync(preferences.edit().putString(key, value));
        }
    }

    private static void commitAsync(
            final SharedPreferences.Editor editor) {
        new AsyncTask<Void, Void, Boolean>() {
            @Override
            protected Boolean doInBackground(Void... voids) {
                return editor.commit();
            }
        }.execute();
    }

    private static List<String> decodeList(String encodedList) throws IOException {
        ObjectInputStream stream = null;
        try {
            stream = new ObjectInputStream(new ByteArrayInputStream(Base64.decode(encodedList, 0)));
            return (List<String>) stream.readObject();
        } catch (ClassNotFoundException e) {
            throw new IOException(e);
        } finally {
            if (stream != null) {
                stream.close();
            }
        }
    }

    private static String encodeList(List<String> list) throws IOException {
        ObjectOutputStream stream = null;
        try {
            ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
            stream = new ObjectOutputStream(byteStream);
            stream.writeObject(list);
            stream.flush();
            return Base64.encodeToString(byteStream.toByteArray(), 0);
        } finally {
            if (stream != null) {
                stream.close();
            }
        }
    }

    // Filter preferences to only those set by the flutter app.
    public static Map<String, String> getUserDefaults(Context context) throws IOException {
        android.content.SharedPreferences preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        Map<String, ?> allPrefs = preferences.getAll();
        Map<String, String> filteredPrefs = new HashMap<>();
        for (String key : allPrefs.keySet()) {
            if (key.startsWith("flutter.")) {
                Object value = allPrefs.get(key);
                if (value instanceof String) {
                    String stringValue = (String) value;
                    if (stringValue.startsWith(LIST_IDENTIFIER)) {
                        value = decodeList(stringValue.substring(LIST_IDENTIFIER.length()));
                    } else if (stringValue.startsWith(BIG_INTEGER_PREFIX)) {
                        String encoded = stringValue.substring(BIG_INTEGER_PREFIX.length());
                        value = new BigInteger(encoded, Character.MAX_RADIX);
                    } else if (stringValue.startsWith(DOUBLE_PREFIX)) {
                        String doubleStr = stringValue.substring(DOUBLE_PREFIX.length());
                        value = Double.valueOf(doubleStr);
                    }
                } else if (value instanceof Set) {
                    // This only happens for previous usage of setStringSet. The app expects a list.
                    List<String> listValue = new ArrayList<>((Set) value);
                    // Let's migrate the value too while we are at it.
                    boolean success =
                            preferences
                                    .edit()
                                    .remove(key)
                                    .putString(key, LIST_IDENTIFIER + encodeList(listValue))
                                    .commit();
                    if (!success) {
                        // If we are unable to migrate the existing preferences, it means we potentially lost them.
                        // In this case, an error from getAllPrefs() is appropriate since it will alert the app during plugin initialization.
                        throw new IOException("Could not migrate set to list");
                    }
                    value = listValue;
                }
                filteredPrefs.put(key, value.toString());
            }
        }
        return filteredPrefs;
    }
}

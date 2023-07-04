import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class Favourite {
  static SharedPreferences? _pref;

  static Future init() async => _pref = await SharedPreferences.getInstance();

  static Future sethandle(String handle) async =>
      await _pref!.setString(handle, handle);

  static bool gethandle(String handle) =>
      _pref?.getString(handle) == null ? false : true;

  static void removehandle(String handle) => _pref?.remove(handle);

  static Future setNotification(int id) async {
    final keys = _pref!.getStringList("notifications") ?? [];
    keys.add(id.toString());

    return await _pref?.setStringList("notifications", keys);
  }

  static Future removeNotification(int id) async {
    List<String> allNotifications = _pref?.getStringList("notifications") ?? [];

    allNotifications.remove(id.toString());
    return await _pref?.setStringList("notifications", allNotifications);
  }

  static List<String> getAllNotifications() {
    final keys = _pref?.getStringList("notifications") ?? [];

    return keys;
  }

  static List<dynamic> getallitems() {
    final keys = _pref?.getKeys();
    if (keys != null) keys.remove("notifications");
    List<dynamic> all = [];
    for (String key in keys ?? []) {
      dynamic val = _pref!.get(key);
      all.add(val);
    }
    return all;
  }
}

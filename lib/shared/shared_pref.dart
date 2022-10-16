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

  static List<dynamic> getallitems() {
    final keys = _pref?.getKeys();
    List<dynamic> all = [];
    for (String key in keys!) {
      dynamic val = _pref!.get(key);
      all.add(val);
    }
    return all;
  }

 
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class UserInfoProvider extends ChangeNotifier {
  bool _loading = false;
  Map _userinfo = {};
  String _errormessage = '';
  bool _error = false;

  bool get loading => _loading;
  Map get userinfo => _userinfo;
  bool get erro => _error;
  String get errmessage => _errormessage;

  Future<void> fetchdata(String handle) async {
    _loading = true;
    notifyListeners();
    final response = await get(
        Uri.parse('https://codeforces.com/api/user.info?handles=$handle'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      try {
        Map data = (jsonDecode(response.body));
        _error = false;
        Map res = {};
        for (var i in data['result']) res.addAll(i);
        _userinfo = res;
      } catch (e) {
        _error = true;
        _errormessage = e.toString();
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      _error = true;
      _errormessage = 'Error:Check User handle/Internet';
    }
    _loading = false;
    notifyListeners();
  }

  UserInfoProvider() {
    _loading = false;
    _userinfo = {};
    _errormessage = '';
    _error = false;
    notifyListeners();
  }
}

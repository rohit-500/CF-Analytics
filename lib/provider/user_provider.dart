import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class UserProvider extends ChangeNotifier {
  bool _loading = false;
  List<dynamic> _userinfo = [];
  List<dynamic> _userstatus = [];
  String _errormessage = '';
  bool _error = false;

  bool get loading => _loading;
  List<dynamic> get userinfo => _userinfo;
  bool get erro => _error;
  String get errmessage => _errormessage;
  List<dynamic> get userstatus => _userstatus;
  Future<void> fetchdata(String handle) async {
    _loading = true;
    notifyListeners();
    final response = await get(
        Uri.parse('https://codeforces.com/api/user.rating?handle=$handle'));
    final res2 = await get(
        Uri.parse('https://codeforces.com/api/user.status?handle=$handle'));

    if (response.statusCode == 200 && res2.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      try {
        Map data = (jsonDecode(response.body));
        Map data1 = (jsonDecode(res2.body));
        _error = false;
        _userstatus = data1['result'];
        _userinfo = data['result'];
      } catch (e) {
        print(e.toString());
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

  UserProvider(String handle) {
    _loading = false;
    _userinfo = [];
    _userstatus = [];
    _errormessage = '';
    _error = false;
    notifyListeners();
    fetchdata(handle);
    notifyListeners();
  }
}

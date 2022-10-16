import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class UpcomingProvider extends ChangeNotifier {
  List<Map> _contest = [];
  bool _loading = false;
  bool _showuc = true;
  bool _showrun = true;
  String _errormessage = '';
  bool _error = false;

  UpcomingProvider() {
    _contest = [];
    _loading = false;
    _errormessage = '';
    _error = false;
    _showuc = true;
    _showrun = true;
    notifyListeners();
    fetchdata();
  }

  bool get loading => _loading;
  List<Map> get contests => _contest;
  bool get erro => _error;
  String get errmessage => _errormessage;

  bool get showrun => _showrun;
  bool get showuc => _showuc;
  Future<void> fetchdata() async {
    _loading = true;
    notifyListeners();

    List<Map<dynamic, dynamic>> result = [];
    final response =
        await get(Uri.parse('https://codeforces.com/api/contest.list'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      try {
        Map data = (jsonDecode(response.body));
        _error = false;
        List<Map> result = [];
        for (var i in data['result']) {
          if (i['phase'] == 'CODING' || i['phase'] == 'BEFORE') {
            result.add(i);
          }
        }

        result.sort((a, b) => (a['startTimeSeconds'] < b['startTimeSeconds']
            ? a['startTimeSeconds']
            : b['startTimeSeconds']));

        _contest = result;
      } catch (e) {
        _error = true;
        _errormessage = e.toString();
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      _error = true;
      _errormessage = 'Error:Failed To load Data Check Internet';
    }
    _loading = false;
    notifyListeners();
  }

  void setshowuc() {
    _showuc = !_showuc;
    notifyListeners();
  }

  void setshowrun() {
    _showrun = !_showrun;
    notifyListeners();
  }
}

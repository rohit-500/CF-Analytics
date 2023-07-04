import 'package:cf_analytics/shared/shared_pref.dart';
import 'package:flutter/cupertino.dart';

class ContestProvider extends ChangeNotifier {
  bool _innotificationon = false;
  ContestProvider(int cont_id) {
    initialvalue(cont_id);
  }
  bool get isnotificationon => _innotificationon;

  void setnotify() {
    _innotificationon = !_innotificationon;
    notifyListeners();
  }

  void initialvalue(int cont_id) async {
    List<String> allNotifications = Favourite.getAllNotifications();
    _innotificationon = allNotifications.contains(cont_id.toString());
    notifyListeners();
  }
}

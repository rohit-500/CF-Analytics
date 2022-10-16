import 'package:cf_analytics/shared/shared_pref.dart';
import 'package:flutter/cupertino.dart';

class FavouriteProvider extends ChangeNotifier {
  List<dynamic> _fav = [];
  bool _isfavourite = false;

  FavouriteProvider({String handle = ''}) {
    _isfavourite = Favourite.gethandle(handle);
    _fav = Favourite.getallitems();
  }
  bool get ifavorite => _isfavourite;
  List<dynamic> get fav => _fav;
  void setfav(String handle) {
    _isfavourite = Favourite.gethandle(handle);

    notifyListeners();
  }

  void updatefavlist() {
    _fav = Favourite.getallitems();
    notifyListeners();
  }
}

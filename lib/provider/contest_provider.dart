import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ContestProvider extends ChangeNotifier {
  bool _innotificationon = false;
  ContestProvider(String device_id, int cont_id) {
    initialvalue(device_id, cont_id);
  }
  bool get isnotificationon => _innotificationon;

  void setnotify() {
    _innotificationon = !_innotificationon;
    notifyListeners();
  }

  void initialvalue(String device_id, int cont_id) async {
    final userDocRef = await FirebaseFirestore.instance
        .collection(device_id)
        .doc('$cont_id')
        .get();
    _innotificationon = userDocRef.exists;

    notifyListeners();
  }
}

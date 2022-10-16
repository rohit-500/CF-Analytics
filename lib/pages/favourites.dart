import 'dart:convert';
import 'package:cf_analytics/home.dart';
import 'package:cf_analytics/pages/user.dart';
import 'package:cf_analytics/pages/user_info.dart';
import 'package:cf_analytics/provider/favourite_provider.dart';
import 'package:cf_analytics/shared/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class Liked extends StatefulWidget {
  const Liked({super.key});

  @override
  State<Liked> createState() => _LikedState();
}

class _LikedState extends State<Liked> {
  Map result = {};
  Future<bool> fetchdata(String handle) async {
    final response = await get(
        Uri.parse('https://codeforces.com/api/user.info?handles=$handle'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      Map data = (jsonDecode(response.body));

      Map res = {};
      for (var i in data['result']) res.addAll(i);

      result = res;
      return true;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return false;
    }
  }

  int _selectedIndex = 2;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Search',
      style: optionStyle,
    ),
    Text(
      'Index 2: Favourites',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Home(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => UserInfo(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  List<dynamic> fav = [];
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavouriteProvider(),
      child: Consumer<FavouriteProvider>(
          builder: ((context, data, child) => Scaffold(
                backgroundColor: Color.fromARGB(255, 34, 31, 31),
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 34, 31, 31),
                  title: Text(
                    "Favourites (${data.fav.length})",
                    style: TextStyle(
                        fontSize: 23,
                        color: Color.fromARGB(255, 218, 210, 201)),
                  ),
                ),
                body: Column(children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.fav.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                              tileColor: Color.fromARGB(255, 1, 1, 0),
                              onTap: () async {
                                await fetchdata(data.fav[index]);
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            User(info: result)));

                                data.updatefavlist();
                              },
                              leading: Text(
                                data.fav[index],
                                style: TextStyle(
                                    fontSize: 23, color: Colors.amber),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    Favourite.removehandle(data.fav[index]);
                                    data.updatefavlist();
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.amber,
                                  ))),
                        );
                      }),
                ]),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Color.fromARGB(255, 34, 31, 31),
                  unselectedItemColor: Colors.grey,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.star_border_purple500_outlined),
                      label: 'Favourites',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.amber[800],
                  onTap: _onItemTapped,
                ),
              ))),
    );
  }
}

import 'package:cf_analytics/home.dart';
import 'package:cf_analytics/pages/favourites.dart';
import 'package:cf_analytics/pages/user.dart';
import 'package:cf_analytics/provider/userinfo_provider.dart';
import 'package:cf_analytics/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

class UserInfo extends StatefulWidget {
  UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  int _selectedIndex = 1;

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
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Liked(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  UserInfoProvider? prod;
  @override
  void initState() {
    super.initState();
  }

  //text field state

  var _controller = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserInfoProvider(),
      child: Consumer<UserInfoProvider>(builder: (context, data, child) {
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 34, 31, 31),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 34, 31, 31),
            title: Text('Search User'),
            actions: [],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                data.loading
                    ? Center(
                        child: SizedBox(
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          color: Colors.amber,
                          minHeight: 4,
                        ),
                      ))
                    : SizedBox(),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                  child: Column(
                    children: [
                      Form(
                        key: _formkey,
                        child: Column(children: [
                          TextFormField(
                            decoration: textinputdecor.copyWith(
                                suffixIcon: IconButton(
                                  onPressed: _controller.clear,
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: 'Enter User handle'),
                            controller: _controller,
                            validator: (val) => val!.isEmpty
                                ? 'Enter an Valid User handle'
                                : null,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.blue;
                                return Colors.grey;
                              }),
                            ),
                            onPressed: () async {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');

                              if (_formkey.currentState!.validate()) {
                                await data.fetchdata(_controller.text);
                                if (data.erro == false) {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              User(info: data.userinfo)));
                                }
                              }
                            },
                            child: Text(
                              'Search',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            data.erro ? data.errmessage : '',
                            style: TextStyle(color: Colors.white),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        );
      }),
    );
  }
}

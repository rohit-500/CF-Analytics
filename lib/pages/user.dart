import 'dart:convert';
import 'dart:math';
import 'package:cf_analytics/pages/problem_cat.dart';
import 'package:cf_analytics/provider/favourite_provider.dart';
import 'package:cf_analytics/provider/user_provider.dart';
import 'package:cf_analytics/shared/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class User extends StatefulWidget {
  Map info;
  User({super.key, required this.info});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  List<ChartData> chartdata = [];

  Map info = {};
  bool hashttp = true;

  @override
  void initState() {
    super.initState();

    info = widget.info;

    String temp = info['avatar'];
    hashttp = temp.contains('https:') ? true : false;
  }

  void addItemsToLocalStorage() async {
    await Favourite.sethandle(info['handle']);
  }

  void removeItemFromLocalStorage() {
    Favourite.removehandle(info['handle']);
  }

  String formatDuration(int time) {
    var date = DateTime.fromMillisecondsSinceEpoch(time * 1000);

    var starttime = date.toString();
    var startdate = starttime.substring(0, 10);
    starttime = starttime.substring(11, 16);
    if (starttime.substring(0, 2) != '00')
      return starttime.substring(0, 2) + ' hours ago';
    if (starttime.substring(3) != '00')
      return starttime.substring(3) + ' minutes ago';
    return 'online now';
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => FavouriteProvider(handle: info['handle'])),
        ChangeNotifierProvider(
            create: (context) => UserProvider(info['handle']))
      ],
      child: Consumer2<FavouriteProvider, UserProvider>(
        builder: ((context, favdata, userstatusdata, child) {
          var last_online = info['lastOnlineTimeSeconds'];
          last_online = formatDuration(last_online);
          int wa = 0, tle = 0, ok = 0, re = 0, ce = 0;
          int best_rank = 99999;
          int worst_rank = -1;
          int ct = 0;
          int total_sub = 0;
          Map mp = {};
          Map tags = {};
          for (var i in userstatusdata.userstatus) {
            // for category statistics
            var tag = i['problem'];

            if (tag != null) {
              tag = tag['tags'];
              for (var j in tag) {
                if (tags.containsKey(j)) {
                  tags[j]++;
                } else {
                  tags[j] = 1;
                }
              }
            }

            // for problem statistics
            var val = i['problem'] ?? {};
            if (val['rating'] != null) {
              if (mp.containsKey(val['rating'])) {
                mp[val['rating']]++;
              } else {
                mp[val['rating']] = 1;
              }
            }
            //for submission statistics
            if (i['verdict'] == 'OK') ok++;
            if (i['verdict'] == 'TIME_LIMIT_EXCEEDED') tle++;
            if (i['verdict'] == 'WRONG_ANSWER') wa++;
            if (i['verdict'] == 'RUNTIME_ERROR') re++;
            if (i['verdict'] == 'COMPILATION_ERROR') ce++;
          }
          total_sub = ok + tle + wa + re + ce;
          tags = Map.fromEntries(tags.entries.toList()
            ..sort((e1, e2) => e1.value.compareTo(e2.value)));
          List<Widget> pyramiddata = [];
          tags.forEach((key, value) {
            pyramiddata.add(PyramidData.Pyramidtile(key, value));
          });
          final List<PieData> piedata = [
            PieData('Correct', ok, Colors.green),
            PieData('Wrong', wa, Colors.red),
            PieData('Tle', tle, Colors.amber),
            PieData('Runtime Error', re, Colors.brown),
            PieData('Compilation Error', ce, Colors.lightGreenAccent)
          ];
          // profile
          for (var i in userstatusdata.userinfo) {
            chartdata.add(ChartData(ct, i['newRating']));
            best_rank = min(best_rank, i['rank']);
            worst_rank = max(worst_rank, i['rank']);
            ct++;
          }
          List<BarData> bardata = [];
          mp = Map.fromEntries(
              mp.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
          mp.forEach(
            (key, value) {
              bardata.add(BarData(key, value));
            },
          );

          Widget helper = (Container(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(hashttp
                        ? ('${info['avatar']}')
                        : 'https:${info['avatar']}'),
                    radius: 60,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    color: Colors.amber,
                    height: 5,
                  ),
                  Card(
                    elevation: 10,
                    color: Color.fromARGB(255, 34, 31, 31),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${info['rank'] ?? '-'}",
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(255, 218, 210, 201)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Rating : ${info['rating'] ?? '-'} (max. ${info['maxRank'] ?? '-'}, ${info['maxRating'] ?? '-'})',
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromRGBO(97, 255, 110, 1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Contribution : ${info['contribution']}",
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromRGBO(97, 255, 110, 1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Contests : ${userstatusdata.userinfo.length}",
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromRGBO(97, 255, 110, 1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Best Rank : ${best_rank == 99999 ? '-' : best_rank}",
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromRGBO(97, 255, 110, 1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Worst Rank : ${worst_rank == -1 ? '-' : worst_rank}",
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromRGBO(97, 255, 110, 1)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Last Online : $last_online',
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromRGBO(97, 255, 110, 1)),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    height: 20,
                    color: Colors.amber,
                  ),
                  Center(
                      child: Container(
                          child: SfCartesianChart(
                              tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  borderWidth: 5,
                                  color: Colors.blue),
                              plotAreaBackgroundColor: Colors.black,
                              // Chart title text
                              title: ChartTitle(
                                  text: 'Rating Graph',
                                  textStyle: TextStyle(color: Colors.amber)),
                              // Initialize category axis
                              primaryXAxis: NumericAxis(isVisible: false),
                              primaryYAxis: NumericAxis(
                                tickPosition: TickPosition.inside,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              series: <ChartSeries<ChartData, int>>[
                        LineSeries<ChartData, int>(
                          color: Colors.blue,
                          dataSource: chartdata,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                        )
                      ]))),
                  Divider(
                    height: 40,
                    color: Colors.amber,
                  ),
                  Center(
                      child: Container(
                          padding: EdgeInsets.all(4),
                          child: SfCircularChart(
                              tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  borderWidth: 5,
                                  color: Colors.blue),
                              title: ChartTitle(
                                  text: 'Submission Statistics',
                                  textStyle: TextStyle(color: Colors.amber)),
                              series: <CircularSeries>[
                                PieSeries<PieData, String>(
                                  explode: true,
                                  dataSource: piedata,
                                  dataLabelSettings: DataLabelSettings(
                                      useSeriesColor: true,
                                      isVisible: true,
                                      textStyle: TextStyle(color: Colors.black),
                                      overflowMode: OverflowMode.trim,

                                      // Positioning the data label
                                      labelIntersectAction:
                                          LabelIntersectAction.shift,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      connectorLineSettings:
                                          ConnectorLineSettings(length: '25%')),
                                  pointColorMapper: (PieData data, _) =>
                                      data.color,
                                  xValueMapper: (PieData data, _) => data.x,
                                  yValueMapper: (PieData data, _) => data.y,
                                  dataLabelMapper: (PieData data, _) => data.x,
                                )
                              ]))),
                  Text(
                    "Total Submissions : $total_sub",
                    style: TextStyle(color: Colors.amber, fontSize: 17),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        height: 20,
                        width: 50,
                        color: Colors.green,
                        child: Center(
                            child: Text(
                          '$ok',
                          style: TextStyle(color: Colors.black),
                        )),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        height: 20,
                        width: 50,
                        color: Colors.red,
                        child: Center(
                            child: Text(
                          '$wa',
                          style: TextStyle(color: Colors.black),
                        )),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        height: 20,
                        width: 50,
                        color: Colors.amber,
                        child: Center(
                            child: Text(
                          '$tle',
                          style: TextStyle(color: Colors.black),
                        )),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        height: 20,
                        width: 50,
                        color: Colors.brown,
                        child: Center(
                            child: Text(
                          '$re',
                          style: TextStyle(color: Colors.black),
                        )),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        height: 20,
                        width: 50,
                        color: Colors.lightGreenAccent,
                        child: Center(
                            child: Text(
                          '$ce',
                          style: TextStyle(color: Colors.black),
                        )),
                      ),
                    ],
                  ),
                  Divider(
                    height: 50,
                    color: Colors.amber,
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Center(
                      child: Container(
                          child: SfCartesianChart(
                              title: ChartTitle(
                                  text: 'Problem Statistics',
                                  textStyle: TextStyle(color: Colors.amber)),
                              tooltipBehavior: TooltipBehavior(
                                  enable: true,
                                  borderWidth: 5,
                                  color: Colors.blue),
                              primaryXAxis: CategoryAxis(
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              series: <ChartSeries<BarData, int>>[
                        ColumnSeries<BarData, int>(
                            dataSource: bardata,
                            xValueMapper: (BarData data, _) => data.x,
                            yValueMapper: (BarData data, _) => data.y,
                            color: Colors.amber)
                      ]))),
                  Divider(
                    height: 50,
                    color: Colors.amber,
                  ),
                  Card(
                    color: Colors.black,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProblemCategory(category: pyramiddata)));
                      },
                      leading: Text(
                        "Solved Problem Category",
                        style: TextStyle(color: Colors.amber, fontSize: 17),
                      ),
                      trailing: Icon(
                        Icons.open_in_new,
                        color: Colors.amber,
                      ),
                    ),
                  )
                ]),
          ));

          return Scaffold(
              backgroundColor: Color.fromARGB(255, 34, 31, 31),
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 34, 31, 31),
                title: Text('${info['handle']}'),
                actions: [
                  IconButton(
                      onPressed: (() {
                        if (!favdata.ifavorite) {
                          addItemsToLocalStorage();
                        } else {
                          removeItemFromLocalStorage();
                        }
                        favdata.setfav(info['handle']);
                      }),
                      icon: (favdata.ifavorite)
                          ? Icon(
                              Icons.favorite,
                              color: Colors.amber,
                            )
                          : Icon(Icons.favorite_border_outlined)),
                ],
              ),
              body: SingleChildScrollView(
                  child: Center(
                      child: Column(
                children: [
                  if (userstatusdata.loading) ...[
                    SizedBox(
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey,
                        color: Colors.amberAccent,
                        minHeight: 4,
                      ),
                    )
                  ] else if (userstatusdata.erro) ...[
                    const Center(
                        child: Text(
                      'Error fetching the data try again',
                      style: TextStyle(color: Colors.amber, fontSize: 21),
                    ))
                  ] else ...[
                    helper,
                  ]
                ],
              ))));
        }),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final int y;
}

class PieData {
  PieData(this.x, this.y, this.color);
  final String x;
  final int y;
  final Color color;
}

class BarData {
  BarData(this.x, this.y);
  final int x;
  final int y;
}

class PyramidData {
  static Widget Pyramidtile(String x, int y) {
    return Card(
        color: Colors.black,
        child: ListTile(
          leading: Text(
            "$x",
            style: TextStyle(color: Colors.amber, fontSize: 18),
          ),
          trailing: Text(
            "$y",
            style: TextStyle(color: Colors.amber, fontSize: 18),
          ),
        ));
  }
}

import 'dart:convert';

import 'package:cf_analytics/models/running.dart';
import 'package:cf_analytics/models/contest.dart';
import 'package:cf_analytics/provider/upcontests_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:provider/provider.dart';

class UpContests extends StatefulWidget {
  const UpContests({super.key});

  @override
  State<UpContests> createState() => _UpContestsState();
}

class _UpContestsState extends State<UpContests> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpcomingProvider(),
      child: Consumer<UpcomingProvider>(builder: (context, data, child) {
        if (data.loading) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.amber,
          ));
        }
        if (data.erro) {
          return const Center(
              child: Text(
            'Error fetching the data try again',
            style: TextStyle(color: Colors.amber, fontSize: 21),
          ));
        }
        Future<void> _refreshPhotos() async {
          await data.fetchdata();
          setState(() {});
        }

        List<ContestTile> upcont = [];
        List<RunningContestTile> runcont = [];
        for (var i in data.contests) {
          if (i['phase'] == 'BEFORE') upcont.add(ContestTile(contests: i));
          if (i['phase'] == 'CODING') {
            runcont.add(RunningContestTile(contests: i));
          }
        }
        Widget up = Column(
          children: upcont,
        );
        Widget run = Column(
          children: runcont,
        );
        return Container(
            child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refreshPhotos,
                child: Container(
                    child: ListView(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: ListTile(
                          tileColor: data.showrun
                              ? Color.fromARGB(255, 1, 1, 0)
                              : Colors.transparent,
                          onTap: (() {
                            data.setshowrun();
                          }),
                          leading: Text(
                            "Running Contests (${runcont.length})",
                            style: TextStyle(
                                color: Color.fromARGB(255, 87, 207, 91),
                                fontSize: 19),
                          ),
                          trailing: data.showrun
                              ? Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.amber,
                                )
                              : Icon(Icons.keyboard_arrow_up_outlined,
                                  color: Colors.amber),
                        ),
                      ),
                      data.showrun ? run : SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: ListTile(
                          tileColor: data.showuc
                              ? Color.fromARGB(255, 1, 1, 0)
                              : Colors.transparent,
                          onTap: (() {
                            data.setshowuc();
                          }),
                          leading: Text(
                            "Upcoming Contests (${upcont.length})",
                            style: TextStyle(
                                color: Color.fromARGB(255, 87, 207, 91),
                                fontSize: 19),
                          ),
                          trailing: data.showuc
                              ? Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.amber,
                                )
                              : Icon(Icons.keyboard_arrow_up_outlined,
                                  color: Colors.amber),
                        ),
                      ),

                      data.showuc ? up : SizedBox(),
                      // child: ListView.builder(
                      //   shrinkWrap: true,
                      //   itemCount: snapshot.data!.length,
                      //   itemBuilder: (context, index) {
                      //     return ContestTile(contests: snapshot.data![index]);
                      //   },
                      // ),
                    ],
                  ),
                ]))));
      }),
    );
  }
}

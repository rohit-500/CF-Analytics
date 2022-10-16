import 'package:cf_analytics/provider/contest_provider.dart';
import 'package:cf_analytics/services/notification.dart';
import 'package:cf_analytics/shared/device_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ContestTile extends StatefulWidget {
  final contests;
  const ContestTile({super.key, required this.contests});

  @override
  State<ContestTile> createState() => _ContestTileState();
}

class _ContestTileState extends State<ContestTile> {
  String device_id = DeviceInfo.device_id!;
  bool isnotificationon = false;
  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${hours}h:${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ContestProvider(device_id, widget.contests['id']),
        child: Consumer<ContestProvider>(
          builder: ((context, data, child) {
            String val = formatDuration(
                Duration(seconds: widget.contests['durationSeconds']));

            Icon icon;
            if (data.isnotificationon == false) {
              icon = Icon(
                Icons.notifications_none,
                color: Colors.white,
              );
            } else {
              icon = Icon(
                Icons.notifications_active,
                color: Colors.white,
              );
            }
            String start_time = "-";
            String start_date = "-";
            if (widget.contests['startTimeSeconds'] != null) {
              var date = DateTime.fromMillisecondsSinceEpoch(
                  widget.contests['startTimeSeconds'] * 1000);

              start_time = date.toString();
              start_date = start_time.substring(0, 10);
              start_time = start_time.substring(11, 16);
            }
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
              color: Colors.black,
              child: ListTile(
                  leading: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "${widget.contests['id']}",
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                            onPressed: () async {
                              if (!data.isnotificationon) {
                                if (widget.contests['startTimeSeconds'] !=
                                    null) {
                                  NotificationService().showNotification(
                                      widget.contests['id'],
                                      'Reminder',
                                      '${widget.contests['name']} ',
                                      widget.contests['startTimeSeconds']);
                                }
                                final colref = FirebaseFirestore.instance
                                    .collection(device_id)
                                    .doc('${widget.contests['id']}');
                                colref.set({
                                  'contest': widget.contests['name'],
                                  'date': start_date,
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection(device_id)
                                    .doc('${widget.contests['id']}')
                                    .delete();
                                NotificationService()
                                    .cancelNotification(widget.contests['id']);
                              }
                              data.setnotify();
                            },
                            icon: icon),
                      ],
                    ),
                  ),
                  trailing: Text(
                    "Duration\n\n${val}",
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        widget.contests['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Date: ${start_date}",
                        style: TextStyle(
                            color: Color.fromARGB(255, 53, 135, 55),
                            fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Time: ${start_time}",
                        style: TextStyle(
                            color: Color.fromARGB(255, 53, 135, 55),
                            fontSize: 15),
                      ),
                    ],
                  )),
            );
          }),
        ));
  }
}

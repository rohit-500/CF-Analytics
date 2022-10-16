import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class RunningContestTile extends StatefulWidget {
  final contests;
  const RunningContestTile({super.key, required this.contests});

  @override
  State<RunningContestTile> createState() => _RunningContestTileState();
}

class _RunningContestTileState extends State<RunningContestTile> {
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
    String val =
        formatDuration(Duration(seconds: widget.contests['durationSeconds']));

    String start_time = "-";
    String start_date = "-";
    String end_time = '-';
    if (widget.contests['startTimeSeconds'] != null) {
      Duration temp = Duration(seconds: widget.contests['startTimeSeconds']);
      Duration t = Duration(seconds: widget.contests['durationSeconds']) + temp;

      var date = DateTime.fromMillisecondsSinceEpoch(
          widget.contests['startTimeSeconds'] * 1000);
      var end = DateTime.fromMicrosecondsSinceEpoch(t.inMilliseconds * 1000);

      end_time = end.toString().substring(11, 16);

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
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Started at: ${start_time}",
                style: TextStyle(
                    color: Color.fromARGB(255, 53, 135, 55), fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Ends at: ${end_time}",
                style: TextStyle(
                    color: Color.fromARGB(255, 53, 135, 55), fontSize: 15),
              ),
            ],
          )),
    );
  }
}

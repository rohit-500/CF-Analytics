import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProblemCategory extends StatelessWidget {
  final List<Widget> category;
  const ProblemCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 34, 31, 31),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 34, 31, 31),
        title: Text('Problem Category (${category.length})',
            style: TextStyle(color: Colors.white, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: category),
        ),
      ),
    );
  }
}

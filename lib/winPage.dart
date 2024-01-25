import 'package:flutter/material.dart';

class winPage extends StatefulWidget {
  final bool isSeekerWin;

  winPage({required this.isSeekerWin});

  @override
  _winPage createState() => _winPage();
}

class _winPage extends State<winPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          widget.isSeekerWin ? 'Seeker Win' : 'Hider Win',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
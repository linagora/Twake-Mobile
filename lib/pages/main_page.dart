import 'package:flutter/material.dart';
import 'package:twake/services/init.dart';

class MainPage extends StatefulWidget {
  static const route = '/main';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  InitData data;
  @override
  void initState() async {
    super.initState();
    data = await initMain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

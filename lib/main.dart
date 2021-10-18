import 'dart:async';

import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:screen_state/screen_state.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Screen and Battery Usage",
      home: Iskele(),
    );
  }
}

class Iskele extends StatelessWidget {
  const Iskele({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen and Battery Usage Info App"),
      ),
      body: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({Key? key}) : super(key: key);

  @override
  _AnaEkranState createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  var battery = Battery();
  int percentage = 0;
  late Timer timer;
  BatteryState batteryState = BatteryState.full;
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBatteryPercentage();
    getBatteryState();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getBatteryPercentage();
    });
  }

  void getBatteryPercentage() async {
    final level = await battery.batteryLevel;
    percentage = level;

    setState(() {});
  }

  void getBatteryState() async {
    streamSubscription = battery.onBatteryStateChanged.listen((state) {
      batteryState = state;
      setState(() {});
    });
  }

  Widget Buildbattery(BatteryState state) {
    switch (state) {
      case BatteryState.full:
        return Container(
          width: 200,
          height: 200,
          child: Icon(
            Icons.battery_full,
            size: 200,
            color: Colors.green,
          ),
        );
      case BatteryState.charging:
        return Container(
          width: 200,
          height: 200,
          child: Icon(
            Icons.battery_charging_full,
            size: 200,
            color: Colors.blue,
          ),
        );
      case BatteryState.discharging:
      default:
        return Container(
          width: 200,
          height: 200,
          child: Icon(
            Icons.battery_alert,
            size: 200,
            color: Colors.deepOrangeAccent,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Buildbattery(batteryState),
            Text(
              "$percentage%",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

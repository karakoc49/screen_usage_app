import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_state/screen_state.dart';
import 'package:pausable_timer/pausable_timer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Screen Usage Tracker",
      home: AnaEkran(),
    );
  }
}

/*
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
*/

class AnaEkran extends StatefulWidget {
  const AnaEkran({Key? key}) : super(key: key);

  @override
  _AnaEkranState createState() => _AnaEkranState();
}

class ScreenStateEventEntry {
  ScreenStateEvent event;
  DateTime? time;

  ScreenStateEventEntry(this.event) {
    time = DateTime.now();
  }
}

class _AnaEkranState extends State<AnaEkran> {
  Screen _screen = Screen();
  late StreamSubscription<ScreenStateEvent> _subscription;
  bool started = false;
  List<ScreenStateEventEntry> _log = [];
  static const countdownDuration = Duration(hours: 3, minutes: 0, seconds: 0);
  Duration duration = Duration();
  Timer? timer;
  bool isCountdown = false;
  final notificationTime = PausableTimer(Duration(seconds: 10),
      () => print("Hello! 10 seconds has passed hooman!"));

  void initState() {
    super.initState();
    initPlatformState();
    reset();
    startTimer();
    notificationTime.start();
    resetTimer();
  }

  Future<void> initPlatformState() async {
    startListening();
  }

  void onData(ScreenStateEvent event) {
    setState(() {
      _log.add(ScreenStateEventEntry(event));
      print(event);
      if (event == ScreenStateEvent.SCREEN_ON) {
        startTimer();
        notificationTime.start();
      } else if (event == ScreenStateEvent.SCREEN_OFF) {
        pauseTimer();
        notificationTime.pause();
      }
    });
  }

  void startListening() {
    try {
      _subscription = _screen.screenStateStream!.listen(onData);
      setState(() => started = true);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void reset() {
    if (isCountdown) {
      setState(() {
        duration = countdownDuration;
      });
    } else {
      setState(() {
        duration = Duration();
      });
    }
  }

  void addTime() {
    final addSeconds = isCountdown ? -1 : 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
      setState(() {
        timer?.cancel();
      });
    }
  }

  void pauseTimer() {
    setState(() {
      timer?.cancel();
    });
  }

  void resetTimer() {
    Timer.periodic(Duration(hours: 24), (_) => reset());
  }

  void sendNotification() {}

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeCard(time: hours, header: 'HOURS'),
        const SizedBox(width: 8),
        buildTimeCard(time: minutes, header: 'MINUTES'),
        const SizedBox(width: 8),
        buildTimeCard(time: seconds, header: 'SECONDS'),
      ],
    );
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 72,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(header),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "You are using the screen for",
              style: TextStyle(fontSize: 30),
            ),
            buildTime(),
            /*ElevatedButton(
                onPressed: () {
                  startTimer();
                },
                child: Text("Start Timer")),
            ElevatedButton(
                onPressed: () {
                  stopTimer();
                },
                child: Text("Stop Timer")),*/
          ],
        ),
      ),
    );
  }
}

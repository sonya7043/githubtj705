import 'dart:async';
import 'package:flutter/material.dart';

class StopWatch extends StatefulWidget {
  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;

  String get _formattedTime {
    final minutes =
        (_stopwatch.elapsedMilliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((_stopwatch.elapsedMilliseconds % 60000) ~/ 1000)
        .toString()
        .padLeft(2, '0');
    final milliseconds = ((_stopwatch.elapsedMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds.$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        title: Text('스톱워치'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formattedTime, style: TextStyle(fontSize: 38)),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(70, 36)),
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                      if (_stopwatch.isRunning) {
                        return Colors.pinkAccent;
                      } else {
                        return Colors.blue;
                      }
                    }),
                  ),
                  onPressed: () {
                    if (_stopwatch.isRunning) {
                      _stopwatch.stop();
                    } else {
                      _stopwatch.start();
                      _timer =
                          Timer.periodic(Duration(milliseconds: 50), (timer) {
                        setState(() {});
                      });
                    }
                  },
                  child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(70, 36)),
                      backgroundColor: MaterialStateProperty.all(Colors.cyan)),
                  onPressed: () {
                    _stopwatch.reset();
                    setState(() {});
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

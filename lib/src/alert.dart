import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:volume_control/volume_control.dart';
import 'package:vibration/vibration.dart';

class AlertPage extends StatefulWidget {
  final player = AudioPlayer();

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  _backToMap() {
    widget.player.stop();
    Vibration.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Vibration.vibrate(pattern: [250, 1000], repeat: 1);
    // VolumeControl.setVolume(1);
    widget.player.setAsset('assets/sounds/alarm.mp3');
    widget.player.setLoopMode(LoopMode.one);
    widget.player.play();

    return WillPopScope(
      onWillPop: () => _backToMap(),
      child: GestureDetector(
        onTap: () => _backToMap(),
        child: Scaffold(
          backgroundColor: Colors.red[800],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 200,
                ),
                Text(
                  'Un bateau a besoin d\'aide !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 80),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

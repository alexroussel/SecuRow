import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_control/volume_control.dart';
import 'package:vibration/vibration.dart';

class AlertPage extends StatefulWidget {
  final player = AudioCache();

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  AudioPlayer audioPlayer;

  _backToMap() {
    audioPlayer.stop();
    Vibration.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Vibration.vibrate(pattern: [250, 1000], repeat: 1);
    VolumeControl.setVolume(1);
    widget.player.loop('sounds/alarm.mp3').then((value) => audioPlayer = value);

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

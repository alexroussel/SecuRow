import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_control/volume_control.dart';
import 'package:vibration/vibration.dart';

class CancelPage extends StatefulWidget {
  final player = AudioCache();

  @override
  _CancelPageState createState() => _CancelPageState();
}

class _CancelPageState extends State<CancelPage> {
  AudioPlayer audioPlayer;

  _backToMap() {
    audioPlayer.stop();
    Vibration.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Vibration.vibrate(pattern: [300, 300, 1000], repeat: 1);
    VolumeControl.setVolume(1);
    widget.player
        .loop('sounds/cancel.mp3')
        .then((value) => audioPlayer = value);

    return WillPopScope(
      onWillPop: () => _backToMap(),
      child: GestureDetector(
        onTap: () => _backToMap(),
        child: Scaffold(
          backgroundColor: Colors.green,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.tag_faces_rounded,
                  color: Colors.white,
                  size: 200,
                ),
                Text(
                  'Fausse alerte !',
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

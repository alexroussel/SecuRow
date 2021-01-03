import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:user_location/user_location.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'src/alert.dart';

void main() {
  runApp(SecurowApp());
}

class SecurowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecuRow',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'SecuRow'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Map attributes
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  List<double> rescueBoatPos = [0, 0];

  // Bluetooth attributes
  BluetoothDevice selectedDevice = BluetoothDevice();
  BluetoothConnection connection;
  String _messageBuffer = '';

  void handleBluetoothConnection() async {
    // Get bonded devices
    List<BluetoothDevice> devices = List<BluetoothDevice>();
    devices = await FlutterBluetoothSerial.instance.getBondedDevices();

    // Select right device in bonded devices
    selectedDevice = devices.firstWhere((device) => device.name == 'SECUROW');

    try {
      connection = await BluetoothConnection.toAddress(selectedDevice.address);
      print('Connected to the device');
      connection.input.listen(_onDataReceived);
    } catch (error) {
      print(error);
    }
  }

  void handleMessage(String message) {
    Map<String, dynamic> parsedMessage = jsonDecode(message);
    if (parsedMessage['data']['type'] == "alert") {
      goAlertPage();
      setState(() {
        rescueBoatPos[0] = parsedMessage['data']['lat'];
        rescueBoatPos[1] = parsedMessage['data']['lng'];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    handleBluetoothConnection();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Voulez-vous vraiment quitter SecuRow ?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Non')),
          FlatButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Oui')),
        ],
      ),
    );
  }

  void goAlertPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AlertPage()));
  }

  @override
  Widget build(BuildContext context) {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: markers,
    );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FlutterMap(
          options: new MapOptions(
            center: new LatLng(45.8, 4.95),
            zoom: 15.0,
            plugins: [
              UserLocationPlugin(),
            ],
          ),
          layers: [
            new TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            new MarkerLayerOptions(
              markers: [
                new Marker(
                  width: 80.0,
                  height: 80.0,
                  point: new LatLng(rescueBoatPos[0], rescueBoatPos[1]),
                  builder: (ctx) => Icon(Icons.location_on, size: 40),
                  // anchorPos: AnchorPos.align(AnchorAlign.top),
                ),
                // new Marker(
                //   width: 80.0,
                //   height: 80.0,
                //   point: new LatLng(45.8, 4.95),
                //   builder: (ctx) =>
                //       Icon(Icons.directions_boat_outlined, size: 40),
                //   // anchorPos: AnchorPos.align(AnchorAlign.top),
                // ),
              ],
            ),
            MarkerLayerOptions(markers: markers),
            userLocationOptions,
          ],
          mapController: mapController,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: goAlertPage,
          child: Icon(Icons.notifications_active),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      String message = backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index);
      handleMessage(message);
      print(message);
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}

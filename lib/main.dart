import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

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
      home: MyHomePage(title: 'SecuRow le S'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FlutterMap(
        options: new MapOptions(
          center: new LatLng(45.8, 4.95),
          zoom: 15.0,
        ),
        layers: [
          new TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 80.0,
                height: 80.0,
                point: new LatLng(45.806831, 4.954534),
                builder: (ctx) => Icon(Icons.location_on, size: 40),
                // anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
              new Marker(
                width: 80.0,
                height: 80.0,
                point: new LatLng(45.8, 4.95),
                builder: (ctx) =>
                    Icon(Icons.directions_boat_outlined, size: 40),
                // anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AlertPage()));
        },
        child: Icon(Icons.notifications_active),
      ),
    );
  }
}

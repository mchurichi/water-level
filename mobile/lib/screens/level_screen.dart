import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:water_level/drawer.dart';
import 'package:mdns/mdns.dart';

class LevelScreen extends StatefulWidget {
  @override
  _LevelScreenState createState() => new _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int _distance = 0;
  DiscoveryCallbacks discoveryCallbacks;

  final apiUrl = new TextEditingController(
//      text: 'http://192.168.0.173/distance'
  );

  void _startWatching() {
    const halfSec = const Duration(milliseconds: 500);
    new Timer.periodic(halfSec, _updateDistance);
  }

  Future<Null> _updateDistance(Timer t) async {
    final response = await _fetchDistance(apiUrl.text);
    final responseJson = json.decode(response.body);
    setState(() {
      _distance = responseJson['distance'];
    });
  }

  Future<http.Response> _fetchDistance(String url) {
    return http.get(url);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Nivel de Agua'),
      ),
      drawer: new AppDrawer(),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('API URL'),
            new TextField(
              controller: apiUrl,
            ),
            new Text(
              '$_distance cms',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _startWatching,
        tooltip: 'Increment',
        child: new Icon(Icons.check),
      ),
    );
  }
}
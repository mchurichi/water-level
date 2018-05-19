import 'package:flutter/material.dart';
import 'package:water_level/drawer.dart';
import 'package:mdns/mdns.dart';
import 'package:water_level/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const serviceName = '_water-level._tcp';

class ConfigurationScreen extends StatefulWidget {

  @override
  _ConfigurationScreenState createState() => new _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool _connected = false;
  bool _lookingForDevices = false;
  String _deviceIP = '';
  Mdns _mdns;
  DiscoveryCallbacks _discoveryCallbacks;

  @override
  initState() {
    super.initState();
    _discoveryCallbacks = new DiscoveryCallbacks(
      onDiscovered: (ServiceInfo info){
        print("Discovered ${info.toString()}");
      },
      onDiscoveryStarted: (){
        print("Discovery started");
      },
      onDiscoveryStopped: (){
        print("Discovery stopped");
      },
      onResolved: (ServiceInfo info){
        print("Resolved Service ${info.toString()}");
        _setDeviceIP(info.host);
      },
    );
  }

  _setDeviceIP(String host) {
    var address = Utils.parseIpAddress(host);
    if (address != null) {
      setState(() {
        _deviceIP = address.host;
        _lookingForDevices = false;
      });
    }
  }

  _startMdnsDiscovery(String serviceType){
    _mdns = new Mdns(discoveryCallbacks: _discoveryCallbacks);
    _mdns.startDiscovery(serviceType);
  }

  _tryConnect(newState) async {
    if (_connected) {
      setState(() {
        _connected = false;
      });
      return;

    }
    try {
      var response = await http.get('http://$_deviceIP/');
      var jsonResponse = json.decode(response.body);
      print(response.body);
      if (jsonResponse['success'] == true) {
        setState(() {
          _connected = true;
        });
      }
    } on FormatException catch (e) {
      print('Error al parsear el json de respuesta');
      print(e);
    } catch (e) {
      print('No se pudo conectar');
      print(e);
    }
  }

  _tryFind() {
    setState(() {
      _lookingForDevices = true;
    });
    _startMdnsDiscovery(serviceName);
  }

  _stopFind() {
    if (_lookingForDevices && _mdns != null) {
      _mdns.stopDiscovery();
      setState(() {
        _lookingForDevices = false;
      });
    }
  }

  _editIPAddress() async {
    var controller = new TextEditingController(
      text: _deviceIP,
    );

    var selected = await showDialog(
      context: context,
      child: new AlertDialog(
        title: const Text('Ingrese la dirección IP:'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new TextField(
                controller: controller,
              )
            ],
          )
        ),
        actions: <Widget>[
          new FlatButton(
              onPressed: () { Navigator.of(context).pop(false); },
              child: const Text('Cancelar')
          ),
          new FlatButton(
              onPressed: () { Navigator.of(context).pop(true); },
            child: const Text('Aceptar')
          ),
        ],
      )
    );

    if (selected) {
      setState(() {
        _setDeviceIP(controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text('Configuración'),
            new IconButton(
              icon: new Icon(Icons.save),
              onPressed: () {},
            )
          ],
        ),
        bottom: new PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: new Theme(
            data: Theme.of(context).copyWith(
              accentColor: Colors.lightGreenAccent,
            ),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  'CONECTADO',
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                new Switch(
                  value: _connected,
                  onChanged: _tryConnect,
                )
              ],
            ),
          )

        )
      ),
      drawer: new AppDrawer(),
      body: new ListView(
        children: <Widget>[
          new ListTile(
            title: const Text('Dirección IP del dispositivo'),
            subtitle: new Text(_deviceIP),
            trailing: (_lookingForDevices)
              ? new IconButton(icon: new Icon(Icons.refresh), onPressed: _stopFind)
              : new IconButton(icon: new Icon(Icons.search), onPressed: _tryFind),
            onTap: _editIPAddress,
          ),
          new ListTile(
            title: const Text('Distancia hacia el nivel máximo de agua (cm)'),
            subtitle: const Text('20'),
          ),
          new ListTile(
            title: const Text('Distancia hacia el nivel mínimo de agua (cm)'),
            subtitle: const Text('150'),
          ),
        ],
      ),
    );
  }
}
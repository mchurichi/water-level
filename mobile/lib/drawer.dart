import 'package:flutter/material.dart';
import 'package:water_level/screens/configuration_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            title: const Text('Inicio'),
            leading: new Icon(Icons.home),
          ),
          new ListTile(
            title: const Text('Configuracion'),
            leading: new Icon(Icons.settings),
            onTap: () => _navigateTo(context, new ConfigurationScreen()),
          )
        ],
      ),
    );
  }

  _navigateTo(BuildContext context, Widget screen) async {
    Navigator.pop(context);
    final result = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => screen),
    );
  }
}
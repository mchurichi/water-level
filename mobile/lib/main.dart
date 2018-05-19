import 'package:flutter/material.dart';
import 'package:water_level/screens/level_screen.dart';

void main() => runApp(new WaterLevel());

class WaterLevel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Nivel de Agua',
      home: new LevelScreen(),
    );
  }
}

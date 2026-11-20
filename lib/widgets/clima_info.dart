import 'package:flutter/material.dart';
import '../models/clima.dart';

class ClimaInfo extends StatelessWidget {
  const ClimaInfo({super.key, required this.clima});
  final Clima clima;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(clima.ciudad, style: textos.headlineMedium),
        Image.network(clima.iconoUrl),
        Text('${clima.temp.toStringAsFixed(1)} °C',
            style: textos.displayMedium),
        Text(clima.descripcion, style: textos.titleMedium),
        const SizedBox(height: 16),
        Text('Sensación: ${clima.sensacion.toStringAsFixed(1)} °C'),
        Text('Humedad: ${clima.humedad}%'),
        Text('Viento: ${clima.viento} m/s'),
      ],
    );
  }
}
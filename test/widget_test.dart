import 'package:flutter_test/flutter_test.dart';
import 'package:clima_app/models/clima.dart';

void main() {
  test('Clima.fromJson lee los datos', () {
    final clima = Clima.fromJson({
      'name': 'Mexico City',
      'weather': [
        {'description': 'cielo claro', 'icon': '01d'}
      ],
      'main': {'temp': 20.5, 'feels_like': 19.6, 'humidity': 35},
      'wind': {'speed': 3.0},
    });
    expect(clima.ciudad, 'Mexico City');
    expect(clima.temp, 20.5);
    expect(clima.humedad, 35);
  });
}
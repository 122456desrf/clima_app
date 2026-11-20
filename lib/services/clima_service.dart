import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/clima.dart';

class ClimaException implements Exception {
  ClimaException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

class _Lugar {
  const _Lugar(this.nombre, this.estado, this.pais, this.lat, this.lon);
  final String nombre, estado, pais;
  final double lat, lon;
}

class ClimaService {
  ClimaService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  /// Acepta "Celaya", "Celaya, Guanajuato", "Celaya, MX", etc.
  /// OpenWeather no entiende nombres de estado en `q=`, así que primero
  /// buscamos la ciudad con el geocodificador y filtramos por estado/país.
  Future<Clima> porCiudad(String texto) async {
    final partes = texto
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (partes.isEmpty) throw ClimaException('Escribe el nombre de una ciudad');

    final filtros = partes.skip(1).map(_normalizar).toList();
    final lugares = await _geocodificar(partes.first);
    if (lugares.isEmpty) throw ClimaException('Ciudad no encontrada');

    final lugar = lugares.firstWhere(
      (l) => filtros.every((f) => _coincide(l, f)),
      orElse: () => lugares.first,
    );
    return porCoordenadas(lugar.lat, lugar.lon, nombre: lugar.nombre);
  }

  Future<Clima> porCoordenadas(double lat, double lon, {String? nombre}) async {
    final res = await _get(Uri.https(apiHost, '/data/2.5/weather', {
      'lat': '$lat',
      'lon': '$lon',
      'appid': apiKey,
      'units': 'metric',
      'lang': 'es',
    }));
    final datos = jsonDecode(res.body) as Map<String, dynamic>;
    if (nombre != null) datos['name'] = nombre;
    return Clima.fromJson(datos);
  }

  Future<List<_Lugar>> _geocodificar(String ciudad) async {
    final res = await _get(Uri.https(apiHost, '/geo/1.0/direct', {
      'q': ciudad,
      'limit': '5',
      'appid': apiKey,
    }));
    final lista = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return [
      for (final l in lista)
        _Lugar(
          l['name'] as String,
          (l['state'] as String?) ?? '',
          (l['country'] as String?) ?? '',
          (l['lat'] as num).toDouble(),
          (l['lon'] as num).toDouble(),
        ),
    ];
  }

  Future<http.Response> _get(Uri url) async {
    try {
      final res = await _client.get(url).timeout(const Duration(seconds: 10));
      switch (res.statusCode) {
        case 200:
          return res;
        case 401:
          throw ClimaException('API key inválida o sin activar');
        case 404:
          throw ClimaException('Ciudad no encontrada');
        case 429:
          throw ClimaException('Demasiadas consultas, intenta en un minuto');
        default:
          throw ClimaException('Error ${res.statusCode}');
      }
    } on TimeoutException {
      throw ClimaException('Sin respuesta, revisa tu conexión');
    } on http.ClientException {
      throw ClimaException('Sin conexión a internet');
    }
  }

  bool _coincide(_Lugar l, String filtro) =>
      _normalizar(l.estado).contains(filtro) ||
      l.pais.toLowerCase() == filtro;

  String _normalizar(String s) {
    const con = 'áéíóúüñ';
    const sin = 'aeiouun';
    var r = s.toLowerCase();
    for (var i = 0; i < con.length; i++) {
      r = r.replaceAll(con[i], sin[i]);
    }
    return r;
  }
}
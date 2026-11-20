import 'package:geolocator/geolocator.dart';
import 'clima_service.dart';

class UbicacionService {
  Future<Position> obtener() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw ClimaException('Activa el GPS del dispositivo');
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      throw ClimaException('Permiso de ubicación denegado');
    }
    return Geolocator.getCurrentPosition();
  }
}
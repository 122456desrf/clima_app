class Clima {
  const Clima({
    required this.ciudad,
    required this.descripcion,
    required this.icono,
    required this.temp,
    required this.sensacion,
    required this.humedad,
    required this.viento,
  });

  final String ciudad, descripcion, icono;
  final double temp, sensacion, viento;
  final int humedad;

  String get iconoUrl => 'https://openweathermap.org/img/wn/$icono@2x.png';

  factory Clima.fromJson(Map<String, dynamic> json) => Clima(
        ciudad: json['name'],
        descripcion: json['weather'][0]['description'],
        icono: json['weather'][0]['icon'],
        temp: (json['main']['temp'] as num).toDouble(),
        sensacion: (json['main']['feels_like'] as num).toDouble(),
        humedad: json['main']['humidity'],
        viento: (json['wind']['speed'] as num).toDouble(),
      );
}
import 'package:flutter/material.dart';
import '../models/clima.dart';
import '../services/clima_service.dart';
import '../services/ubicacion_service.dart';
import '../widgets/clima_info.dart';

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});
  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  final _climaService = ClimaService();
  final _ubicacionService = UbicacionService();
  final _ctrl = TextEditingController(text: 'Mexico City');
  late Future<Clima> _clima = _climaService.porCiudad(_ctrl.text);

  void _buscar() {
    FocusScope.of(context).unfocus();
    setState(() => _clima = _climaService.porCiudad(_ctrl.text));
  }

  void _miUbicacion() => setState(() {
        _clima = _ubicacionService
            .obtener()
            .then((p) => _climaService.porCoordenadas(p.latitude, p.longitude));
      });

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima 🌦')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBuscador(),
            const SizedBox(height: 24),
            Expanded(child: _buildResultado()),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscador() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _buscar(),
            ),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: _buscar),
          IconButton(
              icon: const Icon(Icons.my_location), onPressed: _miUbicacion),
        ],
      );

  Widget _buildResultado() => FutureBuilder<Clima>(
        future: _clima,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          return ClimaInfo(clima: snap.data!);
        },
      );
}
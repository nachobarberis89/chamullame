import 'package:flutter/material.dart';

void main() {
  runApp(const FonoChatApp());
}

class FonoChatApp extends StatelessWidget {
  const FonoChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fono Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EntryFlowScreen(),
    );
  }
}

class EntryFlowScreen extends StatefulWidget {
  const EntryFlowScreen({super.key});

  @override
  State<EntryFlowScreen> createState() => _EntryFlowScreenState();
}

class _EntryFlowScreenState extends State<EntryFlowScreen> {
  int _stepIndex = 0;

  void _nextStep() {
    setState(() {
      _stepIndex = (_stepIndex + 1).clamp(0, 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _QrEntryStep(onContinue: _nextStep),
      _SelfieStep(onContinue: _nextStep),
      const _RoomStep(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fono Chat'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: steps[_stepIndex],
      ),
    );
  }
}

class _QrEntryStep extends StatelessWidget {
  const _QrEntryStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('qr-step'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escanea el QR del evento para ingresar.',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            'La app valida tu acceso con un código único del evento y solo funciona dentro del WiFi dedicado.',
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Simular escaneo de QR'),
          ),
        ],
      ),
    );
  }
}

class _SelfieStep extends StatelessWidget {
  const _SelfieStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('selfie-step'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selfie obligatoria',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            'La imagen se toma en el momento y se elimina automáticamente al finalizar el evento.',
          ),
          const SizedBox(height: 24),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_outlined, size: 64),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.camera),
            label: const Text('Tomar selfie y continuar'),
          ),
        ],
      ),
    );
  }
}

class _RoomStep extends StatelessWidget {
  const _RoomStep();

  @override
  Widget build(BuildContext context) {
    final participants = [
      Participant(alias: 'Persona 12', status: 'Disponible'),
      Participant(alias: 'Persona 4', status: 'Ocupado'),
      Participant(alias: 'Persona 21', status: 'No molestar'),
      Participant(alias: 'Persona 33', status: 'Disponible'),
    ];

    return Padding(
      key: const ValueKey('room-step'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sala principal',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Participantes conectados y disponibles para llamada.'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: participants.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(participant.alias.split(' ').last),
                  ),
                  title: Text(participant.alias),
                  subtitle: Text(participant.status),
                  trailing: FilledButton(
                    onPressed: participant.status == 'Disponible' ? () {} : null,
                    child: const Text('Llamar'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.report_outlined),
            label: const Text('Reportar comportamiento'),
          ),
        ],
      ),
    );
  }
}

class Participant {
  const Participant({required this.alias, required this.status});

  final String alias;
  final String status;
}

import 'package:flutter/material.dart';
import 'intro_video_screen.dart';

void main() {
  runApp(MaterialApp(home: PlayerSetupScreen()));
}

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  int _playerCount = 3;
  late List<TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (_) => TextEditingController(text: null));
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _allNamesFilled() {
    for (int i = 0; i < _playerCount; i++) {
      if (_controllers[i].text.trim().isEmpty) return false;
    }
    return true;
  }

  void _onPlayPressed() {
    if (_allNamesFilled()) {
      final names = List<String>.generate(_playerCount, (i) => _controllers[i].text.trim());
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => IntroVideoScreen(playerNames: names)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color.fromRGBO(13, 71, 161, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Siparty Setup',
          style: TextStyle(fontFamily: 'Gyparody', fontSize: 50, color: darkBlue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('brought to you by', style: TextStyle(fontSize: 16))),
              Center(
                child: Text('Johnny Utah', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Center(child: Text('(as seen on Drinkers\' Den 2024)', style: TextStyle(fontSize: 16))),

              const SizedBox(height: 32),
              const Text('Select number of players:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                value: _playerCount,
                items: [3, 4, 5].map((n) => DropdownMenuItem(value: n, child: Text(n.toString()))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _playerCount = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: const Text('Enter player names:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...List.generate(_playerCount, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: _controllers[i],
                    decoration: InputDecoration(labelText: 'Player ${i + 1} Name', border: const OutlineInputBorder()),
                    textInputAction: TextInputAction.next,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a name' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                );
              }),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _allNamesFilled() ? _onPlayPressed : null, child: const Text('Play')),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topRight,
                child: Text('created by Jackson Wiebe', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'game_board_screen.dart';
import 'main.dart';
import 'package:just_audio/just_audio.dart';

class EndOfGameScreen extends StatefulWidget {
  final List<Player> players;
  const EndOfGameScreen({super.key, required this.players});

  @override
  State<EndOfGameScreen> createState() => _EndOfGameScreenState();
}

class _EndOfGameScreenState extends State<EndOfGameScreen> {
  late final List<Player> players;
  final audio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    players = widget.players;

    Future.delayed(Duration.zero, () {
      audio.setAsset('assets/outro.mp3');
      audio.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Find the highest score
    int topScore = players.fold(0, (prev, p) => p.score > prev ? p.score : prev);
    // Find all winners (in case of a tie)
    List<Player> winners = players.where((p) => p.score == topScore).toList();

    const Color darkBlue = Color.fromRGBO(13, 71, 161, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Siparty!',
          style: TextStyle(fontFamily: 'Gyparody', fontSize: 50, color: darkBlue),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            Text(
              winners.length == 1 ? '🏆 WINNER: ${winners.first.name}!' : '🏆 It\'s a tie between: ${winners.map((w) => w.name).join(", ")}!',
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text('Final Scores', style: TextStyle(fontSize: 60, fontWeight: FontWeight.w600)),
            const Divider(thickness: 2, height: 32),
            ...players.map(
              (p) => IntrinsicHeight(
                child: Row(
                  children: [
                    if (winners.contains(p)) const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(p.name, style: TextStyle(fontSize: 50, fontWeight: winners.contains(p) ? FontWeight.bold : FontWeight.normal)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${p.score} pts',
                      style: TextStyle(fontSize: 50, fontWeight: winners.contains(p) ? FontWeight.bold : FontWeight.normal, color: winners.contains(p) ? Colors.green[700] : Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PlayerSetupScreen()), (route) => false);
                },
                icon: const Icon(Icons.replay),
                label: const Text('Restart Game'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), textStyle: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

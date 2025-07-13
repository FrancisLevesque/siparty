import 'package:flutter/material.dart';
import 'end_of_game_scren.dart';

class Player {
  final String name;
  int score;
  Player({required this.name, this.score = 0});
}

class SipartyTile {
  final String question;
  final int value;
  bool revealed;
  bool awarded;
  SipartyTile({
    required this.question,
    required this.value,
    this.revealed = false,
    this.awarded = false,
  });
}

class GameBoardScreen extends StatefulWidget {
  final List<String> playerNames;
  const GameBoardScreen({super.key, required this.playerNames});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  // Sample categories and board data
  final List<String> categories = [
    'SCIENCE',
    'HISTORY',
    'SPORTS',
    'ANOTHER',
    'ONE MORE',
  ];

  late List<Player> players;

  late List<List<SipartyTile>> boardData;

  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    players = widget.playerNames.map((name) => Player(name: name)).toList();

    boardData = [
      [
        SipartyTile(
          question: 'What planet is known as the Red Planet?',
          value: 100,
        ),
        SipartyTile(question: 'Who discovered penicillin?', value: 200),
        SipartyTile(question: 'What is H2O?', value: 300),
      ],
      [
        SipartyTile(
          question: 'Who was the first President of the USA?',
          value: 100,
        ),
        SipartyTile(question: 'In which year did WW2 end?', value: 200),
        SipartyTile(question: 'Who wrote the Iliad?', value: 300),
      ],
      [
        SipartyTile(question: 'How many players on a soccer team?', value: 100),
        SipartyTile(question: 'What is a touchdown worth?', value: 200),
        SipartyTile(
          question: 'Which country hosts the Tour de France?',
          value: 300,
        ),
      ],
      [
        SipartyTile(question: 'What is H2O?', value: 300),
        SipartyTile(question: 'What is H2O?', value: 300),
        SipartyTile(question: 'What is H2O?', value: 300),
      ],
      [
        SipartyTile(question: 'What is H2O?', value: 300),
        SipartyTile(question: 'What is H2O?', value: 300),
        SipartyTile(question: 'What is H2O?', value: 300),
      ],
    ];
  }

  void _revealTile(int row, int col) {
    setState(() {
      if (!boardData[row][col].revealed && !boardData[row][col].awarded) {
        boardData[row][col].revealed = true;
        selectedRow = row;
        selectedCol = col;
      }
    });
  }

  void _awardPointsToPlayer(int playerIndex) {
    if (selectedRow == null || selectedCol == null) return;
    final tile = boardData[selectedRow!][selectedCol!];
    if (tile.awarded) return;

    setState(() {
      players[playerIndex].score += tile.value;
      tile.awarded = true;
      selectedRow = null;
      selectedCol = null;
    });

    // After awarding, check if all tiles are awarded
    bool allAwarded = boardData
        .expand((col) => col)
        .every((tile) => tile.awarded);
    if (allAwarded) {
      // Navigate to end game screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EndOfGameScreen(
            players: players
                .map((p) => Player(name: p.name, score: p.score))
                .toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int categoryCount = categories.length;
    final int valueCount = boardData[0].length;
    const Color darkBlue = Color.fromRGBO(13, 71, 161, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Siparty!',
          style: TextStyle(
            fontFamily: 'Gyparody',
            fontSize: 50,
            color: darkBlue,
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: categories
                .map(
                  (cat) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: darkBlue,
                      child: Text(
                        cat,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Game Board Tiles
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: categoryCount,
                childAspectRatio: 1.2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: categoryCount * valueCount,
              itemBuilder: (context, index) {
                int row = index ~/ categoryCount;
                int col = index % categoryCount;
                final tile =
                    boardData[col][row]; // Note: col-row order for grid

                return GestureDetector(
                  onTap: () {
                    if (!tile.revealed &&
                        !tile.awarded &&
                        selectedRow == null) {
                      _revealTile(col, row);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: darkBlue,
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: tile.awarded
                          ? Text('')
                          : tile.revealed
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tile.question,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'ITC Korinna',
                                ),
                              ),
                            )
                          : Text(
                              '\$${tile.value}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 70,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ITC Korinna',
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Players Row
          Container(
            color: Colors.indigo[50],
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(players.length, (i) {
                final player = players[i];
                final canAward =
                    selectedRow != null &&
                    selectedCol != null &&
                    !boardData[selectedRow!][selectedCol!].awarded;
                return GestureDetector(
                  onTap: canAward ? () => _awardPointsToPlayer(i) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: canAward ? Colors.green[200] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: canAward ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${player.score} pts',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

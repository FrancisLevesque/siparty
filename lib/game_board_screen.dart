import 'package:flutter/material.dart';
import 'end_of_game_scren.dart';
import 'package:just_audio/just_audio.dart';

class Player {
  final String name;
  int score;
  Player({required this.name, this.score = 0});
}

class SipartyTile {
  final String answer;
  final String question;
  final int value;
  bool revealed;
  bool answered;
  bool awarded;
  SipartyTile({required this.answer, required this.question, required this.value, this.revealed = false, this.answered = false, this.awarded = true});
}

class GameBoardScreen extends StatefulWidget {
  final List<String> playerNames;
  const GameBoardScreen({super.key, required this.playerNames});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  // Sample categories and board data
  final List<String> categories = ['HIGHBALLS', 'COCKTAILS', 'MIXERS', 'SPIRITS'];
  late List<Player> players;
  late List<List<SipartyTile>> boardData;

  final audio = AudioPlayer();

  int? catagoriesRevealed;
  int? selectedRow;
  int? selectedCol;
  bool firstTime = true;
  bool correctAnswer = false;

  @override
  void initState() {
    super.initState();
    players = widget.playerNames.map((name) => Player(name: name)).toList();
    catagoriesRevealed = -1;

    boardData = [
      [
        SipartyTile(answer: 'Gin and Tonic', question: 'It is commonly referred to as a G and T.', value: 100),
        SipartyTile(answer: 'Scotch and Soda', question: 'Rumour has it this drink was invented when an English stage actor entered a New York bar and requested a “Scotch Highball.”', value: 200),
        SipartyTile(answer: 'Rum and Coke or Cuba libre', question: 'This cocktail originated in the early 20th century in Cuba, after the country won its independence.', value: 300),
        SipartyTile(answer: 'Vodka Cran', question: 'Also called a Cape Codder. Some recipes call for squeezing a lime wedge over the glass.', value: 400),
      ],
      [
        SipartyTile(answer: 'Long Island iced tea', question: 'This drink was invented on a Long Island, but it\'s unclear if it was the island in Tennessee or in New York.', value: 100),
        SipartyTile(answer: 'Moscow Mule', question: 'Also called a "vodka buck", this drink is popularly served in a copper mug.', value: 200),
        SipartyTile(answer: 'Margarita', question: 'Spanish for "daisy", this drink is the world\'s most popular tequila-based cocktail.', value: 300),
        SipartyTile(answer: 'Piña Colada', question: 'Named for the strained pineapple juice that is one of the main ingredients of this drink.', value: 400),
      ],
      [
        SipartyTile(answer: 'Ginger Ale', question: 'Touted for its soothing effect on upset stomachs, this is a popular drink of choice for airline passengers.', value: 100),
        SipartyTile(answer: 'Coca-Cola or Coke', question: 'A popular drink invented in Atlanta, Georgia.', value: 200),
        SipartyTile(answer: 'Club Soda', question: 'The recipe was originally described in a pamphlet from 1772 called Directions for Impregnating Water with Fixed Air.', value: 300),
        SipartyTile(answer: 'Cranberry Juice', question: 'A 2008 study found that this drink might help prevent UTIs. A 2012 review has since refuted these findings.', value: 400),
      ],
      [
        SipartyTile(answer: 'Tequila', question: 'A distilled beverage made from the blue agave plant.', value: 100),
        SipartyTile(answer: 'Vodka or водка', question: 'Composed mainly of water and ethanol, but sometimes packaged with a variety of flavourings.', value: 200),
        SipartyTile(answer: 'Jägermeister', question: 'Developed in 1934, the 56 herbs and spices this drink is made with have never changed.', value: 300),
        SipartyTile(answer: 'Gin', question: 'Originally a medicinal liquor made by monks and alchemists across Europe.', value: 400),
      ],
    ];
  }

  bool _categoryRevealed(String name) {
    var categoryMap = categories.asMap();
    var category = categoryMap.entries.firstWhere((category) => category.value == name);
    if (category.key <= catagoriesRevealed!) {
      return true;
    }
    return false;
  }

  Future<void> _loadBoard() async {
    List<SipartyTile> allTiles = [];
    for (var row in boardData) {
      allTiles.addAll(row);
    }

    allTiles.shuffle();
    await Future.delayed(Duration(milliseconds: 800));
    for (var tile in allTiles) {
      await Future.delayed(Duration(milliseconds: 150));
      setState(() {
        tile.awarded = false;
      });
    }
  }

  void _revealCatagory() async {
    setState(() {
      catagoriesRevealed = catagoriesRevealed! + 1;
    });
    if (catagoriesRevealed! >= (categories.length - 1)) {
      if (firstTime) {
        audio.setAsset('assets/correct.mp3');
        audio.play();
        await Future.delayed(Duration(seconds: 1));
        firstTime = false;
        audio.setAsset('assets/load_board.mp3');
        audio.play();
        _loadBoard();
      }
      return;
    } else {
      audio.setAsset('assets/correct.mp3');
      audio.play();
    }
  }

  void _revealTile(int col, int row) {
    setState(() {
      if (catagoriesRevealed! >= (categories.length - 1) && !boardData[col][row].revealed && !boardData[col][row].answered && !boardData[col][row].awarded) {
        boardData[col][row].revealed = true;
        selectedRow = col;
        selectedCol = row;
      }
    });
  }

  void _revealAnswer(int col, int row, bool correct) {
    setState(() {
      if (catagoriesRevealed! >= (categories.length - 1) && boardData[col][row].revealed && !boardData[col][row].answered && !boardData[col][row].awarded) {
        boardData[col][row].answered = true;
        if (correct) {
          audio.setAsset('assets/correct.mp3');
          correctAnswer = true;
        } else {
          audio.setAsset('assets/wrong.mp3');
        }
        audio.play();
        selectedRow = col;
        selectedCol = row;
      }
    });
  }

  void _awardPointsToPlayer(int playerIndex) {
    if (selectedRow == null || selectedCol == null) return;
    final tile = boardData[selectedRow!][selectedCol!];
    if (tile.awarded) return;
    if (!tile.answered) {
      audio.setAsset('assets/wrong.mp3');
      audio.play();
      setState(() {
        players[playerIndex].score -= tile.value;
      });
      return;
    }

    setState(() {
      if (correctAnswer) {
        players[playerIndex].score += tile.value;
      } else {
        players[playerIndex].score -= tile.value;
      }
      tile.awarded = true;
      selectedRow = null;
      selectedCol = null;
      correctAnswer = false; // resets colouring on player points section
    });

    // After awarding, check if all tiles are awarded
    bool allAwarded = boardData.expand((col) => col).every((tile) => tile.awarded);
    if (allAwarded) {
      // Navigate to end game screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EndOfGameScreen(
            players: players.map((p) => Player(name: p.name, score: p.score)).toList(),
          ),
        ),
      );
    }
  }

  void _everyoneWasWrong() {
    if (selectedRow == null || selectedCol == null) return;
    final tile = boardData[selectedRow!][selectedCol!];
    if (tile.awarded) return;

    setState(() {
      tile.awarded = true;
      selectedRow = null;
      selectedCol = null;
      correctAnswer = false; // resets colouring on player points section
    });

    // After awarding, check if all tiles are awarded
    bool allAwarded = boardData.expand((col) => col).every((tile) => tile.awarded);
    if (allAwarded) {
      // Navigate to end game screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EndOfGameScreen(
            players: players.map((p) => Player(name: p.name, score: p.score)).toList(),
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
          style: TextStyle(fontFamily: 'Gyparody', fontSize: 50, color: darkBlue),
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
                    child: GestureDetector(
                      onTap: () {
                        _revealCatagory();
                      },
                      onLongPress: () {
                        _everyoneWasWrong();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: darkBlue,
                        child: Text(
                          _categoryRevealed(cat) ? cat : '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: categoryCount, childAspectRatio: 2.45, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemCount: categoryCount * valueCount,
              itemBuilder: (context, index) {
                int row = index ~/ categoryCount;
                int col = index % categoryCount;
                final tile = boardData[col][row]; // Note: col-row order for grid

                return GestureDetector(
                  onTap: () {
                    if (!tile.revealed && selectedRow == null) {
                      _revealTile(col, row);
                    } else if (!tile.answered) {
                      _revealAnswer(col, row, true);
                    }
                  },
                  onLongPress: () {
                    if (tile.revealed && !tile.answered) {
                      _revealAnswer(col, row, false);
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
                          : tile.answered
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tile.answer,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w400, fontFamily: 'ITC Korinna'),
                              ),
                            )
                          : tile.revealed
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                tile.question,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400, fontFamily: 'ITC Korinna'),
                              ),
                            )
                          : Text(
                              '\$${tile.value}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.amber, fontSize: 70, fontWeight: FontWeight.bold, fontFamily: 'ITC Korinna'),
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
                return GestureDetector(
                  onTap: () => _awardPointsToPlayer(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: correctAnswer
                          ? Colors.green[200]
                          : player.score < 0
                          ? Colors.red[200]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: correctAnswer ? Colors.green : Colors.grey, width: 2),
                    ),
                    child: Row(
                      children: [
                        Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        const SizedBox(width: 16),
                        Text('${player.score} pts', style: const TextStyle(fontSize: 24)),
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

import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const PuzzleGameApp());
}

class PuzzleGameApp extends StatelessWidget {
  const PuzzleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Puzzle Game\n Developed by Tatayya Naidu Chavatapalli',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),
      home: const PuzzleGame(),
    );
  }
}

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final Random random = Random();

  List<int> tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  int moves = 0;

  @override
  void initState() {
    super.initState();
    newGame();
  }

  void newGame() {
    setState(() {
      tiles = [1, 2, 3, 4, 5, 6, 7, 8, 0];

      // Make many valid random moves so the puzzle remains solvable.
      for (int i = 0; i < 100; i++) {
        _randomMove();
      }

      moves = 0;
    });
  }

  void _randomMove() {
    int emptyIndex = tiles.indexOf(0);

    List<int> possibleMoves = [];

    int row = emptyIndex ~/ 3;
    int col = emptyIndex % 3;

    if (row > 0) {
      possibleMoves.add(emptyIndex - 3);
    }

    if (row < 2) {
      possibleMoves.add(emptyIndex + 3);
    }

    if (col > 0) {
      possibleMoves.add(emptyIndex - 1);
    }

    if (col < 2) {
      possibleMoves.add(emptyIndex + 1);
    }

    int selectedIndex = possibleMoves[random.nextInt(possibleMoves.length)];

    tiles[emptyIndex] = tiles[selectedIndex];
    tiles[selectedIndex] = 0;
  }

  void moveTile(int index) {
    int emptyIndex = tiles.indexOf(0);

    int row = index ~/ 3;
    int col = index % 3;

    int emptyRow = emptyIndex ~/ 3;
    int emptyCol = emptyIndex % 3;

    bool isAdjacent = (row - emptyRow).abs() + (col - emptyCol).abs() == 1;

    if (!isAdjacent) {
      return;
    }

    setState(() {
      tiles[emptyIndex] = tiles[index];
      tiles[index] = 0;

      moves++;
    });

    if (_isSolved()) {
      _showWinDialog();
    }
  }

  bool _isSolved() {
    for (int i = 0; i < 8; i++) {
      if (tiles[i] != i + 1) {
        return false;
      }
    }

    return tiles[8] == 0;
  }

  void _showWinDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              '🎉 Congratulations!',
              textAlign: TextAlign.center,
            ),
            content: Text(
              'Puzzle solved in $moves moves!',
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    newGame();
                  },
                  child: const Text('PLAY AGAIN'),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget buildTile(int value, int index) {
    if (value == 0) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
      );
    }

    return GestureDetector(
      onTap: () => moveTile(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8B7CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1FF),
      appBar: AppBar(
        title: const Text(
          '🧩 8 Puzzle Game',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 500;
            final spacing = compact ? 8.0 : 20.0;
            final boardSize = min(
              constraints.maxWidth - 50,
              constraints.maxHeight * 0.5,
            );

            return Column(
              children: [
                SizedBox(height: compact ? 8 : 25),
                const Text(
                  'Arrange the numbers from 1 to 8',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: spacing),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Text(
                    'Moves: $moves',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: boardSize,
                  height: boardSize,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      return buildTile(tiles[index], index);
                    },
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: compact ? 8 : 30,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: newGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'NEW GAME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A5AE0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

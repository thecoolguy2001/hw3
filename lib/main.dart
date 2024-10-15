// Demonte Walker HW3
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class CardModel {
  final String image;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.image, this.isFaceUp = false, this.isMatched = false});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  List<CardModel> cards = [];
  int _score = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;
  CardModel? firstCard;
  CardModel? secondCard;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _elapsedSeconds = 0;
      firstCard = null;
      secondCard = null;
      _startTimer();

      // Initialize the card grid (using 8 pairs for a 4x4 grid)
      List<String> images = [
        '🍎', '🍌', '🍓', '🍇', '🍉', '🍒', '🍑', '🍍'
      ];

      cards = images.expand((image) => [
        CardModel(image: image),
        CardModel(image: image)
      ]).toList();

      cards.shuffle(); // Shuffle the cards for randomness
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _onCardTap(int index) {
  setState(() {
    if (cards[index].isFaceUp || cards[index].isMatched) return;

    cards[index].isFaceUp = true;

    if (firstCard == null) {
      firstCard = cards[index];
    } else if (secondCard == null) {
      secondCard = cards[index];

      // Check if cards match
      if (firstCard!.image == secondCard!.image) {
        _score += 100;  // Award 100 points for a correct match
        firstCard!.isMatched = true;
        secondCard!.isMatched = true;
        firstCard = null;
        secondCard = null;

        // Check for win condition
        if (_score == cards.length ~/ 2 * 100) { // Adjusting win condition for new scoring
          _stopTimer();
          _showVictoryMessage();
        }
      } else {
        // Deduct points for incorrect match
        _score = (_score >= 100) ? _score - 100 : 0; // Ensure score doesn't go below 0
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            firstCard!.isFaceUp = false;
            secondCard!.isFaceUp = false;
            firstCard = null;
            secondCard = null;
          });
        });
      }
    }
  });
}


  void _showVictoryMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Victory!'),
        content: Text('You won in $_elapsedSeconds seconds with a score of $_score!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $_elapsedSeconds s', style: const TextStyle(fontSize: 18)),
                Text('Score: $_score', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.6, // Adjust aspect ratio for smaller cards
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: cards[index].isFaceUp || cards[index].isMatched
                          ? Colors.white
                          : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        cards[index].isFaceUp || cards[index].isMatched
                            ? cards[index].image
                            : '',
                        style: const TextStyle(fontSize: 18), // Smaller font size for cards
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

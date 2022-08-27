// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_quiz/const.dart';
import 'package:math_quiz/quiz_brain.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

QuizBrain _quizBrain = QuizBrain();
int _score = 0;
int _highScore = 0;
double _value = 0;
int falseCounter = 0;
int totalQuizes = 0;

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  static const id = 'game_screen';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer _timer;
  int _totalTime = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() async {
    _quizBrain.makeQuiz();
    startTimer();
    _value = 1;
    _score = 0;
    falseCounter = 0;
    totalQuizes = 0;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _highScore = sharedPreferences.getInt('highscore') ?? 0;
  }

  void startTimer() {
    const speed = Duration(milliseconds: 100);
    _timer = Timer.periodic(speed, (timer) {
      if (_value > 0) {
        setState(() {
          _value > 0.01 ? _value -= 0.01 : _value = 0;
          _totalTime = (_value * 10 + 1).toInt();
        });
      } else {
        setState(() {
          _totalTime = 0;
          newGameDialog();
          _timer.cancel();
        });
      }
    });
  }

  Future<void> newGameDialog() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: const Color.fromARGB(255, 28, 73, 155),
            title: const FittedBox(
              child: Text(
                'Game Over',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent),
              ),
            ),
            content: Text(
              'Score: $_score  | $totalQuizes',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 18, color: Colors.white60),
                ),
              ),
              TextButton(
                onPressed: () {
                  startGame();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          );
        },
        barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 1, 104, 152),
              Color.fromARGB(255, 88, 248, 248),
            ],
          ),
        ),
        child: Column(
          children: [
            ScoreIndicators(),
            QuizBody(),
            Expanded(
              flex: 2,
              child: CircularPercentIndicator(
                radius: 72,
                lineWidth: 12,
                percent: _value,
                progressColor: _value > 0.6
                    ? Colors.green
                    : _value > 0.3
                        ? const Color.fromARGB(255, 181, 167, 40)
                        : const Color.fromARGB(255, 178, 49, 39),
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  _totalTime.toString(),
                  style: GoogleFonts.architectsDaughter(
                    textStyle: Theme.of(context).textTheme.headline4,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  TrueFalseButton(
                    color: Colors.greenAccent,
                    userChoice: 'True',
                  ),
                  TrueFalseButton(
                    color: Colors.redAccent,
                    userChoice: 'False',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrueFalseButton extends StatelessWidget {
  const TrueFalseButton({
    Key? key,
    required this.userChoice,
    required this.color,
  }) : super(key: key);

  final String userChoice;
  final Color color;

  void checkAnswer() async {
    if (userChoice == _quizBrain.quizAns) {
      _score++;
      _value >= 0.90 ? _value = 1 : _value += 0.1;
      if (_highScore < _score) {
        _highScore = _score;
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setInt('highscore', _highScore);
      }
    } else {
      falseCounter++;
      _value < 0.1 * falseCounter ? _value = 0 : _value -= 0.1 * falseCounter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            side: const BorderSide(
              width: 2,
              color: Colors.white60,
            ),
          ),
          onPressed: () {
            checkAnswer();
            totalQuizes++;
            _quizBrain.makeQuiz();
          },
          child: Center(
            child: Text(
              userChoice,
              style: GoogleFonts.architectsDaughter(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 32,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizBody extends StatelessWidget {
  const QuizBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(
            _quizBrain.quiz,
            style: GoogleFonts.architectsDaughter(
              textStyle: Theme.of(context).textTheme.headline4,
              fontSize: 32,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ScoreIndicators extends StatelessWidget {
  const ScoreIndicators({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
      ),
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ScoreIndicator(label: 'HIGHSCORE', score: '$_highScore'),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
            ),
            ScoreIndicator(label: 'SCORE', score: '$_score'),
          ],
        ),
      ),
    );
  }
}

class ScoreIndicator extends StatelessWidget {
  const ScoreIndicator({Key? key, required this.label, required this.score})
      : super(key: key);

  final String label;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: kScoreLabelTextStyle),
        const SizedBox(height: 10),
        Text(score, style: kScoreIndicatorTextStyle),
      ],
    );
  }
}

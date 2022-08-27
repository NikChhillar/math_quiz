import 'dart:math';

class QuizBrain {
  var _quizAns = '';
  var _quiz = '';

  void makeQuiz() {
    List<String> listOfSignsOp = ['+', '-', '*', '/'];
    Random randomEq = Random();
    var selectedSign = listOfSignsOp[randomEq.nextInt(listOfSignsOp.length)];

    var firstNum = randomEq.nextInt(10) + 10;
    var secondNum = randomEq.nextInt(9) + 1;

    // ignore: prefer_typing_uninitialized_variables
    var result;
    switch (selectedSign) {
      case '+':
        result = firstNum + secondNum;
        break;

      case '-':
        result = firstNum - secondNum;
        break;

      case '*':
        result = firstNum * secondNum;
        break;

      case '/':
        {
          if (firstNum % secondNum != 0) {
            if (firstNum % 2 != 0) firstNum++;
            for (int i = secondNum; i > 0; i--) {
              if (firstNum % i == 0) {
                secondNum = i;
                break;
              }
            }
          }
          result = firstNum ~/ secondNum;
        }
    }

    var falseMaker = [-3, -2, -1, 1, 2, 3];
    var randomChosen = falseMaker[randomEq.nextInt(falseMaker.length)];

    var trueFalse = randomEq.nextInt(2);

    _quizAns = 'True';
    if (trueFalse == 0) {
      _quizAns = 'False';
      result = result + randomChosen;
      if (result < 0) result = result + randomEq.nextInt(2) + 4;
    }

    _quiz = '$firstNum $selectedSign $secondNum = $result';
  }

  get quizAns => _quizAns;
  get quiz => _quiz;
}

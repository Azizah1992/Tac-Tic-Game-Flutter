// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:xo/game_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String activePlayer = 'X'; // معرفه من سيلعب الان
  bool gameOver =
      false; // هل اللعبه منتهيه ام  لا مع بدايه اللعب لن تكون منتهيه
  int turn = 0; // عدد مرات اللعب
  String result = 'XX';
  Game game = Game();

  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? Column(
                children: [
                  ...firstBlock(),
                  _expanded(context),
                  ...lastBlock(), //الثلاث نقاط تستخدم لاستخراج العناصر من اللست
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...firstBlock(),
                        ...lastBlock(),
                      ],
                    ),
                  ),
                  _expanded(context),
                ],
              ),
      ),
    );
  }

  List<Widget> firstBlock() {
    return [
      SwitchListTile.adaptive(
        title: const Text(
          'Turn on/off two player ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        value: isSwitched,
        onChanged: (bool newValue) {
          setState(() {
            isSwitched = newValue;
          });
        },
      ),
      Text(
        " it's $activePlayer  turn ".toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 52,
        ),
        textAlign: TextAlign.center,
      ),
    ];
  }

  List<Widget> lastBlock() {
    return [
      Text(
        result,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 42,
        ),
        textAlign: TextAlign.center,
      ),
      ElevatedButton.icon(
        onPressed: () {
          setState(() {
            player.playerX = [];
            player.playerO = []; // داله  تصفر كل القيم

            activePlayer = 'X'; // معرفه من سيلعب الان
            gameOver =
                false; // هل اللعبه منتهيه ام  لا مع بدايه اللعب لن تكون منتهيه
            turn = 0; // عدد مرات اللعب
            result = '';
          });
        },
        icon: const Icon(Icons.replay),
        label: const Text('Repat the game'),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).splashColor),
        ),
      ),
    ];
  }

  Expanded _expanded(BuildContext context) {
    return Expanded(
      child: GridView.count(
        padding: EdgeInsets.all(16),
        mainAxisSpacing: 8.0, // الفراغات بين الشبكه
        crossAxisSpacing: 8.0,
        childAspectRatio: 1.0, // مهمه جدا لضبط الابعاد والريسبونسف
        crossAxisCount: 3,

        children: List.generate(
            9,
            (index) => InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: gameOver
                      ? null
                      : () {
                          _onTap(index);
                        }, // هل القيم اوفر تساوي ترو true
                  //  اذا كان نعم يعطيني نل  ---> اذا غير ذللك عطني الفنكشن
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        player.playerX.contains(index)
                            ? 'X'
                            : player.playerO.contains(
                                    index) // هل البلاير آو يحتوي على الانديكس
                                ? 'O' // اذا كان نعم قم بوضع بلاير او
                                : '', // اذا كان لا ضع قيمه فارغه
                        style: TextStyle(
                          color: player.playerX.contains(index)
                              ? Colors.blue
                              : Colors.pink,
                          fontSize: 52,
                        ),
                      ),
                    ),
                  ),
                )),
      ),
    );
  }

  _onTap(int index) async // فنكشن تقوم بتنفيذ اللعب
  {
    if ((player.playerX.isEmpty || !player.playerX.contains(index)) &&
        (player.playerO.isEmpty || !player.playerO.contains(index))) {
      game.playGame(index, activePlayer);
      updateState();

      if (!isSwitched && !gameOver && turn != 9) {
        await game.autoPlay(activePlayer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(() {
      activePlayer = (activePlayer == 'X') ? 'O' : 'X';
      turn++;

      String winnerPlayer = game.checkWinner();

      if (winnerPlayer != '') {
        gameOver = true;
        result = '$winnerPlayer is the winner';
      } else if (!gameOver && turn == 9) {
        result = "it's Draw !";
      }
    });
  }
}

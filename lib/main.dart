import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // declarations
  bool oTurn = true;

  // 1st player is O
  List<String> displayElement = ['', '', '', '', '', '', '', '', ''];
  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  String? winner;


    final List<List<int>> adjacencyMatrix = [
    [1, 3],    // Square 0
    [0, 2, 4], // Square 1
    [1, 5],    // Square 2
    [0, 4, 6], // Square 3
    [1, 3, 5, 7], // Square 4
    [2, 4, 8], // Square 5
    [3, 7],    // Square 6
    [4, 6, 8], // Square 7
    [5, 7],    // Square 8
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo[900],
        body: Column(
          children: <Widget>[
             SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Player X',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            xScore.toString(),
                            style:
                                TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Player 0',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            oScore.toString(),
                            style:
                                TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // const Spacer(),
            /////////////////////////////////
            Expanded(
              flex: 4,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _tapped(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 25.0,
                            ),
                          ],
                        ),
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              displayElement[index],
                              style: TextStyle(
                                color: displayElement[index] == 'O'
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              // Button for Clearing the Enter board
              // as well as Scoreboard to start allover again

              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _clearScoreBoard,
                      child: const Text("Clear Score Board"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


//   bool isAdjacent(int index1, int index2) {
//   // Function to check if two cell indices are adjacent
//   return adjacencyMatrix[index1].contains(index2);
// }

void _startDragging(String symbol) {
  // Function to initiate dragging when the user taps on an 'O' or 'X' after reaching a count of 3
  setState(() {
    if (oTurn && symbol == 'O') {
      draggableO = List.generate(3, (_) => 'O');
    } else if (!oTurn && symbol == 'X') {
      draggableX = List.generate(3, (_) => 'X');
    }
  });
}

int oCount = 0;
int xCount = 0;
List<String> draggableO = []; // Store 'O's that reached the limit
List<String> draggableX = []; // Store 'X's that reached the limit


List<String> draggableTokens = [];

void _tapped(int index) {
  setState(() {
    if (oTurn) {
      _handlePlayerMove('O', index);
    } else {
      _handlePlayerMove('X', index);
    }

    oTurn = !oTurn;
    _checkWinner();
  });
}

bool isAdjacent(int index1, int index2) {
  // Assuming the grid size is 3x3
  int row1 = index1 ~/ 3;
  int col1 = index1 % 3;
  int row2 = index2 ~/ 3;
  int col2 = index2 % 3;

  return (row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1;
}


void _handlePlayerMove(String player, int index) {
  if (isDraggable(player)) {
    if (displayElement[index].isEmpty) {
      // Drag the player token to an adjacent square
      int lastIndex = displayElement.indexOf(player);
      if (lastIndex != -1 && isAdjacent(lastIndex, index)) {
        setState(() {
          displayElement[lastIndex] = '';
          displayElement[index] = player;
        });
      }
    } else if (displayElement[index] == player) {
      // Start dragging the player token
      _startDragging(player);
    }
  } else {
    // Normal tap behavior when the player's count is less than 3
    if (displayElement[index].isEmpty) {
      setState(() {
        displayElement[index] = player;
        filledBoxes++;
        if (getPlayerCount(player) == 3) {
          draggableTokens.add(player);
        }
      });

      // Check if the game is over
      _checkWinner();
    }
  }
}


void _resetGame() {
  setState(() {
    displayElement = List.filled(9, ''); // Reset the game board to an empty state
    filledBoxes = 0; // Reset the filled boxes count
    oCount = 0; // Reset 'O' count
    xCount = 0; // Reset 'X' count
    draggableO.clear(); // Clear the 'O' draggable list
    draggableX.clear(); // Clear the 'X' draggable list
    draggableTokens.clear(); // Clear the draggableTokens list
  });
}



bool isDraggable(String player) {
  return draggableTokens.contains(player);
}

int getPlayerCount(String player) {
  return displayElement.where((element) => element == player).length;
}


  // bool isAdjacent(int sourceIndex, int targetIndex) {
  //   return adjacencyMatrix[sourceIndex].contains(targetIndex);
  // }

  String?  _checkWinner() {
    // Checking rows
    if (displayElement[0] == displayElement[1] &&
        displayElement[0] == displayElement[2] &&
        displayElement[0] != '') {
      //  _showWinDialog(displayElement[0]);
      showWinSnackBar(displayElement[0]);
    }
    if (displayElement[3] == displayElement[4] &&
        displayElement[3] == displayElement[5] &&
        displayElement[3] != '') {
      showWinSnackBar(displayElement[3]);
    }
    if (displayElement[6] == displayElement[7] &&
        displayElement[6] == displayElement[8] &&
        displayElement[6] != '') {
      showWinSnackBar(displayElement[6]);
    }

    // Checking Column
    if (displayElement[0] == displayElement[3] &&
        displayElement[0] == displayElement[6] &&
        displayElement[0] != '') {
      showWinSnackBar(displayElement[0]);
    }
    if (displayElement[1] == displayElement[4] &&
        displayElement[1] == displayElement[7] &&
        displayElement[1] != '') {
      showWinSnackBar(displayElement[1]);
    }
    if (displayElement[2] == displayElement[5] &&
        displayElement[2] == displayElement[8] &&
        displayElement[2] != '') {
      showWinSnackBar(displayElement[2]);
    }

    // Checking Diagonal
    if (displayElement[0] == displayElement[4] &&
        displayElement[0] == displayElement[8] &&
        displayElement[0] != '') {
      showWinSnackBar(displayElement[0]);
    }
    if (displayElement[2] == displayElement[4] &&
        displayElement[2] == displayElement[6] &&
        displayElement[2] != '') {
      showWinSnackBar(displayElement[2]);
    } else if (filledBoxes == 9) {
      showDrawSnackBar();
    }

      if (winner != null || filledBoxes == 9) {
    return winner; // Return the winner (can be 'O', 'X', or null for a draw)
  } else {
    return null; // Game is not over yet
  }
  }

  void showWinSnackBar(String winner) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 20),
        content: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 75),
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.black),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "\" $winner \" is Winner!!!",
              style: const TextStyle(fontSize: 25),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 1000,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Play again',
          onPressed: () {
            _clearBoard();
          },
        ),
      ),
    );
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
  }

  void showDrawSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 20),
        content: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 75),
          decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.black),
              borderRadius: BorderRadius.circular(20)),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Draw",
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 1000,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Play again',
          onPressed: () {
            _clearBoard();
          },
        ),
      ),
    );
  }

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
    });

    filledBoxes = 0;
  }

  void _clearScoreBoard() {
    setState(() {
      xScore = 0;
      oScore = 0;
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
    });
    filledBoxes = 0;
  }
}
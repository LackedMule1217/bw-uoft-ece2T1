//
//  playMove.cpp
//  TicTacTo
//
//  Created by Tarek Abdelrahman on 2018-05-15.
//  Copyright © 2018 Tarek Abdelrahman. All rights reserved.
//

#include <iostream>
#include <tic-tac-toe/playMove.h>

using namespace std;

// print helper function prototype
void print(int board[3][3], int row, int col, bool& turn, bool& validMove, bool& gameOver, int& winCode);

void playMove(int board[3][3], int row, int col, bool& turn, bool& validMove, bool& gameOver, int& winCode) {

    // If the game is over, do nothing
    if (gameOver) return;

    // Insert your code here
    // 1) Check if valid move
    if (board[row][col] != 0) {
        validMove = false;
        print(board, row, col, turn, validMove, gameOver, winCode);
        return;
    } else {
        validMove = true;
    }

    // 2) If validMove, then update the board at given location and switch "turn" boolean value
    if (turn == false) {
        board[row][col] = -1;
    } else {
        board[row][col] = 1;
    }
    turn = !turn;

    // 3) Check if game over
    // check horizontal and vertical match
    for (int m = 0; m < (boardSize); m++) {
        // check horizontal match
        if ((board[m][0] != 0) && (board[m][0] == board[m][1]) && (board[m][0] == board[m][2]))
        {
            gameOver = true;
            winCode = m + 1;
            print(board, row, col, turn, validMove, gameOver, winCode);
            return;
        }
        // check vertical match
        else if ((board[0][m] != 0) && (board[0][m] == board[1][m]) && (board[0][m] == board[2][m]))
        {
            gameOver = true;
            winCode = m + 4;
            print(board, row, col, turn, validMove, gameOver, winCode);
            return;
        }
    }
    // check diagonal match
    if ((board[0][0] != 0) && (board[0][0] == board[1][1]) && (board[0][0] == board[2][2]))
    {
        gameOver = true;
        winCode = 7;
        print(board, row, col, turn, validMove, gameOver, winCode);
        return;
    }
    else if ((board[0][2] != 0) && (board[0][2] == board[1][1]) && (board[0][2] == board[2][0]))
    {
        gameOver = true;
        winCode = 8;
        print(board, row, col, turn, validMove, gameOver, winCode);
        return;
    }
    // check if draw
    int zeroCnt = 0;
    for (int row=0; row<boardSize; row++) {
        for (int col=0; col<boardSize; col++) {
            // iterate through board and increase zeroCnt by 1 for each board element == 0
            if (board[row][col] == 0) {
                zeroCnt++;
            }
        }
    }
    if (zeroCnt == 0) { // if zeroCnt == 0, then draw
        gameOver = true;
        winCode = 0;
        print(board, row, col, turn, validMove, gameOver, winCode);
        return;
    }

    // 4) Since it's not game over, set gameOver to false, print output and return
    gameOver = false;
    print(board, row, col, turn, validMove, gameOver, winCode);
    return;
}

// The function must always print the output specified in the handout before it exits
// Use the standard output (i.e., cout) to print the output

// Insert code to print the output below
// Helper Function: print the output
void print(int board[3][3], int row, int col, bool& turn, bool& validMove, bool& gameOver, int& winCode) {
    // cout each element in board array
    for (int row=0; row<boardSize; row++) {
        for (int col=0; col<boardSize; col++) {
            cout << board[row][col] << " ";
        }
    }
    
    // cout the rest of the necessary elements
    cout << row << " " << col << " " << turn << " " << validMove << " " << gameOver<< " " << winCode << endl;
    return;
}

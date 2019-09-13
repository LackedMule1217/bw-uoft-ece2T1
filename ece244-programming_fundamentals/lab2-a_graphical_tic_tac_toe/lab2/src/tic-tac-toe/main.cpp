//
//  main.cpp
//  TicTacTo
//
//  Created by Tarek Abdelrahman on 2018-05-15.
//  Copyright © 2018 Tarek Abdelrahman. All rights reserved.
//

#include <SFML/Graphics.hpp>
#include <iostream>

#include "tic-tac-toe/playMove.h"

using namespace std;
using namespace sf;


int main() {

    /************************************************************************************************************/
    /* The following variables define the state of the game                                                     */
    /************************************************************************************************************/

    // You should complete the following declarations
    // Make sure to initialize the variables

    // The game board array
    int gameBoard[3][3] = {Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty,Empty};

    // An boolean that represents the turn in the game; X gets the first turn
    bool turn = true;

    // A boolean to represent if the move is valid
    bool validMove = false;

    // A boolean to represent if the game is over
    bool gameOver = false;

    // An integer that represents the win code
    int winCode = 0;

    /************************************************************************************************************/
    /* Insert code that loads the various images used by the game and creates the sprites                       */
    /* The loading of the X image is shown. Repeat for the rest of the images                                  */
    /************************************************************************************************************/

    // Get the X image
    sf::Texture X_texture;
    if (!X_texture.loadFromFile("X.jpg")) {
        return EXIT_FAILURE;
    }
    sf::Sprite X_sprite(X_texture);

    // Get the O image
    sf::Texture O_texture;
    if (!O_texture.loadFromFile("O.jpg")) {
        return EXIT_FAILURE;
    }
    sf::Sprite O_sprite(O_texture);

    // Get the blank image
    sf::Texture blank_texture;
    if (!blank_texture.loadFromFile("blank.jpg")) {
        return EXIT_FAILURE;
    }
    sf::Sprite blank_sprite(blank_texture);

    /************************************************************************************************************/
    /* Insert code that creates the window and displays it                                                      */
    /************************************************************************************************************/

    // First, we find the sizes of the images so we can determine the size of the window we must create
    // The images (X, O and Blank) are assumed to be square are are all of the same size
    // Thus, we just find the size of one of them

    // The tile size is the size of the images
    const int tileSize = X_texture.getSize().x;

    // The cell borders (thick lines) are rectangles
    // The size of these rectangles is 1/20th of the size of the tile by 3 cell sizes plus 2 barWidth's
    const int barWidth = tileSize/20;
    const int barHeight = boardSize*tileSize + (boardSize-1)*barWidth;

    // The size of the window in pixels can now be calculated
    const int windowSize = boardSize*tileSize + (boardSize-1)*barWidth;

    // Create the main window: it has a title bar and a close button, but is not resizable
    sf::RenderWindow window(sf::VideoMode(windowSize, windowSize), "ECE244 Tic-Tac-Toe", sf::Style::Titlebar | sf::Style::Close);

    // Set the Icon that appears in the task bar when the window is minimized
    // Insert you code here, see the lab handout
    sf::Image icon;
    if (!icon.loadFromFile("icon.jpg")) {
        return EXIT_FAILURE;
    }
    window.setIcon(icon.getSize().x, icon.getSize().y, icon.getPixelsPtr());

    // Create the horizonal (vertical) borders as rectangles of sizes barWidth and barHeight (berHeight and barWidth)
    // Insert your code here
    sf::RectangleShape borderRectangle(sf::Vector2f(barWidth, barHeight));
    borderRectangle.setFillColor(sf::Color::Black);

    /************************************************************************************************************/
    /* This is the main event loop of the code                                                                  */
    /************************************************************************************************************/

    // Start the game loop that runs as long as the window is open
    while (window.isOpen()) {
        // The event
        sf::Event event;

        // Process the events
        while (window.pollEvent(event)) {

            // This is the handling of the close window event
            // Close window: exit
            if (event.type == sf::Event::Closed) {
                window.close();
            }

            // Escape pressed: exit
            if (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Escape) {
                window.close();
            }

            // Left mouse button pressed: get the click position and play the move
            // is_game_over is a variable you should define above
            if (event.type == sf::Event::MouseButtonPressed && event.mouseButton.button == sf::Mouse::Left) {
                // left mouse button is pressed: get the coordinates in pixels
                // Insert your code to get the coordinates here
                sf::Vector2i localPosition = Mouse::getPosition(window);

                // Convert the pixel coordinates into game board rows and columns
                // Just divide by tileSize
                // Observe that the x axis is the rows and the y axis is the columns
                // Also make sure that row and column values are valid
                // Insert your code below
                int row = localPosition.y / tileSize;
                int col = localPosition.x / tileSize;

                // Play the move by calling the playMove function
                // Insert your code below
                if (row > -1 && col > -1 && row < tileSize && col < tileSize) {
                    playMove(gameBoard, row, col, turn, validMove, gameOver, winCode);
                }
            }
        }

        // Insert code to draw the tiles using the sprites created earlier
        // You must determine the position of each cell on the grid, taking into account the width of
        // the border and then position the sprite there and draw it.
        // Draw the entire board, cell borders included,
        // reflecting any move that has just happened (check the gameBoard array)
        // Further, if the game is over and one player wins, you must create and draw a rectangle of
        // windowSize width and 10 pixels height to indicate the winning marks
        // The fill of this rectangle should be white

        // Insert your code here
        // draw tiles
        for (int row=0; row<boardSize; row++) {
            for (int col=0; col<boardSize; col++) {
                if (gameBoard[row][col] == -1) { // draw O tiles
                    O_sprite.setPosition(col * (tileSize + barWidth), row * (tileSize + barWidth));
                    window.draw(O_sprite);
                } else if (gameBoard[row][col] == 1) { // draw X tiles
                    X_sprite.setPosition(col * (tileSize + barWidth), row * (tileSize + barWidth));
                    window.draw(X_sprite);
                } else { // draw blank tiles
                    blank_sprite.setPosition(col * (tileSize + barWidth), row * (tileSize + barWidth));
                    window.draw(blank_sprite);
                }
            }
        }
        // draw horizontal and vertical borders
        for (int row=1; row<boardSize; row++) {
            // draw horizontal borders
            borderRectangle.setPosition(0, (row*tileSize + row*barWidth));
            borderRectangle.rotate(-90);
            window.draw(borderRectangle);
            borderRectangle.rotate(90);
            
            // draw vertical borders
            borderRectangle.setPosition((row*tileSize + (row-1)*barWidth), 0);
            window.draw(borderRectangle);
        }
        
        // draw winning marks if gameOver and it's not a draw
        if (gameOver && winCode != 0) {
            
            sf::RectangleShape winMarkRectangle(sf::Vector2f(windowSize, 10));
            
            // set colour 
            winMarkRectangle.setFillColor(sf::Color::White);
            // set horizontal winning mark to be in the center of the winning row
            if ((winCode >= 1) && (winCode <= 3)) {
                winMarkRectangle.setPosition(0, ((tileSize / 2) + (barWidth / 2) + ((winCode - 1)*(tileSize + barWidth))));
            }
            
            // set vertical winning mark to be in the center of the winning column
            else if ((winCode >= 4) && (winCode <= 6)) {
                winMarkRectangle.setPosition(((tileSize / 2) + (barWidth / 2) + ((winCode - 4)*(tileSize + barWidth))), 0);
                winMarkRectangle.rotate(90);
            }
            
            // set diagonal winning mark
            else if (winCode == 7) { // Northwest to Southeast
                winMarkRectangle.setPosition((tileSize / 2), (tileSize / 2));
                winMarkRectangle.rotate(45);
            }
            else if (winCode == 8) { // Northeast to Southwest
                winMarkRectangle.setPosition(((boardSize-0.5) * tileSize), (tileSize / 2));
                winMarkRectangle.rotate(135);
            }
            
            // draw winning mark to screen
            window.draw(winMarkRectangle);
            
        }

        // Display to the window
        window.display();
    }

    return EXIT_SUCCESS;
}

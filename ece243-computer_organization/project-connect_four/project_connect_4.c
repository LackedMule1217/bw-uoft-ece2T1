/**
 * Program that draws a few moving rectangles connected by lines
 */

#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "address_map_arm.h"

// Define Project Constants
#define CANVAS_XDIM 320
#define CANVAS_YDIM 240
#define TXT_CANVAS_XDIM 80
#define TXT_CANVAS_YDIM 60
#define CHIP_ROW_NUM 7
#define CHIP_COL_NUM 11
#define MATCH_NUM 4
#define BACKGROUND_COLOUR 0x0000
#define BOARD_COLOUR 0x02DF         // aqua blue
#define BOARD_HOLE_COLOUR 0x0000    // black
#define CHIP1_COLOUR 0xF800         // red
#define CHIP2_COLOUR 0xF780         // yellow
#define CHIP1_SHADOW_COLOUR 0xA800  // red shadow
#define CHIP2_SHADOW_COLOUR 0xA500  // yellow shadow
#define BLACK 0x0000
#define BLUE 0x001F
#define RED 0xF800
#define ORANGE 0xFC00
#define YELLOW 0xFFE0
#define GREEN 0x07E0
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define WHITE 0xFFFF



// Function Prototypes
// A. VGA Display
void update_canvas(int x, int y, short int colour);
void update_canvas_camf(int x, int y, short int colour, int camf_colour);
void update_txt_canvas(int x, int y, const char* str_ptr);
void clear_txt_canvas();
void draw_canvas();
void draw_txt_canvas();
void plot_pixel(int x, int y, short int colour);
void plot_char(int x, int y, char* text_ptr);
void wait_for_vsync();
// B. Fill Objects
void fill_canvas(int colour);
void fill_midpoint_circle(int x_center,
                          int y_center,
                          int radius,
                          int fill_colour,
                          int camf_colour);     // -1=none
// C. Draw Objects
void draw_background(bool is_on_boot);
void draw_line(int x0,
               int y0,
               int x1,
               int y1,
               int line_width,
               int colour,
               int camf_colour);                // -1=none
void draw_rec(int x0,
              int y0,
              int x1,
              int y1,
              int border_colour,
              int border_width,
              int fill_colour);                 // -1=none
void draw_midpoint_circle(int x_center,
                          int y_center,
                          int radius,
                          int border_colour,
                          int border_width,
                          int fill_colour);     // -1=none
// D. Game Logic
void wait_player_move();                        // updates 'is_reset_game' and 'is_forfeit_game' vars
void preview_place_chip(int col, bool is_player1);
void erase_preview_place_chip();
bool place_chip(int col, bool is_player1);
int check_game_over();                          // returns 0: continue game | 1: game over
                                                //  -> sets winning line position
void handle_game_over();
void draw_winning_line();
void reset_board();                             // resets board for another play
void reset_game();                              // resets entire game including score
// E. Control
int wait_for_keyb();                            // returns 0: enter | 1: left | 2: right | 3: e | 4: esc
int wait_for_correct_key(const int* expected_keys);  // returns index to 'PS2_KEY_CODES'
void wait_for_correct_one_key(const int expected_key);	// returns index to 'PS2_KEY_CODES'
void reset_key_bytes();
int mov_preview_chip_col(int current_value, int increment_val);

// Constant Variables
const int BOARD_REC_LOC[2][2] = {{15, 50}, {303, 239}};
const int BOARD_HOLE_LOC[CHIP_ROW_NUM][CHIP_COL_NUM][2] =
        {{{ 29,  63}, { 55,  63}, { 81,  63}, {107,  63}, {133,  63}, {159,  63}, {185,  63}, {211,  63}, {237,  63}, {263,  63}, {289,  63}},
         {{ 29,  89}, { 55,  89}, { 81,  89}, {107,  89}, {133,  89}, {159,  89}, {185,  89}, {211,  89}, {237,  89}, {263,  89}, {289,  89}},
         {{ 29, 115}, { 55, 115}, { 81, 115}, {107, 115}, {133, 115}, {159, 115}, {185, 115}, {211, 115}, {237, 115}, {263, 115}, {289, 115}},
         {{ 29, 141}, { 55, 141}, { 81, 141}, {107, 141}, {133, 141}, {159, 141}, {185, 141}, {211, 141}, {237, 141}, {263, 141}, {289, 141}},
         {{ 29, 167}, { 55, 167}, { 81, 167}, {107, 167}, {133, 167}, {159, 167}, {185, 167}, {211, 167}, {237, 167}, {263, 167}, {289, 167}},
         {{ 29, 193}, { 55, 193}, { 81, 193}, {107, 193}, {133, 193}, {159, 193}, {185, 193}, {211, 193}, {237, 193}, {263, 193}, {289, 193}},
         {{ 29, 219}, { 55, 219}, { 81, 219}, {107, 219}, {133, 219}, {159, 219}, {185, 219}, {211, 219}, {237, 219}, {263, 219}, {289, 219}}};
const int BOARD_HOLE_RADIUS = 11;
const int CHIP_START_LOC[CHIP_COL_NUM][2] =
        {{ 29,  35}, { 55,  35}, { 81,  35}, {107,  35}, {133,  35}, {159,  35}, {185,  35}, {211,  35}, {237,  35}, {263,  35}, {289,  35}};
const int CHIP_RADIUS = 12;
const int CHIP_DROP_SPEED = 4;
const int INI_CHIP_COL = 5;
const int TITLE_LINE_LOC[2][2] = {{0, 9}, {319, 9}};
const int TITLE_LINE_COLOUR = WHITE;
const int WIN_LINE_COLOUR = GREEN;
const int WIN_LINE_WIDTH = 5;
const int INFO_TXT_COLOUR = WHITE;
const int PLAYER_TXT_COLOUR = ORANGE;
const int SCORE_COLOUR = RED;
const char TITLE_TXT[21] = "    CONNECT FOUR    \0";
const char INFO_TXT[5][21] = {" P:     P1:   P2:   \0",        // custom: [3]=turn | [11-12]=p1 score | [17-18]=p2 score
                              "   Player 1 Wins!   \0",
                              "   Player 2 Wins!   \0",
                              "    It is a Tie!    \0",
                              "    Press  Enter    \0"};
const char SCORE[11] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '\0'};
const int PS2_KEY_CODES[8] = {0x5AF05A,                       // 0 = enter
                              0x29F029,                       // 1 = space bar
                              0x72F072,                       // 2 = down arrow
                              0x6BF06B,                       // 3 = left arrow
                              0x74F074,                       // 4 = right arrow
                              0x24F024,                       // 5 = e
                              0x76F076,                       // 6 = esc
                              0x000000};                      // null terminated
//const char PS2_KEY_CODES[5][3] = {{0xF0, 0x5A, 0x5A},        // enter
//                                  {0x6B, 0xE0, 0x6B},        // left arrow
//                                  {0x74, 0xE0, 0x74},        // right arrow
//                                  {0xF0, 0x24, 0x24},        // e
//                                  {0xF0, 0x76, 0x76}};       // esc


// Global Variables
volatile int* pixel_ctrl_ptr = (int*)0xFF203020;
volatile int* char_buffer_ptr = (int*)0xC9000000;
volatile int pixel_buffer_start;
volatile int * PS2_ptr = (int *)PS2_BASE;
int canvas[CANVAS_YDIM][CANVAS_XDIM];
int canvas_backup[CANVAS_YDIM][CANVAS_XDIM];
char txt_canvas[TXT_CANVAS_YDIM][TXT_CANVAS_XDIM];
int win_line_loc[2][2];
int place_chip_loc[2];
unsigned game_state = 0;    // 0: in game | 1: player 1 won | 2: player 2 won | 3: tie
unsigned win_type = 0;      // 0: no win | 1: horizontal | 2: vertical | 3: up diagonal | 4: down diagonal | 5: tie
int player1_score = 0;
int player2_score = 0;
char game_chip_matrix[CHIP_ROW_NUM][CHIP_COL_NUM];
bool is_player1_turn = false;
bool is_reset_game = false;
bool is_forfeit_game = false;
int key_code_prev;
char byte1 = 0, byte2 = 0, byte3 = 0;



int main(void)
{
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000;                                 // first store the address in the back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    fill_canvas(BACKGROUND_COLOUR);                                     // clear buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1);                         // we draw on the back buffer
    fill_canvas(BACKGROUND_COLOUR);                                     // clear back buffer
    /* clear txt buffer */
    clear_txt_canvas();
    draw_txt_canvas();
    // PS/2 mouse needs to be reset (must be already plugged in)
    *(PS2_ptr) = 0xFF; // reset
    while (true) {
        // 1) Draw initial game board and then wait for any key
        is_player1_turn = true;
        draw_background(true);
        draw_canvas();
        wait_for_correct_one_key(PS2_KEY_CODES[0]);                      // wait for enter
        draw_background(false);
        draw_canvas();
        // 2) Run game loop
        while (true) {
            wait_player_move();
            if (is_reset_game)  break;
            draw_background(false);
            draw_canvas();
            check_game_over();
            handle_game_over();
            is_player1_turn = !is_player1_turn;
            draw_background(false);
            draw_canvas();
        }
        // 3) Handle game reset
        reset_game();
        erase_preview_place_chip();
        draw_background(false);
        draw_canvas();
        clear_txt_canvas();
        draw_txt_canvas();
    }
}



// A. VGA Display
void update_canvas(int x, int y, short int colour) {
    canvas[y][x] = colour;
}

void update_canvas_camf(int x, int y, short int colour, int camf_colour) {
    if (camf_colour == -1)                   canvas[y][x] = colour;
    else if (canvas[y][x] != camf_colour)    canvas[y][x] = colour;
}

void update_txt_canvas(int x, int y, const char* str_ptr) {
    int i = 0;
    while (*str_ptr != '\0') {
        txt_canvas[y][x + i] = *str_ptr;
        i++;
        str_ptr++;
    }
}

void clear_txt_canvas() {
    int x = 0;
    int y = 0;
    for (x = 0; x < TXT_CANVAS_XDIM; x++)
        for (y = 0; y < TXT_CANVAS_YDIM; y++)
            txt_canvas[y][x] = 0;
}

void draw_canvas() {
    int x = 0;
    int y = 0;
    for (x = 0; x < CANVAS_XDIM; x++)
        for (y = 0; y < CANVAS_YDIM; y++)
            plot_pixel(x, y, canvas[y][x]);
    wait_for_vsync();
    pixel_buffer_start = *(pixel_ctrl_ptr + 1);         // new back buffer
}

void draw_txt_canvas() {
    int x = 0;
    int y = 0;
    for (x = 0; x < TXT_CANVAS_XDIM; x++)
        for (y = 0; y < TXT_CANVAS_YDIM; y++)
            plot_char(x, y, &txt_canvas[y][x]);
}

void plot_pixel(int x, int y, short int colour) {
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = colour;
}

void plot_char(int x, int y, char* text_ptr) {
    // Assume that the text string fits on one line
    int offset = (y << 7) + x;
    while (*text_ptr != '\0') {
        *(char_buffer_ptr + offset) = *(text_ptr);      // write to character buffer
        text_ptr++;
        offset++;
    }
}

void wait_for_vsync() {
    volatile int* pixel_status_reg_ptr = (int*)0xFF203020;
    int status;
    *pixel_status_reg_ptr = 1;              // start the synchronization process
    status = *(pixel_status_reg_ptr + 3);   // get status register
    while ((status & 0x01) != 0)            status = *(pixel_status_reg_ptr + 3);
}



// B. Fill Objects
void fill_canvas(int colour) {
    int x = 0;
    int y = 0;
    for (x = 0; x < 320; x++)
        for (y = 0; y < 240; y++)
            update_canvas(x, y, colour);
}

void fill_midpoint_circle(int x_center,
                          int y_center,
                          int radius,
                          int fill_colour,
                          int camf_colour) {
    int x = radius;
    int y = 0;
    int err = 0;
    // Fill circle
    while (x >= y) {
        draw_line(x_center + x, y_center + y, x_center + x, y_center - y, 1, fill_colour, camf_colour);
        draw_line(x_center - x, y_center + y, x_center - x, y_center - y, 1, fill_colour, camf_colour);
        draw_line(x_center + y, y_center + x, x_center + y, y_center - x, 1, fill_colour, camf_colour);
        draw_line(x_center - y, y_center + x, x_center - y, y_center - x, 1, fill_colour, camf_colour);
        if (err <= 0) {
            y += 1;
            err += 2 * y + 1;
        }
        if (err > 0) {
            x -= 1;
            err -= 2 * x + 1;
        }
    }
}



// C. Draw Objects
void draw_background(bool is_on_boot) {
    // 1) Draw text
    clear_txt_canvas();
    //    1.1) Draw title
    char title_txt[21];
    strncpy(title_txt, TITLE_TXT, 21);
    update_txt_canvas(0, 0, title_txt);
    //    1.2) Draw info and score
    char info_txt[21];
    if (is_on_boot) strncpy(info_txt, INFO_TXT[4], 21);
    else {
        strncpy(info_txt, INFO_TXT[0], 21);
        //         1.2.1) turn
        if (is_player1_turn)
            info_txt[3] = '1';
        else
            info_txt[3] = '2';
        //         1.2.2) score
        info_txt[11] = SCORE[player1_score / 10];
        info_txt[12] = SCORE[player1_score % 10];
        info_txt[17] = SCORE[player2_score / 10];
        info_txt[18] = SCORE[player2_score % 10];
    }
    update_txt_canvas(0, 1, info_txt);
    draw_txt_canvas();
    // 2) Draw title line
    draw_line(TITLE_LINE_LOC[0][0],
              TITLE_LINE_LOC[0][1],
              TITLE_LINE_LOC[1][0],
              TITLE_LINE_LOC[1][1],
              1,
              TITLE_LINE_COLOUR,
              -1);
    // 3) Draw board rectangle
    draw_rec(BOARD_REC_LOC[0][0],
             BOARD_REC_LOC[0][1],
             BOARD_REC_LOC[1][0],
             BOARD_REC_LOC[1][1],
             BOARD_COLOUR,
             1,
             BOARD_COLOUR);
    // 4) Draw chips / holes
    int x = 0;
    int y = 0;
    for (x = 0; x < CHIP_COL_NUM; x++) {
        for (y = 0; y < CHIP_ROW_NUM; y++) {
            fill_midpoint_circle(BOARD_HOLE_LOC[y][x][0],
                                 BOARD_HOLE_LOC[y][x][1],
                                 BOARD_HOLE_RADIUS,
                                 BOARD_HOLE_COLOUR,
                                 -1);
            switch (game_chip_matrix[y][x]) {
                case 1 :                        // player 1 chip
                    fill_midpoint_circle(BOARD_HOLE_LOC[y][x][0],
                                         BOARD_HOLE_LOC[y][x][1],
                                         CHIP_RADIUS,
                                         CHIP1_COLOUR,
                                         BOARD_COLOUR);
                    break;
                case 2 :                        // player 2 chip

                    fill_midpoint_circle(BOARD_HOLE_LOC[y][x][0],
                                         BOARD_HOLE_LOC[y][x][1],
                                         CHIP_RADIUS,
                                         CHIP2_COLOUR,
                                         BOARD_COLOUR);
                    break;
            }
        }
    }
}

void draw_line(int x0, int y0, int x1, int y1, int line_width, int colour, int camf_colour) {
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);
    int temp = 0;
    int i = 0;
    // if slope is greater than 1, set pivot to y instead of x
    if (is_steep) {
        // swap x0, y0
        temp = x0;
        x0 = y0;
        y0 = temp;
        // swap x1, y1
        temp = x1;
        x1 = y1;
        y1 = temp;
    }
    // start at the lowest pivot position with x0
    if (x0 > x1) {
        // swap x0, x1
        temp = x0;
        x0 = x1;
        x1 = temp;
        // swap y0, y1
        temp = y0;
        y0 = y1;
        y1 = temp;
    }
    // declare variables
    int dx = x1 - x0;
    int dy = abs(y1 - y0);
    int dx2 = 2 * dx;
    int dy2 = 2 * dy;
    int error = dy2 - dx;
    int y = y0;
    // determine step value
    int step = 1;
    if (y1 - y0 < 0)    step = -1;
    // plot initial point
    if (is_steep) {
        for (i = 0; i < line_width; i++)
            update_canvas_camf(y0+i, x0, colour, camf_colour);
    }
    else {
        for (i = 0; i < line_width; i++)
            update_canvas_camf(x0, y0+i, colour, camf_colour);
    }
    // plot subsequent points
    int x = 0;
    for (x = x0 + 1; x <= x1; x++) {
        if (error < 0) {
            if (is_steep) {
                for (i = 0; i < line_width; i++)
                    update_canvas_camf(y+i, x, colour, camf_colour);
            }
            else {
                for (i = 0; i < line_width; i++)
                    update_canvas_camf(x, y+i, colour, camf_colour);
            }
            error += dy2;
            continue;
        }
        else {
            y += step;
            if (is_steep) {
                for (i = 0; i < line_width; i++)
                    update_canvas_camf(y+i, x, colour, camf_colour);
            }
            else {
                for (i = 0; i < line_width; i++)
                    update_canvas_camf(x, y+i, colour, camf_colour);
            }
            error += dy2 - dx2;
        }
    }
}

void draw_rec(int x0,
              int y0,
              int x1,
              int y1,
              int border_colour,
              int border_width,
              int fill_colour) {
    int temp = 0;
    int i = 0;
    // 1) Draw rectangle border
    //    1.1) Horizontal lines
    //         swap lowest y point to y0
    if (y1 < y0) {
        temp = x0;
        x0 = x1;
        x1 = temp;
        temp = y0;
        y0 = y1;
        y1 = temp;
    }
    //         draw horizontal lines with width
    for (i = 0; i < border_width; i++) {
        draw_line(x0, y0 + i, x1, y0 + i, 1, border_colour, -1);
        draw_line(x0, y1 - i, x1, y1 - i, 1, border_colour, -1);
    }
    //    1.1) Vertical lines
    //         swap lowest x point to x0
    if (x1 < x0) {
        temp = x0;
        x0 = x1;
        x1 = temp;
        temp = y0;
        y0 = y1;
        y1 = temp;
    }
    //         draw lines with width
    for (i = 0; i < border_width; i++) {
        draw_line(x0 + i, y0, x0 + i, y1, 1, border_colour, -1);
        draw_line(x1 - i, y0, x1 - i, y1, 1, border_colour, -1);
    }
    // 2) Fill rectangle if requested
    if (fill_colour == -1)  return;
    for (i = x0 + border_width; i <= x1 - border_width; i++) {
        if (y0 < y1)    draw_line(i, y0 + border_width, i, y1 - border_width, 1, fill_colour, -1);
        else            draw_line(i, y0 - border_width, i, y1 + border_width, 1, fill_colour, -1);
    }
}

void draw_midpoint_circle(int x_center,
                                 int y_center,
                                 int radius,
                                 int border_colour,
                                 int border_width,
                                 int fill_colour) {    // -1=none
    int x = 0;
    int y = 0;
    int err = 0;
    int border_width_cnt = 0;
    // Draw circle with border
    for (border_width_cnt = 0; border_width_cnt != border_width; border_width_cnt++) {
        x = radius - border_width_cnt;
        y = 0;
        err = 0;
        while (x >= y) {
            update_canvas(x_center + x, y_center + y, border_colour);
            update_canvas(x_center + y, y_center + x, border_colour);
            update_canvas(x_center - y, y_center + x, border_colour);
            update_canvas(x_center - x, y_center + y, border_colour);
            update_canvas(x_center - x, y_center - y, border_colour);
            update_canvas(x_center - y, y_center - x, border_colour);
            update_canvas(x_center + y, y_center - x, border_colour);
            update_canvas(x_center + x, y_center - y, border_colour);
            if (err <= 0) {
                y += 1;
                err += 2 * y + 1;
            }
            if (err > 0) {
                x -= 1;
                err -= 2 * x + 1;
            }
        }
    }
    // Draw circle filling if specified (!= -1)
    if (fill_colour == -1)  return;
    for (border_width_cnt = border_width; border_width_cnt <= radius; border_width_cnt++) {
        x = radius - border_width_cnt;
        y = 0;
        err = 0;
        while (x >= y) {
            update_canvas(x_center + x, y_center + y, fill_colour);
            update_canvas(x_center + y, y_center + x, fill_colour);
            update_canvas(x_center - y, y_center + x, fill_colour);
            update_canvas(x_center - x, y_center + y, fill_colour);
            update_canvas(x_center - x, y_center - y, fill_colour);
            update_canvas(x_center - y, y_center - x, fill_colour);
            update_canvas(x_center + y, y_center - x, fill_colour);
            update_canvas(x_center + x, y_center - y, fill_colour);
            if (err <= 0) {
                y += 1;
                err += 2 * y + 1;
            }
            if (err > 0) {
                x -= 1;
                err -= 2 * x + 1;
            }
        }
    }
}



// D. Game Logic
void wait_player_move() {
    // 1) Check for key input if match a list of accepted inputs
    int key = 0;
    int i = 0;
    int chip_col = INI_CHIP_COL;
    while (true) {
        chip_col = mov_preview_chip_col(chip_col, 0);
		erase_preview_place_chip();
        preview_place_chip(chip_col, is_player1_turn);
        draw_canvas();
        key = wait_for_correct_key(PS2_KEY_CODES);
        switch (key) {
            case 0 :                                    // enter: drop chip but first checks if move is valid
            case 1 :                                    // space bar: drop chip but first checks if move is valid
            case 2 :                                    // down arrow: drop chip but first checks if move is valid
                if (game_chip_matrix[0][chip_col] != 0)  break;
                erase_preview_place_chip();
                place_chip(chip_col, is_player1_turn);
                return;
            case 3 :                                    // left arrow: move chip to the next available slot to left
				chip_col = mov_preview_chip_col(chip_col, -1);
                break;
            case 4 :                                    // right arrow: move chip to the next available slot to right
				chip_col = mov_preview_chip_col(chip_col, 1);
                break;
            case 5 :                                    // e: forfeit game
                is_forfeit_game = true;
                return;
            case 6 :                                    // esc: reset game
                is_reset_game = true;
                return;
        }
    }
}

void preview_place_chip(int col, bool is_player1) {
    // Don't draw preview if board column is full
    if (game_chip_matrix[0][col] != 0)
        return;
    if (is_player1)
        fill_midpoint_circle(CHIP_START_LOC[col][0],
                             CHIP_START_LOC[col][1],
                             CHIP_RADIUS,
                             CHIP1_SHADOW_COLOUR,
                             -1);
    else
        fill_midpoint_circle(CHIP_START_LOC[col][0],
                             CHIP_START_LOC[col][1],
                             CHIP_RADIUS,
                             CHIP2_SHADOW_COLOUR,
                             -1);
}

void erase_preview_place_chip() {
    int col = 0;
    for (col = 0; col < CHIP_COL_NUM; col++)
        fill_midpoint_circle(CHIP_START_LOC[col][0],
                             CHIP_START_LOC[col][1],
                             CHIP_RADIUS,
                             BACKGROUND_COLOUR,
                             -1);
}

bool place_chip(int col, bool is_player1) {
    // 1) Determine colour
    int player_val = 0;
    int colour = 0;
    double chip_speed_incr = 0;
    if (is_player1) {
        player_val = 1;
        colour = CHIP1_COLOUR;
    }
    else {
        player_val = 2;
        colour = CHIP2_COLOUR;
    }
    // 2) Set initial chip position
    memcpy(place_chip_loc, CHIP_START_LOC[col], sizeof(place_chip_loc));
    // 3) Determine end position
    int empty_row = 0;
    for (empty_row = CHIP_ROW_NUM - 1; empty_row >= -1; empty_row--) {
        if (empty_row == -1)    return false;       // if column has been filled, return false
        if (game_chip_matrix[empty_row][col] == 0) {
            break;
        }
    }
    // 4) Draw and update chip animation location in while loop
    memcpy(canvas_backup, canvas, sizeof(canvas_backup));
    while (place_chip_loc[1] < BOARD_HOLE_LOC[empty_row][col][1]) {
        memcpy(canvas, canvas_backup, sizeof(canvas));
        fill_midpoint_circle(place_chip_loc[0],
                             place_chip_loc[1],
                             CHIP_RADIUS,
                             colour,
                             BOARD_COLOUR);
        place_chip_loc[1] += (int)chip_speed_incr;
        chip_speed_incr += 2;
        draw_canvas();
    }
    memcpy(canvas, canvas_backup, sizeof(canvas));
    fill_midpoint_circle(place_chip_loc[0],
                         BOARD_HOLE_LOC[empty_row][col][1],
                         CHIP_RADIUS,
                         colour,
                         BOARD_COLOUR);
    draw_canvas();
    // 5) Update game chip matrix
    memcpy(canvas_backup, canvas, sizeof(canvas_backup));
    game_chip_matrix[empty_row][col] = player_val;
    return true;
}

int check_game_over() {
    int x = 0;
    int y = 0;
    // 0) Check if game has been forfeited
    if (is_forfeit_game) {
        if (is_player1_turn)            game_state = 2;
        else                            game_state = 1;
        win_type = 0;
        return 1;
    }
    // 1) Check horizontal match
    for (x = 0; x < CHIP_COL_NUM - MATCH_NUM + 1; x++)
        for (y = 0; y < CHIP_ROW_NUM; y++)
            if (game_chip_matrix[y][x] != 0 &&
                game_chip_matrix[y][x] == game_chip_matrix[y][x+1] &&
                game_chip_matrix[y][x] == game_chip_matrix[y][x+2] &&
                game_chip_matrix[y][x] == game_chip_matrix[y][x+3]) {
                int win_line_loc_L[2][2] = {{y, x}, {y, x+3}};
                memcpy(win_line_loc, win_line_loc_L, sizeof(win_line_loc));
                win_type = 1;
                if (is_player1_turn)    game_state = 1;
                else                    game_state = 2;
                return 1;
            }
    // 2) Check vertical match
    for (x = 0; x < CHIP_COL_NUM; x++)
        for (y = 0; y < CHIP_ROW_NUM - MATCH_NUM + 1; y++)
            if (game_chip_matrix[y][x] != 0 &&
                game_chip_matrix[y][x] == game_chip_matrix[y+1][x] &&
                game_chip_matrix[y][x] == game_chip_matrix[y+2][x] &&
                game_chip_matrix[y][x] == game_chip_matrix[y+3][x]) {
                int win_line_loc_L[2][2] = {{y, x}, {y+3, x}};
                memcpy(win_line_loc, win_line_loc_L, sizeof(win_line_loc));
                win_type = 2;
                if (is_player1_turn)    game_state = 1;
                else                    game_state = 2;
                return 1;
            }
    // 3) Check up diagonal match
    for (x = 0; x < CHIP_COL_NUM - MATCH_NUM + 1; x++)
        for (y = MATCH_NUM - 1; y < CHIP_ROW_NUM; y++)
            if (game_chip_matrix[y][x] != 0 &&
                game_chip_matrix[y][x] == game_chip_matrix[y-1][x+1] &&
                game_chip_matrix[y][x] == game_chip_matrix[y-2][x+2] &&
                game_chip_matrix[y][x] == game_chip_matrix[y-3][x+3]) {
                int win_line_loc_L[2][2] = {{y, x}, {y-3, x+3}};
                memcpy(win_line_loc, win_line_loc_L, sizeof(win_line_loc));
                win_type = 3;
                if (is_player1_turn)    game_state = 1;
                else                    game_state = 2;
                return 1;
            }
    // 4) Check down diagonal match
    for (x = 0; x < CHIP_COL_NUM - MATCH_NUM + 1; x++)
        for (y = 0; y < CHIP_ROW_NUM - MATCH_NUM + 1; y++)
            if (game_chip_matrix[y][x] != 0 &&
                game_chip_matrix[y][x] == game_chip_matrix[y+1][x+1] &&
                game_chip_matrix[y][x] == game_chip_matrix[y+2][x+2] &&
                game_chip_matrix[y][x] == game_chip_matrix[y+3][x+3]) {
                int win_line_loc_L[2][2] = {{y, x}, {y+3, x+3}};
                memcpy(win_line_loc, win_line_loc_L, sizeof(win_line_loc));
                win_type = 4;
                if (is_player1_turn)    game_state = 1;
                else                    game_state = 2;
                return 1;
            }
    // 5) No one won; game continues
    for (x = 0; x < CHIP_COL_NUM; x++)
        for (y = 0; y < CHIP_ROW_NUM; y++)
            if (game_chip_matrix[y][x] == 0) {
                win_type = 0;
                game_state = 0;
                return 0;
            }
    // 6) Tie: all board holes have been filled
    win_type = 5;
    game_state = 3;
    return 1;
}

void handle_game_over() {
    // Handle game states and show winner
    switch (game_state) {
        case 1 :
            player1_score++;
			draw_winning_line();
            update_txt_canvas(0, 1, INFO_TXT[game_state]);
            draw_txt_canvas();
            reset_board();
            wait_for_correct_one_key(PS2_KEY_CODES[0]);                      // wait for enter
			draw_background(false);
            break;
        case 2 :
            player2_score++;
            draw_winning_line();
            update_txt_canvas(0, 1, INFO_TXT[game_state]);
            draw_txt_canvas();
            reset_board();
            wait_for_correct_one_key(PS2_KEY_CODES[0]);                      // wait for enter
			draw_background(false);
            break;
        case 3 :
            update_txt_canvas(0, 1, INFO_TXT[game_state]);
            draw_txt_canvas();
            reset_board();
            wait_for_correct_one_key(PS2_KEY_CODES[0]);                      // wait for enter
			draw_background(false);
            break;
    }
}

void draw_winning_line() {
    int i = 0;
    switch (win_type) {
        case 1 :        // horizontal
            draw_line(BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][0],
                      BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][1] - 1,
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][0],
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][1] - 1,
                      3,
                      WIN_LINE_COLOUR,
                      -1);
            break;
        case 2 :        // vertical
            draw_line(BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][0] - 1,
                      BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][1],
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][0] - 1,
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][1],
                      3,
                      WIN_LINE_COLOUR,
                      -1);
            break;
        case 3 :        // up diagonal
            draw_line(BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][0] - 2,
                      BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][1],
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][0] - 2,
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][1],
                      5,
                      WIN_LINE_COLOUR,
                      -1);
            break;
        case 4 :        // down diagonal
            draw_line(BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][0] - 2,
                      BOARD_HOLE_LOC[win_line_loc[0][0]][win_line_loc[0][1]][1],
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][0] - 2,
                      BOARD_HOLE_LOC[win_line_loc[1][0]][win_line_loc[1][1]][1],
                      5,
                      WIN_LINE_COLOUR,
                      -1);
            break;
        default : return;
    }
	draw_canvas();
}

void reset_board() {
    // 1) Clear game chip matrix array
    int x = 0;
    int y = 0;
    for (x = 0; x < CHIP_COL_NUM; x++)
        for (y = 0; y < CHIP_ROW_NUM; y++)
            game_chip_matrix[y][x] = 0;
    // 2) Reset turn
    is_player1_turn = false;
    is_forfeit_game = false;
    // 3) If any player's score is greater than 99, reset score
    if (player1_score > 99 || player2_score > 99) {
        player1_score = 0;
        player2_score = 0;
    }
}

void reset_game() {
    // 1) Reset variables
    player1_score = 0;
    player2_score = 0;
    is_reset_game = false;
    // 2) Reset board
    reset_board();
}



// E. Control
int wait_for_keyb() {
    // 1) Store keyboard codes
    int PS2_data, RVALID, current_key;
    while (true) {
        PS2_data = *(PS2_ptr);                          // read the Data register in the PS/2 port
        RVALID = PS2_data & 0x8000;                     // extract the RVALID field
        if (RVALID) {
            /* shift the next data byte into the display */
            byte1 = byte2;
            byte2 = byte3;
            byte3 = PS2_data & 0xFF;
        }
        // 1.1) Translate to a single code
        current_key = (byte3 << 16) | (byte2 << 8) | byte3;
		return current_key;
    }
}

int wait_for_correct_key(const int* expected_keys) {
    *(PS2_ptr) = 0xFF;                          // reset keyboard
    *(PS2_ptr) = 0xF4;                          // enable keyboard input
    while (true) {
		int i = 0;
        int key = wait_for_keyb();
        while (expected_keys[i] != 0x0) {
            if (key == expected_keys[i]) {
				reset_key_bytes();
                *(PS2_ptr) = 0xF5;              // disable keyboard input
                return i;
			}
			i++;
        }
    }
}

void wait_for_correct_one_key(const int expected_key) {
    *(PS2_ptr) = 0xFF;                          // reset keyboard
    *(PS2_ptr) = 0xF4;                          // enable keyboard input
	while (true) {
		if (expected_key == wait_for_keyb()) {
			reset_key_bytes();
            *(PS2_ptr) = 0xF5;                  // disable keyboard input
			return;
		}
    }
}

void reset_key_bytes() {
	byte1 = 0;
	byte2 = 0;
	byte3 = 0;
}

int mov_preview_chip_col(int current_col, int increment_val) {
    current_col += increment_val;
    if      (current_col < 0)                   current_col = CHIP_COL_NUM + current_col;
    else if (current_col >= CHIP_COL_NUM)       current_col %= CHIP_COL_NUM;
    while (game_chip_matrix[0][current_col] != 0) {
        if (increment_val >= 0)                 current_col += 1;
        else                                    current_col -= 1;
        if      (current_col < 0)               current_col = CHIP_COL_NUM + current_col;
        else if (current_col >= CHIP_COL_NUM)   current_col %= CHIP_COL_NUM;
    }
    return current_col;
}

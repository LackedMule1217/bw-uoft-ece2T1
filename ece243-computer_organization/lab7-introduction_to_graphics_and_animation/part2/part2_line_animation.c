/**
 * Program that draws a line that bounces edge to edge of the screen
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// function prototypes
void plot_pixel(int x, int y, short int line_color);
void clear_screen();
void wait_for_vsync();
void draw_line(int x0, int y0, int x1, int y1, int colour);

volatile int pixel_buffer_start; // global variable
volatile int* pixel_ctrl_ptr;

int main(void) {
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_ctrl_ptr = (int*)0xFF203020;
    pixel_buffer_start = *pixel_ctrl_ptr;
    // Initialize variables
    srand(time(NULL));
    int x0 = rand() % 319;
    int x1 = rand() % 319;
    int y0 = rand() % 239;
    int y1 = rand() % 239;
    int x0_prev = -1;
    int x1_prev = -1;
    int y0_prev = -1;
    int y1_prev = -1;
    int colour = rand() % 55535 + 10000;
    int x_min = 1;
    int x_max = 319;
    int y_min = 1;
    int y_max = 239;
    int mov_inc_x = rand() % 2;
    if (mov_inc_x == 0)   mov_inc_x = -1;
    int mov_inc_y = rand() % 2;
    if (mov_inc_y == 0)   mov_inc_y = -1;
    // Clear screen
    clear_screen();
    // Loop to draw animation
    while (true) {
        // erase previous line
        if (x0_prev != -1) {
            draw_line(x0_prev, y0_prev, x1_prev, y1_prev, 0x0);
            wait_for_vsync();
        }
        x0_prev = x0;
        x1_prev = x1;
        y0_prev = y0;
        y1_prev = y1;
        // draw line
        draw_line(x0, y0, x1, y1, colour);
        // wait for V-sync
        wait_for_vsync();
        // update line position
        x0 += mov_inc_x;
        x1 += mov_inc_x;
        y0 += mov_inc_y;
        y1 += mov_inc_y;
        // if position is outside screen, reverse move increment value
        if (x0 > x_max || x0 < x_min || x1 > x_max || x1 < x_min) mov_inc_x = -1 * mov_inc_x;
        if (y0 > y_max || y0 < y_min || y1 > y_max || y1 < y_min) mov_inc_y = -1 * mov_inc_y;
    }
}

// code not shown for clear_screen() and draw_line() subroutines

void plot_pixel(int x, int y, short int line_color) {
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void clear_screen() {
	int x = 0;
	int y = 0;
    for (x = 0; x < 320; x++)
        for (y = 0; y < 240; y++)
            plot_pixel(x, y, 0x0);
}

void wait_for_vsync() {
    volatile int* pixel_status_reg_ptr = (int*)0xFF203020;
    int status;
    *pixel_status_reg_ptr = 1;              // start the synchronization process
    status = *(pixel_status_reg_ptr + 3);   // get status register
    while ((status & 0x01) != 0)        status = *(pixel_status_reg_ptr + 3);
}

void draw_line(int x0, int y0, int x1, int y1, int colour) {
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);
    int temp = 0;
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
    if (is_steep)   plot_pixel(y0, x0, colour);
    else            plot_pixel(x0, y0, colour);
    // plot subsequent points
    int x = 0;
    for (x = x0 + 1; x <= x1; x++) {
        if (error < 0) {
            if (is_steep)   plot_pixel(y, x, colour);
            else            plot_pixel(x, y, colour);
            error += dy2;
            continue;
        }
        else {
            y += step;
            if (is_steep)   plot_pixel(y, x, colour);
            else            plot_pixel(x, y, colour);
            error += dy2 - dx2;
        }
    }
}

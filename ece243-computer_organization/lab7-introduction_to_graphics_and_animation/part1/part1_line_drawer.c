/**
 * Program that draws lines of different colours onto the screen
 */

#include <stdbool.h>

// function prototypes
void plot_pixel(int x, int y, short int line_color);
void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, int colour);

volatile int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);      // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0);    // this line is green
    draw_line(0, 239, 319, 239, 0xF800);    // this line is red
    draw_line(230, 10, 100, 50, 0xF81F);    // this line is a pink color
    draw_line(50, 0, 50, 200, 0xFFFF);      // this vertical line is while
    draw_line(0, 100, 200, 100, 0xFFFF);    // this horizontal line is while
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

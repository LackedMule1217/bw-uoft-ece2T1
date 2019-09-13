/**
 * Program that draws a few moving rectangles connected by lines
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// function prototypes
void plot_pixel(int x, int y, short int line_color);
void clear_screen();
void wait_for_vsync();
void draw_line(int x0, int y0, int x1, int y1, int colour_L);
void draw_rec(int x, int y, int colour_L);

volatile int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
    int xy_rec_barrier_min = 2;
    int x_rec_barrier_max = 317;
    int y_rec_barrier_max = 237;
    int dim_x = 320;
    int dim_y = 240;
    int i = 0;
    int j = 0;
    int dir = 0;
    const int LINE_COLOUR = 0x001F;
    int rec_rand_colour = 0;
    srand(time(NULL));
    // initialize location and direction of rectangles(not shown)
    // a) location
    int rec_loc[8][2] = {{rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y},
                         {rand() % dim_x, rand() % dim_y}};
    int rec_prev_loc[8][2];
    for (i = 0; i < 8; i++)
        for (j = 0; j < 2; j++)
            rec_prev_loc[i][j] = rec_loc[i][j];
    // b) direction
    int rec_dir[8][2];
    for (i = 0; i < 8; i++) {
        for (j = 0; j < 2; j++) {
            dir = rand() % 2;
            if (dir == 0) dir = -1;
            rec_dir[i][j] = dir;
        }
    }
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen();                                             // clear buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen();                             // clear back buffer

    while (1) {
        /* Erase any boxes and lines that were drawn in the last iteration */
//        for (i = 0; i < 8; i++) {
//            if (i == 7) draw_line(rec_prev_loc[i][0], rec_prev_loc[i][1], rec_prev_loc[0][0], rec_prev_loc[0][1], 0xFFFF);
//            else        draw_line(rec_prev_loc[i][0], rec_prev_loc[i][1], rec_prev_loc[i+1][0], rec_prev_loc[i+1][1], 0xFFFF);
//            draw_rec(rec_prev_loc[i][0], rec_prev_loc[i][1], 0xFFFF);
//        }
        clear_screen();
        for (i = 0; i < 8; i++)
            for (j = 0; j < 2; j++)
                rec_prev_loc[i][j] = rec_loc[i][j];
        // code for drawing the boxes and lines (not shown)
        for (i = 0; i < 8; i++) {
            if (i == 7) draw_line(rec_loc[i][0], rec_loc[i][1], rec_loc[0][0], rec_loc[0][1], LINE_COLOUR);
            else        draw_line(rec_loc[i][0], rec_loc[i][1], rec_loc[i+1][0], rec_loc[i+1][1], LINE_COLOUR);
        }
        for (i = 0; i < 8; i++) {
            rec_rand_colour = rand() % 65535;
            draw_rec(rec_loc[i][0], rec_loc[i][1], rec_rand_colour);
        }
        // code for updating the locations of boxes (not shown)
        for (i = 0; i < 8; i++) {
            for (j = 0; j < 2; j++) {
                rec_loc[i][j] += rec_dir[i][j];
            }
            if      (rec_loc[i][0] >= x_rec_barrier_max)        rec_dir[i][0] = -1;
            else if (rec_loc[i][0] <= xy_rec_barrier_min)       rec_dir[i][0] = 1;
            if      (rec_loc[i][1] >= y_rec_barrier_max)        rec_dir[i][1] = -1;
            else if (rec_loc[i][1] <= xy_rec_barrier_min)       rec_dir[i][1] = 1;
        }
        // wait for next frame
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)
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
    while ((status & 0x01) != 0)            status = *(pixel_status_reg_ptr + 3);
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

void draw_rec(int x, int y, int colour_L) {
    int i = 0;
    int j = 0;
    for (i = 0; i < 5; i++)
        for (j = 0; j < 5; j++)
            plot_pixel(x - 2 + i, y - 2 + j, colour_L);
}
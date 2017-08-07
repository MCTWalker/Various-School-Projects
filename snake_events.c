//******************************************************************************
//	Lab 09b - snake_events.c  (03/27/2017)
//
//       Author:  Paul Roper, Brigham Young University
//  Description:  Event Service Routines
//    Revisions:  1.0		11/25/2012		RBX430-1
//                1.1		03/24/2016	add_head() & delete_tail loosely coupled
//							03/29/2016	lcd draw head moved to snakelib.c
//				  1.2		03/27/2017	delete_tail, lcd_point removed from snakelib.c
//   Disclaimer:  This code is the work of Paul Roper.  I certify this to be my
//                source code and not obtained from any student, past or current.
//
//  Built with Code Composer Studio Version: 5.2.0.00090
//******************************************************************************
//
#include "msp430.h"
#include <stdlib.h>
#include "RBX430-1.h"
#include "RBX430_lcd.h"
#include "snake.h"
#include "snakelib.h"

extern volatile uint16 sys_event;			// pending events

volatile enum MODE game_mode;				// 0=idle, 1=play, 2=next
volatile uint16 score;						// current score
volatile uint16 seconds;					// time
volatile uint16 move_cnt;					// snake speed

volatile uint8 level;						// current level (1-4)
uint8 direction;							// current move direction
uint8 head;									// head index into snake array
uint8 tail;									// tail index into snake array
SNAKE snake[MAX_SNAKE];						// snake segments

extern const uint16 snake_text_image[];		// snake text image
extern const uint16 snake1_image[];			// snake image


//------------------------------------------------------------------------------
//-- move snake event ----------------------------------------------------------
//
void MOVE_SNAKE_event(void)
{
	if (level > 0)
	{
		add_head(&head, &direction);		// add head
		lcd_point(COL(snake[head].point.x), ROW(snake[head].point.y), PENTX);

		//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		//	Add code here to check for collisions...
		if (snake[head].xy == ((0 << 8) + 12)) { beep(); blink(); }
		lcd_square(COL(12), ROW(0), 2, 1 + FILL);
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		// delete tail on lcd				// delete tail
		lcd_point(COL(snake[tail].point.x), ROW(snake[tail].point.y), PENTX_OFF);
		tail = (tail + 1) & (~MAX_SNAKE);
	}
	return;
} // end MOVE_SNAKE_event


//------------------------------------------------------------------------------
//-- new game event ------------------------------------------------------------
//
void NEW_GAME_event(void)
{
	int i;
	lcd_clear();							// clear lcd
	lcd_backlight(1);						// turn on backlight

	switch (game_mode)
	{
	case IDLE:
		//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		// ***demo only***
		lcd_wordImage(snake1_image, (159-60)/2, 60, 1);
		lcd_wordImage(snake_text_image, (159-111)/2, 20, 1);
		lcd_diamond(COL(16), ROW(20), 2, 1);
		lcd_star(COL(17), ROW(20), 2, 1);
		lcd_circle(COL(18), ROW(20), 2, 1);
		lcd_square(COL(19), ROW(20), 2, 1);
		lcd_triangle(COL(20), ROW(20), 2, 1);
		score = 10;
		move_cnt = WDT_MOVE2;				// level 2, speed 2
		level = 2;
		// ***demo only***
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	default:
		break;
	}
	head = 0;
	tail = 0;
	snake[head].point.x = 0;
	snake[head].point.y = 0;
	direction = RIGHT;

	// build snake
	for (i = score - 1; i > 0; --i)
	{
		add_head(&head, &direction);
		lcd_point(COL(snake[head].point.x), ROW(snake[head].point.y), PENTX);
	}
	sys_event = START_LEVEL;
	return;
} // end NEW_GAME_event


//------------------------------------------------------------------------------
//-- start level event -----------------------------------------------------------
//
void START_LEVEL_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to setup playing board for next level
	//	Draw snake, foods, reset timer, set level, move_cnt etc
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	game_mode = PLAY;						// start level
	seconds = 0;							// restart timer
	return;
} // end START_LEVEL_event


//------------------------------------------------------------------------------
//-- next level event -----------------------------------------------------------
//
void NEXT_LEVEL_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle NEXT_LEVEL event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
} // end NEXT_LEVEL_event


//------------------------------------------------------------------------------
//-- end game event -------------------------------------------------------------
//
void END_GAME_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle END_GAME event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
} // end END_GAME_event


//------------------------------------------------------------------------------
//-- switch #1 event -----------------------------------------------------------
//
void SWITCH_1_event(void)
{
	switch (game_mode)
	{
		case IDLE:
			sys_event |= NEW_GAME;
			break;

		case PLAY:
			switch (direction)
			{
				case UP:
				case DOWN:
					if ((level != 2) || (snake[head].point.x < X_MAX))
					{
						direction = RIGHT;
						sys_event |= MOVE_SNAKE;
					}

				case RIGHT:					// ignore if going right
				case LEFT:					// ignore if going left
					break;
			}
			break;

		case NEXT:
			sys_event |= NEW_GAME;
			break;
	}
	return;
} // end SWITCH_1_event

void move_left(){
	if ((snake[head].point.x > 0)) {
		direction = LEFT;
		sys_event |= MOVE_SNAKE;
	}
}

void move_down(){
	if ((snake[head].point.y > 0)) {
		direction = DOWN;
		sys_event |= MOVE_SNAKE;
	}
}

void move_up(){
	if ((snake[head].point.y < Y_MAX)) {
		direction = UP;
		sys_event |= MOVE_SNAKE;
	}
}
//------------------------------------------------------------------------------
//-- switch #2 event -----------------------------------------------------------
//
void SWITCH_2_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle SWITCH_2 event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	switch (direction)
	{
		case RIGHT:					// ignore if going right
		case LEFT:					// ignore if going left
			break;
		case UP:
		case DOWN:
			move_left();
	}
} // end SWITCH_2_event


//------------------------------------------------------------------------------
//-- switch #3 event -----------------------------------------------------------
//
void SWITCH_3_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle SWITCH_2 event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	switch (direction)
	{
		case RIGHT:
		case LEFT:
			move_down();
			break;
		case UP:
		case DOWN:
			break;
	}
} // end SWITCH_3_event


//------------------------------------------------------------------------------
//-- switch #4 event -----------------------------------------------------------
//
void SWITCH_4_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle SWITCH_2 event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	switch (direction)
	{
		case RIGHT:
		case LEFT:
			move_up();
			break;
		case UP:
		case DOWN:
			break;
	}
} // end SWITCH_4_event


//------------------------------------------------------------------------------
//-- update LCD event -----------------------------------------------------------
//
void LCD_UPDATE_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle LCD_UPDATE event
	lcd_cursor((score < 100) ? 75 : 66, 65);
	lcd_printf("\b\t%d", seconds);
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
} // end LCD_UPDATE_event//******************************************************************************
//	Lab 09b - snake_events.c  (03/27/2017)
//
//       Author:  Maura Walker, Brigham Young University
//  Description:  Event Service Routines
//    Revisions:  1.0		11/25/2012		RBX430-1
//                1.1		03/24/2016	add_head() & delete_tail loosely coupled
//							03/29/2016	lcd draw head moved to snakelib.c
//				  1.2		03/27/2017	delete_tail, lcd_point removed from snakelib.c
//   Disclaimer:  This code is the work of Maura Walker.  I certify this to be my
//                source code and not obtained from any student, past or current.
//
//  Built with Code Composer Studio Version: 5.2.0.00090
//******************************************************************************
//
#include "msp430.h"
#include <stdlib.h>
#include "RBX430-1.h"
#include "RBX430_lcd.h"
#include "snake.h"
#include "snakelib.h"

extern volatile uint16 sys_event;			// pending events

volatile enum MODE game_mode;				// 0=idle, 1=play, 2=next
volatile uint16 score;						// current score
volatile uint16 seconds;					// time
volatile uint16 move_cnt;					// snake speed

volatile uint8 level;						// current level (1-4)
uint8 direction;							// current move direction
uint8 head;									// head index into snake array
uint8 tail;									// tail index into snake array
SNAKE snake[MAX_SNAKE];						// snake segments

extern const uint16 snake_text_image[];		// snake text image
extern const uint16 snake1_image[];			// snake image


//------------------------------------------------------------------------------
//-- move snake event ----------------------------------------------------------
//
void MOVE_SNAKE_event(void)
{
	if (level > 0)
	{
		add_head(&head, &direction);		// add head
		lcd_point(COL(snake[head].point.x), ROW(snake[head].point.y), PENTX);

		//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		//	Add code here to check for collisions...
		if (snake[head].xy == ((0 << 8) + 12)) {
			beep(); blink();

		} else {
			// delete tail on lcd				// delete tail
			lcd_point(COL(snake[tail].point.x), ROW(snake[tail].point.y), PENTX_OFF);
			tail = (tail + 1) & (~MAX_SNAKE);
		}
		lcd_square(COL(12), ROW(0), 2, 1 + FILL);
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	}
	return;
} // end MOVE_SNAKE_event


//------------------------------------------------------------------------------
//-- new game event ------------------------------------------------------------
//
void NEW_GAME_event(void)
{
	int i;
	lcd_clear();							// clear lcd
	lcd_backlight(1);						// turn on backlight

	switch (game_mode)
	{
	case IDLE:
		score = 0;
		move_cnt = WDT_MOVE2;
		level = 0;
		lcd_rectangle(2, 4, 154, 149, 15);
		lcd_rectangle(0, 0, 159, 159, 15);
		lcd_cursor(5, 0);
		lcd_printf(" UP");
		lcd_cursor(40, 0);
		lcd_printf(" DOWN");
		lcd_cursor(90, 0);
		lcd_printf(" LEFT");
		lcd_cursor(125, 0);
		lcd_printf(" RIGHT");
		//lcd_wordImage(snake1_image, (159-60)/2, 60, 1);
		//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		// ***demo only***
//		lcd_wordImage(snake1_image, (159-60)/2, 60, 1);
//		lcd_wordImage(snake_text_image, (159-111)/2, 20, 1);
//		lcd_diamond(COL(16), ROW(20), 2, 1);
//		lcd_star(COL(17), ROW(20), 2, 1);
//		lcd_circle(COL(18), ROW(20), 2, 1);
//		lcd_square(COL(19), ROW(20), 2, 1);
//		lcd_triangle(COL(20), ROW(20), 2, 1);
//		score = 10;
//		move_cnt = WDT_MOVE2;				// level 2, speed 2
//		level = 2;
		// ***demo only***
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


	default:
		break;
	}
	head = 0;
	tail = 0;
	snake[head].point.x = 0;
	snake[head].point.y = 0;
	direction = RIGHT;

	// build snake
	for (i = score + 1; i > 0; --i)
	{
		add_head(&head, &direction);
		lcd_point(COL(snake[head].point.x), ROW(snake[head].point.y), PENTX);
	}
	sys_event = START_LEVEL;
	return;
} // end NEW_GAME_event


//------------------------------------------------------------------------------
//-- start level event -----------------------------------------------------------
//
void START_LEVEL_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to setup playing board for next level
	//	Draw snake, foods, reset timer, set level, move_cnt etc
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	game_mode = PLAY;						// start level
	level++;

	switch (level)
	{
		case 2:
		case 3:
		case 4:
	}
	seconds = 0;							// restart timer
	return;
} // end START_LEVEL_event


//------------------------------------------------------------------------------
//-- next level event -----------------------------------------------------------
//
void NEXT_LEVEL_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle NEXT_LEVEL event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
} // end NEXT_LEVEL_event


//------------------------------------------------------------------------------
//-- end game event -------------------------------------------------------------
//
void END_GAME_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle END_GAME event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
} // end END_GAME_event


//------------------------------------------------------------------------------
//-- switch #1 event -----------------------------------------------------------
//
void SWITCH_1_event(void)
{
	switch (game_mode)
	{
		case IDLE:
			sys_event |= NEW_GAME;
			break;

		case PLAY:
			switch (direction)
			{
				case UP:
				case DOWN:
					if ((level != 2) || (snake[head].point.x < X_MAX))
					{
						direction = RIGHT;
						sys_event |= MOVE_SNAKE;
					}

				case RIGHT:					// ignore if going right
				case LEFT:					// ignore if going left
					break;
			}
			break;

		case NEXT:
			sys_event |= NEW_GAME;
			break;
	}
	return;
} // end SWITCH_1_event

void move_left(){
	if ((snake[head].point.x > 0)) {
		direction = LEFT;
		sys_event |= MOVE_SNAKE;
	}
}

void move_down(){
	if ((snake[head].point.y > 0)) {
		direction = DOWN;
		sys_event |= MOVE_SNAKE;
	}
}

void move_up(){
	if ((snake[head].point.y < Y_MAX)) {
		direction = UP;
		sys_event |= MOVE_SNAKE;
	}
}
//------------------------------------------------------------------------------
//-- switch #2 event -----------------------------------------------------------
//
void SWITCH_2_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle SWITCH_2 event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	switch (direction)
	{
		case RIGHT:					// ignore if going right
		case LEFT:					// ignore if going left
			break;
		case UP:
		case DOWN:
			move_left();
	}
} // end SWITCH_2_event


//------------------------------------------------------------------------------
//-- switch #3 event -----------------------------------------------------------
//
void SWITCH_3_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle SWITCH_2 event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	switch (direction)
	{
		case RIGHT:
		case LEFT:
			move_down();
			break;
		case UP:
		case DOWN:
			break;
	}
} // end SWITCH_3_event


//------------------------------------------------------------------------------
//-- switch #4 event -----------------------------------------------------------
//
void SWITCH_4_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle SWITCH_2 event
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	switch (direction)
	{
		case RIGHT:
		case LEFT:
			move_up();
			break;
		case UP:
		case DOWN:
			break;
	}
} // end SWITCH_4_event


//------------------------------------------------------------------------------
//-- update LCD event -----------------------------------------------------------
//
void LCD_UPDATE_event(void)
{
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	//	Add code here to handle LCD_UPDATE event
	lcd_cursor(8, 150);
	lcd_printf("Score %d", score);
	lcd_cursor(60, 150);
	lcd_printf("Level %d", level);
	lcd_cursor(105, 150);
	lcd_printf("Time %d", seconds);
	lcd_cursor((score < 100) ? 75 : 66, 65);
	lcd_printf("\b\t%d", seconds);
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
} // end LCD_UPDATE_event


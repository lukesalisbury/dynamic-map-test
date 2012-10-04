#tryinclude <map_default>
#include <core>
#include <string>

new map[1024] = { '0', ... };
new items[1024] = { '\32', ... };
new generating = true;
new c = 0;

new seed = 99;

new _x = 16 , _y = 16;

starting_point(v)
{
	new value = random(seed) % 3;
	switch( value )
	{
		case 0:
			map[v] = '=';
		case 1:
			map[v] = '|';
		default:
			map[v] = '+';
	}

}


#define POINT(%1,%2) (%1 + (%2*32))
new intersection_likely = 0;


continue_road(oldroad, x, y)
{
	if ( x < 0 || x > 31)
		return;
	if ( y < 0 || y > 31)
		return;
	if ( map[POINT(x,y)]  != '0' )
		return;

	Draw();	
	sleep;
	Draw();
	sleep;
	Draw();
	sleep;


	items[POINT(x,y)] = 'X';

	new value = random(cellmax) % 99;
	switch( value )
	{
		case 20 .. 32: // add intersection
		{
			if ( get_point(x+1,y, '+' ) || get_point(x-1,y, '+' ) || get_point(x,y+1, '+' ) || get_point(x,y-1, '+' ) )
			{
				continue_road(oldroad, x, y)
			}
			else
			{
				map[POINT(x,y)] = '+';
				continue_road('=', x - 1, y);
				continue_road('=', x + 1, y);
				continue_road('|', x, y -1);
				continue_road('|', x, y +1);
			}
			
		}
		default: // continue road
		{
			map[POINT(x,y)] = oldroad;
			look_at_road(x, y);
			
		}
	}
	items[POINT(x,y)] = '\32';
}


set_point(x,y, value )
{
	if ( x < 0 || x > 31)
		return;
	if ( y < 0 || y > 31)
		return;
	if ( map[POINT(x,y)] == '0' )
		map[POINT(x,y)] = value;
}



get_point(x,y, value )
{
	if ( x < 0 || x > 31)
		return true;
	if ( y < 0 || y > 31)
		return true;
	if ( map[POINT(x,y)] ==value ) 
		return true;
}


look_at_road(x, y)
{
	new fx = x;
	new fy = y;

	if ( x < 0 || x > 31)
		return;
	if ( y < 0 || y > 31)
		return;

	new value = map[POINT(fx,fy)];
	switch( value )
	{
		case '=':
		{
			set_point(fx,fy-1, 'H' );
			set_point(fx,fy+1, 'H' );
			continue_road('=', fx+1, fy);
			continue_road('=', fx-1, fy);
		}
		case '|':
		{
			set_point(fx-1,fy, 'H' );
			set_point(fx+1,fy, 'H' );
			continue_road('|', fx, fy-1);
			continue_road('|', fx, fy+1);
		}
		case '+':
		{
			continue_road('=', fx-1, fy);
			continue_road('=', fx+1, fy);
			continue_road('|', fx, fy-1);
			continue_road('|', fx, fy+1);
		}
		default:
		{
			return;
		}
	}
}

strsubcat( dest[], source[], start, length )
{
	for( new q = 0; q < length; q++)
	{
		dest[q] = source[q+start];
	}

}
Draw()
{
	
	for( new y = 0; y < 32; y++)
	{
		new line[33] = {0, ... };
		strsubcat( line, map, (y*32), 32 );
		GraphicsDraw(line, TEXT, 10, 10 +(y*8) , 4, 0,0, WHITE );
		strsubcat( line, items, (y*32), 32 );
		GraphicsDraw(line, TEXT, 10, 10 +(y*8) , 5, 0,0, RED );
	}
}

main()
{

	c = 0;
	if ( generating )
	{
		if ( map[528] == '0' )
		{
			starting_point(528);
			look_at_road(_x, _y);
		}

		for( new y = 0; y < 32; y++)
		{
			if ( y == 0 || y ==31)
			{
				for( new x = 0; x < 32; x++)
				{
					if ( map[POINT(x,y)] == '0' )
						map[POINT(x,y)] = 'H';

					Draw();	
					sleep;
					Draw();
					sleep;
				}
			}
			else
			{
				if ( map[POINT(0,y)] == '0' )
					map[POINT(0,y)] = 'H';
				if ( map[POINT(31,y)] == '0' )
					map[POINT(31,y)] = 'H';
			}
		}

		for( new y = 0; y < 32; y++)
		{
			for( new x = 0; x < 32; x++)
			{
				if ( map[POINT(x,y)] == '0' )
					map[POINT(x,y)] = 'H';
			}
		}
		for( new y = 0; y < 32; y++)
		{
			for( new x = 0; x < 32; x++)
			{
				if ( map[POINT(x,y)] == '+' )
				{
					if ( get_point(x+1,y, 'H' ) && get_point(x-1,y, 'H' ) )
						items[POINT(x,y)] = '|';
				}
				if ( map[POINT(x,y)] == '=' )
				{
					if ( get_point(x+1,y, 'H' ) || get_point(x-1,y, 'H' ) )
						items[POINT(x,y)] = '*'
					if ( get_point(x,y+1, '+' ) || get_point(x,y-1, '+' ) || get_point(x,y+1, '|' ) || get_point(x,y-1, '|' ))
						items[POINT(x,y)] = '+'
				}
				if ( map[POINT(x,y)] == '|' )
				{
					if ( get_point(x,y+1, 'H' ) || get_point(x,y-1, 'H' ) )
						items[POINT(x,y)] = '*'
					if ( get_point(x+1,y, '+' ) || get_point(x-1,y, '+' ) || get_point(x+1,y, '=' ) || get_point(x-1,y, '=' ))
						items[POINT(x,y)] = '+'
				}			
				Draw();	
				sleep;
				Draw();
				sleep;
			}
		}
		generating = false;
	}
	Draw()

}

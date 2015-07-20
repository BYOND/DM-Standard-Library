#ifndef STDLIB
#define STDLIB 1

#ifndef TILE_WIDTH
#ifndef STDLIB_NOWARN
#warn TILE_WIDTH/TILE_HEIGHT is undefined. Defaulting to 32x32. Either define STDLIB_NOWARN to remove this warning, or explicitly define TILE_WIDTH and TILE_HEIGHT.
#endif
#define TILE_WIDTH 32
#define TILE_HEIGHT 32
#endif

#ifndef FPS
#ifndef STDLIB_NOWARN
#warn FPS is undefined. Defaulting to 25. Either define STDLIB_NOWARN to remove this warning, or explicitly define FPS.
#endif
#define FPS 25
#endif

#define TICK_LAG 10/FPS

#define floor(x) round(x)
#define ceil(x) -floor(-(x))
#define inner(x) x<0 ? ceil(x) : floor(x)
#define outer(x) x<0 ? floor(x) : ceil(x)

proc
	decimal(x)
		. = x - inner(x)

	to_places(x,places)
		if(places)
			var/whole = inner(x)
			var/shift = 10**(places-1)
			. = whole + inner((x - whole) * shift) / shift
		else
			. = inner(x)

#define clamp(value,low,high) min(max(value,low),high)

#define ismovable(o) istype(o,/atom/movable)
#define islist(o) istype(o,/list)

#define left_x(O) (O:loc ? ((O:x-1)*TILE_WIDTH + (ismovable(O) ? O:step_x + O:bound_x : 0)) : null)
#define bottom_y(O) (O:loc ? ((O:y-1)*TILE_HEIGHT + (ismovable(O) ? O:step_y + O:bound_y : 0)) : null)
#define center_x(O) (O:loc ? ((O:x-1)*TILE_WIDTH + (ismovable(O) ? O:step_x + O:bound_x + O:bound_width/2 - 1 : floor(TILE_WIDTH/2)-1)) : null)
#define center_y(O) (O:loc ? ((O:y-1)*TILE_HEIGHT + (ismovable(O) ? O:step_y + O:bound_y + O:bound_height/2 - 1 : floor(TILE_HEIGHT/2)-1)) : null)
#define right_x(O) (O:loc ? ((O:x-1)*TILE_WIDTH + (ismovable(O) ? O:step_x + O:bound_x + O:bound_width - 1 : TILE_WIDTH-1)) : null)
#define top_y(O) (O:loc ? ((O:y-1)*TILE_HEIGHT + (ismovable(O) ? O:step_y + O:bound_y + O:bound_height - 1 : TILE_HEIGHT-1)) : null)

var
	list
		__dir_ang = list(90,270,null,0,45,315,0,180,135,225,180,null,90,180,null)
		__dir_names = list("north"=NORTH,"south"=SOUTH,null,"east"=EAST,"northeast"=NORTHEAST,"southeast"=SOUTHEAST,null,"west"=WEST,"northwest"=NORTHWEST,"southwest"=SOUTHWEST)
		__euler_dirs = list(EAST,NORTHEAST,NORTH,NORTHWEST,WEST,SOUTHWEST,SOUTH,SOUTHEAST)

#define dir2ang(x) __dir_ang[x]
#define dir2text(x) __dir_names[x]
#define text2dir(name) __dir_names[lowertext(name)]

#define cot(a) (1/tan(a))
#define sec(a) (1/cos(a))
#define csc(a) (1/sin(a))
#define arcsec(a) arccos(1 / (a))
#define arccsc(a) arcsin(1 / (a))

proc
	atan2(x,y)
		return (x||y)&&(y>=0 ? arccos(x/sqrt(x*x+y*y)) : 360-arccos(x/sqrt(x*x+y*y)))

	ang2dir(x)
		//ensure that the angle is between 0 and 360
		if(x<0)
			x = x+360*ceil(x/-360)
		. = __euler_dirs[floor(ceil(x/22.5)%16 / 2)+1]

	getang(atom/a,atom/b)
		. = atan2(center_x(b)-center_x(a),center_y(b)-center_y(a))

	hypotenuse(a,b)
		. = sqrt(a*a + b*b)

	tan(ang)
		. = sin(ang) / cos(ang)

	arctan(ang)
		. = arccos(1 / sqrt(1 + ang * ang))

	arccot(ang)
		. = arcsin(1 / sqrt(1 + ang * ang))

proc
	str_ends_withEx(str,substr)
		var/len = length(str)
		var/slen = length(substr)
		var/pos = len-slen+1
		. = len>=slen&&findtextEx(str,pos)

	str_ends_with(str,substr)
		var/len = length(str)
		var/slen = length(substr)
		var/pos = len-slen+1
		. = len>=slen&&findtext(str,substr,pos)==pos

	str_begins_withEx(str,substr)
		var/slen = length(substr)
		. = length(str)>=slen&&findtextEx(str,substr,1,slen+1)

	str_begins_with(str,substr)
		var/slen = length(substr)
		. = length(str)>=slen&&findtext(str,substr,1,slen+1)

	str_copy_after(str,sep,spos=1)
		var/len = length(str)
		if(!spos||spos>=len) return null
		else if(spos<0) spos += len
		var/slen = length(sep)
		var/pos = findtext(str,sep,spos)
		slen += pos
		. = pos&&len>=slen ? copytext(str,slen,0) : null

	str_copy_afterEx(str,sep,spos=1)
		var/len = length(str)
		if(!spos||spos>=len) return null
		else if(spos<0) spos += len
		var/slen = length(sep)
		var/pos = findtextEx(str,sep,spos)
		slen += pos
		. = pos&&len>=slen ? copytext(str,slen,0) : null

	str_copy_before(str,sep,spos=1)
		var/len = length(str)
		if(!spos||spos>=len) return str
		else if(spos<0) spos += len
		var/pos = findtext(str,sep,spos)
		. = pos ? copytext(str,1,pos) : str

	str_copy_beforeEx(str,sep,spos=1)
		var/len = length(str)
		if(!spos||spos>=len) return str
		else if(spos<0) spos += len
		var/pos = findtextEx(str,sep,spos)
		. = pos ? copytext(str,1,pos) : str

	str_replaceEx(str,findstr,repstr)
		. = ""
		var/slen = length(str)
		var/flen = length(findstr)
		var/pos = 1
		var/fpos = 1
		while(fpos&&pos<=slen)
			fpos = findtextEx(str,findstr,pos)
			if(fpos==pos)
				. += ""
				pos = fpos + flen
			else if(fpos)
				. += copytext(str,pos,fpos)
				pos = fpos + flen
		if(pos<=slen)
			. += copytext(str,pos)

	str_replace(str,findstr,repstr)
		. = ""
		var/slen = length(str)
		var/flen = length(findstr)
		var/pos = 1
		var/fpos = 1
		while(fpos&&pos<=slen)
			fpos = findtext(str,findstr,pos)
			if(fpos==pos)
				. += repstr
				pos = fpos + flen
			else if(fpos)
				. += copytext(str,pos,fpos) + repstr
				pos = fpos + flen
		if(pos<=slen)
			. += copytext(str,pos)

	tokenizeEx(str,separator)
		var/slen = length(str)
		var/flen = length(separator)
		var/pos = 1
		var/fpos = 1
		. = list()
		while(fpos&&pos<=slen)
			fpos = findtextEx(str,separator,pos)
			if(fpos>pos)
				pos = fpos + flen
			else if(fpos)
				. += copytext(str,pos,fpos)
				pos = fpos + flen
		if(pos<=slen)
			. += copytext(str,pos)

	tokenize(str,separator)
		var/slen = length(str)
		var/flen = length(separator)
		var/pos = 1
		var/fpos = 1
		. = list()
		while(fpos&&pos<=slen)
			fpos = findtext(str,separator,pos)
			if(fpos==pos)
				pos = fpos + flen
			else if(fpos)
				. += copytext(str,pos,fpos)
				pos = fpos + flen
		if(pos<=slen)
			. += copytext(str,pos)

	trim_whitespace(str)
		var/spos = 0
		var/epos = length(str)
		while(++spos<=epos)
			switch(text2ascii(str,spos))
				if(32,9 to 13,133,160)
					continue
				else
					break
		var/len = epos++
		while(--epos>spos)
			switch(text2ascii(str,epos))
				if(32,9 to 13,133,160)
					continue
				else
					break
		if(spos<epos)
			if(spos>1||epos<len)
				. = copytext(str,spos,epos+1)
			else
				. = str
		else
			. = ""

	findtext_all(str,findstr)
		. = list()
		var/pos = 1
		var/fpos = 1
		var/len = length(str)
		var/flen = length(findstr)
		while(fpos&&pos<=len)
			fpos = findtext(str,findstr,pos)
			if(fpos)
				. += fpos
				pos = fpos+flen

	findtextEx_all(str,findstr)
		. = list()
		var/pos = 1
		var/fpos = 1
		var/len = length(str)
		var/flen = length(findstr)
		while(fpos&&pos<=len)
			fpos = findtextEx(str,findstr,pos)
			if(fpos)
				. += fpos
				pos = fpos+flen

	screen_loc2num(str)
		. = tokenize(str,",")
		.[1] = (text2num(.[1])-1)*TILE_WIDTH + text2num(str_copy_after(.[1],":"))
		.[2] = (text2num(.[2])-1)*TILE_HEIGHT + text2num(str_copy_after(.[2],":"))

#ifdef STDLIB_MOUSE

#define MOUSE_LEFT 1
#define MOUSE_RIGHT 2
#define MOUSE_MIDDLE 4

client
	var
		mouse_x = 0
		mouse_y = 0

		mouse_buttons = 0

	proc
		UpdateMousePos(list/params)
			if(!islist(params))
				params = params2list(params)
			var/list/l = screen_loc2num(params["screen-loc"])
			mouse_x = l[1]
			mouse_y = l[2]

	New()
		var/atom/movable/o = new()
		o.layer = -1#INF
		o.screen_loc = "1,1 to NORTH,EAST"
		o.mouse_opacity = 2
		screen += o
		. = ..()

	MouseMove(object,location,control,params)
		UpdateMousePos(params)
		..()

	MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
		UpdateMousePos(params)
		..()

	MouseDown(object,location,control,params)
		var/list/l = params2list(params)
		UpdateMousePos(l)
		if(l["left"]) mouse_buttons |= MOUSE_LEFT
		if(l["right"]) mouse_buttons |= MOUSE_RIGHT
		if(l["middle"]) mouse_buttons |= MOUSE_MIDDLE
		..()

	MouseUp(object,location,control,params)
		var/list/l = params2list(params)
		UpdateMousePos(l)
		if(l["left"]) mouse_buttons &= ~MOUSE_LEFT
		if(l["right"]) mouse_buttons &= ~MOUSE_RIGHT
		if(l["middle"]) mouse_buttons &= ~MOUSE_MIDDLE

#endif

#ifdef STDLIB_KEYS

#ifndef STDLIB_MOUSE
#define MOUSE_LEFT 1
#define MOUSE_RIGHT 2
#define MOUSE_MIDDLE 4
#endif

#define KEY_BACKSPACE		8
#define KEY_TAB				9
#define KEY_CENTER			12
#define KEY_RETURN			13
#define KEY_SHIFT			16
#define KEY_CTRL			17
#define KEY_ALT				18
#define KEY_PAUSE			19
#define KEY_ESCAPE			27
#define KEY_SPACE			32
#define KEY_PGUP			33
#define KEY_PGDN			34
#define KEY_END				35
#define KEY_HOME			36
#define KEY_LEFT			37
#define KEY_UP				38
#define KEY_RIGHT			39
#define KEY_DOWN			40
#define KEY_INSERT			45
#define KEY_DELETE			46
#define KEY_0				48
#define KEY_1				49
#define KEY_2				50
#define KEY_3				51
#define KEY_4				52
#define KEY_5				53
#define KEY_6				54
#define KEY_7				55
#define KEY_8				56
#define KEY_9				57
#define KEY_A				65
#define KEY_B				66
#define KEY_C				67
#define KEY_D				68
#define KEY_E				69
#define KEY_F				70
#define KEY_G				71
#define KEY_H				72
#define KEY_I				73
#define KEY_J				74
#define KEY_K				75
#define KEY_L				76
#define KEY_M				77
#define KEY_N				78
#define KEY_O				79
#define KEY_P				80
#define KEY_Q				81
#define KEY_R				82
#define KEY_S				83
#define KEY_T				84
#define KEY_U				85
#define KEY_V				86
#define KEY_W				87
#define KEY_X				88
#define KEY_Y				89
#define KEY_Z				90
#define KEY_LWIN			91
#define KEY_RWIN			92
#define KEY_SELECT			93
#define KEY_NUMPAD_0		96
#define KEY_NUMPAD_1		97
#define KEY_NUMPAD_2		98
#define KEY_NUMPAD_3		99
#define KEY_NUMPAD_4		100
#define KEY_NUMPAD_5		101
#define KEY_NUMPAD_6		102
#define KEY_NUMPAD_7		103
#define KEY_NUMPAD_8		104
#define KEY_NUMPAD_9		105
#define KEY_MULTIPLY		106
#define KEY_ADD				107
#define KEY_SUBTRACT		109
#define KEY_DECIMAL			110
#define KEY_DIVIDE			111
#define KEY_F1				112
#define KEY_F2				113
#define KEY_F3				114
#define KEY_F4				115
#define KEY_F5				116
#define KEY_F6				117
#define KEY_F7				118
#define KEY_F8				119
#define KEY_F9				120
#define KEY_F10				121
#define KEY_F11				122
#define KEY_F12				123
#define KEY_SEMICOLON		186
#define KEY_EQUAL			187
#define KEY_COMMA			188
#define KEY_DASH			189
#define KEY_PERIOD			190
#define KEY_SLASH			191
#define KEY_GRAVE			192
#define KEY_OPEN_BRACKET	219
#define KEY_BACKSLASH		220
#define KEY_CLOSE_BRACKET	221
#define KEY_SINGLE_QUOTE	222

#define CATEGORY_NONE		0
#define CATEGORY_MODIFIER	1
#define CATEGORY_CONTROL	2
#define CATEGORY_FUNCTION	4
#define CATEGORY_NUMPAD		8
#define CATEGORY_ALPHA		16
#define CATEGORY_NUMERIC	32
#define CATEGORY_SYMBOL		64
#define CATEGORY_MOUSE		128

#define key_category(keycode) __key_category[keycode]
#define key_name(keycode) __key_names[keycode]
#define name2keycode(name) __keycode_names[name]
#define char2keycode(char) __keycode_chars[char]

proc
	keycode2char(keycode,shift=0,capslock=0,raw=0)
		if(key_category(keycode)==CATEGORY_ALPHA)
			shift &= ~capslock
		if(shift)
			if(raw&&(key_category(keycode)&CATEGORY_SYMBOL))
				switch(keycode)
					if(KEY_7)
						. = "&"
					if(KEY_COMMA)
						. = "<"
					if(KEY_PERIOD)
						. = ">"
					else
						. = __key_chars_shift[keycode]
			else
				. = __key_chars_shift[keycode]
		else
			. = __key_chars[keycode]

var/list
	__key_category = list(CATEGORY_MOUSE,CATEGORY_MOUSE,CATEGORY_NONE,CATEGORY_MOUSE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_CONTROL,CATEGORY_CONTROL|CATEGORY_SYMBOL,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_SYMBOL|CATEGORY_NUMPAD,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_MODIFIER,
						CATEGORY_MODIFIER,CATEGORY_MODIFIER,CATEGORY_CONTROL,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_CONTROL,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_CONTROL|CATEGORY_SYMBOL,
						CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_CONTROL|CATEGORY_NUMPAD,CATEGORY_NONE,CATEGORY_NUMERIC|CATEGORY_SYMBOL,
						CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NUMERIC|CATEGORY_SYMBOL,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,
						CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,
						CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_ALPHA,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NUMERIC|CATEGORY_NUMPAD,
						CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_NUMERIC|CATEGORY_NUMPAD,CATEGORY_SYMBOL|CATEGORY_NUMPAD,CATEGORY_SYMBOL|CATEGORY_NUMPAD,CATEGORY_NONE,CATEGORY_SYMBOL|CATEGORY_NUMPAD,CATEGORY_SYMBOL|CATEGORY_NUMPAD,CATEGORY_SYMBOL|CATEGORY_NUMPAD,CATEGORY_FUNCTION,
						CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_FUNCTION,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,
						CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,
						CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,
						CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,
						CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL,
						CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,
						CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_NONE,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL,CATEGORY_SYMBOL)

	__key_names =	  list("mouse1","mouse2",null,"mouse3",null,null,null,"backspace","tab",null,null,"center","return",null,null,"shift",
						"ctrl","alt","pause",null,null,null,null,null,null,null,"escape",null,null,null,null,"space",
						"page up","page down","end","home","left","up","right","down",null,null,null,null,"insert","delete",null,"0",
						"1","2","3","4","5","6","7","8","9",null,null,null,null,null,null,null,
						"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
						"q","r","s","t","u","v","w","x","y","z","lwin","rwin","select",null,null,"numpad 0",
						"numpad 1","numpad 2","numpad 3","numpad 4","numpad 5","numpad 6","numpad 7","numpad 8","numpad 9","numpad multiply","numpad add",null,"numpad subtract","numpad decimal","numpad divide","f1",
						"f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,"semicolon","equal","comma","dash","period","slash","grave",
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,"open bracket","backslash","close bracket","single quote")

	__key_chars =	  list(null,null,null,null,null,null,null,null,"\t",null,null,null,"\n",null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null," ",
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,"0",
						"1","2","3","4","5","6","7","8","9",null,null,null,null,null,null,null,
						"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
						"q","r","s","t","u","v","w","x","y","z",null,null,null,null,null,"0",
						"1","2","3","4","5","6","7","8","9","*","+",null,"-",".","/",null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,";","=",",","-",".","/","`",
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,"\[","\\","]","'")

	__key_chars_shift = list(null,null,null,null,null,null,null,null,null,null,null,null,"\n",null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null," ",
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,")",
						"!","@","#","$","%","^","&amp;","*","(",null,null,null,null,null,null,null,
						"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
						"Q","R","S","T","U","V","W","X","Y","Z",null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,"*","+",null,"-",null,"/",null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,":","+","&lt;","_","&gt;","?","~",
						null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
						null,null,null,null,null,null,null,null,null,null,"{","|","}","\"")

	__keycode_names = list("mouse1"=MOUSE_LEFT,"mouse2"=MOUSE_RIGHT,"mouse3"=MOUSE_MIDDLE,"backspace"=KEY_BACKSPACE,"tab"=KEY_TAB,"center"=KEY_CENTER,"return"=KEY_RETURN,"shift"=KEY_SHIFT,
						"ctrl"=KEY_CTRL,"alt"=KEY_ALT,"pause"=KEY_PAUSE,"escape"=KEY_ESCAPE,"space"=KEY_SPACE,
						"page up"=KEY_PGUP,"page down"=KEY_PGDN,"end"=KEY_END,"home"=KEY_HOME,"left"=KEY_LEFT,"right"=KEY_RIGHT,"down"=KEY_DOWN,"insert"=KEY_INSERT,"delete"=KEY_DELETE,"0"=KEY_0,
						"1"=KEY_1,"2"=KEY_2,"3"=KEY_3,"4"=KEY_4,"5"=KEY_5,"6"=KEY_6,"7"=KEY_7,"8"=KEY_8,"9"=KEY_9,
						"a"=KEY_A,"b"=KEY_B,"c"=KEY_C,"d"=KEY_D,"e"=KEY_E,"f"=KEY_F,"g"=KEY_G,"h"=KEY_H,"i"=KEY_I,"j"=KEY_J,"k"=KEY_J,"l"=KEY_L,"m"=KEY_M,"n"=KEY_N,"o"=KEY_O,"p"=KEY_P,
						"q"=KEY_Q,"r"=KEY_R,"s"=KEY_S,"t"=KEY_T,"u"=KEY_U,"v"=KEY_V,"w"=KEY_W,"x"=KEY_X,"y"=KEY_Y,"z"=KEY_Z,"lwin"=KEY_LWIN,"rwin"=KEY_RWIN,"select"=KEY_SELECT,"numpad 0"=KEY_NUMPAD_0,
						"numpad 1"=KEY_NUMPAD_1,"numpad 2"=KEY_NUMPAD_2,"numpad 3"=KEY_NUMPAD_3,"numpad 4"=KEY_NUMPAD_4,"numpad 5"=KEY_NUMPAD_5,"numpad 6"=KEY_NUMPAD_6,"numpad 7"=KEY_NUMPAD_7,"numpad 8"=KEY_NUMPAD_8,"numpad 9"=KEY_NUMPAD_9,"numpad multiply"=KEY_MULTIPLY,"numpad add"=KEY_ADD,"numpad subtract"=KEY_SUBTRACT,"numpad decimal"=KEY_DECIMAL,"numpad divide"=KEY_DIVIDE,
						"f1"=KEY_F1,"f2"=KEY_F2,"f3"=KEY_F3,"f4"=KEY_F4,"f5"=KEY_F5,"f6"=KEY_F6,"f7"=KEY_F7,"f8"=KEY_F8,"f9"=KEY_F9,"f10"=KEY_F10,"f11"=KEY_F11,"f12"=KEY_F12,
						"semicolon"=KEY_SEMICOLON,"equal"=KEY_EQUAL,"comma"=KEY_COMMA,"dash"=KEY_DASH,"period"=KEY_PERIOD,"slash"=KEY_SLASH,"grave"=KEY_GRAVE,
						"open bracket"=KEY_OPEN_BRACKET,"backslash"=KEY_BACKSLASH,"close bracket"=KEY_CLOSE_BRACKET,"single quote"=KEY_SINGLE_QUOTE)

	__keycode_chars = list(" "=KEY_SPACE,
						"0"=KEY_0,")"=KEY_0,
						"1"=KEY_1,"2"=KEY_2,"3"=KEY_3,"4"=KEY_4,"5"=KEY_5,"6"=KEY_6,"7"=KEY_7,"8"=KEY_8,"9"=KEY_9,"!"=KEY_1,"@"=KEY_2,"#"=KEY_3,"$"=KEY_4,"%"=KEY_5,"^"=KEY_6,"&amp;"=KEY_7,"*"=KEY_8,"("=KEY_9,
						"a"=KEY_A,"b"=KEY_B,"c"=KEY_C,"d"=KEY_D,"e"=KEY_E,"f"=KEY_F,"g"=KEY_G,"h"=KEY_H,"i"=KEY_I,"j"=KEY_J,"k"=KEY_J,"l"=KEY_L,"m"=KEY_M,"n"=KEY_N,"o"=KEY_O,"p"=KEY_P,
						"q"=KEY_Q,"r"=KEY_R,"s"=KEY_S,"t"=KEY_T,"u"=KEY_U,"v"=KEY_V,"w"=KEY_W,"x"=KEY_X,"y"=KEY_Y,"z"=KEY_Z,
						"A"=KEY_A,"B"=KEY_B,"C"=KEY_C,"D"=KEY_D,"E"=KEY_E,"F"=KEY_F,"G"=KEY_G,"H"=KEY_H,"I"=KEY_I,"J"=KEY_J,"K"=KEY_J,"L"=KEY_L,"M"=KEY_M,"N"=KEY_N,"O"=KEY_O,"P"=KEY_P,
						"Q"=KEY_Q,"R"=KEY_R,"S"=KEY_S,"T"=KEY_T,"U"=KEY_U,"V"=KEY_V,"W"=KEY_W,"X"=KEY_X,"Y"=KEY_Y,"Z"=KEY_Z,
						";"=KEY_SEMICOLON,"="=KEY_EQUAL,","=KEY_COMMA,"-"=KEY_DASH,"."=KEY_PERIOD,"/"=KEY_SLASH,"`"=KEY_GRAVE,
						":"=KEY_SEMICOLON,"+"=KEY_EQUAL,"&lt;"=KEY_COMMA,"_"=KEY_DASH,"&gt;"=KEY_PERIOD,"?"=KEY_SLASH,"~"=KEY_GRAVE,
						"\["=KEY_OPEN_BRACKET,"\\"=KEY_BACKSLASH,"]"=KEY_CLOSE_BRACKET,"'"=KEY_SINGLE_QUOTE,
						"{"=KEY_OPEN_BRACKET,"|"=KEY_BACKSLASH,"}"=KEY_CLOSE_BRACKET,"\""=KEY_SINGLE_QUOTE)

#endif

datum
	proc
		Cleanup()

atom
	movable
		Cleanup()
			loc = null

client
	Del()
		Cleanup()
		..()
	proc
		Cleanup()

var/datum/void = new()

//DO NOT INITIALIZE THESE. THIS IS AN INTERFACE FOR CASTING APPEARANCES ONLY

appearance
	var
		alpha
		blend_mode
		color
		density
		desc
		dir
		gender
		icon
		icon_state
		invisibility
		infra_luminosity
		layer
		luminosity
		maptext
		maptext_width
		maptext_height
		maptext_x
		maptext_y
		mouse_over_pointer
		mouse_drag_pointer
		mouse_drop_pointer
		mouse_drop_zone
		mouse_opacity
		name
		opacity
		list/overlays
		override
		pixel_x
		pixel_y
		pixel_z
		suffix
		screen_loc
		text
		transform
		list/underlays
		list/verbs
	New()
		del src
#endif
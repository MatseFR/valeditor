package valeditor.input;

/**
 * ...
 * @author Matse
 */
class InputActionID 
{
	// edition
	static public inline var COPY:String = "copy";
	static public inline var CUT:String = "cut";
	static public inline var DELETE:String = "delete";
	static public inline var PASTE:String = "paste";
	//static public inline var PASTE_IN_PLACE:String = "paste in place";
	static public inline var REDO:String = "redo";
	static public inline var SELECT_ALL:String = "select_all";
	static public inline var UNDO:String = "undo";
	static public inline var UNSELECT_ALL:String = "unselect_all";
	
	// control
	static public inline var PLAY_STOP:String = "play_stop";
	static public inline var INSERT_FRAME:String = "insert_frame";
	static public inline var INSERT_KEYFRAME:String = "insert_keyframe";
	static public inline var REMOVE_FRAME:String = "remove_frame";
	static public inline var REMOVE_KEYFRAME:String = "remove_keyframe";
	
	// object
	static public inline var MOVE_DOWN_1:String = "move_down_1";
	static public inline var MOVE_DOWN_10:String = "move_down_10";
	static public inline var MOVE_LEFT_1:String = "move_left_1";
	static public inline var MOVE_LEFT_10:String = "move_left_10";
	static public inline var MOVE_RIGHT_1:String = "move_right_1";
	static public inline var MOVE_RIGHT_10:String = "move_right_10";
	static public inline var MOVE_UP_1:String = "move_up_1";
	static public inline var MOVE_UP_10:String = "move_up_10";
	
	// file
	static public inline var EXPORT:String = "export";
	static public inline var EXPORT_AS:String = "export_as";
	static public inline var NEW_FILE:String = "new_file";
	static public inline var OPEN:String = "open";
	static public inline var SAVE:String = "save";
	static public inline var SAVE_AS:String = "save_as";
	
}
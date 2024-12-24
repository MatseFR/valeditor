package valeditor.input;

/**
 * ...
 * @author Matse
 */
class InputActionID 
{
	// edition
	inline static public var COPY:String = "copy";
	inline static public var CUT:String = "cut";
	inline static public var DELETE:String = "delete";
	inline static public var PASTE:String = "paste";
	//inline static public var PASTE_IN_PLACE:String = "paste in place";
	inline static public var REDO:String = "redo";
	inline static public var SELECT_ALL:String = "select_all";
	inline static public var UNDO:String = "undo";
	inline static public var UNSELECT_ALL:String = "unselect_all";
	
	// control
	inline static public var PLAY_STOP:String = "play_stop";
	inline static public var INSERT_FRAME:String = "insert_frame";
	inline static public var INSERT_KEYFRAME:String = "insert_keyframe";
	inline static public var REMOVE_FRAME:String = "remove_frame";
	inline static public var REMOVE_KEYFRAME:String = "remove_keyframe";
	
	// object
	inline static public var MOVE_DOWN_1:String = "move_down_1";
	inline static public var MOVE_DOWN_10:String = "move_down_10";
	inline static public var MOVE_LEFT_1:String = "move_left_1";
	inline static public var MOVE_LEFT_10:String = "move_left_10";
	inline static public var MOVE_RIGHT_1:String = "move_right_1";
	inline static public var MOVE_RIGHT_10:String = "move_right_10";
	inline static public var MOVE_UP_1:String = "move_up_1";
	inline static public var MOVE_UP_10:String = "move_up_10";
	
	// file
	inline static public var CLOSE_FILE:String = "close_file";
	inline static public var EXPORT:String = "export";
	inline static public var EXPORT_AS:String = "export_as";
	inline static public var NEW_FILE:String = "new_file";
	inline static public var OPEN:String = "open";
	inline static public var SAVE:String = "save";
	inline static public var SAVE_AS:String = "save_as";
	
	// window
	inline static public var ASSET_BROWSER:String = "asset_browser";
	
}
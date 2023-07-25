package valeditor;

import valedit.ValEditKeyFrame;

/**
 * ...
 * @author Matse
 */
class ValEditorKeyFrame extends ValEditKeyFrame 
{
	static private var _POOL:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	
	static public function fromPool():ValEditorKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorKeyFrame();
	}
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}
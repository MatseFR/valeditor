package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineFrameUpdateAll extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineFrameUpdateAll> = new Array<TimeLineFrameUpdateAll>();
	
	static public function fromPool():TimeLineFrameUpdateAll
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineFrameUpdateAll();
	}
	
	public var timeLine:ValEditorTimeLine;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.timeLine = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(timeLine:ValEditorTimeLine):Void
	{
		this.timeLine = timeLine;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineFrameUpdateAll already applied");
		}
		
		this.timeLine.frameCollection.updateAll();
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineFrameUpdateAll already cancelled");
		}
		
		this.timeLine.frameCollection.updateAll();
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
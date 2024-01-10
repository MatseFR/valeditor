package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineUpdateLastFrameIndex extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineUpdateLastFrameIndex> = new Array<TimeLineUpdateLastFrameIndex>();
	
	static public function fromPool():TimeLineUpdateLastFrameIndex
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineUpdateLastFrameIndex();
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
			throw new Error("TimeLineUpdateLastFrameIndex already applied");
		}
		
		this.timeLine.updateLastFrameIndex();
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineUpdateLastFrameIndex already cancelled");
		}
		
		this.timeLine.updateLastFrameIndex();
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
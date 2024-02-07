package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineSetSelectedFrameIndex extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineSetSelectedFrameIndex> = new Array<TimeLineSetSelectedFrameIndex>();
	
	static public function fromPool():TimeLineSetSelectedFrameIndex
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetSelectedFrameIndex();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var index:Int;
	public var previousIndex:Int;
	
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
	
	public function setup(timeLine:ValEditorTimeLine, index:Int):Void
	{
		this.timeLine = timeLine;
		this.index = index;
		this.previousIndex = this.timeLine.selectedFrameIndex;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineSetSelectedFrameIndex already applied");
		}
		
		this.timeLine.selectedFrameIndex = this.index;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineSetSelectedFrameIndex already cancelled");
		}
		
		this.timeLine.selectedFrameIndex = this.previousIndex;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
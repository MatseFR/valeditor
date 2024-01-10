package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineSetFrameIndex extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineSetFrameIndex> = new Array<TimeLineSetFrameIndex>();
	
	static public function fromPool():TimeLineSetFrameIndex
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetFrameIndex();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var frameIndex:Int;
	public var previousFrameIndex:Int;
	
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
	
	public function setup(timeLine:ValEditorTimeLine, frameIndex:Int):Void
	{
		this.timeLine = timeLine;
		this.frameIndex = frameIndex;
		this.previousFrameIndex = this.timeLine.frameIndex;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineFrameIndex already applied");
		}
		
		this.timeLine.frameIndex = this.frameIndex;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineFrameIndex already cancelled");
		}
		
		this.timeLine.frameIndex = this.previousFrameIndex;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
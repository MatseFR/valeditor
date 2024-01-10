package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineUnregisterKeyFrame extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineUnregisterKeyFrame> = new Array<TimeLineUnregisterKeyFrame>();
	
	static public function fromPool():TimeLineUnregisterKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineUnregisterKeyFrame();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var keyFrame:ValEditorKeyFrame;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.timeLine = null;
		this.keyFrame = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(timeLine:ValEditorTimeLine, keyFrame:ValEditorKeyFrame):Void
	{
		this.timeLine = timeLine;
		this.keyFrame = keyFrame;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineUnregisterKeyFrame already applied");
		}
		
		this.timeLine.unregisterKeyFrame(this.keyFrame);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineUnregisterKeyFrame already cancelled");
		}
		
		this.timeLine.registerKeyFrame(this.keyFrame);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
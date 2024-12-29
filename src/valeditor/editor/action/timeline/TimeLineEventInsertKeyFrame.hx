package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;
import valeditor.events.TimeLineEvent;

/**
 * ...
 * @author Matse
 */
class TimeLineEventInsertKeyFrame extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineEventInsertKeyFrame> = new Array<TimeLineEventInsertKeyFrame>();
	
	static public function fromPool():TimeLineEventInsertKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineEventInsertKeyFrame();
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
			throw new Error("TimeLineEventInsertKeyFrame already applied");
		}
		TimeLineEvent.dispatch(this.timeLine, TimeLineEvent.INSERT_KEYFRAME);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineEventInsertKeyFrame already cancelled");
		}
		TimeLineEvent.dispatch(this.timeLine, TimeLineEvent.REMOVE_KEYFRAME);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
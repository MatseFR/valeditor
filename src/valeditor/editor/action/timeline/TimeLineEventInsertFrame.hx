package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;
import valeditor.events.TimeLineEvent;

/**
 * ...
 * @author Matse
 */
class TimeLineEventInsertFrame extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineEventInsertFrame> = new Array<TimeLineEventInsertFrame>();
	
	static public function fromPool():TimeLineEventInsertFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineEventInsertFrame();
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
			throw new Error("TimeLineEventInsertFrame already applied");
		}
		TimeLineEvent.dispatch(this.timeLine, TimeLineEvent.INSERT_FRAME);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineEventInsertFrame already cancelled");
		}
		TimeLineEvent.dispatch(this.timeLine, TimeLineEvent.REMOVE_FRAME);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;
import valeditor.events.TimeLineEvent;

/**
 * ...
 * @author Matse
 */
class TimeLineEventRemoveFrame extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineEventRemoveFrame> = new Array<TimeLineEventRemoveFrame>();
	
	static public function fromPool():TimeLineEventRemoveFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineEventRemoveFrame();
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
			throw new Error("TimeLineEventRemoveFrame already applied");
		}
		TimeLineEvent.dispatch(this.timeLine, TimeLineEvent.REMOVE_FRAME);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineEventRemoveFrame already cancelled");
		}
		TimeLineEvent.dispatch(this.timeLine, TimeLineEvent.INSERT_FRAME);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
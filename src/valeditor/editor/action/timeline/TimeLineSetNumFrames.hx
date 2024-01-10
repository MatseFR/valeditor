package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineSetNumFrames extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineSetNumFrames> = new Array<TimeLineSetNumFrames>();
	
	static public function fromPool():TimeLineSetNumFrames
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetNumFrames();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var valueChange:Int;
	
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
	
	public function setup(timeLine:ValEditorTimeLine, valueChange:Int):Void
	{
		this.timeLine = timeLine;
		this.valueChange = valueChange;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineNumFrames already applied");
		}
		
		this.timeLine.numFrames += this.valueChange;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineNumFrames already cancelled");
		}
		
		this.timeLine.numFrames -= this.valueChange;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
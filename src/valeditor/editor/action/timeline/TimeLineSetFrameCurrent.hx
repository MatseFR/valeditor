package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
@:access(valeditor.ValEditorTimeLine)
class TimeLineSetFrameCurrent extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineSetFrameCurrent> = new Array<TimeLineSetFrameCurrent>();
	
	static public function fromPool():TimeLineSetFrameCurrent
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetFrameCurrent();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var keyFrame:ValEditorKeyFrame;
	public var previousKeyFrame:ValEditorKeyFrame;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.timeLine = null;
		this.keyFrame = null;
		this.previousKeyFrame = null;
		
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
		this.previousKeyFrame = cast this.timeLine.frameCurrent;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineSetFrameCurrent already applied");
		}
		
		this.timeLine.setFrameCurrent(this.keyFrame);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineSetFrameCurrent already cancelled");
		}
		
		this.timeLine.setFrameCurrent(this.previousKeyFrame);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
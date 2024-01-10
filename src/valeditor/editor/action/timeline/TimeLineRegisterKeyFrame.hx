package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineRegisterKeyFrame extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineRegisterKeyFrame> = new Array<TimeLineRegisterKeyFrame>();
	
	static public function fromPool():TimeLineRegisterKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineRegisterKeyFrame();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var keyFrame:ValEditorKeyFrame;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.timeLine = null;
		//if (this.status == ValEditorActionStatus.UNDONE)
		//{
			//this.keyFrame.pool();
		//}
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
			throw new Error("TimeLineRegisterKeyFrame already applied");
		}
		this.timeLine.registerKeyFrame(this.keyFrame);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineRegisterKeyFrame already cancelled");
		}
		this.timeLine.unregisterKeyFrame(this.keyFrame);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TimeLineSetFrameAction extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineSetFrameAction> = new Array<TimeLineSetFrameAction>();
	
	static public function fromPool():TimeLineSetFrameAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetFrameAction();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var keyFrame:ValEditorKeyFrame;
	public var indexStart:Int;
	public var indexEnd:Int;
	
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
	
	public function setup(timeLine:ValEditorTimeLine, keyFrame:ValEditorKeyFrame, indexStart:Int, indexEnd:Int):Void
	{
		this.timeLine = timeLine;
		this.keyFrame = keyFrame;
		this.indexStart = indexStart;
		this.indexEnd = indexEnd;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineSetFrameAction already applied");
		}
		
		
	}
	
}
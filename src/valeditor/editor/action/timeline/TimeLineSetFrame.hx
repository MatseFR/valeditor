package valeditor.editor.action.timeline;

import openfl.errors.Error;
import valedit.utils.ReverseIterator;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
@:access(valeditor.ValEditorTimeLine)
class TimeLineSetFrame extends ValEditorAction 
{
	static private var _POOL:Array<TimeLineSetFrame> = new Array<TimeLineSetFrame>();
	
	static public function fromPool():TimeLineSetFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineSetFrame();
	}
	
	public var timeLine:ValEditorTimeLine;
	public var keyFrame:ValEditorKeyFrame;
	public var indexStart:Int;
	public var indexEnd:Int;
	public var previousFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	public var previousIndexStart:Int;
	public var previousIndexEnd:Int;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.timeLine = null;
		this.keyFrame = null;
		this.previousFrames.resize(0);
		
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
		this.previousIndexStart = this.keyFrame.indexStart;
		this.previousIndexEnd = this.keyFrame.indexEnd;
		
		for (i in this.indexStart...this.indexEnd + 1)
		{
			this.previousFrames.push(this.timeLine._frames[i]);
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TimeLineSetFrame already applied");
		}
		
		for (i in new ReverseIterator(this.previousIndexEnd, this.indexEnd + 1))
		{
			if (this.timeLine._frames[i] == this.keyFrame)
			{
				this.timeLine._frames[i] = null;
				this.timeLine._frameDatas[i].frame = null;
			}
		}
		
		this.keyFrame.indexStart = this.indexStart;
		this.keyFrame.indexEnd = this.indexEnd;
		
		for (i in this.indexStart...this.indexEnd + 1)
		{
			this.timeLine._frames[i] = this.keyFrame;
			this.timeLine._frameDatas[i].frame = this.keyFrame;
		}
		
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TimeLineSetFrame already cancelled");
		}
		
		this.keyFrame.indexStart = this.previousIndexStart;
		this.keyFrame.indexEnd = this.previousIndexEnd;
		
		var count:Int = this.previousFrames.length;
		for (i in 0...count)
		{
			this.timeLine._frames[this.indexStart + i] = this.previousFrames[i];
			this.timeLine._frameDatas[this.indexStart + i].frame = this.previousFrames[i];
		}
		
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
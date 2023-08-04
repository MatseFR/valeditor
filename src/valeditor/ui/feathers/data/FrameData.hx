package valeditor.ui.feathers.data;
import valeditor.ValEditorKeyFrame;

/**
 * ...
 * @author Matse
 */
class FrameData 
{
	static private var _POOL:Array<FrameData> = new Array<FrameData>();
	
	static public function fromPool(?frame:ValEditorKeyFrame = null):FrameData
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(frame);
		return new FrameData(frame);
	}
	
	public var frame:ValEditorKeyFrame;
	
	public function new(?frame:ValEditorKeyFrame) 
	{
		this.frame = frame;
	}
	
	public function clear():Void
	{
		
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(frame:ValEditorKeyFrame):FrameData
	{
		this.frame = frame;
		return this;
	}
	
}
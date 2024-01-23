package valeditor.editor.clipboard;
import haxe.iterators.ArrayIterator;
import valeditor.ValEditorKeyFrame;

/**
 * ...
 * @author Matse
 */
class ValEditorFrameCopyGroup 
{
	public var isRealClipboard:Bool = false;
	public var numFrames(get, never):Int;
	
	private function get_numFrames():Int { return this._frames.length; }
	
	private var _frames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	
	public function new() 
	{
		
	}
	
	public function iterator():ArrayIterator<ValEditorKeyFrame>
	{
		return this._frames.iterator();
	}
	
	public function clear():Void
	{
		if (this.isRealClipboard)
		{
			for (frame in this._frames)
			{
				frame.isInClipboard = false;
				if (frame.canBeDestroyed())
				{
					frame.pool();
				}
			}
		}
		this._frames.resize(0);
	}
	
	public function copyFrom(group:ValEditorFrameCopyGroup):Void
	{
		for (frame in group._frames)
		{
			addFrame(frame);
		}
	}
	
	public function addFrame(frame:ValEditorKeyFrame):Void
	{
		if (this._frames.indexOf(frame) != -1) return;
		if (this.isRealClipboard) frame.isInClipboard = true;
		this._frames.push(frame);
	}
	
	public function getFrameAt(index:Int):ValEditorKeyFrame
	{
		return this._frames[index];
	}
	
	public function hasFrame(frame:ValEditorKeyFrame):Bool
	{
		return this._frames.indexOf(frame) != -1;
	}
	
	public function removeFrame(frame:ValEditorKeyFrame):Bool
	{
		var result:Bool = this._frames.remove(frame);
		if (result && this.isRealClipboard)
		{
			frame.isInClipboard = false;
			if (frame.canBeDestroyed())
			{
				frame.pool();
			}
		}
		return result;
	}
	
}
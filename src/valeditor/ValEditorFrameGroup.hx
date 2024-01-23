package valeditor;
import haxe.iterators.ArrayIterator;

/**
 * ...
 * @author Matse
 */
class ValEditorFrameGroup 
{
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
		this._frames.resize(0);
	}
	
	public function copyFrom(group:ValEditorFrameGroup):Void
	{
		addFrames(group._frames);
	}
	
	public function addFrame(frame:ValEditorKeyFrame):Void
	{
		if (this._frames.indexOf(frame) != -1) return;
		this._frames.push(frame);
	}
	
	public function addFrames(frames:Array<ValEditorKeyFrame>):Void
	{
		for (frame in frames)
		{
			addFrame(frame);
		}
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
		return this._frames.remove(frame);
	}
	
}
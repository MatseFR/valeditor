package valeditor;
import haxe.iterators.ArrayIterator;
import valedit.ValEditKeyFrame;

/**
 * ...
 * @author Matse
 */
class ValEditorFrameGroup 
{
	public var numFrames(get, never):Int;
	
	private function get_numFrames():Int { return this._frames.length; }
	
	private var _frames:Array<ValEditKeyFrame> = new Array<ValEditKeyFrame>();
	
	public function new() 
	{
		
	}
	
	public function iterator():ArrayIterator<ValEditKeyFrame>
	{
		return this._frames.iterator();
	}
	
	public function clear():Void
	{
		this._frames.resize(0);
	}
	
	public function addFrame(frame:ValEditKeyFrame):Void
	{
		if (this._frames.indexOf(frame) != -1) return;
		this._frames.push(frame);
	}
	
	public function getFrameAt(index:Int):ValEditKeyFrame
	{
		return this._frames[index];
	}
	
	public function hasFrame(frame:ValEditKeyFrame):Bool
	{
		return this._frames.indexOf(frame) != -1;
	}
	
	public function removeFrame(frame:ValEditKeyFrame):Bool
	{
		return this._frames.remove(frame);
	}
	
}
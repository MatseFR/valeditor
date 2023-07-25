package valeditor;
import haxe.iterators.ArrayIterator;
import valedit.ValEditFrame;

/**
 * ...
 * @author Matse
 */
class ValEditorFrameGroup 
{
	public var numFrames(get, never):Int;
	
	private function get_numFrames():Int { return this._frames.length; }
	
	private var _frames:Array<ValEditFrame> = new Array<ValEditFrame>();
	
	public function new() 
	{
		
	}
	
	public function iterator():ArrayIterator<ValEditFrame>
	{
		return this._frames.iterator();
	}
	
	public function clear():Void
	{
		this._frames.resize(0);
	}
	
	public function addFrame(frame:ValEditFrame):Void
	{
		if (this._frames.indexOf(frame) != -1) return;
		this._frames.push(frame);
	}
	
	public function getFrameAt(index:Int):ValEditFrame
	{
		return this._frames[index];
	}
	
	public function hasFrame(frame:ValEditFrame):Bool
	{
		return this._frames.indexOf(frame) != -1;
	}
	
	public function removeFrame(frame:ValEditFrame):Bool
	{
		return this._frames.remove(frame);
	}
	
}
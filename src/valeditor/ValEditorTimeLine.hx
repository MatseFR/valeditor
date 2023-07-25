package valeditor;

import feathers.data.ArrayCollection;
import valedit.ValEditFrame;
import valedit.ValEditTimeLine;

/**
 * ...
 * @author Matse
 */
class ValEditorTimeLine extends ValEditTimeLine 
{
	static private var _POOL:Array<ValEditorTimeLine> = new Array<ValEditorTimeLine>();
	
	static public function fromPool(numFrames:Int):ValEditorTimeLine
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(numFrames);
		return new ValEditorTimeLine(numFrames);
	}
	
	public var frameCollection(default, null):ArrayCollection<ValEditFrame> = new ArrayCollection<ValEditFrame>();
	public var numFrames(get, set):Int;
	
	private var _numFrames:Int = 0;
	private function get_numFrames():Int { return this._numFrames; }
	private function set_numFrames(value:Int):Int
	{
		if (this._numFrames == value) return value;
		if (value < this._numFrames)
		{
			for (i in value...this._numFrames)
			{
				this._frames[i].pool();
				this.frameCollection.removeAt(i);
			}
			this._frames.resize(value);
		}
		else
		{
			var frame:ValEditFrame;
			for (i in this._numFrames...value)
			{
				frame = ValEditFrame.fromPool();
				this._frames[i] = frame;
				this.frameCollection.add(frame);
			}
		}
		return this._numFrames = value;
	}

	public function new(numFrames:Int) 
	{
		super();
		this.numFrames = numFrames;
	}
	
	override public function clear():Void 
	{
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function addFrame():Void 
	{
		super.addFrame();
		
		var frame:ValEditFrame = ValEditFrame.fromPool();
		this._frames[this._frames.length] = frame;
		this.frameCollection.add(frame);
	}
	
	override public function removeFrameAt(index:Int, pool:Bool):Void 
	{
		super.removeFrameAt(index, pool);
		
		if (this._frames[index].isKeyFrame)
		{
			
		}
		else
		{
			if (pool) this._frames[index].pool();
			this._frames.splice(index, 1);
			this.frameCollection.removeAt(index);
		}
	}
	
	private function setTo(numFrames:Int):ValEditorTimeLine
	{
		this.numFrames = numFrames;
		return this;
	}
	
}
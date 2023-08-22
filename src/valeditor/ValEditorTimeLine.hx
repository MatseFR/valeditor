package valeditor;

import feathers.data.ArrayCollection;
import openfl.events.Event;
import valedit.ValEditKeyFrame;
import valedit.ValEditTimeLine;
import valeditor.events.TimeLineEvent;
import valeditor.ui.feathers.data.FrameData;
import valedit.utils.ReverseIterator;

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
	
	public var frameCollection(default, null):ArrayCollection<FrameData>;
	public var lastKeyFrame(get, never):ValEditorKeyFrame;
	public var nextKeyFrame(get, never):ValEditorKeyFrame;
	public var numFrames(get, set):Int;
	public var previousKeyFrame(get, never):ValEditorKeyFrame;
	
	override function set_frameIndex(value:Int):Int 
	{
		if (this._frameIndex == value) return value;
		super.set_frameIndex(value);
		TimeLineEvent.dispatch(this, TimeLineEvent.FRAME_INDEX_CHANGE);
		return this._frameIndex;
	}
	
	private function get_lastKeyFrame():ValEditorKeyFrame
	{
		for (i in new ReverseIterator(this._numFrames - 1, 0))
		{
			if (this._frames[i] != null) return cast this._frames[i];
		}
		return null;
	}
	
	private function get_nextKeyFrame():ValEditorKeyFrame
	{
		for (i in this._frameIndex + 1...this._numFrames)
		{
			if (this._frames[i] != null && this._frames[i] != this._frameCurrent)
			{
				return cast this._frames[i];
			}
		}
		return null;
	}
	
	private function get_numFrames():Int { return this._numFrames; }
	private function set_numFrames(value:Int):Int
	{
		if (this._numFrames == value) return value;
		if (value < this._numFrames)
		{
			for (i in value...this._numFrames)
			{
				if (this._frames[i] != null)
				{
					if (this._frames[i].indexStart == i)
					{
						this._frames[i].pool();
					}
					else
					{
						this._frames[i].indexEnd--;
					}
				}
				this._frameDatas[i].pool();
			}
			this._frames.resize(value);
			this._frameDatas.resize(value);
			if (this.frameCollection != null) this.frameCollection.updateAll();
		}
		else
		{
			for (i in this._numFrames...value)
			{
				this._frames[i] = null;
				this._frameDatas[i] = FrameData.fromPool();
			}
			if (this.frameCollection != null) this.frameCollection.updateAll();
		}
		return this._numFrames = value;
	}
	
	private function get_previousKeyFrame():ValEditorKeyFrame
	{
		for (i in new ReverseIterator(this._frameIndex, 0))
		{
			if (this._frames[i] != this._frameCurrent && Std.isOfType(this._frames[i], ValEditorKeyFrame))
			{
				return cast this._frames[i];
			}
		}
		return null;
	}
	
	private var _frameDatas:Array<FrameData> = new Array<FrameData>();

	public function new(numFrames:Int) 
	{
		super();
		this.numFrames = numFrames;
		this.frameCollection = new ArrayCollection(this._frameDatas);
	}
	
	override public function clear():Void 
	{
		this.frameCollection.removeAll();
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function play():Void 
	{
		if (this._isPlaying) return;
		
		var lastFrame:ValEditKeyFrame = null;
		for (frame in this._frames)
		{
			if (frame != lastFrame)
			{
				cast(frame, ValEditorKeyFrame).isPlaying = true;
				lastFrame = frame;
			}
		}
		updateLastFrameIndex();
		super.play();
	}
	
	override public function stop():Void 
	{
		if (!this._isPlaying) return;
		
		var lastFrame:ValEditKeyFrame = null;
		for (frame in this._frames)
		{
			if (frame != lastFrame)
			{
				cast(frame, ValEditorKeyFrame).isPlaying = false;
				lastFrame = frame;
			}
		}
		super.stop();
	}
	
	override public function registerKeyFrame(keyFrame:ValEditKeyFrame):Void 
	{
		super.registerKeyFrame(keyFrame);
		keyFrame.addEventListener(Event.CHANGE, onKeyFrameChange);
	}
	
	private function onKeyFrameChange(evt:Event):Void
	{
		var keyFrame:ValEditorKeyFrame = cast evt.target;
		for (i in keyFrame.indexStart...keyFrame.indexEnd + 1)
		{
			this.frameCollection.updateAt(i);
		}
	}
	
	public function unregisterKeyFrame(keyFrame:ValEditKeyFrame):Void
	{
		keyFrame.removeEventListener(Event.CHANGE, onKeyFrameChange);
	}
	
	public function insertFrame():Void 
	{
		if (this._frameCurrent != null)
		{
			if (this._frameCurrent.indexEnd == this._numFrames)
			{
				this.numFrames++;
			}
			this._frameCurrent.indexEnd++;
			
			var lastFrame:ValEditKeyFrame = this.lastKeyFrame;
			while (lastFrame != null && lastFrame != this._frameCurrent)
			{
				lastFrame.indexStart++;
				lastFrame.indexEnd++;
				this._frames[lastFrame.indexEnd] = lastFrame;
				this._frameDatas[lastFrame.indexEnd].frame = cast lastFrame;
				lastFrame = getPreviousKeyFrame(lastFrame);
			}
			this._frames[this._frameCurrent.indexEnd] = this._frameCurrent;
			this._frameDatas[this._frameCurrent.indexEnd].frame = cast this._frameCurrent;
		}
		else
		{
			var keyFrame:ValEditKeyFrame = getPreviousKeyFrameFromIndex(this._frameIndex);
			if (keyFrame == null)
			{
				keyFrame = ValEditorKeyFrame.fromPool();
				registerKeyFrame(keyFrame);
				keyFrame.indexStart = 0;
				keyFrame.indexEnd = this._frameIndex - 1;
				for (i in 0...this._frameIndex)
				{
					this._frames[i] = keyFrame;
					this._frameDatas[i].frame = cast keyFrame;
				}
			}
			else
			{
				for (i in keyFrame.indexEnd...this._frameIndex)
				{
					this._frames[i] = keyFrame;
					this._frameDatas[i].frame = cast keyFrame;
				}
				keyFrame.indexEnd = this._frameIndex - 1;
			}
		}
		this.frameCollection.updateAll();
	}
	
	public function insertKeyFrame():Void 
	{
		var keyFrame:ValEditorKeyFrame;
		if (this._frameCurrent != null)
		{
			if (this._frameCurrent.indexStart == this._frameIndex)
			{
				if (this._frameCurrent.indexEnd == this._frameIndex)
				{
					if (this._frameIndex == this._numFrames)
					{
						this.numFrames++;
					}
					
					if (getNextKeyFrame(this._frameCurrent) == null)
					{
						keyFrame = ValEditorKeyFrame.fromPool();
						registerKeyFrame(keyFrame);
						keyFrame.indexStart = keyFrame.indexEnd = this._frameIndex + 1;
						keyFrame.copyObjectsFrom(this._frameCurrent);
						this._frames[this._frameIndex + 1] = keyFrame;
						this._frameDatas[this._frameIndex + 1].frame = keyFrame;
					}
				}
				else
				{
					keyFrame = ValEditorKeyFrame.fromPool();
					registerKeyFrame(keyFrame);
					keyFrame.indexStart = this._frameIndex + 1;
					keyFrame.indexEnd = this._frameCurrent.indexEnd;
					keyFrame.copyObjectsFrom(this._frameCurrent);
					this._frameCurrent.indexEnd = this._frameIndex;
					for (i in this._frameIndex + 1...keyFrame.indexEnd + 1)
					{
						this._frames[i] = keyFrame;
						this._frameDatas[i].frame = keyFrame;
					}
				}
				this._parent.frameIndex++;
			}
			else
			{
				keyFrame = ValEditorKeyFrame.fromPool();
				registerKeyFrame(keyFrame);
				keyFrame.indexStart = this._frameIndex;
				keyFrame.indexEnd = this._frameCurrent.indexEnd;
				keyFrame.copyObjectsFrom(this._frameCurrent);
				this._frameCurrent.indexEnd = this._frameIndex - 1;
				for (i in this._frameIndex...keyFrame.indexEnd + 1)
				{
					this._frames[i] = keyFrame;
					this._frameDatas[i].frame = keyFrame;
				}
				setFrameCurrent(keyFrame);
			}
		}
		else
		{
			// empty frame
			var prevFrame:ValEditKeyFrame = null;
			if (this._frameIndex != 0)
			{
				prevFrame = getPreviousKeyFrameFromIndex(this._frameIndex);
				if (prevFrame == null)
				{
					keyFrame = ValEditorKeyFrame.fromPool();
					registerKeyFrame(keyFrame);
					keyFrame.indexStart = 0;
					keyFrame.indexEnd = this._frameIndex - 1;
					for (i in 0...this._frameIndex)
					{
						this._frames[i] = keyFrame;
						this._frameDatas[i].frame = keyFrame;
					}
				}
				else
				{
					for (i in prevFrame.indexEnd + 1...this._frameIndex)
					{
						this._frames[i] = prevFrame;
						this._frameDatas[i].frame = cast prevFrame;
					}
					prevFrame.indexEnd = this._frameIndex - 1;
				}
			}
			keyFrame = ValEditorKeyFrame.fromPool();
			registerKeyFrame(keyFrame);
			keyFrame.indexStart = keyFrame.indexEnd = this._frameIndex;
			if (prevFrame != null)
			{
				keyFrame.copyObjectsFrom(prevFrame);
			}
			this._frames[this._frameIndex] = keyFrame;
			this._frameDatas[this._frameIndex] = FrameData.fromPool(keyFrame);
			setFrameCurrent(keyFrame);
		}
		this.frameCollection.updateAll();
	}
	
	public function removeFrame():Void
	{
		if (this._frameCurrent != null)
		{
			var keyFrame:ValEditKeyFrame;
			if (this._frameCurrent.indexStart == this._frameCurrent.indexEnd)
			{
				// remove key frame
				keyFrame = getNextKeyFrame(this._frameCurrent);
				while (keyFrame != null)
				{
					keyFrame.indexStart--;
					this._frames[keyFrame.indexStart] = keyFrame;
					this._frameDatas[keyFrame.indexStart].frame = cast keyFrame;
					this._frames[keyFrame.indexEnd] = null;
					this._frameDatas[keyFrame.indexEnd].frame = null;
					keyFrame.indexEnd--;
					keyFrame = getNextKeyFrame(keyFrame);
				}
				
				unregisterKeyFrame(this._frameCurrent);
				this._frameCurrent.pool();
				setFrameCurrent(this._frames[this._frameIndex]);
			}
			else
			{
				// remove frame
				this._frames[this._frameCurrent.indexEnd] = null;
				this._frameDatas[this._frameCurrent.indexEnd].frame = null;
				this._frameCurrent.indexEnd--;
				keyFrame = getNextKeyFrame(this._frameCurrent);
				while (keyFrame != null)
				{
					keyFrame.indexStart--;
					this._frames[keyFrame.indexStart] = keyFrame;
					this._frameDatas[keyFrame.indexStart].frame = cast keyFrame;
					this._frames[keyFrame.indexEnd] = null;
					this._frameDatas[keyFrame.indexEnd].frame = null;
					keyFrame.indexEnd--;
					keyFrame = getNextKeyFrame(keyFrame);
				}
				setFrameCurrent(this._frames[this._frameIndex]);
			}
			this.frameCollection.updateAll();
		}
	}
	
	/* Doesn't remove frames, doesn't remove the last key frame (use removeFrame for that). 
	 * This only works when a key frame is selected and there is another key frame in the timeline, otherwise it does nothing */
	public function removeKeyFrame():Void
	{
		if (this._frameCurrent != null)
		{
			if (this._frameCurrent.indexStart == this._frameIndex)
			{
				var keyFrame:ValEditKeyFrame;
				// look for previous key frame
				keyFrame = getPreviousKeyFrame(this._frameCurrent);
				if (keyFrame != null)
				{
					for (i in keyFrame.indexEnd + 1...this._frameCurrent.indexEnd + 1)
					{
						this._frames[i] = keyFrame;
						this._frameDatas[i].frame = cast keyFrame;
					}
					keyFrame.indexEnd = this._frameCurrent.indexEnd;
					unregisterKeyFrame(this._frameCurrent);
					this._frameCurrent.pool();
					setFrameCurrent(keyFrame);
				}
				else
				{
					// look for next keyFrame
					keyFrame = getNextKeyFrame(this._frameCurrent);
					if (keyFrame != null)
					{
						for (i in this._frameCurrent.indexStart...keyFrame.indexStart)
						{
							this._frames[i] = keyFrame;
							this._frameDatas[i].frame = cast keyFrame;
						}
						keyFrame.indexStart = this._frameCurrent.indexStart;
						unregisterKeyFrame(this._frameCurrent);
						this._frameCurrent.pool();
						setFrameCurrent(keyFrame);
					}
				}
				this.frameCollection.updateAll();
			}
		}
	}
	
	private function setTo(numFrames:Int):ValEditorTimeLine
	{
		this.numFrames = numFrames;
		return this;
	}
	
}
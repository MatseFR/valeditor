package valeditor;

import feathers.data.ArrayCollection;
import juggler.animation.IAnimatable;
import juggler.animation.Juggler;
import openfl.events.EventDispatcher;
import valedit.ExposedCollection;
import valedit.events.PlayEvent;
import valedit.utils.ReverseIterator;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.keyframe.KeyFrameCopyObjectsFrom;
import valeditor.editor.action.keyframe.KeyFrameCreate;
import valeditor.editor.action.keyframe.KeyFrameDestroy;
import valeditor.editor.action.timeline.TimeLineFrameUpdateAll;
import valeditor.editor.action.timeline.TimeLineRegisterKeyFrame;
import valeditor.editor.action.timeline.TimeLineSetFrame;
import valeditor.editor.action.timeline.TimeLineSetFrameCurrent;
import valeditor.editor.action.timeline.TimeLineSetFrameIndex;
import valeditor.editor.action.timeline.TimeLineSetNumFrames;
import valeditor.editor.action.timeline.TimeLineUnregisterKeyFrame;
import valeditor.editor.action.timeline.TimeLineUpdateLastFrameIndex;
import valeditor.events.KeyFrameEvent;
import valeditor.events.TimeLineActionEvent;
import valeditor.events.TimeLineEvent;
import valeditor.ui.feathers.data.FrameData;

/**
 * ...
 * @author Matse
 */
class ValEditorTimeLine extends EventDispatcher implements IAnimatable
{
	static private var _POOL:Array<ValEditorTimeLine> = new Array<ValEditorTimeLine>();
	
	static public function fromPool(numFrames:Int):ValEditorTimeLine
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(numFrames);
		return new ValEditorTimeLine(numFrames);
	}
	
	public var activateFunction(get, set):ValEditorObject->Void;
	public var autoIncreaseNumFrames:Bool = true;
	public var children(get, never):Array<ValEditorTimeLine>;
	public var deactivateFunction(get, set):ValEditorObject->Void;
	public var frameCollection(default, null):ArrayCollection<FrameData>;
	public var frameCurrent(get, never):ValEditorKeyFrame;
	public var frameIndex(get, set):Int;
	public var frameRate(get, set):Float;
	public var frames(get, never):Array<ValEditorKeyFrame>;
	public var frameTime(get, never):Float;
	public var isPlaying(get, never):Bool;
	public var isReverse(get, never):Bool;
	public var juggler(get, set):Juggler;
	public var keyFrames(get, never):Array<ValEditorKeyFrame>;
	public var lastFrameIndex(get, never):Int;
	public var lastKeyFrame(get, never):ValEditorKeyFrame;
	public var loop(get, set):Bool;
	public var nextKeyFrame(get, never):ValEditorKeyFrame;
	public var numFrames(get, set):Int;
	public var numKeyFrames(get, never):Int;
	/** 0 = infinite */
	public var numLoops(get, set):Int;
	public var parent(get, set):ValEditorTimeLine;
	public var previousKeyFrame(get, never):ValEditorKeyFrame;
	public var reverse(get, set):Bool;
	public var slaves(get, never):Array<ValEditorTimeLine>;
	public var selectedFrameIndex(get, set):Int;
	
	private var _activateFunction:ValEditorObject->Void;
	private function get_activateFunction():ValEditorObject->Void { return this._activateFunction; }
	private function set_activateFunction(value:ValEditorObject->Void):ValEditorObject->Void
	{
		for (keyFrame in this._keyFrames)
		{
			keyFrame.activateFunction = value;
		}
		return this._activateFunction = value;
	}
	
	private var _children:Array<ValEditorTimeLine> = new Array<ValEditorTimeLine>();
	private function get_children():Array<ValEditorTimeLine> { return this._children; }
	
	private var _deactivateFunction:ValEditorObject->Void;
	private function get_deactivateFunction():ValEditorObject->Void { return this._deactivateFunction; }
	private function set_deactivateFunction(value:ValEditorObject->Void):ValEditorObject->Void
	{
		for (keyFrame in this._keyFrames)
		{
			keyFrame.deactivateFunction = value;
		}
		return this._deactivateFunction = value;
	}
	
	private var _frameCurrent:ValEditorKeyFrame;
	private function get_frameCurrent():ValEditorKeyFrame { return this._frameCurrent; }
	
	private var _frameIndex:Int = -1;
	private function get_frameIndex():Int { return this._frameIndex; }
	private function set_frameIndex(value:Int):Int 
	{
		if (this._frameIndex == value) return value;
		
		if (value >= this._numFrames)
		{
			value = this._numFrames -1;
		}
		
		this._frameIndex = value;
		
		setFrameCurrent(this._frames[value]);
		
		for (slave in this._slaves)
		{
			slave.frameIndex = this._frameIndex;
		}
		
		if (!this._isPlaying && this._frameCurrent != null)
		{
			var diff:Float = (this._frameIndex - this._frameCurrent.indexStart) * this._frameTime;
			for (child in this._children)
			{
				child.setTime(diff);
			}
		}
		
		TimeLineEvent.dispatch(this, TimeLineEvent.FRAME_INDEX_CHANGE);
		return this._frameIndex;
	}
	
	private var _frameRate:Float;
	private function get_frameRate():Float { return this._frameRate; }
	private function set_frameRate(value:Float):Float
	{
		if (this._frameRate == value) return value;
		this._frameTime = 1.0 / value;
		for (slave in this._slaves)
		{
			slave.frameRate = value;
		}
		return this._frameRate = value;
	}
	
	private var _frameTime:Float;
	private function get_frameTime():Float { return this._frameTime; }
	
	private var _frames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	private function get_frames():Array<ValEditorKeyFrame> { return this._frames; }
	
	private var _isPlaying:Bool = false;
	private function get_isPlaying():Bool { return this._isPlaying; }
	
	private var _isReverse:Bool = false;
	private function get_isReverse():Bool { return this._isReverse; }
	
	private var _juggler:Juggler;
	private function get_juggler():Juggler { return this._juggler; }
	private function set_juggler(value:Juggler):Juggler
	{
		return this._juggler = value;
	}
	
	private var _keyFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	private function get_keyFrames():Array<ValEditorKeyFrame> { return this._keyFrames; }
	
	private var _lastFrameIndex:Int;
	private function get_lastFrameIndex():Int { return this._lastFrameIndex; }
	
	private function get_lastKeyFrame():ValEditorKeyFrame
	{
		for (i in new ReverseIterator(this._numFrames - 1, 0))
		{
			if (this._frames[i] != null) return this._frames[i];
		}
		return null;
	}
	
	private var _loop:Bool = false;
	private function get_loop():Bool { return this._loop; }
	private function set_loop(value:Bool):Bool
	{
		for (slave in this._slaves)
		{
			slave.loop = value;
		}
		return this._loop = value;
	}
	
	private function get_nextKeyFrame():ValEditorKeyFrame
	{
		for (i in this._frameIndex + 1...this._numFrames)
		{
			if (this._frames[i] != null && this._frames[i] != this._frameCurrent)
			{
				return this._frames[i];
			}
		}
		return null;
	}
	
	private var _numFrames:Int = 0;
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
						unregisterKeyFrame(this._frames[i]);
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
		
		// set numFrames on slaves too
		for (slave in this._slaves)
		{
			slave.numFrames = value;
		}
		
		TimeLineEvent.dispatch(this, TimeLineEvent.NUM_FRAMES_CHANGE);
		
		return this._numFrames = value;
	}
	
	private function get_numKeyFrames():Int { return this._keyFrames.length; }
	
	private var _numLoops:Int = 0;
	private function get_numLoops():Int { return this._numLoops; }
	private function set_numLoops(value:Int):Int
	{
		for (slave in this._slaves)
		{
			slave.numLoops = value;
		}
		return this._numLoops = value;
	}
	
	private var _parent:ValEditorTimeLine;
	private function get_parent():ValEditorTimeLine { return this._parent; }
	private function set_parent(value:ValEditorTimeLine):ValEditorTimeLine
	{
		return this._parent = value;
	}
	
	private function get_previousKeyFrame():ValEditorKeyFrame
	{
		for (i in new ReverseIterator(this._frameIndex, 0))
		{
			if (this._frames[i] != this._frameCurrent)// && Std.isOfType(this._frames[i], ValEditorKeyFrame))
			{
				return this._frames[i];
			}
		}
		return null;
	}
	
	private var _reverse:Bool = false;
	private function get_reverse():Bool { return this._reverse; }
	private function set_reverse(value:Bool):Bool
	{
		for (slave in this._slaves)
		{
			slave.reverse = value;
		}
		return this._reverse = value;
	}
	
	private var _selectedFrameIndex:Int = -1;
	private function get_selectedFrameIndex():Int { return this._selectedFrameIndex; }
	private function set_selectedFrameIndex(value:Int):Int
	{
		if (this._selectedFrameIndex == value) return value;
		
		this._selectedFrameIndex = value;
		TimeLineEvent.dispatch(this, TimeLineEvent.SELECTED_FRAME_INDEX_CHANGE);
		return this._selectedFrameIndex;
	}
	
	private var _slaves:Array<ValEditorTimeLine> = new Array<ValEditorTimeLine>();
	private function get_slaves():Array<ValEditorTimeLine> { return this._slaves; }
	
	private var _playTime:Float = 0;
	private var _loopCount:Int;
	private var _frameDatas:Array<FrameData> = new Array<FrameData>();
	
	private var _tempObjectMap:Map<ValEditorObject, ValEditorObject> = new Map<ValEditorObject, ValEditorObject>();

	public function new(numFrames:Int) 
	{
		super();
		this.frameRate = 60;
		this.numFrames = numFrames;
		this.frameCollection = new ArrayCollection(this._frameDatas);
		this._selectedFrameIndex = -1;
	}
	
	public function clear():Void 
	{
		if (this._isPlaying)
		{
			stop();
		}
		
		this.frameCollection.removeAll();
		for (keyFrame in this._keyFrames)
		{
			keyFrame.removeEventListener(KeyFrameEvent.STATE_CHANGE, onKeyFrameStateChange);
			keyFrame.removeEventListener(KeyFrameEvent.TRANSITION_CHANGE, onKeyFrameTransitionChange);
			keyFrame.removeEventListener(KeyFrameEvent.TWEEN_CHANGE, onKeyFrameTweenChange);
			keyFrame.pool();
		}
		this._keyFrames.resize(0);
		
		// WARNING : children are NOT pooled since the typical case is children time lines are owned by layers
		this._slaves.resize(0);
		
		this.activateFunction = null;
		this.deactivateFunction = null;
		this._frameCurrent = null;
		this._frameIndex = -1;
		this.frameRate = 60;
		this._frames.resize(0);
		this._juggler = null;
		this._loop = false;
		this._numFrames = 0;
		this._numLoops = 0;
		this._parent = null;
		this._reverse = false;
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function play():Void 
	{
		if (this._isPlaying) return;
		
		for (frame in this._keyFrames)
		{
			frame.isPlaying = true;
		}
		
		this._playTime = 0.0;
		this._loopCount = 0;
		this._isReverse = false;
		this._isPlaying = true;
		if (this._juggler != null) this._juggler.add(this);
		
		for (child in this._children)
		{
			child.play();
		}
		
		for (slave in this._slaves)
		{
			slave.play();
		}
		
		PlayEvent.dispatch(this, PlayEvent.PLAY);
	}
	
	public function stop():Void 
	{
		if (!this._isPlaying) return;
		
		for (frame in this._keyFrames)
		{
			frame.isPlaying = false;
		}
		
		this._isPlaying = false;
		if (this._juggler != null) this._juggler.remove(this);
		
		for (child in this._children)
		{
			child.stop();
		}
		
		for (slave in this._slaves)
		{
			slave.stop();
		}
		
		PlayEvent.dispatch(this, PlayEvent.STOP);
	}
	
	public function setTime(time:Float):Void
	{
		this.frameIndex = 0;
		this._playTime = 0.0;
		advanceTime(time);
	}
	
	public function advanceTime(time:Float):Void
	{
		for (child in this._children)
		{
			child.advanceTime(time);
		}
		
		for (slave in this._slaves)
		{
			slave.advanceTimeForChildren(time);
		}
		
		this._playTime += time;
		while (this._playTime >= this._frameTime)
		{
			playProgress();
			this._playTime -= this._frameTime;
		}
	}
	
	public function advanceTimeForChildren(time:Float):Void
	{
		for (child in this._children)
		{
			child.advanceTime(time);
		}
	}
	
	private function playProgress():Void
	{
		if (this._isReverse)
		{
			if (this._frameIndex != 0)
			{
				this.frameIndex--;
			}
			else
			{
				if (this._loop && (this._numLoops == 0 || (this._loopCount < this._numLoops)))
				{
					this._loopCount++;
					this._isReverse = false;
					if (this._lastFrameIndex != 0)
					{
						this.frameIndex++;
					}
				}
				else
				{
					stop();
				}
			}
		}
		else
		{
			if (this._frameIndex != this._lastFrameIndex)
			{
				this.frameIndex++;
			}
			else
			{
				if (this._loop && (this._numLoops == 0 || (this._loopCount < this._numLoops)))
				{
					this._loopCount++;
					if (this._reverse)
					{
						this._isReverse = true;
						if (this._frameIndex != 0)
						{
							this.frameIndex--;
						}
					}
					else
					{
						this.frameIndex = 0;
					}
				}
				else
				{
					stop();
				}
			}
		}
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		this._frameCurrent.add(object);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		this._frameCurrent.remove(object);
	}
	
	public function addKeyFrame(keyFrame:ValEditorKeyFrame):Void 
	{
		registerKeyFrame(keyFrame);
		
		for (i in keyFrame.indexStart...keyFrame.indexEnd + 1)
		{
			this._frames[i] = keyFrame;
			this._frameDatas[i].frame = keyFrame;
		}
		
		if (this._frameIndex >= keyFrame.indexStart && this._frameIndex <= keyFrame.indexEnd)
		{
			setFrameCurrent(keyFrame);
		}
	}
	
	public function getKeyFrameAt(index:Int):ValEditorKeyFrame
	{
		return this._frames[index];
	}
	
	public function registerKeyFrame(keyFrame:ValEditorKeyFrame):Void 
	{
		keyFrame.timeLine = this;
		keyFrame.activateFunction = this.activateFunction;
		keyFrame.deactivateFunction = this.deactivateFunction;
		
		var pos:Int = -1;
		var count:Int = this.keyFrames.length;
		for (i in 0...count)
		{
			if (this._keyFrames[i].indexStart > keyFrame.indexStart)
			{
				pos = i;
				break;
			}
		}
		
		if (pos == -1)
		{
			this._keyFrames[count] = keyFrame;
		}
		else
		{
			this._keyFrames.insert(pos, keyFrame);
		}
		
		keyFrame.addEventListener(KeyFrameEvent.OBJECT_ADDED, onKeyFrameObjectAdded);
		keyFrame.addEventListener(KeyFrameEvent.OBJECT_REMOVED, onKeyFrameObjectRemoved);
		keyFrame.addEventListener(KeyFrameEvent.STATE_CHANGE, onKeyFrameStateChange);
		keyFrame.addEventListener(KeyFrameEvent.TRANSITION_CHANGE, onKeyFrameTransitionChange);
		keyFrame.addEventListener(KeyFrameEvent.TWEEN_CHANGE, onKeyFrameTweenChange);
	}
	
	public function unregisterKeyFrame(keyFrame:ValEditorKeyFrame):Void
	{
		this._keyFrames.remove(keyFrame);
		
		keyFrame.removeEventListener(KeyFrameEvent.OBJECT_ADDED, onKeyFrameObjectAdded);
		keyFrame.removeEventListener(KeyFrameEvent.OBJECT_REMOVED, onKeyFrameObjectRemoved);
		keyFrame.removeEventListener(KeyFrameEvent.STATE_CHANGE, onKeyFrameStateChange);
		keyFrame.removeEventListener(KeyFrameEvent.TRANSITION_CHANGE, onKeyFrameTransitionChange);
		keyFrame.removeEventListener(KeyFrameEvent.TWEEN_CHANGE, onKeyFrameTweenChange);
	}
	
	private function setFrameCurrent(frame:ValEditorKeyFrame):Void
	{
		if (frame != this._frameCurrent)
		{
			if (this._frameCurrent != null)
			{
				this._frameCurrent.exit();
			}
			this._frameCurrent = frame;
			if (this._frameCurrent != null)
			{
				this._frameCurrent.enter();
			}
		}
		if (this._frameCurrent != null) this._frameCurrent.indexCurrent = this._frameIndex;
	}
	
	public function addChild(timeLine:ValEditorTimeLine):ValEditorTimeLine
	{
		addChildAt(timeLine, this._children.length);
		return timeLine;
	}
	
	public function addChildAt(timeLine:ValEditorTimeLine, index:Int):ValEditorTimeLine
	{
		this._children.insert(index, timeLine);
		return timeLine;
	}
	
	public function removeChild(timeLine:ValEditorTimeLine):ValEditorTimeLine
	{
		this._children.remove(timeLine);
		return timeLine;
	}
	
	public function removeChildAt(index:Int):ValEditorTimeLine
	{
		return this._children.splice(index, 1)[0];
	}
	
	public function addSlave(timeLine:ValEditorTimeLine):ValEditorTimeLine
	{
		addSlaveAt(timeLine, this._slaves.length);
		return timeLine;
	}
	
	public function addSlaveAt(timeLine:ValEditorTimeLine, index:Int):ValEditorTimeLine
	{
		this._slaves.insert(index, timeLine);
		timeLine.parent = this;
		timeLine.frameIndex = this._frameIndex;
		timeLine.frameRate = this._frameRate;
		timeLine.loop = this._loop;
		timeLine.numFrames = this.numFrames;
		timeLine.numLoops = this._numLoops;
		timeLine.reverse = this._reverse;
		if (timeLine.lastFrameIndex > this.lastFrameIndex)
		{
			this._lastFrameIndex = timeLine.lastFrameIndex;
		}
		return timeLine;
	}
	
	public function removeSlave(timeLine:ValEditorTimeLine):ValEditorTimeLine
	{
		var index:Int = this._slaves.indexOf(timeLine);
		return removeSlaveAt(index);
	}
	
	public function removeSlaveAt(index:Int):ValEditorTimeLine
	{
		var timeLine:ValEditorTimeLine = this._slaves[index];
		timeLine.parent = null;
		this._slaves.splice(index, 1);
		if (timeLine.lastFrameIndex == this.lastFrameIndex)
		{
			updateLastFrameIndex();
		}
		return timeLine;
	}
	
	public function updateLastFrameIndex():Void
	{
		this._lastFrameIndex = 0;
		if (this._frames.length != 0)
		{
			for (i in new ReverseIterator(this._frames.length - 1, 0))
			{
				if (this._frames[i] != null)
				{
					this._lastFrameIndex = i;
					break;
				}
			}
		}
		
		for (timeLine in this._slaves)
		{
			if (timeLine._lastFrameIndex > this._lastFrameIndex)
			{
				this._lastFrameIndex = timeLine._lastFrameIndex;
			}
		}
		
		if (this._parent != null)
		{
			this._parent.updateLastFrameIndex();
		}
	}
	
	public function getNextKeyFrame(frame:ValEditorKeyFrame):ValEditorKeyFrame
	{
		var keyFrameIndex:Int = this._keyFrames.indexOf(frame);
		if (keyFrameIndex != -1 && keyFrameIndex < this._keyFrames.length - 1)
		{
			return this._keyFrames[keyFrameIndex + 1];
		}
		return null;
	}
	
	public function getNextKeyFrameFromIndex(index:Int):ValEditorKeyFrame
	{
		var keyFrameIndex:Int = this._keyFrames.indexOf(this._frames[index]);
		if (keyFrameIndex != -1 && keyFrameIndex < this._keyFrames.length - 1)
		{
			return this._keyFrames[keyFrameIndex + 1];
		}
		return null;
	}
	
	public function getPreviousKeyFrame(frame:ValEditorKeyFrame):ValEditorKeyFrame
	{
		var keyFrameIndex:Int = this._keyFrames.indexOf(frame);
		if (keyFrameIndex > 0)
		{
			return this._keyFrames[keyFrameIndex - 1];
		}
		return null;
	}
	
	public function getPreviousKeyFrameFromIndex(index:Int):ValEditorKeyFrame
	{
		if (this._frames[index] == null)
		{
			return this._keyFrames[this._keyFrames.length - 1];
		}
		
		var keyFrameIndex:Int = this._keyFrames.indexOf(this._frames[index]);
		if (keyFrameIndex > 0)
		{
			return this._keyFrames[keyFrameIndex - 1];
		}
		return null;
	}
	
	private function onKeyFrameObjectAdded(evt:KeyFrameEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function onKeyFrameObjectRemoved(evt:KeyFrameEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function onKeyFrameStateChange(evt:KeyFrameEvent):Void
	{
		var keyFrame:ValEditorKeyFrame = evt.target;
		for (i in keyFrame.indexStart...keyFrame.indexEnd + 1)
		{
			this.frameCollection.updateAt(i);
		}
	}
	
	private function onKeyFrameTransitionChange(evt:KeyFrameEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function onKeyFrameTweenChange(evt:KeyFrameEvent):Void
	{
		dispatchEvent(evt);
	}
	
	public function insertFrame(?action:MultiAction):Void 
	{
		var timeLineSetNumFrames:TimeLineSetNumFrames;
		var timeLineSetFrame:TimeLineSetFrame;
		var keyFrameCreate:KeyFrameCreate;
		var timeLineRegisterKeyFrame:TimeLineRegisterKeyFrame;
		var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
		var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
		var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
		
		TimeLineActionEvent.dispatch(this, TimeLineActionEvent.INSERT_FRAME, action);
		
		if (this._frameCurrent != null)
		{
			if (this._lastFrameIndex == this._numFrames - 1)
			{
				if (this.autoIncreaseNumFrames)
				{
					if (action == null)
					{
						if (this._parent != null)
						{
							this._parent.numFrames++;
						}
						else
						{
							this.numFrames++;
						}
					}
					else
					{
						timeLineSetNumFrames = TimeLineSetNumFrames.fromPool();
						if (this._parent != null)
						{
							timeLineSetNumFrames.setup(this._parent, 1);
						}
						else
						{
							timeLineSetNumFrames.setup(this, 1);
						}
						action.add(timeLineSetNumFrames);
					}
				}
				else
				{
					return;
				}
			}
			
			var lastFrame:ValEditorKeyFrame = this.lastKeyFrame;
			if (action == null)
			{
				this._frameCurrent.indexEnd++;
				while (lastFrame != null && lastFrame != this._frameCurrent)
				{
					lastFrame.indexStart++;
					lastFrame.indexEnd++;
					this._frames[lastFrame.indexEnd] = lastFrame;
					this._frameDatas[lastFrame.indexEnd].frame = lastFrame;
				}
				this._frames[this._frameCurrent.indexEnd] = this._frameCurrent;
				this._frameDatas[this._frameCurrent.indexEnd].frame = this._frameCurrent;
			}
			else
			{
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, this._frameCurrent, this._frameCurrent.indexStart, this._frameCurrent.indexEnd + 1);
				action.add(timeLineSetFrame);
				
				while (lastFrame != null && lastFrame != this._frameCurrent)
				{
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, lastFrame, lastFrame.indexStart + 1, lastFrame.indexEnd + 1);
					action.add(timeLineSetFrame);
					lastFrame = getPreviousKeyFrame(lastFrame);
				}
			}
		}
		else
		{
			var keyFrame:ValEditorKeyFrame = getPreviousKeyFrameFromIndex(this._frameIndex);
			if (keyFrame == null)
			{
				keyFrame = ValEditor.createKeyFrame();
				
				if (action == null)
				{
					keyFrame.indexStart = 0;
					keyFrame.indexEnd = this._frameIndex - 1;
					for (i in 0...this._frameIndex)
					{
						this._frames[i] = keyFrame;
						this._frameDatas[i].frame = keyFrame;
					}
					
					registerKeyFrame(keyFrame);
				}
				else
				{
					keyFrameCreate = KeyFrameCreate.fromPool();
					keyFrameCreate.setup(keyFrame);
					action.add(keyFrameCreate);
					
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, keyFrame, 0, this._frameIndex - 1);
					action.add(timeLineSetFrame);
					
					timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
					timeLineRegisterKeyFrame.setup(this, keyFrame);
					action.add(timeLineRegisterKeyFrame);
				}
			}
			else
			{
				if (action == null)
				{
					for (i in keyFrame.indexEnd...this._frameIndex + 1)
					{
						this._frames[i] = keyFrame;
						this._frameDatas[i].frame = keyFrame;
					}
					keyFrame.indexEnd = this._frameIndex;
				}
				else
				{
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, keyFrame, keyFrame.indexStart, this._frameIndex);
					action.add(timeLineSetFrame);
				}
			}
			
			if (action == null)
			{
				setFrameCurrent(keyFrame);
			}
			else
			{
				timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
				timeLineSetFrameCurrent.setup(this, keyFrame);
				action.add(timeLineSetFrameCurrent);
			}
		}
		
		if (action == null)
		{
			this.frameCollection.updateAll();
			updateLastFrameIndex();
		}
		else
		{
			timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
			timeLineFrameUpdateAll.setup(this);
			action.addPost(timeLineFrameUpdateAll);
			
			timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
			timeLineUpdateLastFrameIndex.setup(this);
			action.addPost(timeLineUpdateLastFrameIndex);
		}
	}
	
	public function insertKeyFrame(?action:MultiAction):Void 
	{
		var keyFrame:ValEditorKeyFrame;
		var timeLineSetNumFrames:TimeLineSetNumFrames;
		var keyFrameCreate:KeyFrameCreate;
		var timeLineRegisterKeyFrame:TimeLineRegisterKeyFrame;
		var keyFrameCopyObjectsFrom:KeyFrameCopyObjectsFrom;
		var timeLineSetFrame:TimeLineSetFrame;
		var timeLineSetFrameIndex:TimeLineSetFrameIndex;
		var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
		var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
		var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
		
		var indexEnd:Int;
		
		TimeLineActionEvent.dispatch(this, TimeLineActionEvent.INSERT_KEYFRAME, action);
		
		if (this._frameCurrent != null)
		{
			if (this._frameCurrent.indexStart == this._frameIndex)
			{
				if (this._frameCurrent.indexEnd == this._frameIndex)
				{
					if (this._lastFrameIndex == this._numFrames - 1)
					{
						if (this.autoIncreaseNumFrames)
						{
							if (action == null)
							{
								if (this._parent != null)
								{
									this._parent.numFrames++;
								}
								else
								{
									this.numFrames++;
								}
							}
							else
							{
								timeLineSetNumFrames = TimeLineSetNumFrames.fromPool();
								if (this._parent != null)
								{
									timeLineSetNumFrames.setup(this._parent, 1);
								}
								else
								{
									timeLineSetNumFrames.setup(this, 1);
								}
								action.add(timeLineSetNumFrames);
							}
						}
						else
						{
							return;
						}
					}
					
					if (getNextKeyFrame(this._frameCurrent) == null)
					{
						keyFrame = ValEditor.createKeyFrame();
						if (action == null)
						{
							keyFrame.indexStart = keyFrame.indexEnd = this._frameIndex + 1;
							keyFrame.copyObjectsFrom(this._frameCurrent);
							this._frames[this._frameIndex + 1] = keyFrame;
							this._frameDatas[this._frameIndex + 1].frame = keyFrame;
							
							registerKeyFrame(keyFrame);
						}
						else
						{
							keyFrameCreate = KeyFrameCreate.fromPool();
							keyFrameCreate.setup(keyFrame);
							action.add(keyFrameCreate);
							
							timeLineSetFrame = TimeLineSetFrame.fromPool();
							timeLineSetFrame.setup(this, keyFrame, this._frameIndex + 1, this._frameIndex + 1);
							action.add(timeLineSetFrame);
							
							timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
							timeLineRegisterKeyFrame.setup(this, keyFrame);
							action.add(timeLineRegisterKeyFrame);
							
							keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
							keyFrameCopyObjectsFrom.setup(keyFrame, this._frameCurrent);
							action.add(keyFrameCopyObjectsFrom);
						}
					}
				}
				else
				{
					keyFrame = ValEditor.createKeyFrame();
					if (action == null)
					{
						keyFrame.indexStart = this._frameIndex + 1;
						keyFrame.indexEnd = this._frameCurrent.indexEnd;
						keyFrame.copyObjectsFrom(this._frameCurrent);
						this._frameCurrent.indexEnd = this._frameIndex;
						for (i in this._frameIndex + 1...keyFrame.indexEnd + 1)
						{
							this._frames[i] = keyFrame;
							this._frameDatas[i].frame = keyFrame;
						}
						
						registerKeyFrame(keyFrame);
					}
					else
					{
						keyFrameCreate = KeyFrameCreate.fromPool();
						keyFrameCreate.setup(keyFrame);
						action.add(keyFrameCreate);
						
						indexEnd = this._frameCurrent.indexEnd;
						
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, this._frameCurrent, this._frameCurrent.indexStart, this._frameIndex);
						action.add(timeLineSetFrame);
						
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, keyFrame, this._frameIndex + 1, indexEnd);
						action.add(timeLineSetFrame);
						
						timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
						timeLineRegisterKeyFrame.setup(this, keyFrame);
						action.add(timeLineRegisterKeyFrame);
						
						keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
						keyFrameCopyObjectsFrom.setup(keyFrame, this._frameCurrent);
						action.add(keyFrameCopyObjectsFrom);
					}
				}
				
				if (action == null)
				{
					this._parent.frameIndex++;
				}
				else
				{
					timeLineSetFrameIndex = TimeLineSetFrameIndex.fromPool();
					timeLineSetFrameIndex.setup(this._parent, this._parent.frameIndex + 1);
					action.add(timeLineSetFrameIndex);
				}
			}
			else
			{
				keyFrame = ValEditor.createKeyFrame();
				if (action == null)
				{
					//keyFrame.copyObjectsFrom(this._frameCurrent);
					
					keyFrame.indexStart = this._frameIndex;
					keyFrame.indexEnd = this._frameCurrent.indexEnd;
					this._frameCurrent.indexEnd = this._frameIndex - 1;
					for (i in this._frameIndex...keyFrame.indexEnd + 1)
					{
						this._frames[i] = keyFrame;
						this._frameDatas[i].frame = keyFrame;
					}
					
					registerKeyFrame(keyFrame);
					
					keyFrame.copyObjectsFrom(this._frameCurrent);
					
					setFrameCurrent(keyFrame);
				}
				else
				{
					keyFrameCreate = KeyFrameCreate.fromPool();
					keyFrameCreate.setup(keyFrame);
					action.add(keyFrameCreate);
					
					indexEnd = this._frameCurrent.indexEnd;
					
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, this._frameCurrent, this._frameCurrent.indexStart, this._frameIndex - 1);
					action.add(timeLineSetFrame);
					
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, keyFrame, this._frameIndex, indexEnd);
					action.add(timeLineSetFrame);
					
					timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
					timeLineRegisterKeyFrame.setup(this, keyFrame);
					action.add(timeLineRegisterKeyFrame);
					
					keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
					keyFrameCopyObjectsFrom.setup(keyFrame, this._frameCurrent);
					action.add(keyFrameCopyObjectsFrom);
					
					timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
					timeLineSetFrameCurrent.setup(this, keyFrame);
					action.addPost(timeLineSetFrameCurrent);
				}
			}
		}
		else
		{
			// empty frame
			var prevFrame:ValEditorKeyFrame = null;
			if (this._frameIndex != 0)
			{
				prevFrame = getPreviousKeyFrameFromIndex(this._frameIndex);
				if (prevFrame == null)
				{
					keyFrame = ValEditor.createKeyFrame();
					if (action == null)
					{
						keyFrame.indexStart = 0;
						keyFrame.indexEnd = this._frameIndex - 1;
						for (i in 0...this._frameIndex)
						{
							this._frames[i] = keyFrame;
							this._frameDatas[i].frame = keyFrame;
						}
						
						registerKeyFrame(keyFrame);
					}
					else
					{
						keyFrameCreate = KeyFrameCreate.fromPool();
						keyFrameCreate.setup(keyFrame);
						action.add(keyFrameCreate);
						
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, keyFrame, 0, this._frameIndex - 1);
						action.add(timeLineSetFrame);
						
						timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
						timeLineRegisterKeyFrame.setup(this, keyFrame);
						action.add(timeLineRegisterKeyFrame);
					}
				}
				else
				{
					if (action == null)
					{
						for (i in prevFrame.indexEnd + 1...this._frameIndex)
						{
							this._frames[i] = prevFrame;
							this._frameDatas[i].frame = prevFrame;
						}
						prevFrame.indexEnd = this._frameIndex - 1;
					}
					else
					{
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, prevFrame, prevFrame.indexStart, this._frameIndex - 1);
						action.add(timeLineSetFrame);
					}
				}
			}
			
			keyFrame = ValEditor.createKeyFrame();
			if (action == null)
			{
				keyFrame.indexStart = keyFrame.indexEnd = this._frameIndex;
				this._frames[this._frameIndex] = keyFrame;
				this._frameDatas[this._frameIndex].frame = keyFrame;
				
				if (prevFrame != null)
				{
					keyFrame.copyObjectsFrom(prevFrame);
				}
				
				registerKeyFrame(keyFrame);
				
				setFrameCurrent(keyFrame);
			}
			else
			{
				keyFrameCreate = KeyFrameCreate.fromPool();
				keyFrameCreate.setup(keyFrame);
				action.add(keyFrameCreate);
				
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, keyFrame, this._frameIndex, this._frameIndex);
				action.add(timeLineSetFrame);
				
				timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
				timeLineRegisterKeyFrame.setup(this, keyFrame);
				action.add(timeLineRegisterKeyFrame);
				
				if (prevFrame != null)
				{
					keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
					keyFrameCopyObjectsFrom.setup(keyFrame, prevFrame);
					action.add(keyFrameCopyObjectsFrom);
				}
				
				timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
				timeLineSetFrameCurrent.setup(this, keyFrame);
				action.addPost(timeLineSetFrameCurrent);
			}
		}
		
		if (action == null)
		{
			this.frameCollection.updateAll();
			
			updateLastFrameIndex();
		}
		else
		{
			timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
			timeLineFrameUpdateAll.setup(this);
			action.addPost(timeLineFrameUpdateAll);
			
			timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
			timeLineUpdateLastFrameIndex.setup(this);
			action.addPost(timeLineUpdateLastFrameIndex);
		}
	}
	
	public function removeFrame(?action:MultiAction):Void
	{
		if (this._frameCurrent != null)
		{
			var keyFrame:ValEditorKeyFrame;
			if (this._frameCurrent.indexStart == this._frameCurrent.indexEnd)
			{
				// remove key frame
				removeKeyFrame(action);
				return;
			}
			else
			{
				if (action == null)
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
						this._frameDatas[keyFrame.indexStart].frame = keyFrame;
						this._frames[keyFrame.indexEnd] = null;
						this._frameDatas[keyFrame.indexEnd].frame = null;
						keyFrame.indexEnd--;
						
						keyFrame = getNextKeyFrame(keyFrame);
					}
					
					setFrameCurrent(this._frames[this._frameIndex]);
					
					this.frameCollection.updateAll();
					
					updateLastFrameIndex();
				}
				else
				{
					var timeLineSetFrame:TimeLineSetFrame;
					var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
					var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
					var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
					
					// remove frame
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, this._frameCurrent, this._frameCurrent.indexStart, this._frameCurrent.indexEnd - 1);
					action.add(timeLineSetFrame);
					
					keyFrame = getNextKeyFrame(this._frameCurrent);
					while (keyFrame != null)
					{
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, keyFrame, keyFrame.indexStart - 1, keyFrame.indexEnd - 1);
						action.add(timeLineSetFrame);
						
						keyFrame = getNextKeyFrame(keyFrame);
					}
					
					timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
					timeLineSetFrameCurrent.setup(this, this._frames[this._frameIndex]);
					action.add(timeLineSetFrameCurrent);
					
					timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
					timeLineFrameUpdateAll.setup(this);
					action.addPost(timeLineFrameUpdateAll);
					
					timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
					timeLineUpdateLastFrameIndex.setup(this);
					action.addPost(timeLineUpdateLastFrameIndex);
				}
			}
			
			TimeLineActionEvent.dispatch(this, TimeLineActionEvent.REMOVE_FRAME, action);
		}
	}
	
	/* Doesn't remove frames, doesn't remove the last key frame (use removeFrame for that). 
	 * This only works when a key frame is selected and there is another key frame in the timeline, otherwise it does nothing */
	public function removeKeyFrame(?action:MultiAction):Void
	{
		if (this._frameCurrent != null)
		{
			if (this._frameCurrent.indexStart == this._frameIndex)
			{
				var keyFrame:ValEditorKeyFrame;
				if (action == null)
				{
					// look for previous key frame
					keyFrame = getPreviousKeyFrame(this._frameCurrent);
					if (keyFrame != null)
					{
						for (i in keyFrame.indexEnd + 1...this._frameCurrent.indexEnd + 1)
						{
							this._frames[i] = keyFrame;
							this._frameDatas[i].frame = keyFrame;
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
								this._frameDatas[i].frame = keyFrame;
							}
							keyFrame.indexStart = this._frameCurrent.indexStart;
							
							unregisterKeyFrame(this._frameCurrent);
							this._frameCurrent.pool();
							
							setFrameCurrent(keyFrame);
						}
					}
					
					this.frameCollection.updateAll();
					
					updateLastFrameIndex();
				}
				else
				{
					var timeLineSetFrame:TimeLineSetFrame;
					var timeLineUnregisterKeyFrame:TimeLineUnregisterKeyFrame;
					var keyFrameDestroy:KeyFrameDestroy;
					var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
					var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
					var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
					
					// look for previous key frame
					keyFrame = getPreviousKeyFrame(this._frameCurrent);
					if (keyFrame != null)
					{
						timeLineUnregisterKeyFrame = TimeLineUnregisterKeyFrame.fromPool();
						timeLineUnregisterKeyFrame.setup(this, this._frameCurrent);
						action.add(timeLineUnregisterKeyFrame);
						
						keyFrameDestroy = KeyFrameDestroy.fromPool();
						keyFrameDestroy.setup(this._frameCurrent);
						action.add(keyFrameDestroy);
						
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, keyFrame, keyFrame.indexStart, this._frameCurrent.indexEnd);
						action.add(timeLineSetFrame);
						
						timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
						timeLineSetFrameCurrent.setup(this, keyFrame);
						action.add(timeLineSetFrameCurrent);
					}
					else
					{
						// look for next keyFrame
						keyFrame = getNextKeyFrame(this._frameCurrent);
						if (keyFrame != null)
						{
							timeLineUnregisterKeyFrame = TimeLineUnregisterKeyFrame.fromPool();
							timeLineUnregisterKeyFrame.setup(this, this._frameCurrent);
							action.add(timeLineUnregisterKeyFrame);
							
							keyFrameDestroy = KeyFrameDestroy.fromPool();
							keyFrameDestroy.setup(this._frameCurrent);
							action.add(keyFrameDestroy);
							
							timeLineSetFrame = TimeLineSetFrame.fromPool();
							timeLineSetFrame.setup(this, keyFrame, this._frameCurrent.indexStart, keyFrame.indexEnd);
							action.add(timeLineSetFrame);
							
							timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
							timeLineSetFrameCurrent.setup(this, keyFrame);
							action.add(timeLineSetFrame);
						}
					}
					
					timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
					timeLineFrameUpdateAll.setup(this);
					action.addPost(timeLineFrameUpdateAll);
					
					timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
					timeLineUpdateLastFrameIndex.setup(this);
					action.addPost(timeLineUpdateLastFrameIndex);
				}
			}
			
			TimeLineActionEvent.dispatch(this, TimeLineActionEvent.REMOVE_KEYFRAME, action);
		}
	}
	
	public function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (objects == null) objects = new Array<ValEditorObject>();
		
		for (keyFrame in this._keyFrames)
		{
			for (object in keyFrame.objects)
			{
				if (objects.indexOf(object) == -1)
				{
					objects[objects.length] = object;
				}
			}
		}
		
		return objects;
	}
	
	public function getReusableObjectsWithTemplateForKeyFrame(template:ValEditorTemplate, keyFrame:ValEditorKeyFrame):Array<ValEditorObject>
	{
		var reusableObjects:Array<ValEditorObject> = new Array<ValEditorObject>();
		
		// take note of eligible objects in the specified frame so we can discard them
		for (object in keyFrame.objects)
		{
			if (object.template == template)
			{
				this._tempObjectMap.set(object, object);
			}
		}
		
		for (frame in this._keyFrames)
		{
			if (frame == keyFrame) continue;
			
			for (object in frame.objects)
			{
				if (object.template != template) continue;
				if (this._tempObjectMap.exists(object)) continue;
				
				reusableObjects[reusableObjects.length] = object;
				this._tempObjectMap.set(object, object);
			}
		}
		
		this._tempObjectMap.clear();
		
		return reusableObjects;
	}
	
	private function setTo(numFrames:Int):ValEditorTimeLine
	{
		this.numFrames = numFrames;
		return this;
	}
	
	public function cloneTo(timeLine:ValEditorTimeLine):Void
	{
		timeLine.frameRate = this.frameRate;
		timeLine.loop = this.loop;
		timeLine.numFrames = this.numFrames;
		timeLine.numLoops = this.numLoops;
		timeLine.reverse = this.reverse;
		
		var cloneFrame:ValEditorKeyFrame;
		for (keyFrame in this.keyFrames)
		{
			cloneFrame = ValEditorKeyFrame.fromPool();
			keyFrame.cloneTo(cloneFrame);
			timeLine.addKeyFrame(cloneFrame);
		}
		
		timeLine._lastFrameIndex = this._lastFrameIndex;
		
		var objects:Array<ValEditorObject> = getAllObjects();
		var cloneObject:ValEditorObject;
		var cloneObjectMap:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
		var collection:ExposedCollection;
		for (object in objects)
		{
			cloneObject = ValEditor.cloneObject(object);
			cloneObjectMap.set(cloneObject.objectID, cloneObject);
		}
		
		for (keyFrame in this.keyFrames)
		{
			cloneFrame = timeLine.getKeyFrameAt(keyFrame.indexStart);
			for (object in keyFrame.objects)
			{
				cloneObject = cloneObjectMap.get(object.objectID);
				collection = object.getCollectionForKeyFrame(keyFrame).clone(true);
				cloneFrame.add(cloneObject, collection);
			}
		}
		
		cloneObjectMap.clear();
		
		for (keyFrame in timeLine.keyFrames)
		{
			if (keyFrame.tween)
			{
				keyFrame.buildTweens();
			}
		}
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.frameRate = json.frameRate;
		this.loop = json.loop;
		this.numFrames = json.numFrames;
		this.numLoops = json.numLoops;
		this.reverse = json.reverse;
		
		var keyFrame:ValEditorKeyFrame;
		var frameList:Array<Dynamic> = json.keyFrames;
		for (node in frameList)
		{
			keyFrame = ValEditorKeyFrame.fromPool();
			keyFrame.fromJSONSave(node);
			addKeyFrame(keyFrame);
		}
		
		updateLastFrameIndex();
		
		for (keyFrame in this._keyFrames)
		{
			if (keyFrame.tween)
			{
				keyFrame.buildTweens();
			}
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.frameIndex = this._frameIndex;
		json.frameRate = this._frameRate;
		json.loop = this._loop;
		json.numFrames = this._numFrames;
		json.numLoops = this._numLoops;
		json.reverse = this._reverse;
		
		var frameList:Array<Dynamic> = [];
		for (keyFrame in this._keyFrames)
		{
			frameList.push(keyFrame.toJSONSave());
		}
		json.keyFrames = frameList;
		
		return json;
	}
	
}
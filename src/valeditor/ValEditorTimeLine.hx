package valeditor;

import feathers.data.ArrayCollection;
import openfl.events.Event;
import valedit.ValEditKeyFrame;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
import valedit.ValEditTimeLine;
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
	
	public var autoIncreaseNumFrames:Bool = true;
	public var frameCollection(default, null):ArrayCollection<FrameData>;
	public var lastKeyFrame(get, never):ValEditorKeyFrame;
	public var nextKeyFrame(get, never):ValEditorKeyFrame;
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
	
	override function set_numFrames(value:Int):Int
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
		
		// set numFrames on children too
		for (child in this._children)
		{
			child.numFrames = value;
		}
		
		TimeLineEvent.dispatch(this, TimeLineEvent.NUM_FRAMES_CHANGE);
		
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
	
	private var _tempObjectMap:Map<ValEditObject, ValEditObject> = new Map<ValEditObject, ValEditObject>();

	public function new(numFrames:Int) 
	{
		super();
		this.numFrames = numFrames;
		this.frameCollection = new ArrayCollection(this._frameDatas);
	}
	
	override public function clear():Void 
	{
		this.frameCollection.removeAll();
		for (keyFrame in this._keyFrames)
		{
			keyFrame.removeEventListener(Event.CHANGE, onKeyFrameChange);
		}
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
		
		for (frame in this._keyFrames)
		{
			cast(frame, ValEditorKeyFrame).isPlaying = true;
		}
		super.play();
	}
	
	override public function stop():Void 
	{
		if (!this._isPlaying) return;
		
		for (frame in this._keyFrames)
		{
			cast(frame, ValEditorKeyFrame).isPlaying = false;
		}
		super.stop();
	}
	
	override public function registerKeyFrame(keyFrame:ValEditKeyFrame):Void 
	{
		super.registerKeyFrame(keyFrame);
		keyFrame.addEventListener(Event.CHANGE, onKeyFrameChange);
	}
	
	override public function unregisterKeyFrame(keyFrame:ValEditKeyFrame):Void
	{
		super.unregisterKeyFrame(keyFrame);
		keyFrame.removeEventListener(Event.CHANGE, onKeyFrameChange);
	}
	
	private function onKeyFrameChange(evt:Event):Void
	{
		//if (this.frameCollection.length == 0) return;
		
		var keyFrame:ValEditorKeyFrame = cast evt.target;
		for (i in keyFrame.indexStart...keyFrame.indexEnd + 1)
		{
			this.frameCollection.updateAt(i);
		}
	}
	
	override public function addKeyFrame(keyFrame:ValEditKeyFrame):Void 
	{
		super.addKeyFrame(keyFrame);
		for (i in keyFrame.indexStart...keyFrame.indexEnd + 1)
		{
			this._frames[i] = keyFrame;
			this._frameDatas[i].frame = cast keyFrame;
		}
	}
	
	public function insertFrame(?action:MultiAction):Void 
	{
		var localAction:Bool = action == null;
		if (localAction)
		{
			action = MultiAction.fromPool();
		}
		var timeLineSetNumFrames:TimeLineSetNumFrames;
		var timeLineSetFrame:TimeLineSetFrame;
		var keyFrameCreate:KeyFrameCreate;
		var timeLineRegisterKeyFrame:TimeLineRegisterKeyFrame;
		var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
		var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
		var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
		
		if (this._frameCurrent != null)
		{
			if (this._lastFrameIndex == this._numFrames - 1)
			{
				if (this.autoIncreaseNumFrames)
				{
					timeLineSetNumFrames = TimeLineSetNumFrames.fromPool();
					if (this._parent != null)
					{
						//this._parent.numFrames++;
						timeLineSetNumFrames.setup(cast this._parent, 1);
					}
					else
					{
						//this.numFrames++;
						timeLineSetNumFrames.setup(this, 1);
					}
					action.add(timeLineSetNumFrames);
				}
				else
				{
					return;
				}
			}
			
			//this._frameCurrent.indexEnd++;
			timeLineSetFrame = TimeLineSetFrame.fromPool();
			timeLineSetFrame.setup(this, cast this._frameCurrent, this._frameCurrent.indexStart, this._frameCurrent.indexEnd + 1);
			action.add(timeLineSetFrame);
			
			var lastFrame:ValEditKeyFrame = this.lastKeyFrame;
			while (lastFrame != null && lastFrame != this._frameCurrent)
			{
				//lastFrame.indexStart++;
				//lastFrame.indexEnd++;
				//this._frames[lastFrame.indexEnd] = lastFrame;
				//this._frameDatas[lastFrame.indexEnd].frame = cast lastFrame;
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, cast lastFrame, lastFrame.indexStart + 1, lastFrame.indexEnd + 1);
				action.add(timeLineSetFrame);
				lastFrame = getPreviousKeyFrame(lastFrame);
			}
			//this._frames[this._frameCurrent.indexEnd] = this._frameCurrent;
			//this._frameDatas[this._frameCurrent.indexEnd].frame = cast this._frameCurrent;
		}
		else
		{
			var keyFrame:ValEditKeyFrame = getPreviousKeyFrameFromIndex(this._frameIndex);
			if (keyFrame == null)
			{
				keyFrame = ValEditor.createKeyFrame();
				keyFrameCreate = KeyFrameCreate.fromPool();
				keyFrameCreate.setup(cast keyFrame);
				action.add(keyFrameCreate);
				
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, cast keyFrame, 0, this._frameIndex - 1);
				action.add(timeLineSetFrame);
				//keyFrame.indexStart = 0;
				//keyFrame.indexEnd = this._frameIndex - 1;
				//for (i in 0...this._frameIndex)
				//{
					//this._frames[i] = keyFrame;
					//this._frameDatas[i].frame = cast keyFrame;
				//}
				
				//registerKeyFrame(keyFrame);
				timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
				timeLineRegisterKeyFrame.setup(this, cast keyFrame);
				action.add(timeLineRegisterKeyFrame);
			}
			else
			{
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, cast keyFrame, keyFrame.indexStart, this._frameIndex);
				action.add(timeLineSetFrame);
				//for (i in keyFrame.indexEnd...this._frameIndex + 1)
				//{
					//this._frames[i] = keyFrame;
					//this._frameDatas[i].frame = cast keyFrame;
				//}
				//keyFrame.indexEnd = this._frameIndex;
			}
			
			timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
			timeLineSetFrameCurrent.setup(this, cast keyFrame);
			action.add(timeLineSetFrameCurrent);
		}
		//this.frameCollection.updateAll();
		timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
		timeLineFrameUpdateAll.setup(this);
		action.addPost(timeLineFrameUpdateAll);
		
		//updateLastFrameIndex();
		timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
		timeLineUpdateLastFrameIndex.setup(this);
		action.addPost(timeLineUpdateLastFrameIndex);
		
		if (localAction)
		{
			ValEditor.actionStack.add(action);
		}
	}
	
	public function insertKeyFrame(?action:MultiAction):Void 
	{
		var localAction:Bool = action == null;
		if (localAction)
		{
			action = MultiAction.fromPool();
		}
		
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
							timeLineSetNumFrames = TimeLineSetNumFrames.fromPool();
							if (this._parent != null)
							{
								//this._parent.numFrames++;
								timeLineSetNumFrames.setup(cast this._parent, 1);
							}
							else
							{
								//this.numFrames++;
								timeLineSetNumFrames.setup(this, 1);
							}
							action.add(timeLineSetNumFrames);
						}
						else
						{
							action.pool();
							return;
						}
					}
					
					if (getNextKeyFrame(this._frameCurrent) == null)
					{
						keyFrame = ValEditor.createKeyFrame();
						keyFrameCreate = KeyFrameCreate.fromPool();
						keyFrameCreate.setup(keyFrame);
						action.add(keyFrameCreate);
						
						keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
						keyFrameCopyObjectsFrom.setup(keyFrame, cast this._frameCurrent);
						action.add(keyFrameCopyObjectsFrom);
						
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, keyFrame, this._frameIndex + 1, this._frameIndex + 1);
						action.add(timeLineSetFrame);
						
						//keyFrame.indexStart = keyFrame.indexEnd = this._frameIndex + 1;
						//keyFrame.copyObjectsFrom(this._frameCurrent);
						//this._frames[this._frameIndex + 1] = keyFrame;
						//this._frameDatas[this._frameIndex + 1].frame = keyFrame;
						
						//registerKeyFrame(keyFrame);
						timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
						timeLineRegisterKeyFrame.setup(this, keyFrame);
						action.add(timeLineRegisterKeyFrame);
					}
				}
				else
				{
					keyFrame = ValEditor.createKeyFrame();
					keyFrameCreate = KeyFrameCreate.fromPool();
					keyFrameCreate.setup(keyFrame);
					action.add(keyFrameCreate);
					
					keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
					keyFrameCopyObjectsFrom.setup(keyFrame, cast this._frameCurrent);
					action.add(keyFrameCopyObjectsFrom);
					
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, cast this._frameCurrent, this._frameCurrent.indexStart, this._frameIndex);
					action.add(timeLineSetFrame);
					
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, keyFrame, this._frameIndex + 1, this._frameCurrent.indexEnd);
					action.add(timeLineSetFrame);
					
					//registerKeyFrame(keyFrame);
					timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
					timeLineRegisterKeyFrame.setup(this, keyFrame);
					action.add(timeLineRegisterKeyFrame);
					
					//keyFrame.indexStart = this._frameIndex + 1;
					//keyFrame.indexEnd = this._frameCurrent.indexEnd;
					//keyFrame.copyObjectsFrom(this._frameCurrent);
					//this._frameCurrent.indexEnd = this._frameIndex;
					//for (i in this._frameIndex + 1...keyFrame.indexEnd + 1)
					//{
						//this._frames[i] = keyFrame;
						//this._frameDatas[i].frame = keyFrame;
					//}
				}
				timeLineSetFrameIndex = TimeLineSetFrameIndex.fromPool();
				timeLineSetFrameIndex.setup(cast this._parent, this._parent.frameIndex + 1);
				action.add(timeLineSetFrameIndex);
				//this._parent.frameIndex++;
			}
			else
			{
				keyFrame = ValEditor.createKeyFrame();
				keyFrameCreate = KeyFrameCreate.fromPool();
				keyFrameCreate.setup(keyFrame);
				action.add(keyFrameCreate);
				
				keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
				keyFrameCopyObjectsFrom.setup(keyFrame, cast this._frameCurrent);
				action.add(keyFrameCopyObjectsFrom);
				
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, cast this._frameCurrent, this._frameCurrent.indexStart, this._frameIndex - 1);
				action.add(timeLineSetFrame);
				
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, keyFrame, this._frameIndex, this._frameCurrent.indexEnd);
				action.add(timeLineSetFrame);
				
				//registerKeyFrame(keyFrame);
				timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
				timeLineRegisterKeyFrame.setup(this, keyFrame);
				action.add(timeLineRegisterKeyFrame);
				
				//keyFrame.indexStart = this._frameIndex;
				//keyFrame.indexEnd = this._frameCurrent.indexEnd;
				//keyFrame.copyObjectsFrom(this._frameCurrent);
				//this._frameCurrent.indexEnd = this._frameIndex - 1;
				//for (i in this._frameIndex...keyFrame.indexEnd + 1)
				//{
					//this._frames[i] = keyFrame;
					//this._frameDatas[i].frame = keyFrame;
				//}
				
				timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
				timeLineSetFrameCurrent.setup(this, keyFrame);
				action.add(timeLineSetFrameCurrent);
				//setFrameCurrent(keyFrame);
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
					keyFrame = ValEditor.createKeyFrame();
					keyFrameCreate = KeyFrameCreate.fromPool();
					keyFrameCreate.setup(keyFrame);
					action.add(keyFrameCreate);
					
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, keyFrame, 0, this._frameIndex - 1);
					action.add(timeLineSetFrame);
					
					//registerKeyFrame(keyFrame);
					timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
					timeLineRegisterKeyFrame.setup(this, keyFrame);
					action.add(timeLineRegisterKeyFrame);
					
					//keyFrame.indexStart = 0;
					//keyFrame.indexEnd = this._frameIndex - 1;
					//for (i in 0...this._frameIndex)
					//{
						//this._frames[i] = keyFrame;
						//this._frameDatas[i].frame = keyFrame;
					//}
				}
				else
				{
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, cast prevFrame, prevFrame.indexStart, this._frameIndex - 1);
					action.add(timeLineSetFrame);
					
					//for (i in prevFrame.indexEnd + 1...this._frameIndex)
					//{
						//this._frames[i] = prevFrame;
						//this._frameDatas[i].frame = cast prevFrame;
					//}
					//prevFrame.indexEnd = this._frameIndex - 1;
				}
			}
			keyFrame = ValEditor.createKeyFrame();
			keyFrameCreate = KeyFrameCreate.fromPool();
			keyFrameCreate.setup(keyFrame);
			action.add(keyFrameCreate);
			
			timeLineSetFrame = TimeLineSetFrame.fromPool();
			timeLineSetFrame.setup(this, keyFrame, this._frameIndex, this._frameIndex);
			action.add(timeLineSetFrame);
			
			//registerKeyFrame(keyFrame);
			timeLineRegisterKeyFrame = TimeLineRegisterKeyFrame.fromPool();
			timeLineRegisterKeyFrame.setup(this, keyFrame);
			action.add(timeLineRegisterKeyFrame);
			
			//keyFrame.indexStart = keyFrame.indexEnd = this._frameIndex;
			if (prevFrame != null)
			{
				//keyFrame.copyObjectsFrom(prevFrame);
				keyFrameCopyObjectsFrom = KeyFrameCopyObjectsFrom.fromPool();
				keyFrameCopyObjectsFrom.setup(keyFrame, cast prevFrame);
				action.add(keyFrameCopyObjectsFrom);
			}
			//this._frames[this._frameIndex] = keyFrame;
			//this._frameDatas[this._frameIndex] = FrameData.fromPool(keyFrame);
			
			//setFrameCurrent(keyFrame);
			timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
			timeLineSetFrameCurrent.setup(this, keyFrame);
			action.add(timeLineSetFrameCurrent);
		}
		//this.frameCollection.updateAll();
		timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
		timeLineFrameUpdateAll.setup(this);
		action.addPost(timeLineFrameUpdateAll);
		
		//updateLastFrameIndex();
		timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
		timeLineUpdateLastFrameIndex.setup(this);
		action.addPost(timeLineUpdateLastFrameIndex);
		
		if (localAction)
		{
			ValEditor.actionStack.add(action);
		}
	}
	
	public function removeFrame(?action:MultiAction):Void
	{
		if (this._frameCurrent != null)
		{
			var keyFrame:ValEditKeyFrame;
			if (this._frameCurrent.indexStart == this._frameCurrent.indexEnd)
			{
				// remove key frame
				removeKeyFrame(action);
				return;
			}
			else
			{
				var localAction:Bool = action == null;
				if (localAction)
				{
					action = MultiAction.fromPool();
				}
				var timeLineSetFrame:TimeLineSetFrame;
				var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
				var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
				var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
				
				// remove frame
				//this._frames[this._frameCurrent.indexEnd] = null;
				//this._frameDatas[this._frameCurrent.indexEnd].frame = null;
				//this._frameCurrent.indexEnd--;
				timeLineSetFrame = TimeLineSetFrame.fromPool();
				timeLineSetFrame.setup(this, cast this._frameCurrent, this._frameCurrent.indexStart, this._frameCurrent.indexEnd - 1);
				action.add(timeLineSetFrame);
				
				keyFrame = getNextKeyFrame(this._frameCurrent);
				while (keyFrame != null)
				{
					//keyFrame.indexStart--;
					//this._frames[keyFrame.indexStart] = keyFrame;
					//this._frameDatas[keyFrame.indexStart].frame = cast keyFrame;
					//this._frames[keyFrame.indexEnd] = null;
					//this._frameDatas[keyFrame.indexEnd].frame = null;
					//keyFrame.indexEnd--;
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, cast keyFrame, keyFrame.indexStart - 1, keyFrame.indexEnd - 1);
					action.add(timeLineSetFrame);
					
					keyFrame = getNextKeyFrame(keyFrame);
				}
				//setFrameCurrent(this._frames[this._frameIndex]);
				timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
				if (this._frameCurrent.indexEnd > this._frameIndex)
				{
					timeLineSetFrameCurrent.setup(this, cast this._frameCurrent);
				}
				else
				{
					timeLineSetFrameCurrent.setup(this, cast getNextKeyFrame(this._frameCurrent));
				}
				action.add(timeLineSetFrameCurrent);
				
				//this.frameCollection.updateAll();
				timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
				timeLineFrameUpdateAll.setup(this);
				action.addPost(timeLineFrameUpdateAll);
				
				//updateLastFrameIndex();
				timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
				timeLineUpdateLastFrameIndex.setup(this);
				action.addPost(timeLineUpdateLastFrameIndex);
				
				if (localAction)
				{
					ValEditor.actionStack.add(action);
				}
			}
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
				var localAction:Bool = action == null;
				if (localAction)
				{
					action = MultiAction.fromPool();
				}
				var timeLineSetFrame:TimeLineSetFrame;
				var timeLineUnregisterKeyFrame:TimeLineUnregisterKeyFrame;
				var keyFrameDestroy:KeyFrameDestroy;
				var timeLineSetFrameCurrent:TimeLineSetFrameCurrent;
				var timeLineFrameUpdateAll:TimeLineFrameUpdateAll;
				var timeLineUpdateLastFrameIndex:TimeLineUpdateLastFrameIndex;
				
				var keyFrame:ValEditKeyFrame;
				// look for previous key frame
				keyFrame = getPreviousKeyFrame(this._frameCurrent);
				if (keyFrame != null)
				{
					timeLineUnregisterKeyFrame = TimeLineUnregisterKeyFrame.fromPool();
					timeLineUnregisterKeyFrame.setup(this, cast this._frameCurrent);
					action.add(timeLineUnregisterKeyFrame);
					
					keyFrameDestroy = KeyFrameDestroy.fromPool();
					keyFrameDestroy.setup(cast this._frameCurrent);
					action.add(keyFrameDestroy);
					
					//for (i in keyFrame.indexEnd + 1...this._frameCurrent.indexEnd + 1)
					//{
						//this._frames[i] = keyFrame;
						//this._frameDatas[i].frame = cast keyFrame;
					//}
					//keyFrame.indexEnd = this._frameCurrent.indexEnd;
					timeLineSetFrame = TimeLineSetFrame.fromPool();
					timeLineSetFrame.setup(this, cast keyFrame, keyFrame.indexStart, this._frameCurrent.indexEnd);
					action.add(timeLineSetFrame);
					
					//unregisterKeyFrame(this._frameCurrent);
					//this._frameCurrent.pool();
					
					//setFrameCurrent(keyFrame);
					timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
					timeLineSetFrameCurrent.setup(this, cast keyFrame);
					action.add(timeLineSetFrameCurrent);
				}
				else
				{
					// look for next keyFrame
					keyFrame = getNextKeyFrame(this._frameCurrent);
					if (keyFrame != null)
					{
						timeLineUnregisterKeyFrame = TimeLineUnregisterKeyFrame.fromPool();
						timeLineUnregisterKeyFrame.setup(this, cast this._frameCurrent);
						action.add(timeLineUnregisterKeyFrame);
						
						keyFrameDestroy = KeyFrameDestroy.fromPool();
						keyFrameDestroy.setup(cast this._frameCurrent);
						action.add(keyFrameDestroy);
						
						//for (i in this._frameCurrent.indexStart...keyFrame.indexStart)
						//{
							//this._frames[i] = keyFrame;
							//this._frameDatas[i].frame = cast keyFrame;
						//}
						//keyFrame.indexStart = this._frameCurrent.indexStart;
						timeLineSetFrame = TimeLineSetFrame.fromPool();
						timeLineSetFrame.setup(this, cast keyFrame, this._frameCurrent.indexStart, keyFrame.indexEnd);
						action.add(timeLineSetFrame);
						
						//unregisterKeyFrame(this._frameCurrent);
						//this._frameCurrent.pool();
						
						//setFrameCurrent(keyFrame);
						timeLineSetFrameCurrent = TimeLineSetFrameCurrent.fromPool();
						timeLineSetFrameCurrent.setup(this, cast keyFrame);
						action.add(timeLineSetFrame);
					}
				}
				//this.frameCollection.updateAll();
				timeLineFrameUpdateAll = TimeLineFrameUpdateAll.fromPool();
				timeLineFrameUpdateAll.setup(this);
				action.addPost(timeLineFrameUpdateAll);
				
				//updateLastFrameIndex();
				timeLineUpdateLastFrameIndex = TimeLineUpdateLastFrameIndex.fromPool();
				timeLineUpdateLastFrameIndex.setup(this);
				action.addPost(timeLineUpdateLastFrameIndex);
				
				if (localAction)
				{
					ValEditor.actionStack.add(action);
				}
			}
		}
	}
	
	public function getReusableObjectsWithTemplateForKeyFrame(template:ValEditTemplate, keyFrame:ValEditKeyFrame):Array<ValEditObject>
	{
		var reusableObjects:Array<ValEditObject> = new Array<ValEditObject>();
		
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
			keyFrame.buildTweens();
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
			frameList.push(cast(keyFrame, ValEditorKeyFrame).toJSONSave());
		}
		json.keyFrames = frameList;
		
		return json;
	}
	
}
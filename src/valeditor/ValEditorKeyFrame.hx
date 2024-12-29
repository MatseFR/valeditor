package valeditor;

import feathers.data.ArrayCollection;
import juggler.animation.Transitions;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import valedit.ExposedCollection;
import valedit.animation.FrameTween;
import valedit.animation.TweenData;
import valeditor.editor.action.keyframe.KeyFrameCopyObjectsFrom;
import valeditor.editor.action.object.ObjectAddKeyFrame;
import valeditor.editor.action.object.ObjectCreate;
import valeditor.editor.change.IChangeUpdate;
import valeditor.events.KeyFrameEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorKeyFrame extends EventDispatcher implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	
	static public function fromPool():ValEditorKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorKeyFrame();
	}
	
	public var activateFunction:ValEditorObject->Void;
	public var deactivateFunction:ValEditorObject->Void;
	public var duration(get, never):Float;
	public var indexCurrent(get, set):Int;
	public var indexEnd:Int = -1;
	public var indexStart:Int = -1;
	public var isActive(default, null):Bool;
	public var isEmpty(get, never):Bool;
	public var isInClipboard:Bool = false;
	public var isPlaying(get, set):Bool;
	public var objectCollection:ArrayCollection<ValEditorObject> = new ArrayCollection();
	public var objects(default, null):Array<ValEditorObject> = new Array<ValEditorObject>();
	public var timeLine:ValEditorTimeLine;
	public var transition(get, set):String;
	public var tween(get, set):Bool;
	
	private function get_duration():Float { return (this.indexEnd - this.indexStart + 1) / this.timeLine.frameRate; }
	
	private var _indexCurrent:Int = -1;
	private function get_indexCurrent():Int { return this._indexCurrent; }
	private function set_indexCurrent(value:Int):Int 
	{
		if (this._indexCurrent == value) return value;
		this._indexCurrent = value;
		if (this._indexCurrent != -1)
		{
			updateTweens();
			updateObjectsSelectable();
		}
		return this._indexCurrent;
	}
	
	private function get_isEmpty():Bool { return this.objects.length == 0; }
	
	private var _isPlaying:Bool;
	private function get_isPlaying():Bool { return this._isPlaying; }
	private function set_isPlaying(value:Bool):Bool
	{
		if (this._isPlaying == value) return value;
		
		this._isPlaying = value;
		if (this._isPlaying)
		{
			for (object in this.objects)
			{
				cast(object, ValEditorObject).isSelectable = false;
			}
		}
		else if (this._indexCurrent != -1)
		{
			updateObjectsSelectable();
		}
		return this._isPlaying;
	}
	
	private var _transition:String = Transitions.LINEAR;
	private function get_transition():String { return this._transition; }
	private function set_transition(value:String):String 
	{
		if (this._transition == value) return value;
		for (tween in this._tweens)
		{
			tween.transition = value;
		}
		if (this.isActive && this._tween) updateTweens();
		this._transition = value;
		KeyFrameEvent.dispatch(this, KeyFrameEvent.TRANSITION_CHANGE);
		return this._transition;
	}
	
	private var _tween:Bool = false;
	private function get_tween():Bool { return this._tween; }
	private function set_tween(value:Bool):Bool 
	{
		if (this._tween == value) return value;
		if (value)
		{
			buildTweens();
		}
		else
		{
			resetTweens();
			clearTweens();
		}
		this._tween = value;
		updateObjectsSelectable();
		updateTweens();
		KeyFrameEvent.dispatch(this, KeyFrameEvent.STATE_CHANGE); // this is used by the timeline UI item to update frames state
		KeyFrameEvent.dispatch(this, KeyFrameEvent.TWEEN_CHANGE);
		return this._tween;
	}
	
	// helper vars
	private var _remainingObjects:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _tweenObjectMap:Map<ValEditorObject, ValEditorObject> = new Map<ValEditorObject, ValEditorObject>();
	private var _tweens:Array<FrameTween> = new Array<FrameTween>();
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void 
	{
		this.isInClipboard = false;
		this._isPlaying = false;
		for (object in this.objects)
		{
			unregisterObject(object);
			object.removeKeyFrame(this);
			if (this.isActive)
			{
				deactivateFunction(object);
			}
			if (object.canBeDestroyed()) ValEditor.destroyObject(cast object);
		}
		this.objects.resize(0);
		
		this.activateFunction = null;
		this.deactivateFunction = null;
		this.indexStart = -1;
		this.indexEnd = -1;
		this.isActive = false;
		this.timeLine = null;
		this._transition = Transitions.LINEAR;
		this.tween = false;
		this._indexCurrent = -1;
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function canBeDestroyed():Bool 
	{
		return this.timeLine == null && !this.isInClipboard;
	}
	
	public function clone(?keyFrame:ValEditorKeyFrame):ValEditorKeyFrame
	{
		if (keyFrame == null) keyFrame = fromPool();
		
		
		
		return keyFrame;
	}
	
	public function copyObjectsFrom(keyFrame:ValEditorKeyFrame, ?action:KeyFrameCopyObjectsFrom):Void
	{
		if (action != null)
		{
			var objectAdd:ObjectAddKeyFrame;
			if (keyFrame.timeLine == this.timeLine)
			{
				for (object in keyFrame.objects)
				{
					objectAdd = ObjectAddKeyFrame.fromPool();
					objectAdd.setup(object, this);
					action.add(objectAdd);
				}
			}
			else
			{
				var objectCreate:ObjectCreate;
				var newObject:ValEditorObject;
				for (object in keyFrame.objects)
				{
					newObject = ValEditor.cloneObject(object);
					objectCreate = ObjectCreate.fromPool();
					objectCreate.setup(newObject);
					action.add(objectCreate);
					
					objectAdd = ObjectAddKeyFrame.fromPool();
					objectAdd.setup(newObject, this);
					action.add(objectAdd);
				}
			}
		}
		else
		{
			if (keyFrame.timeLine == this.timeLine)
			{
				for (object in keyFrame.objects)
				{
					add(object);
				}
			}
			else
			{
				for (object in keyFrame.objects)
				{
					add(ValEditor.cloneObject(object));
				}
			}
		}
	}
	
	public function add(object:ValEditorObject, collection:ExposedCollection = null):Void 
	{
		this.objects[this.objects.length] = object;
		object.addKeyFrame(this, collection);
		if (this.isActive)
		{
			object.setKeyFrame(this);
			activateFunction(object);
		}
		
		KeyFrameEvent.dispatch(this, KeyFrameEvent.OBJECT_ADDED, object);
		
		rebuildTweens();
		
		if (this.timeLine != null)
		{
			var prevFrame:ValEditorKeyFrame = this.timeLine.getPreviousKeyFrame(this);
			if (prevFrame != null)
			{
				prevFrame.rebuildTweens();
			}
		}
		
		if (this.isActive)
		{
			registerObject(object);
		}
		
		if (this.objects.length == 1) KeyFrameEvent.dispatch(this, KeyFrameEvent.STATE_CHANGE);
	}
	
	public function hasObject(object:ValEditorObject):Bool
	{
		return this.objects.indexOf(object) != -1;
	}
	
	public function remove(object:ValEditorObject, poolCollection:Bool = true):Void 
	{
		this.objects.remove(object);
		object.removeKeyFrame(this, poolCollection);
		if (this.isActive)
		{
			deactivateFunction(object);
		}
		
		KeyFrameEvent.dispatch(this, KeyFrameEvent.OBJECT_REMOVED, object);
		
		rebuildTweens();
		
		if (this.timeLine != null)
		{
			var prevFrame:ValEditorKeyFrame = this.timeLine.getPreviousKeyFrame(this);
			if (prevFrame != null)
			{
				prevFrame.rebuildTweens();
			}
		}
		
		if (this.isActive)
		{
			unregisterObject(object);
		}
		
		if (this.objects.length == 0) KeyFrameEvent.dispatch(this, KeyFrameEvent.STATE_CHANGE);
	}
	
	private function registerObject(object:ValEditorObject):Void
	{
		object.addEventListener(ObjectPropertyEvent.CHANGE, onObjectPropertyChange);
		object.addEventListener(ObjectFunctionEvent.CALLED, onObjectPropertyChange);
	}
	
	private function unregisterObject(object:ValEditorObject):Void
	{
		object.removeEventListener(ObjectPropertyEvent.CHANGE, onObjectPropertyChange);
		object.removeEventListener(ObjectFunctionEvent.CALLED, onObjectPropertyChange);
	}
	
	public function enter():Void 
	{
		for (object in this.objects)
		{
			object.setKeyFrame(this);
			activateFunction(object);
		}
		this.isActive = true;
		
		// register objects
		for (object in this.objects)
		{
			registerObject(object);
		}
	}
	
	public function exit():Void 
	{
		for (object in this.objects)
		{
			deactivateFunction(object);
		}
		this.isActive = false;
		this._indexCurrent = -1;
		
		resetTweens();
		
		// unregister & unselect objects if needed
		for (object in this.objects)
		{
			unregisterObject(object);
			
			if (ValEditor.selection.hasObject(object))
			{
				ValEditor.selection.removeObject(object);
			}
		}
	}
	
	public function buildTweens():Void
	{
		var nextFrame:ValEditorKeyFrame = this.timeLine.getNextKeyFrame(this);
		if (nextFrame == null) return;
		var duration:Float = this.duration;
		var collection:ExposedCollection;
		var nextCollection:ExposedCollection;
		var tweenData:TweenData = TweenData.fromPool();
		
		for (object in this.objects)
		{
			nextCollection = object.getCollectionForKeyFrame(nextFrame);
			if (nextCollection != null)
			{
				collection = object.getCollectionForKeyFrame(this);
				collection.getTweenData(nextCollection, tweenData, object.object);
				tweenData.buildTweens(duration, this._transition, this._tweens);
				tweenData.clear();
				this._tweenObjectMap.set(object, object);
			}
			else
			{
				this._remainingObjects[this._remainingObjects.length] = object;
			}
		}
		
		for (object in this._remainingObjects)
		{
			for (nextObject in nextFrame.objects)
			{
				if (this._tweenObjectMap.exists(nextObject)) continue;
				
				if (object.clss == nextObject.clss && object.template == nextObject.template)
				{
					collection = object.getCollectionForKeyFrame(this);
					nextCollection = nextObject.getCollectionForKeyFrame(nextFrame);
					collection.getTweenData(nextCollection, tweenData, object.object);
					tweenData.buildTweens(duration, this._transition, this._tweens);
					tweenData.clear();
					this._tweenObjectMap.set(nextObject, nextObject);
					break;
				}
			}
		}
		
		tweenData.pool();
		this._tweenObjectMap.clear();
		this._remainingObjects.resize(0);
	}
	
	private function clearTweens():Void
	{
		for (twn in this._tweens)
		{
			twn.pool();
		}
		this._tweens.resize(0);
	}
	
	private function rebuildTweens():Void
	{
		if (!this._tween) return;
		
		var reset:Bool = this.isActive && this._indexCurrent != this.indexStart;
		if (reset)
		{
			resetTweens();
		}
		clearTweens();
		buildTweens();
		if (reset)
		{
			updateTweens();
		}
	}
	
	public function updateTweens():Void
	{
		var ratio:Float = (this._indexCurrent - this.indexStart) / (this.indexEnd - this.indexStart + 1);
		for (tween in this._tweens)
		{
			tween.setRatio(ratio);
		}
	}
	
	public function resetTweens():Void
	{
		for (tween in this._tweens)
		{
			tween.setRatio(0);
		}
	}
	
	public function selectAllObjects():Void
	{
		for (object in this.objects)
		{
			if (!ValEditor.selection.hasObject(object))
			{
				ValEditor.selection.addObject(object);
			}
		}
	}
	
	private function updateObjectsSelectable():Void
	{
		if (this._isPlaying) return;
		if (this._tween)
		{
			if (this._indexCurrent == this.indexStart)
			{
				for (object in this.objects)
				{
					object.isSelectable = true;
				}
			}
			else
			{
				for (object in this.objects)
				{
					if (ValEditor.selection.hasObject(object))
					{
						ValEditor.selection.removeObject(object);
					}
					object.isSelectable = false;
				}
			}
		}
		else
		{
			for (object in this.objects)
			{
				object.isSelectable = true;
			}
		}
	}
	
	public function changeUpdate():Void
	{
		rebuildTweens();
	}
	
	private function onObjectPropertyChange(evt:Event):Void
	{
		ValEditor.registerForChangeUpdate(this);
		
		var prevFrame:ValEditorKeyFrame = this.timeLine.getPreviousKeyFrame(this);
		if (prevFrame != null && prevFrame._tween)
		{
			ValEditor.registerForChangeUpdate(cast prevFrame);
		}
	}
	
	public function cloneTo(keyFrame:ValEditorKeyFrame):Void
	{
		keyFrame.indexStart = this.indexStart;
		keyFrame.indexEnd = this.indexEnd;
		
		//var cloneObject:ValEditorObject;
		//var collection:ExposedCollection;
		//for (object in this.objects)
		//{
			//cloneObject = ValEditor.cloneObject(cast object);
			//collection = object.getCollectionForKeyFrame(this);
			//keyFrame.add(cloneObject, collection.clone(true));
		//}
		
		keyFrame.transition = this.transition;
		keyFrame._tween = this.tween;
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.indexStart = json.indexStart;
		this.indexEnd = json.indexEnd;
		
		var collection:ExposedCollection;
		var object:ValEditorObject;
		var template:ValEditorTemplate;
		var objects:Array<Dynamic> = json.objects;
		for (node in objects)
		{
			if (node.templateID != null)
			{
				template = ValEditor.getTemplate(node.templateID);
				object = template.getInstance(node.id);
				collection = template.clss.getCollection();
				collection.readFromObject(object.object);
				collection.fromJSONSave(node.collection);
				template.visibilityCollectionCurrent.applyToTemplateObjectCollection(collection);
			}
			else
			{
				object = this.timeLine.container.objectLibrary.getObject(node.objectID != null ? node.objectID : node.id);
				collection = object.clss.getCollection();
				collection.readFromObject(object.object);
				collection.fromJSONSave(node.collection);
			}
			collection.apply();
			add(object, collection);
		}
		
		this.transition = json.transition;
		this._tween = json.tween;
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		if (this.isActive)
		{
			// reset tweens to avoid messing up collection values
			resetTweens();
		}
		
		json.indexStart = this.indexStart;
		json.indexEnd = this.indexEnd;
		
		var objects:Array<Dynamic> = [];
		for (object in this.objects)
		{
			objects[objects.length] = object.toJSONSaveKeyFrame(this);
		}
		json.objects = objects;
		
		json.transition = this._transition;
		json.tween = this._tween;
		
		if (this.isActive)
		{
			// restore tweens progress
			updateTweens();
		}
		
		return json;
	}
	
}
package valeditor;

import feathers.data.ArrayCollection;
import openfl.events.Event;
import valedit.ExposedCollection;
import valedit.ValEdit;
import valedit.ValEditKeyFrame;
import valedit.ValEditObject;
import valeditor.editor.action.keyframe.KeyFrameCopyObjectsFrom;
import valeditor.editor.action.object.ObjectAddKeyFrame;
import valeditor.editor.action.object.ObjectCreate;
import valeditor.editor.change.IChangeUpdate;
import valeditor.events.DefaultEvent;
import valeditor.events.ObjectEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorKeyFrame extends ValEditKeyFrame implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	
	static public function fromPool():ValEditorKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorKeyFrame();
	}
	
	public var isInClipboard:Bool = false;
	public var isPlaying(get, set):Bool;
	public var objectCollection:ArrayCollection<ValEditObject> = new ArrayCollection();
	
	override function set_indexCurrent(value:Int):Int 
	{
		if (this._indexCurrent == value) return value;
		this._indexCurrent = value;
		updateTweens();
		updateObjectsSelectable();
		return this._indexCurrent;
	}
	
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
		else
		{
			updateObjectsSelectable();
		}
		return this._isPlaying;
	}
	
	override function set_tween(value:Bool):Bool 
	{
		if (this._tween == value) return value;
		super.set_tween(value);
		updateObjectsSelectable();
		updateTweens();
		DefaultEvent.dispatch(this, Event.CHANGE); // this is used by the timeline UI item to update frames state
		return this._tween;
	}
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		this.isInClipboard = false;
		this._isPlaying = false;
		for (object in this.objects)
		{
			unregisterObject(object);
			ValEditor.destroyObject(cast object);
		}
		this.objects.resize(0);
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function canBeDestroyed():Bool 
	{
		return super.canBeDestroyed() && !this.isInClipboard;
	}
	
	public function clone(?keyFrame:ValEditorKeyFrame):ValEditorKeyFrame
	{
		if (keyFrame == null) keyFrame = fromPool();
		
		
		
		return keyFrame;
	}
	
	public function copyObjectsFrom(keyFrame:ValEditKeyFrame, ?action:KeyFrameCopyObjectsFrom):Void
	{
		if (action != null)
		{
			var objectAdd:ObjectAddKeyFrame;
			if (keyFrame.timeLine == this.timeLine)
			{
				for (object in keyFrame.objects)
				{
					objectAdd = ObjectAddKeyFrame.fromPool();
					objectAdd.setup(cast object, this);
					action.add(objectAdd);
				}
			}
			else
			{
				var objectCreate:ObjectCreate;
				var newObject:ValEditorObject;
				for (object in keyFrame.objects)
				{
					newObject = cast ValEditor.cloneObject(object);
					objectCreate = ObjectCreate.fromPool();
					objectCreate.setup(newObject);
					action.add(objectCreate);
					
					objectAdd = ObjectAddKeyFrame.fromPool();
					objectAdd.setup(cast object, this);
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
	
	override public function add(object:ValEditObject, collection:ExposedCollection = null):Void 
	{
		super.add(object, collection);
		rebuildTweens();
		
		if (this.timeLine != null)
		{
			var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
			if (prevFrame != null)
			{
				prevFrame.rebuildTweens();
			}
		}
		
		if (this.isActive)
		{
			registerObject(object);
		}
		
		if (this.objects.length == 1) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	public function hasObject(object:ValEditObject):Bool
	{
		return this.objects.indexOf(object) != -1;
	}
	
	override public function remove(object:ValEditObject, poolCollection:Bool = true):Void 
	{
		super.remove(object, poolCollection);
		rebuildTweens();
		
		if (this.timeLine != null)
		{
			var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
			if (prevFrame != null)
			{
				prevFrame.rebuildTweens();
			}
		}
		
		if (this.isActive)
		{
			unregisterObject(object);
		}
		
		if (this.objects.length == 0) DefaultEvent.dispatch(this, Event.CHANGE);
	}
	
	private function registerObject(object:ValEditObject):Void
	{
		object.addEventListener(ObjectEvent.PROPERTY_CHANGE, onObjectPropertyChange);
		object.addEventListener(ObjectEvent.FUNCTION_CALLED, onObjectPropertyChange);
	}
	
	private function unregisterObject(object:ValEditObject):Void
	{
		object.removeEventListener(ObjectEvent.PROPERTY_CHANGE, onObjectPropertyChange);
		object.removeEventListener(ObjectEvent.FUNCTION_CALLED, onObjectPropertyChange);
	}
	
	override public function enter():Void 
	{
		super.enter();
		
		// register objects
		for (object in this.objects)
		{
			registerObject(object);
		}
	}
	
	override public function exit():Void 
	{
		super.exit();
		
		resetTweens();
		
		// unregister & unselect objects if needed
		for (object in this.objects)
		{
			unregisterObject(object);
			
			if (ValEditor.selection.hasObject(cast object))
			{
				ValEditor.selection.removeObject(cast object);
			}
		}
	}
	
	public function selectAllObjects():Void
	{
		for (object in this.objects)
		{
			if (!ValEditor.selection.hasObject(cast object))
			{
				ValEditor.selection.addObject(cast object);
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
					cast(object, ValEditorObject).isSelectable = true;
				}
			}
			else
			{
				for (object in this.objects)
				{
					if (ValEditor.selection.hasObject(cast object))
					{
						ValEditor.selection.removeObject(cast object);
					}
					cast(object, ValEditorObject).isSelectable = false;
				}
			}
		}
		else
		{
			for (object in this.objects)
			{
				cast(object, ValEditorObject).isSelectable = true;
			}
		}
	}
	
	public function changeUpdate():Void
	{
		rebuildTweens();
	}
	
	private function onObjectPropertyChange(evt:ObjectEvent):Void
	{
		ValEditor.registerForChangeUpdate(this);
		
		var prevFrame:ValEditKeyFrame = this.timeLine.getPreviousKeyFrame(this);
		if (prevFrame != null && prevFrame._tween)
		{
			ValEditor.registerForChangeUpdate(cast prevFrame);
		}
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
			template = cast ValEdit.getTemplate(node.templateID);
			object = cast template.getInstance(node.id);
			collection = template.clss.getCollection();
			collection.readValuesFromObject(object.object);
			collection.fromJSONSave(node.collection);
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
			objects.push(cast(object, ValEditorObject).toJSONSaveKeyFrame(this));
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
package valeditor;

import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import valedit.DisplayObjectType;
import valedit.ValEditLayer;
import valedit.ValEditObject;
import valedit.ValEditTimeLine;
import valedit.utils.RegularPropertyName;
import valedit.utils.StringIndexedMap;
import valeditor.events.KeyFrameEvent;
import valeditor.events.LayerEvent;
import valeditor.events.RenameEvent;
import valeditor.events.TimeLineEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorLayer extends ValEditLayer 
{
	static private var _POOL:Array<ValEditorLayer> = new Array<ValEditorLayer>();
	
	static public function fromPool(?timeLine:ValEditorTimeLine):ValEditorLayer
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(timeLine);
		return new ValEditorLayer(timeLine);
	}
	
	public var index(get, set):Int;
	public var selected(get, set):Bool;
	
	private var _index:Int = -1;
	private function get_index():Int { return this._index; }
	private function set_index(value:Int):Int
	{
		if (this._index == value) return value;
		
		if (this._rootContainer != null)
		{
			if (this._displayContainer != null)
			{
				this._rootContainer.setChildIndex(this._displayContainer, value);
			}
		}
		#if starling
		if (this._rootContainerStarling != null)
		{
			if (this._displayContainerStarling != null)
			{
				this._rootContainerStarling.setChildIndex(this._displayContainerStarling, value);
			}
		}
		#end
		return this._index = value;
	}
	
	override function set_locked(value:Bool):Bool 
	{
		if (this._locked == value) return value;
		super.set_locked(value);
		LayerEvent.dispatch(this, LayerEvent.LOCK_CHANGE, this);
		return this._locked;
	}
	
	override function set_name(value:String):String 
	{
		if (this._name == value) return value;
		var previousName:String = this._name;
		super.set_name(value);
		RenameEvent.dispatch(this, RenameEvent.RENAMED, previousName);
		return this._name;
	}
	
	override function set_rootContainer(value:DisplayObjectContainer):DisplayObjectContainer 
	{
		if (this._rootContainer == value) return value;
		if (value != null)
		{
			if (this._displayContainer != null && this._index != -1)
			{
				value.addChildAt(this._displayContainer, this._index);
			}
		}
		else if (this._rootContainer != null)
		{
			if (this._displayContainer != null)
			{
				this._rootContainer.removeChild(this._displayContainer);
			}
		}
		return this._rootContainer = value;
	}
	
	#if starling
	override function set_rootContainerStarling(value:starling.display.DisplayObjectContainer):starling.display.DisplayObjectContainer 
	{
		if (this._rootContainerStarling == value) return value;
		if (value != null)
		{
			if (this._displayContainerStarling != null && this._index != -1)
			{
				value.addChildAt(this._displayContainerStarling, this._index);
			}
		}
		else if (this._rootContainerStarling != null)
		{
			if (this._displayContainerStarling != null)
			{
				this._rootContainerStarling.removeChild(this._displayContainerStarling);
			}
		}
		return this._rootContainerStarling = value;
	}
	#end
	
	private var _selected:Bool = false;
	private function get_selected():Bool { return this._selected; }
	private function set_selected(value:Bool):Bool
	{
		if (this._selected == value) return value;
		this._selected = value;
		if (this._selected)
		{
			LayerEvent.dispatch(this, LayerEvent.SELECTED, this);
		}
		else
		{
			LayerEvent.dispatch(this, LayerEvent.UNSELECTED, this);
		}
		return this._selected;
	}
	
	override function set_visible(value:Bool):Bool 
	{
		if (this._visible == value) return value;
		super.set_visible(value);
		LayerEvent.dispatch(this, LayerEvent.VISIBLE_CHANGE, this);
		return this._visible;
	}
	
	private var _displayObjects:StringIndexedMap<ValEditorObject> = new StringIndexedMap<ValEditorObject>();
	
	public function new(?timeLine:ValEditorTimeLine) 
	{
		if (timeLine == null) timeLine = ValEditorTimeLine.fromPool(0);
		super(timeLine);
		createDisplayContainer();
		createDisplayContainerStarling();
		this._clearContainers = false;
	}
	
	override public function clear():Void 
	{
		this._displayObjects.clear();
		this._selected = false;
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function setTo(timeLine:ValEditTimeLine):ValEditLayer 
	{
		if (timeLine == null) timeLine = ValEditorTimeLine.fromPool(0);
		return super.setTo(timeLine);
	}
	
	/**
	   This will change the layer's index without triggering removeChild/AddChild calls
	   @param	newIndex
	**/
	public function indexUpdate(newIndex:Int):Void
	{
		this._index = newIndex;
		if (this._rootContainer != null && this._displayContainer != null)
		{
			this._rootContainer.removeChild(this._displayContainer);
			if (this._index != -1)
			{
				this._rootContainer.addChildAt(this._displayContainer, this._index);
			}
		}
		
		#if starling
		if (this._rootContainerStarling != null && this._displayContainerStarling != null)
		{
			this._rootContainerStarling.removeChild(this._displayContainerStarling);
			if (this._index != -1)
			{
				this._rootContainerStarling.addChildAt(this._displayContainerStarling, this._index);
			}
		}
		#end
	}
	
	public function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		return cast(this.timeLine, ValEditorTimeLine).getAllObjects(objects);
	}
	
	public function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (visibleObjects == null) visibleObjects = new Array<ValEditorObject>();
		
		for (object in this._displayObjects)
		{
			if (object.getProperty(RegularPropertyName.VISIBLE) == true)
			{
				visibleObjects.push(object);
			}
		}
		
		return visibleObjects;
	}
	
	public function hasVisibleObject():Bool
	{
		for (object in this._displayObjects)
		{
			if (object.getProperty(RegularPropertyName.VISIBLE) == true)
			{
				return true;
			}
		}
		return false;
	}
	
	public function canAddObject():Bool
	{
		return this.timeLine.frameCurrent != null && (!this.timeLine.frameCurrent.tween || this.timeLine.frameCurrent.indexCurrent == this.timeLine.frameCurrent.indexStart);
	}
	
	override public function activate(object:ValEditObject):Void 
	{
		super.activate(object);
		
		var editorObject:ValEditorObject = cast object;
		
		if (object.isDisplayObject)
		{
			this._displayObjects.set(editorObject.id, editorObject);
			
			switch (object.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					this._displayContainer.addChild(cast editorObject.interactiveObject);
				
				#if starling
				case DisplayObjectType.STARLING :
					this._displayContainerStarling.addChild(cast editorObject.interactiveObject);
				#end
				
				case DisplayObjectType.MIXED :
					// nothing ?
				
				default :
					throw new Error("ValEditorLayer.add ::: unknown display object type " + object.displayObjectType);
			}
		}
	}
	
	override public function deactivate(object:ValEditObject):Void 
	{
		super.deactivate(object);
		
		var editorObject:ValEditorObject = cast object;
		
		if (object.isDisplayObject)
		{
			this._displayObjects.remove(editorObject.id);
			
			switch (object.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					this._displayContainer.removeChild(cast editorObject.interactiveObject);
				
				#if starling
				case DisplayObjectType.STARLING :
					this._displayContainerStarling.removeChild(cast editorObject.interactiveObject);
				#end
				
				case DisplayObjectType.MIXED :
					// nothing ?
				
				default :
					throw new Error("ValEditorContainer.remove ::: unknown display object type " + object.displayObjectType);
			}
		}
	}
	
	override function addDisplayContainer():Void 
	{
		if (this._rootContainer != null && this._index != -1)
		{
			this._rootContainer.addChildAt(this._displayContainer, this._index);
		}
	}
	
	override function addDisplayContainerStarling():Void 
	{
		if (this._rootContainerStarling != null && this._index != -1)
		{
			this._rootContainerStarling.addChildAt(this._displayContainerStarling, this._index);
		}
	}
	
	override function onKeyFrameObjectAdded(evt:KeyFrameEvent):Void 
	{
		if (evt.object.numKeyFrames == 1)
		{
			this.allObjects[this.allObjects.length] = evt.object;
		}
		LayerEvent.dispatch(this, LayerEvent.OBJECT_ADDED, this, evt.object);
	}
	
	override function onKeyFrameObjectRemoved(evt:KeyFrameEvent):Void 
	{
		if (evt.object.numKeyFrames == 0)
		{
			this.allObjects.remove(evt.object);
		}
		LayerEvent.dispatch(this, LayerEvent.OBJECT_REMOVED, this, evt.object);
	}
	
	private function onTimeLineSelectedFrameIndexChange(evt:TimeLineEvent):Void
	{
		dispatchEvent(evt);
	}
	
	public function cloneTo(layer:ValEditorLayer):Void
	{
		layer.index = this.index;
		layer.name = this.name;
		layer.visible = this.visible;
		layer.x = this.x;
		layer.y = this.y;
		
		cast(this.timeLine, ValEditorTimeLine).cloneTo(cast layer.timeLine);
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.name = json.name;
		this.locked = json.locked;
		this.visible = json.visible;
		this.x = json.x;
		this.y = json.y;
		
		cast(this.timeLine, ValEditorTimeLine).fromJSONSave(json.timeLine);
		
		for (keyFrame in this.timeLine.keyFrames)
		{
			for (object in keyFrame.objects)
			{
				if (object.numKeyFrames == 1)
				{
					this.allObjects[this.allObjects.length] = object;
				}
				else if (this.allObjects.indexOf(object) == -1)
				{
					this.allObjects[this.allObjects.length] = object;
				}
			}
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.name = this.name;
		json.locked = this.locked;
		json.visible = this.visible;
		json.x = this.x;
		json.y = this.y;
		
		json.timeLine = cast(this.timeLine, ValEditorTimeLine).toJSONSave();
		
		return json;
	}
	
}
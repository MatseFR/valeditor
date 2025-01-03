package valeditor.container;
import valeditor.ValEditorObject;
#if starling
import openfl.events.EventDispatcher;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
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
class LayerStarlingEditable extends EventDispatcher implements ITimeLineLayerEditable implements ILayerStarlingEditable
{
	static private var _POOL:Array<LayerStarlingEditable> = new Array<LayerStarlingEditable>();
	
	static public function fromPool():LayerStarlingEditable
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerStarlingEditable();
	}
	
	public var allObjects(default, null):Array<ValEditorObject> = new Array<ValEditorObject>();
	public var container(get, set):ITimeLineContainerEditable;
	public var index(get, set):Int;
	public var locked(get, set):Bool;
	public var name(get, set):String;
	public var rootContainerStarling(get, set):DisplayObjectContainer;
	public var selected(get, set):Bool;
	public var timeLine(default, null):ValEditorTimeLine;
	public var visible(get, set):Bool;
	
	private var _container:ITimeLineContainerEditable;
	private function get_container():ITimeLineContainerEditable { return this._container; }
	private function set_container(value:ITimeLineContainerEditable):ITimeLineContainerEditable
	{
		this.timeLine.container = value;
		return this._container = value;
	}
	
	private var _index:Int = -1;
	private function get_index():Int { return this._index; }
	private function set_index(value:Int):Int
	{
		if (this._rootContainerStarling != null)
		{
			this._rootContainerStarling.setChildIndex(this._displayContainerStarling, value);
		}
		return this._index = value;
	}
	
	private var _locked:Bool = false;
	private function get_locked():Bool { return this._locked; }
	private function set_locked(value:Bool):Bool
	{
		if (this._locked == value) return value;
		this._displayContainerStarling.touchable = !value;
		this._locked = value;
		LayerEvent.dispatch(this, LayerEvent.LOCK_CHANGE, this);
		return this._locked;
	}
	
	private var _name:String;
	private function get_name():String { return this._name; }
	private function set_name(value:String):String 
	{
		if (this._name == value) return value;
		var previousName:String = this._name;
		this._name = value;
		RenameEvent.dispatch(this, RenameEvent.RENAMED, previousName);
		return this._name;
	}
	
	private var _rootContainerStarling:DisplayObjectContainer;
	private function get_rootContainerStarling():DisplayObjectContainer { return this._rootContainerStarling; }
	private function set_rootContainerStarling(value:DisplayObjectContainer):DisplayObjectContainer 
	{
		if (this._rootContainerStarling == value) return value;
		
		if (this._rootContainerStarling != null)
		{
			this._rootContainerStarling.removeChild(this._displayContainerStarling);
		}
		
		if (value != null)
		{
			value.addChildAt(this._displayContainerStarling, this._index);
		}
		
		return this._rootContainerStarling = value;
	}
	
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
	
	private var _visible:Bool = true;
	private function get_visible():Bool { return this._visible; }
	private function set_visible(value:Bool):Bool
	{
		if (this._visible == value) return value;
		this._displayContainerStarling.visible = value;
		this._visible = value;
		LayerEvent.dispatch(this, LayerEvent.VISIBLE_CHANGE, this);
		return this._visible;
	}
	
	private var _displayContainerStarling:Sprite = new Sprite();
	private var _displayObjects:StringIndexedMap<ValEditorObject> = new StringIndexedMap<ValEditorObject>();
	
	public function new() 
	{
		super();
		
		this.timeLine = ValEditorTimeLine.fromPool(0);
		this.timeLine.activateFunction = this.activate;
		this.timeLine.deactivateFunction = this.deactivate;
		this.timeLine.addEventListener(KeyFrameEvent.OBJECT_ADDED, onKeyFrameObjectAdded);
		this.timeLine.addEventListener(KeyFrameEvent.OBJECT_REMOVED, onKeyFrameObjectRemoved);
	}
	
	public function clear():Void 
	{
		this.timeLine.clear();
		this.timeLine.activateFunction = this.activate;
		this.timeLine.deactivateFunction = this.deactivate;
		
		this.rootContainerStarling = null;
		
		this.allObjects.resize(0);
		this._displayObjects.clear();
		this.container = null;
		this.index = -1;
		this.locked = false;
		this._name = null;
		this._selected = false;
		this.visible = true;
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	/**
	   This will change the layer's index without triggering removeChild/AddChild calls
	   @param	newIndex
	**/
	public function indexUpdate(newIndex:Int):Void
	{
		this._index = newIndex;
		
		if (this._rootContainerStarling != null && this._displayContainerStarling != null)
		{
			if (this._index == -1)
			{
				this._rootContainerStarling.removeChild(this._displayContainerStarling);
			}
			else
			{
				this._rootContainerStarling.setChildIndex(this._displayContainerStarling, this._index);
			}
		}
	}
	
	public function canAddObject(object:ValEditorObject):Bool
	{
		return this.timeLine.frameCurrent != null && (!this.timeLine.frameCurrent.tween || this.timeLine.frameCurrent.indexCurrent == this.timeLine.frameCurrent.indexStart);
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		this.timeLine.addObject(object);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		this.timeLine.removeObject(object);
	}
	
	public function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		return this.timeLine.getAllObjects(objects);
	}
	
	public function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (visibleObjects == null) visibleObjects = new Array<ValEditorObject>();
		
		for (object in this._displayObjects)
		{
			if (object.getProperty(RegularPropertyName.VISIBLE) == true)
			{
				visibleObjects[visibleObjects.length] = object;
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
	
	public function activate(object:ValEditorObject):Void 
	{
		if (object.isDisplayObject)
		{
			this._displayObjects.set(object.id, object);
			
			if (object.clss.addToDisplayFunction != null)
			{
				#if neko
				Reflect.callMethod(null, object.clss.addToDisplayFunction, [object.object, this._displayContainerStarling]);
				#else
				object.clss.addToDisplayFunction(object.object, this._displayContainerStarling);
				#end
			}
			else
			{
				this._displayContainerStarling.addChild(object.object);
			}
			this._displayContainerStarling.addChild(cast object.interactiveObject);
		}
		else if (object.isContainer)
		{
			this._displayObjects.set(object.id, object);
			
			cast(object.object, IContainerStarlingEditable).rootContainerStarling = this._displayContainerStarling;
			
			if (object.isTimeLineContainer)
			{
				this.timeLine.addChild(cast(object.object, ITimeLineContainerEditable).timeLine);
			}
		}
		LayerEvent.dispatch(this, LayerEvent.OBJECT_ACTIVATED, this, object);
	}
	
	public function deactivate(object:ValEditorObject):Void 
	{
		if (object.isDisplayObject)
		{
			this._displayObjects.remove(object.id);
			
			if (object.clss.removeFromDisplayFunction != null)
			{
				#if neko
				Reflect.callMethod(null, object.clss.removeFromDisplayFunction, [object.object, this._displayContainerStarling]);
				#else
				object.clss.removeFromDisplayFunction(object.object, this._displayContainerStarling);
				#end
			}
			else
			{
				this._displayContainerStarling.removeChild(object.object);
			}
			this._displayContainerStarling.removeChild(cast object.interactiveObject);
		}
		else if (object.isContainer)
		{
			this._displayObjects.remove(object.id);
			
			cast(object.object, IContainerStarlingEditable).rootContainerStarling = null;
			
			if (object.isTimeLineContainer)
			{
				this.timeLine.removeChild(cast(object.object, ITimeLineContainerEditable).timeLine);
			}
		}
		LayerEvent.dispatch(this, LayerEvent.OBJECT_ACTIVATED, this, object);
	}
	
	private function onKeyFrameObjectAdded(evt:KeyFrameEvent):Void 
	{
		if (evt.object.numKeyFrames == 1)
		{
			this.allObjects[this.allObjects.length] = evt.object;
		}
		LayerEvent.dispatch(this, LayerEvent.OBJECT_ADDED, this, evt.object);
	}
	
	private function onKeyFrameObjectRemoved(evt:KeyFrameEvent):Void 
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
	
	public function cloneTo(layer:ITimeLineLayerEditable):Void
	{
		layer.index = this.index;
		layer.name = this.name;
		layer.visible = this.visible;
		
		this.timeLine.cloneTo(layer.timeLine);
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.name = json.name;
		this.locked = json.locked;
		this.visible = json.visible;
		
		this.timeLine.fromJSONSave(json.timeLine);
		
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
		
		json.timeLine = this.timeLine.toJSONSave();
		
		return json;
	}
	
}
#end
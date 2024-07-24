package valeditor;

import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import valedit.DisplayObjectType;
import valedit.IValEditOpenFLContainer;
import valedit.ValEditObject;
import valedit.utils.RegularPropertyName;
import valeditor.editor.data.ContainerSaveData;
import valeditor.events.ContainerEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
import valeditor.ui.UIConfig;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class SpriteContainer extends Sprite implements IValEditorContainer
{
	static private var _POOL:Array<SpriteContainer> = new Array<SpriteContainer>();
	
	static public function fromPool():SpriteContainer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SpriteContainer();
	}
	
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var container(get, never):DisplayObjectContainer;
	public var containerUI(default, null):DisplayObjectContainer = new Sprite();
	public var isOpen(get, never):Bool;
	public var rootContainer(get, set):DisplayObjectContainer;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	
	private var _cameraX:Float = 0;
	private function get_cameraX():Float { return this._cameraX; }
	private function set_cameraX(value:Float):Float
	{
		this._container.x = this.x - value;
		this.containerUI.x = this.x - value;
		return this._cameraX = value;
	}
	
	private var _cameraY:Float = 0;
	private function get_cameraY():Float { return this._cameraY; }
	private function set_cameraY(value:Float):Float
	{
		this._container.y = this.y - value;
		this.containerUI.y = this.y - value;
		return this._cameraY = value;
	}
	
	private var _container:Sprite = new Sprite();
	private function get_container():DisplayObjectContainer { return this._container; }
	
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	
	private var _rootContainer:DisplayObjectContainer;
	private function get_rootContainer():DisplayObjectContainer { return this._rootContainer; }
	private function set_rootContainer(value:DisplayObjectContainer):DisplayObjectContainer
	{
		if (value == this._rootContainer) return value;
		
		if (this._rootContainer != null)
		{
			this._rootContainer.removeChild(this);
		}
		
		if (value != null)
		{
			this._rootContainer.addChild(this);
		}
		
		return this._rootContainer = value;
	}
	
	private var _viewCenterX:Float = 0;
	private function get_viewCenterX():Float { return this._viewCenterX; }
	private function set_viewCenterX(value:Float):Float
	{
		this.cameraX = Math.fround(value - this._viewWidth / 2);
		return this._viewCenterX = value;
	}
	
	private var _viewCenterY:Float = 0;
	private function get_viewCenterY():Float { return this._viewCenterY; }
	private function set_viewCenterY(value:Float):Float
	{
		this.cameraY = Math.fround(value - this._viewHeight / 2);
		return this._viewCenterY = value;
	}
	
	private var _viewHeight:Float = 0;
	private function get_viewHeight():Float { return this._viewHeight; }
	private function set_viewHeight(value:Float):Float
	{
		return this._viewHeight = value;
	}
	
	private var _viewWidth:Float = 0;
	private function get_viewWidth():Float { return this._viewWidth; }
	private function set_viewWidth(value:Float):Float
	{
		return this._viewWidth = value;
	}
	
	private var _allObjects:Map<String, ValEditObject> = new Map<String, ValEditObject>();
	private var _displayObjects:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	private var _pivotIndicator:PivotIndicator = new PivotIndicator(UIConfig.CONTAINER_PIVOT_SIZE, UIConfig.CONTAINER_PIVOT_COLOR,
		UIConfig.CONTAINER_PIVOT_ALPHA, UIConfig.CONTAINER_PIVOT_OUTLINE_COLOR, UIConfig.CONTAINER_PIVOT_OUTLINE_ALPHA);
	
	public function new() 
	{
		super();
		addChild(this._container);
		addChild(this.containerUI);
	}
	
	public function clear():Void
	{
		this.activeObjectsCollection.removeAll();
		this.allObjectsCollection.removeAll();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function open():Void
	{
		if (this._isOpen) return;
		
		this._isOpen = true;
		this.containerUI.addChild(this._pivotIndicator);
		ContainerEvent.dispatch(this, ContainerEvent.OPEN);
	}
	
	public function close():Void
	{
		if (!this._isOpen) return;
		
		this._isOpen = false;
		this.containerUI.removeChild(this._pivotIndicator);
		ContainerEvent.dispatch(this, ContainerEvent.CLOSE);
	}
	
	public function adjustView():Void
	{
		// TODO
	}
	
	public function canAddObject(object:ValEditorObject):Bool
	{
		if (object.isDisplayObject)
		{
			return object.displayObjectType == DisplayObjectType.OPENFL;
		}
		else if (object.isContainer)
		{
			return object.isContainerOpenFL;
		}
		return false;
	}
	
	public function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (objects == null) return this._objects.copy();
		
		for (object in this._objects)
		{
			objects[objects.length] = object;
		}
		
		return objects;
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
	
	public function getActiveObject(objectID:String):ValEditObject
	{
		return getObject(objectID);
	}
	
	public function getObject(objectID:String):ValEditObject
	{
		return this._allObjects.get(objectID);
	}
	
	public function hasActiveObject(objectID:String):Bool
	{
		return this._allObjects.exists(objectID);
	}
	
	public function hasObject(objectID:String):Bool
	{
		return this._allObjects.exists(objectID);
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
	
	public function addObject(object:ValEditObject):Void
	{
		this._allObjects.set(object.objectID, object);
		this._objects[this._objects.length] = cast object;
		this.activeObjectsCollection.add(cast object);
		this.allObjectsCollection.add(cast object);
		
		object.addEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.addEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.addEventListener(RenameEvent.RENAMED, object_renamed);
		
		if (object.isDisplayObject)
		{
			this._displayObjects[this._displayObjects.length] = cast object;
			this.container.addChild(cast object.object);
		}
		else if (object.isContainer)
		{
			this._displayObjects[this._displayObjects.length] = cast object;
			if (object.isContainerOpenFL)
			{
				cast(object.object, IValEditOpenFLContainer).rootContainer = this.container;
			}
		}
	}
	
	public function removeObject(object:ValEditObject):Void
	{
		this._allObjects.remove(object.objectID);
		this._objects.remove(cast object);
		this.activeObjectsCollection.remove(cast object);
		this.allObjectsCollection.remove(cast object);
		
		object.removeEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.removeEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.removeEventListener(RenameEvent.RENAMED, object_renamed);
		
		if (object.isDisplayObject)
		{
			this._displayObjects.remove(cast object);
			this.container.removeChild(cast object.object);
		}
		else if (object.isContainer)
		{
			this._displayObjects.remove(cast object);
			if (object.isContainerOpenFL)
			{
				cast(object.object, IValEditOpenFLContainer).rootContainer = null;
			}
		}
	}
	
	public function getContainerDependencies(data:ContainerSaveData):Void
	{
		for (object in this.allObjectsCollection)
		{
			if (object.template != null && object.clss.isContainer && !data.hasDependency(cast object.template))
			{
				data.addDependency(cast object.template);
			}
		}
	}
	
	private function object_functionCalled(evt:ObjectFunctionEvent):Void
	{
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_FUNCTION_CALLED, evt.object, evt);
	}
	
	private function object_propertyChange(evt:ObjectPropertyEvent):Void
	{
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_PROPERTY_CHANGE, evt.object, evt);
	}
	
	private function cloneTo(container:SpriteContainer):Void
	{
		container.alpha = this.alpha;
		container.visible = this.visible;
		container.x = this.x;
		container.y = this.y;
		container.viewCenterX = this.viewCenterX;
		container.viewCenterY = this.viewCenterY;
		
		// TODO : clone objects
	}
	
	private function object_renamed(evt:RenameEvent):Void
	{
		var object:ValEditorObject = cast evt.target;
		
		this._allObjects.remove(evt.previousNameOrID);
		this._allObjects.set(object.objectID, object);
		this.activeObjectsCollection.updateAt(this.activeObjectsCollection.indexOf(object));
		this.allObjectsCollection.updateAt(this.allObjectsCollection.indexOf(object));
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		return json;
	}
	
}
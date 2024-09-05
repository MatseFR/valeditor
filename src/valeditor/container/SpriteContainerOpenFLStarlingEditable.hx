package valeditor.container;

import feathers.data.ArrayCollection;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;
import valedit.DisplayObjectType;
import valedit.utils.RegularPropertyName;
import valedit.utils.ReverseIterator;
import valeditor.editor.data.ContainerSaveData;
import valeditor.events.ContainerEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
import valeditor.ui.UIConfig;
import valeditor.ui.shape.PivotIndicator;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class SpriteContainerOpenFLStarlingEditable extends EventDispatcher implements IContainerEditable implements IContainerOpenFLEditable implements IContainerStarlingEditable
{
	static private var _POOL:Array<SpriteContainerOpenFLStarlingEditable> = new Array<SpriteContainerOpenFLStarlingEditable>();
	
	static public function fromPool():SpriteContainerOpenFLStarlingEditable
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SpriteContainerOpenFLStarlingEditable();
	}
	
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var alpha(get, set):Float;
	public var blendMode(get, set):BlendMode;
	public var blendModeStarling(get, set):String;
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var container(get, never):DisplayObjectContainer;
	public var containerStarling(get, never):starling.display.DisplayObjectContainer;
	public var containerUI(default, null):DisplayObjectContainer = new Sprite();
	public var height(get, set):Float;
	public var isOpen(get, never):Bool;
	public var parent(get, never):DisplayObjectContainer;
	public var rootContainer(get, set):DisplayObjectContainer;
	public var rootContainerStarling(get, set):starling.display.DisplayObjectContainer;
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	public var visible(get, set):Bool;
	public var width(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	private function get_alpha():Float { return this._container.alpha; }
	private function set_alpha(value:Float):Float
	{
		return this._container.alpha = this._containerStarling.alpha = value;
	}
	
	private function get_blendMode():BlendMode { return this._container.blendMode; }
	private function set_blendMode(value:BlendMode):BlendMode
	{
		return this._container.blendMode = value;
	}
	
	private var _cameraX:Float = 0;
	private function get_cameraX():Float { return this._cameraX; }
	private function set_cameraX(value:Float):Float
	{
		this.containerUI.x = this._container.x = this._containerStarling.x = this._x - value;
		return this._cameraX = value;
	}
	
	private var _cameraY:Float = 0;
	private function get_cameraY():Float { return this._cameraY; }
	private function set_cameraY(value:Float):Float
	{
		this.containerUI.y = this._container.y = this._containerStarling.y = this._y - value;
		return this._cameraY = value;
	}
	
	private var _container:Sprite = new Sprite();
	private function get_container():DisplayObjectContainer { return this._container; }
	
	private var _containerStarling:starling.display.Sprite = new starling.display.Sprite();
	private function get_containerStarling():starling.display.DisplayObjectContainer { return this._containerStarling; }
	
	private function get_blendModeStarling():String { return this._containerStarling.blendMode; }
	private function set_blendModeStarling(value:String):String
	{
		return this._containerStarling.blendMode = value;
	}
	
	private function get_height():Float { return Math.max(this._container.height, this._containerStarling.height); }
	private function set_height(value:Float):Float
	{
		var h:Float = this.height / this.scaleY;
		if (h == 0.0) return h;
		this.scaleY = value / h;
		return value;
	}
	
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	
	private function get_parent():DisplayObjectContainer { return this._rootContainer; }
	
	private var _rootContainer:DisplayObjectContainer;
	private function get_rootContainer():DisplayObjectContainer { return this._rootContainer; }
	private function set_rootContainer(value:DisplayObjectContainer):DisplayObjectContainer
	{
		if (value == this._rootContainer) return value;
		
		if (this._rootContainer != null)
		{
			this._rootContainer.removeChild(this._container);
			this._rootContainer.removeChild(this.containerUI);
		}
		
		if (value != null)
		{
			value.addChild(this._container);
			value.addChild(this.containerUI);
		}
		
		return this._rootContainer = value;
	}
	
	private var _rootContainerStarling:starling.display.DisplayObjectContainer;
	private function get_rootContainerStarling():starling.display.DisplayObjectContainer { return this._rootContainerStarling; }
	private function set_rootContainerStarling(value:starling.display.DisplayObjectContainer):starling.display.DisplayObjectContainer
	{
		if (this._rootContainerStarling == value) return value;
		
		if (value != null)
		{
			value.addChild(this._containerStarling);
		}
		else
		{
			this._containerStarling.removeFromParent();
		}
		
		return this._rootContainerStarling = value;
	}
	
	private var _rotation:Float = 0;
	private function get_rotation():Float { return this._rotation; }
	private function set_rotation(value:Float):Float 
	{
		this.containerUI.rotation = this._container.rotation = value;
		this._containerStarling.rotation = MathUtil.deg2rad(value);
		return this._rotation = value;
	}
	
	private var _scaleX:Float = 1.0;
	private function get_scaleX():Float { return this._scaleX; }
	private function set_scaleX(value:Float):Float 
	{
		this._container.scaleX = this._containerStarling.scaleX = value;
		return this._scaleX = value;
	}
	
	private var _scaleY:Float = 1.0;
	private function get_scaleY():Float { return this._scaleY; }
	private function set_scaleY(value:Float):Float 
	{
		this._container.scaleY = this._containerStarling.scaleY = value;
		return this._scaleY = value;
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
	
	private var _visible:Bool = true;
	private function get_visible():Bool { return this._visible; }
	private function set_visible(value:Bool):Bool
	{
		this._container.visible = this._containerStarling.visible = value;
		return this._visible = value;
	}
	
	private function get_width():Float { return Math.max(this._container.width, this._containerStarling.width); }
	private function set_width(value:Float):Float
	{
		var w:Float = this.width / this.scaleX;
		if (w == 0.0) return w;
		this.scaleX = value / w;
		return value;
	}
	
	private var _x:Float = 0;
	private function get_x():Float { return this._x; }
	private function set_x(value:Float):Float 
	{
		this.containerUI.x = this._container.x = this._containerStarling.x = value - this._cameraX;
		return this._x = value;
	}
	
	private var _y:Float = 0;
	private function get_y():Float { return this._y; }
	private function set_y(value:Float):Float 
	{
		this.containerUI.y = this._container.y = this._containerStarling.y = value - this._cameraY;
		return this._y = value;
	}
	
	private var _allObjects:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
	private var _displayObjects:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	private var _pivotIndicator:PivotIndicator = new PivotIndicator(UIConfig.CONTAINER_PIVOT_SIZE, UIConfig.CONTAINER_PIVOT_COLOR,
		UIConfig.CONTAINER_PIVOT_ALPHA, UIConfig.CONTAINER_PIVOT_OUTLINE_COLOR, UIConfig.CONTAINER_PIVOT_OUTLINE_ALPHA);
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		var object:ValEditorObject;
		for (i in new ReverseIterator(this._objects.length - 1, 0))
		{
			object = this._objects[i];
			removeObject(object);
			if (object.canBeDestroyed())
			{
				ValEditor.destroyObject(object);
			}
		}
		
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
		this.viewCenterX = this._viewCenterX;
		this.viewCenterY = this._viewCenterY;
	}
	
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		var rect:Rectangle = null;
		var rectStarling:Rectangle = null;
		var targetSpaceStarling:Dynamic = null;
		
		if (targetSpace == this || targetSpace == this._container)
		{
			targetSpace = this._container;
			targetSpaceStarling = this._containerStarling;
		}
		else if (targetSpace == this._rootContainer)
		{
			targetSpaceStarling = this._rootContainerStarling;
		}
		
		rect = this._container.getBounds(targetSpace);
		rectStarling = this._containerStarling.getBounds(targetSpaceStarling);
		
		return rect.union(rectStarling);
	}
	
	public function canAddObject(object:ValEditorObject):Bool
	{
		if (object.isDisplayObject)
		{
			return object.displayObjectType == DisplayObjectType.OPENFL || object.displayObjectType == DisplayObjectType.STARLING;
		}
		else if (object.isContainer)
		{
			return object.isContainerOpenFL || object.isContainerStarling;
		}
		return true;
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
	
	public function getActiveObject(objectID:String):ValEditorObject
	{
		return getObject(objectID);
	}
	
	public function getObject(objectID:String):ValEditorObject
	{
		return this._allObjects.get(objectID);
	}
	
	public function hasActiveObject(objectID:String):Bool
	{
		return hasObject(objectID);
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
	
	public function addObject(object:ValEditorObject):Void
	{
		this._allObjects.set(object.objectID, object);
		this._objects[this._objects.length] = object;
		this.activeObjectsCollection.add(object);
		this.allObjectsCollection.add(object);
		
		object.addEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.addEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.addEventListener(RenameEvent.RENAMED, object_renamed);
		
		if (object.isDisplayObject)
		{
			this._displayObjects[this._displayObjects.length] = object;
			if (object.displayObjectType == DisplayObjectType.OPENFL)
			{
				this._container.addChild(cast object.object);
				this._container.addChild(cast object.interactiveObject);
			}
			else
			{
				this._containerStarling.addChild(cast object.object);
				this._containerStarling.addChild(cast object.interactiveObject);
			}
		}
		else if (object.isContainer)
		{
			this._displayObjects[this._displayObjects.length] = object;
			if (object.isContainerOpenFL)
			{
				cast(object.object, IContainerOpenFLEditable).rootContainer = this._container;
			}
			else if (object.isContainerStarling)
			{
				cast(object.object, IContainerStarlingEditable).rootContainerStarling = this._containerStarling;
			}
		}
		
		object.container = this;
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED, object);
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED_TO_CONTAINER, object);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		this._allObjects.remove(object.objectID);
		this._objects.remove(object);
		this.activeObjectsCollection.remove(object);
		this.allObjectsCollection.remove(object);
		
		object.removeEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.removeEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.removeEventListener(RenameEvent.RENAMED, object_renamed);
		
		if (object.isDisplayObject)
		{
			this._displayObjects.remove(object);
			if (object.displayObjectType == DisplayObjectType.OPENFL)
			{
				this._container.removeChild(cast object.object);
				this._container.removeChild(cast object.interactiveObject);
			}
			else
			{
				this._containerStarling.removeChild(cast object.object);
			}
		}
		else if (object.isContainer)
		{
			this._displayObjects.remove(object);
			if (object.isContainerOpenFL)
			{
				cast(object.object, IContainerOpenFLEditable).rootContainer = null;
			}
			else if (object.isContainerStarling)
			{
				cast(object.object, IContainerStarlingEditable).rootContainerStarling = null;
			}
		}
		
		object.container = null;
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED, object);
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED_FROM_CONTAINER, object);
	}
	
	public function removeObjectCompletely(object:ValEditorObject):Void
	{
		removeObject(object);
	}
	
	public function getContainerDependencies(data:ContainerSaveData):Void
	{
		for (object in this._objects)
		{
			if (object.template != null && object.clss.isContainer && !data.hasDependency(object.template))
			{
				data.addDependency(object.template);
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
	
	private function object_renamed(evt:RenameEvent):Void
	{
		var object:ValEditorObject = cast evt.target;
		
		this._allObjects.remove(evt.previousNameOrID);
		this._allObjects.set(object.objectID, object);
		this.activeObjectsCollection.updateAt(this.activeObjectsCollection.indexOf(object));
		this.allObjectsCollection.updateAt(this.allObjectsCollection.indexOf(object));
	}
	
	private function cloneTo(container:SpriteContainerOpenFLStarlingEditable):Void
	{
		container.alpha = this.alpha;
		container.blendMode = this.blendMode;
		container.blendModeStarling = this.blendModeStarling;
		container.rotation = this.rotation;
		container.scaleX = this.scaleX;
		container.scaleY = this.scaleY;
		container.visible = this.visible;
		container.viewCenterX = this.viewCenterX;
		container.viewCenterY = this.viewCenterY;
		container.x = this.x;
		container.y = this.y;
		
		var cloneObject:ValEditorObject;
		for (object in this._objects)
		{
			cloneObject = ValEditor.cloneObject(object);
			object.currentCollection.copyValuesTo(cloneObject.currentCollection);
			container.addObject(cloneObject);
		}
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		var object:ValEditorObject;
		var objects:Array<Dynamic> = json.objects;
		for (data in objects)
		{
			if (data.templateID != null)
			{
				object = ValEditor.getTemplate(data.templateID).getInstance(data.id);
			}
			else
			{
				object = ValEditor.getClassByName(data.clss).getObjectByID(data.id);
			}
			object.currentCollection.apply();
			if (object.interactiveObject != null)
			{
				object.interactiveObject.objectUpdate(object);
			}
			addObject(object);
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		var objects:Array<Dynamic> = [];
		var data:Dynamic;
		for (object in this._objects)
		{
			data = {};
			data.id = object.id;
			if (object.template != null)
			{
				data.templateID = object.template.id;
			}
			else
			{
				data.clss = object.clss.className;
			}
			objects[objects.length] = data;
		}
		json.objects = objects;
		
		return json;
	}
	
}
package valeditor.container;
import starling.display.BlendMode;
import valeditor.ValEditorObjectLibrary;

#if starling
import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;
import valedit.utils.RegularPropertyName;
import valedit.utils.ReverseIterator;
import valeditor.container.IContainerEditable;
import valeditor.container.IContainerStarlingEditable;
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
class SpriteContainerStarlingEditable extends EventDispatcher implements IContainerEditable implements IContainerStarlingEditable
{
	static private var _POOL:Array<SpriteContainerStarlingEditable> = new Array<SpriteContainerStarlingEditable>();
	
	static public function fromPool():SpriteContainerStarlingEditable
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SpriteContainerStarlingEditable();
	}
	
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var alpha(get, set):Float;
	public var blendMode(get, set):String;
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var containerStarling(get, never):starling.display.DisplayObjectContainer;
	public var containerUI(default, null):DisplayObjectContainer = new Sprite();
	public var height(get, set):Float;
	public var isLoaded(get, never):Bool;
	public var isOpen(get, never):Bool;
	public var mask(get, set):starling.display.DisplayObject;
	public var maskInverted(get, set):Bool;
	public var objectLibrary(default, null):ValEditorObjectLibrary = new ValEditorObjectLibrary();
	public var parent(get, never):starling.display.DisplayObjectContainer;
	public var pivotX(get, set):Float;
	public var pivotY(get, set):Float;
	public var rootContainer(get, set):DisplayObjectContainer;
	public var rootContainerStarling(get, set):starling.display.DisplayObjectContainer;
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var skewX(get, set):Float;
	public var skewY(get, set):Float;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	public var visible(get, set):Bool;
	public var width(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	private function get_alpha():Float { return this._containerStarling.alpha; }
	private function set_alpha(value:Float):Float
	{
		return this._containerStarling.alpha = value;
	}
	
	private function get_blendMode():String { return this._containerStarling.blendMode; }
	private function set_blendMode(value:String):String
	{
		return this._containerStarling.blendMode = value;
	}
	
	private var _cameraX:Float = 0;
	private function get_cameraX():Float { return this._cameraX; }
	private function set_cameraX(value:Float):Float
	{
		this._containerStarling.x = this.containerUI.x = this.x - value;
		return this._cameraX = value;
	}
	
	private var _cameraY:Float = 0;
	private function get_cameraY():Float { return this._cameraY; }
	private function set_cameraY(value:Float):Float
	{
		this._containerStarling.y = this.containerUI.y = this.y - value;
		return this._cameraY = value;
	}
	
	private var _containerStarling:starling.display.Sprite = new starling.display.Sprite();
	private function get_containerStarling():starling.display.Sprite { return this._containerStarling; }
	
	private function get_height():Float { return this._containerStarling.height; }
	private function set_height(value:Float):Float
	{
		return this._containerStarling.height = value;
	}
	
	private function get_isLoaded():Bool { return this.objectLibrary.isLoaded; }
	
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	
	private function get_mask():starling.display.DisplayObject { return this._containerStarling.mask; }
	private function set_mask(value:starling.display.DisplayObject):starling.display.DisplayObject
	{
		return this._containerStarling.mask = value;
	}
	
	private function get_maskInverted():Bool { return this._containerStarling.maskInverted; }
	private function set_maskInverted(value:Bool):Bool
	{
		return this._containerStarling.maskInverted = value;
	}
	
	private function get_parent():starling.display.DisplayObjectContainer { return this._rootContainerStarling; }
	
	private function get_pivotX():Float { return this._containerStarling.pivotX; }
	private function set_pivotX(value:Float):Float
	{
		return this._containerStarling.pivotX = value;
	}
	
	private function get_pivotY():Float { return this._containerStarling.pivotY; }
	private function set_pivotY(value:Float):Float
	{
		return this._containerStarling.pivotY = value;
	}
	
	private var _rootContainer:DisplayObjectContainer;
	private function get_rootContainer():DisplayObjectContainer { return this._rootContainer; }
	private function set_rootContainer(value:DisplayObjectContainer):DisplayObjectContainer
	{
		if (value == this._rootContainer) return value;
		
		if (this._rootContainer != null)
		{
			this._rootContainer.removeChild(this.containerUI);
		}
		
		if (value != null)
		{
			value.addChild(this.containerUI);
		}
		
		return this._rootContainer = value;
	}
	
	private var _rootContainerStarling:starling.display.DisplayObjectContainer;
	private function get_rootContainerStarling():starling.display.DisplayObjectContainer { return this._rootContainerStarling; }
	private function set_rootContainerStarling(value:starling.display.DisplayObjectContainer):starling.display.DisplayObjectContainer
	{
		if (value == this._rootContainerStarling) return value;
		
		if (this._rootContainerStarling != null)
		{
			this._rootContainerStarling.removeChild(this._containerStarling);
		}
		
		if (value != null)
		{
			value.addChild(this._containerStarling);
		}
		
		return this._rootContainerStarling = value;
	}
	
	private function get_rotation():Float { return this._containerStarling.rotation; }
	private function set_rotation(value:Float):Float
	{
		this.containerUI.rotation = MathUtil.rad2deg(value);
		return this._containerStarling.rotation = value;
	}
	
	private function get_scaleX():Float { return this._containerStarling.scaleX; }
	private function set_scaleX(value:Float):Float
	{
		return this._containerStarling.scaleX = value;
	}
	
	private function get_scaleY():Float { return this._containerStarling.scaleY; }
	private function set_scaleY(value:Float):Float
	{
		return this._containerStarling.scaleY = value;
	}
	
	private function get_skewX():Float { return this._containerStarling.skewX; }
	private function set_skewX(value:Float):Float
	{
		return this._containerStarling.skewX = value;
	}
	
	private function get_skewY():Float { return this._containerStarling.skewY; }
	private function set_skewY(value:Float):Float
	{
		return this._containerStarling.skewY = value;
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
		this.cameraY = Math.fround(this._viewCenterY - value / 2);
		return this._viewHeight = value;
	}
	
	private var _viewWidth:Float = 0;
	private function get_viewWidth():Float { return this._viewWidth; }
	private function set_viewWidth(value:Float):Float
	{
		this.cameraX = Math.fround(this._viewCenterX - value / 2);
		return this._viewWidth = value;
	}
	
	private function get_visible():Bool { return this._containerStarling.visible; }
	private function set_visible(value:Bool):Bool
	{
		this.containerUI.visible = value;
		return this._containerStarling.visible = value;
	}
	
	private function get_width():Float { return this._containerStarling.width; }
	private function set_width(value:Float):Float
	{
		return this._containerStarling.width = value;
	}
	
	private var _x:Float = 0;
	private function get_x():Float { return this._x; }
	private function set_x(value:Float):Float
	{
		this._containerStarling.x = this.containerUI.x = value - this._cameraX;
		return this._x = value;
	}
	
	private var _y:Float = 0;
	private function get_y():Float { return this._y; }
	private function set_y(value:Float):Float
	{
		this._containerStarling.y = this.containerUI.y = value - this._cameraY;
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
		this.objectLibrary.clear();
		
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
		
		this._allObjects.clear();
		this._displayObjects.resize(0);
		this._objects.resize(0);
		
		this.alpha = 1.0;
		this.blendMode = BlendMode.NORMAL;
		this.cameraX = 0;
		this.cameraY = 0;
		this.rotation = 0;
		this.scaleX = 1.0;
		this.scaleY = 1.0;
		this.visible = true;
		this.x = 0;
		this.y = 0;
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
		// no need ?
	}
	
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		if (targetSpace == this)
		{
			targetSpace = this._containerStarling;
		}
		return this._containerStarling.getBounds(targetSpace);
	}
	
	public function canAddObject(object:ValEditorObject):Bool
	{
		if (object.isDisplayObject)
		{
			return object.isDisplayObjectStarling;
		}
		else if (object.isContainer)
		{
			return object.isContainerStarling && !object.isContainerOpenFL;
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
			this._containerStarling.addChild(object.object);
			this._containerStarling.addChild(cast object.interactiveObject);
		}
		else if (object.isContainer)
		{
			this._displayObjects[this._displayObjects.length] = object;
			if (object.isContainerStarling)
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
			this._containerStarling.removeChild(cast object.object);
			this._containerStarling.removeChild(cast object.interactiveObject);
		}
		else if (object.isContainer)
		{
			this._displayObjects.remove(object);
			if (object.isContainerStarling)
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
	
	private function cloneTo(container:SpriteContainerStarlingEditable):Void
	{
		container.alpha = this.alpha;
		container.blendMode = this.blendMode;
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
		this.viewCenterX = json.viewCenterX;
		this.viewCenterY = json.viewCenterY;
		
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
		
		json.viewCenterX = this.viewCenterX;
		json.viewCenterY = this.viewCenterY;
		
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
#end
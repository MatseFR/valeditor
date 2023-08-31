package valeditor;

import feathers.data.ArrayCollection;
import haxe.ds.ObjectMap;
import juggler.animation.IAnimatable;
import juggler.animation.Juggler;
import openfl.Lib;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import valedit.DisplayObjectType;
import valedit.ValEditContainer;
import valedit.ValEditLayer;
import valedit.utils.RegularPropertyName;
import valeditor.events.ContainerEvent;
import valeditor.events.LayerEvent;
import valeditor.events.SelectionEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.UIConfig;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class ValEditorContainer extends ValEditContainer implements IAnimatable implements IValEditorContainer
{
	static private var _POOL:Array<ValEditorContainer> = new Array<ValEditorContainer>();
	
	static public function fromPool():ValEditorContainer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorContainer();
	}
	
	public var isOpen(get, never):Bool;
	public var layerCollection(default, null):ArrayCollection<ValEditorLayer> = new ArrayCollection<ValEditorLayer>();
	public var objectCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var selection(default, null):ValEditorObjectGroup = new ValEditorObjectGroup();
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	
	private var _isOpen:Bool;
	private function get_isOpen():Bool { return this._isOpen; }
	
	override function set_x(value:Float):Float 
	{
		if (this._containerUI != null)
		{
			this._containerUI.x = value - this._cameraX;
		}
		return super.set_x(value);
	}
	
	override function set_y(value:Float):Float 
	{
		if (this._containerUI != null)
		{
			this._containerUI.y = value - this._cameraY;
		}
		return super.set_y(value);
	}
	
	override function set_cameraX(value:Float):Float 
	{
		if (this._containerUI != null)
		{
			this._containerUI.x = this._x - value;
		}
		return super.set_cameraX(value);
	}
	
	override function set_cameraY(value:Float):Float 
	{
		if (this._containerUI != null)
		{
			this._containerUI.y = this._y - value;
		}
		return super.set_cameraY(value);
	}
	
	override function set_currentLayer(value:ValEditLayer):ValEditLayer 
	{
		if (this._currentLayer == value) return value;
		super.set_currentLayer(value);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
		return this._currentLayer;
	}
	
	override function set_rootContainer(value:DisplayObjectContainer):DisplayObjectContainer 
	{
		var oldContainer:DisplayObjectContainer = this._rootContainer;
		super.set_rootContainer(value);
		if (value != null)
		{
			value.addChild(this._containerUI);
		}
		else if (oldContainer != null)
		{
			oldContainer.removeChild(this._containerUI);
		}
		return value;
	}
	
	private var _viewCenterX:Float = 0;
	private function get_viewCenterX():Float { return this._viewCenterX; }
	private function set_viewCenterX(value:Float):Float
	{
		this.cameraX = value - this._viewWidth / 2;
		return this._viewCenterX;
	}
	
	private var _viewCenterY:Float = 0;
	private function get_viewCenterY():Float { return this._viewCenterY; }
	private function set_viewCenterY(value:Float):Float
	{
		this.cameraY = value - this._viewHeight / 2;
		return this._viewCenterX;
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
	
	private var _containerUI:Sprite = new Sprite();
	private var _pivotIndicator:PivotIndicator = new PivotIndicator(UIConfig.CONTAINER_PIVOT_SIZE, UIConfig.CONTAINER_PIVOT_COLOR,
		UIConfig.CONTAINER_PIVOT_ALPHA, UIConfig.CONTAINER_PIVOT_OUTLINE_COLOR, UIConfig.CONTAINER_PIVOT_OUTLINE_ALPHA);
	
	private var _interactiveObjectToValEditObject:ObjectMap<Dynamic, ValEditorObject> = new ObjectMap<Dynamic, ValEditorObject>();
	
	private var _mouseObject:ValEditorObject;
	private var _mouseObjectOffsetX:Float;
	private var _mouseObjectOffsetY:Float;
	
	private var _mouseDownOnObject:Bool;
	private var _mouseDownWithCtrl:Bool;
	private var _mouseDownWithShift:Bool;
	
	private var _middleMouseX:Float;
	private var _middleMouseY:Float;
	
	private var _layerNameIndex:Int = 0;
	private var _objectsToDeselect:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _pt:Point = new Point();
	
	public function new() 
	{
		this.timeLine = new ValEditorTimeLine(0);
		super();
		this._containerUI.addChild(this._pivotIndicator);
	}
	
	override public function clear():Void
	{
		this.layerCollection.removeAll();
		this.objectCollection.removeAll();
		this.viewCenterX = 0;
		this.viewCenterY = 0;
		this.viewWidth = 0;
		this.viewHeight = 0;
		
		this._currentLayer = null;
		this._interactiveObjectToValEditObject.clear();
		
		this._mouseObject = null;
		
		this.selection.clear();
		
		this._layerNameIndex = 0;
		
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function play():Void 
	{
		this.timeLine.updateLastFrameIndex();
		super.play();
	}
	
	public function adjustView():Void
	{
		this.viewCenterX = this._viewCenterX;
		this.viewCenterY = this._viewCenterY;
	}
	
	public function makeLayerName():String
	{
		var name:String = null;
		while (true)
		{
			this._layerNameIndex++;
			name = "layer " + this._layerNameIndex;
			if (!this._layerMap.exists(name)) break;
		}
		return name;
	}
	
	public function canAddObject():Bool
	{
		return cast(this._currentLayer, ValEditorLayer).canAddObject();
	}
	
	override public function addLayer(layer:ValEditLayer):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.add(cast layer);
		super.addLayer(layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_ADDED, layer);
		this.currentLayer = layer;
	}
	
	override public function addLayerAt(layer:ValEditLayer, index:Int):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.addAt(cast layer, index);
		super.addLayerAt(layer, index);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_ADDED, layer);
		this.currentLayer = layer;
	}
	
	public function getLayerIndex(layer:ValEditLayer):Int
	{
		return this._layers.indexOf(layer);
	}
	
	override public function removeLayer(layer:ValEditLayer):Void 
	{
		var index:Int = this.layerCollection.indexOf(cast layer);
		this.layerCollection.remove(cast layer);
		super.removeLayer(layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_REMOVED, layer);
		if (this._currentLayer == layer)
		{
			if (index != 0)
			{
				index --;
			}
			this.currentLayer = this.layerCollection.get(index);
		}
	}
	
	override public function removeLayerAt(index:Int):Void 
	{
		var layer:ValEditLayer = this._layers[index];
		this.layerCollection.removeAt(index);
		super.removeLayerAt(index);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_REMOVED, layer);
		if (this._currentLayer == layer)
		{
			if (index != 0)
			{
				index --;
			}
			this.currentLayer = this.layerCollection.get(index);
		}
	}
	
	override function layer_objectAdded(evt:LayerEvent):Void 
	{
		super.layer_objectAdded(evt);
		
		var editorObject:ValEditorObject = cast evt.object;
		
		editorObject.container = this;
		
		if (editorObject.isDisplayObject)
		{
			switch (editorObject.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					var dispatcher:EventDispatcher = cast editorObject.interactiveObject;
					dispatcher.addEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
				
				#if starling
				case DisplayObjectType.STARLING :
					var starlingDispatcher:starling.events.EventDispatcher = cast editorObject.interactiveObject;
					starlingDispatcher.addEventListener(TouchEvent.TOUCH, onObjectTouch);
				#end
				
				default :
					throw new Error("ValEditorContainer.layer_objectAdded ::: unknown display object type " + editorObject.displayObjectType);
			}
		}
		
		if (editorObject.interactiveObject != null)
		{
			this._interactiveObjectToValEditObject.set(editorObject.interactiveObject, editorObject);
		}
		this.objectCollection.add(editorObject);
	}
	
	override function layer_objectRemoved(evt:LayerEvent):Void 
	{
		super.layer_objectRemoved(evt);
		
		var editorObject:ValEditorObject = cast evt.object;
		
		editorObject.container = null;
		
		if (editorObject.isDisplayObject)
		{
			switch (editorObject.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					var dispatcher:EventDispatcher = cast editorObject.interactiveObject;
					dispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
				
				#if starling
				case DisplayObjectType.STARLING :
					var starlingDispatcher:starling.events.EventDispatcher = cast editorObject.interactiveObject;
					starlingDispatcher.removeEventListener(TouchEvent.TOUCH, onObjectTouch);
				#end
				
				default :
					throw new Error("ValEditorContainer.layer_objectRemoved ::: unknown display object type " + editorObject.displayObjectType);
			}
		}
		
		if (editorObject.interactiveObject != null)
		{
			this._interactiveObjectToValEditObject.remove(editorObject.interactiveObject);
		}
		this.objectCollection.remove(editorObject);
	}
	
	public function open():Void
	{
		if (this._isOpen) return;
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
		Lib.current.stage.addEventListener(MouseEvent.CLICK, onStageMouseClick);
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
		
		Juggler.root.add(this);
		
		ContainerEvent.dispatch(this, ContainerEvent.OPEN);
	}
	
	public function close():Void
	{
		if (!this._isOpen) return;
		
		ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onSelectionChange);
		Lib.current.stage.removeEventListener(MouseEvent.CLICK, onStageMouseClick);
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
		
		Juggler.root.remove(this);
		
		ContainerEvent.dispatch(this, ContainerEvent.CLOSE);
	}
	
	private function onObjectMouseDown(evt:MouseEvent):Void
	{
		if (this._mouseDownOnObject) return;
		this._mouseDownOnObject = true;
		
		this._mouseDownWithCtrl = evt.ctrlKey;
		this._mouseDownWithShift = evt.shiftKey;
		
		var object:ValEditorObject = this._interactiveObjectToValEditObject.get(evt.target);
		if (!object.isSelectable) return;
		if (this._mouseObject != null && this._mouseObject != object && !this._mouseDownWithCtrl && !this._mouseDownWithShift)
		{
			ValEditor.selection.object = null;
		}
		this._mouseObject = object;
		this._mouseObject.isMouseDown = true;
		this.selection.isMouseDown = true;
		this._mouseObjectOffsetX = evt.localX;
		this._mouseObjectOffsetY = evt.localY;
		
		if (this.selection.hasObject(this._mouseObject))
		{
			for (object in this.selection)
			{
				if (object.isDisplayObject)
				{
					object.mouseRestoreX = object.getProperty(RegularPropertyName.X);
					object.mouseRestoreY = object.getProperty(RegularPropertyName.Y);
				}
			}
		}
		else
		{
			this._mouseObject.mouseRestoreX = this._mouseObject.getProperty(RegularPropertyName.X);
			this._mouseObject.mouseRestoreY = this._mouseObject.getProperty(RegularPropertyName.Y);
		}
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
	}
	
	private function onObjectMouseUp(evt:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
		
		if ((this._mouseDownWithCtrl && evt.ctrlKey) || (this._mouseDownWithShift && evt.shiftKey))
		{
			if (this.selection.hasObject(this._mouseObject))
			{
				ValEditor.selection.removeObject(this._mouseObject);
			}
			else
			{
				ValEditor.selection.addObject(this._mouseObject);
			}
		}
		else if (!this.selection.hasObject(this._mouseObject))
		{
			ValEditor.selection.object = this._mouseObject;
		}
		
		this._mouseObject.isMouseDown = false;
		this.selection.isMouseDown = false;
		
		if (ValEditor.isMouseOverUI)
		{
			// release outside
			if (this.selection.hasObject(this._mouseObject))
			{
				for (obj in this.selection)
				{
					if (obj.isDisplayObject)
					{
						obj.setProperty(RegularPropertyName.X, obj.mouseRestoreX);
						obj.setProperty(RegularPropertyName.Y, obj.mouseRestoreY);
					}
				}
			}
			else
			{
				this._mouseObject.setProperty(RegularPropertyName.X, this._mouseObject.mouseRestoreX);
				this._mouseObject.setProperty(RegularPropertyName.Y, this._mouseObject.mouseRestoreY);
			}
		}
		
		this._mouseObject = null;
		
		for (obj in this.selection)
		{
			obj.selectionBox.objectUpdate(obj);
			obj.pivotIndicator.objectUpdate(obj);
		}
	}
	
	private function onObjectRightMouseUp(evt:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
		
		this._mouseObject.isMouseDown = false;
		this.selection.isMouseDown = false;
		
		// cancel move
		if (this.selection.hasObject(this._mouseObject))
		{
			for (obj in this.selection)
			{
				if (obj.isDisplayObject)
				{
					obj.setProperty(RegularPropertyName.X, obj.mouseRestoreX);
					obj.setProperty(RegularPropertyName.Y, obj.mouseRestoreY);
				}
			}
		}
		else
		{
			this._mouseObject.setProperty(RegularPropertyName.X, this._mouseObject.mouseRestoreX);
			this._mouseObject.setProperty(RegularPropertyName.Y, this._mouseObject.mouseRestoreY);
		}
		
		this._mouseObject = null;
		
		for (obj in this.selection)
		{
			obj.selectionBox.objectUpdate(obj);
			obj.pivotIndicator.objectUpdate(obj);
		}
	}
	
	private function onObjectMouseMove(evt:MouseEvent):Void
	{
		// MouseEvent.stageX/Y is incorrect sometimes, at least on flash target
		// in the full editor it happens when mouse goes over the side panels, 
		// no biggie but the feeling is much better using Stage.mouseX directly
		
		this._mouseDownWithCtrl = false;
		this._mouseDownWithShift = false;
		
		var moveX:Float = Lib.current.stage.mouseX - this._x - this._mouseObjectOffsetX + this._cameraX - this._mouseObject.getProperty(RegularPropertyName.X);
		var moveY:Float = Lib.current.stage.mouseY - this._y - this._mouseObjectOffsetY + this._cameraY - this._mouseObject.getProperty(RegularPropertyName.Y);
		
		if (!this.selection.hasObject(this._mouseObject))
		{
			ValEditor.selection.object = null;
			this._mouseObject.modifyProperty(RegularPropertyName.X, moveX);
			this._mouseObject.modifyProperty(RegularPropertyName.Y, moveY);
		}
		else
		{
			this.selection.modifyDisplayProperty(RegularPropertyName.X, moveX);
			this.selection.modifyDisplayProperty(RegularPropertyName.Y, moveY);
		}
	}
	
	#if starling
	private function onObjectTouch(evt:TouchEvent):Void
	{
		var touch:Touch = evt.touches[0];
		var object:ValEditorObject = this._interactiveObjectToValEditObject.get(evt.target);
		if (touch.phase == TouchPhase.BEGAN)
		{
			if (this._mouseDownOnObject) return;
			this._mouseDownOnObject = true;
			
			this._mouseDownWithCtrl = evt.ctrlKey;
			this._mouseDownWithShift = evt.shiftKey;
			
			if (this._mouseObject != null && this._mouseObject != object && !this._mouseDownWithCtrl && !this._mouseDownWithShift)
			{
				ValEditor.selection.object = null;
			}
			this._mouseObject = object;
			this._mouseObject.isMouseDown = true;
			this.selection.isMouseDown = true;
			touch.getLocation(cast object.interactiveObject, _pt);
			if (this._mouseObject.hasPivotProperties)
			{
				this._mouseObjectOffsetX = _pt.x - this._mouseObject.getProperty(RegularPropertyName.PIVOT_X);
				this._mouseObjectOffsetY = _pt.y - this._mouseObject.getProperty(RegularPropertyName.PIVOT_Y);
			}
			else
			{
				this._mouseObjectOffsetX = _pt.x;
				this._mouseObjectOffsetY = _pt.y;
			}
			
			if (this.selection.hasObject(this._mouseObject))
			{
				for (obj in this.selection)
				{
					if (obj.isDisplayObject)
					{
						obj.mouseRestoreX = obj.getProperty(RegularPropertyName.X);
						obj.mouseRestoreY = obj.getProperty(RegularPropertyName.Y);
					}
				}
			}
			else
			{
				this._mouseObject.mouseRestoreX = this._mouseObject.getProperty(RegularPropertyName.X);
				this._mouseObject.mouseRestoreY = this._mouseObject.getProperty(RegularPropertyName.Y);
			}
			
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
			Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
		}
		else if (touch.phase == TouchPhase.ENDED)
		{
			if (this._mouseObject == null) return;
			
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
			Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
			
			if ((this._mouseDownWithCtrl && evt.ctrlKey) || (this._mouseDownWithShift && evt.shiftKey))
			{
				if (this.selection.hasObject(this._mouseObject))
				{
					ValEditor.selection.removeObject(this._mouseObject);
				}
				else
				{
					ValEditor.selection.addObject(this._mouseObject);
				}
			}
			else if (!this.selection.hasObject(this._mouseObject))
			{
				ValEditor.selection.object = this._mouseObject;
			}
			
			this._mouseObject.isMouseDown = false;
			this.selection.isMouseDown = false;
			
			if (ValEditor.isMouseOverUI)
			{
				// release outside
				if (this.selection.hasObject(this._mouseObject))
				{
					for (obj in this.selection)
					{
						if (obj.isDisplayObject)
						{
							obj.setProperty(RegularPropertyName.X, obj.mouseRestoreX);
							obj.setProperty(RegularPropertyName.Y, obj.mouseRestoreY);
						}
					}
				}
				else
				{
					this._mouseObject.setProperty(RegularPropertyName.X, this._mouseObject.mouseRestoreX);
					this._mouseObject.setProperty(RegularPropertyName.Y, this._mouseObject.mouseRestoreY);
				}
			}
			
			this._mouseObject = null;
			
			for (obj in this.selection)
			{
				obj.selectionBox.objectUpdate(obj);
				obj.pivotIndicator.objectUpdate(obj);
			}
		}
	}
	#end
	
	public function selectAllVisible():Void
	{
		clearSelection();
		
		var visibleObjects:Array<ValEditorObject> = new Array<ValEditorObject>();
		for (layer in this.layerCollection)
		{
			layer.getAllVisibleObjects(visibleObjects);
		}
		for (object in visibleObjects)
		{
			ValEditor.selection.addObject(object);
		}
	}
	
	private function select(object:ValEditorObject):Void
	{
		if (object.isDisplayObject)
		{
			var box:SelectionBox = SelectionBox.fromPool();
			this._containerUI.addChild(box);
			object.selectionBox = box;
			
			var pivot:PivotIndicator = PivotIndicator.fromPool();
			this._containerUI.addChild(pivot);
			object.pivotIndicator = pivot;
		}
		
		this.selection.addObject(object);
	}
	
	private function unselect(object:ValEditorObject):Void
	{
		if (object.isDisplayObject)
		{
			var box:SelectionBox = object.selectionBox;
			if (box != null)
			{
				this._containerUI.removeChild(box);
				object.selectionBox = null;
				box.pool();
			}
			
			var pivot:PivotIndicator = object.pivotIndicator;
			if (pivot != null)
			{
				this._containerUI.removeChild(pivot);
				object.pivotIndicator = null;
				pivot.pool();
			}
		}
		
		this.selection.removeObject(object);
	}
	
	private function clearSelection():Void
	{
		for (object in this.selection)
		{
			this._objectsToDeselect.push(object);
		}
		
		for (object in this._objectsToDeselect)
		{
			unselect(object);
		}
		this._objectsToDeselect.resize(0);
	}
	
	private function onSelectionChange(evt:SelectionEvent):Void
	{
		if (evt.object == null)
		{
			clearSelection();
		}
		else if (Std.isOfType(evt.object, ValEditorObject))
		{
			var object:ValEditorObject = cast evt.object;
			if (this.selection.hasObject(object))
			{
				for (obj in this.selection)
				{
					if (obj != object) this._objectsToDeselect.push(obj);
				}
				
				for (obj in this._objectsToDeselect)
				{
					unselect(obj);
				}
				this._objectsToDeselect.resize(0);
			}
			else
			{
				clearSelection();
				select(object);
			}
		}
		else if (Std.isOfType(evt.object, ValEditorObjectGroup))
		{
			var group:ValEditorObjectGroup = cast evt.object;
			for (obj in this.selection)
			{
				if (!group.hasObject(obj))
				{
					this._objectsToDeselect.push(obj);
				}
			}
			
			for (obj in this._objectsToDeselect)
			{
				unselect(obj);
			}
			this._objectsToDeselect.resize(0);
			
			for (obj in group)
			{
				if (!this.selection.hasObject(obj))
				{
					select(obj);
				}
			}
		}
		else
		{
			clearSelection();
		}
	}
	
	private function onStageMouseClick(evt:MouseEvent):Void
	{
		if (evt.target != Lib.current.stage) return;
		if (this._mouseObject != null) return;
		//if (this.selection.numObjects == 0) return;
		ValEditor.selection.object = null;
	}
	
	private function onMiddleMouseDown(evt:MouseEvent):Void
	{
		if (evt.target != Lib.current.stage && !Std.isOfType(evt.target, IInteractiveObject)) return;
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.RELEASE_OUTSIDE, onMiddleMouseUpOutside);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMiddleMouseMove);
		
		this._middleMouseX = evt.stageX;
		this._middleMouseY = evt.stageY;
	}
	
	private function onMiddleMouseUp(evt:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onMiddleMouseUpOutside);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMiddleMouseMove);
	}
	
	private function onMiddleMouseUpOutside(evt:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RELEASE_OUTSIDE, onMiddleMouseUpOutside);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMiddleMouseMove);
	}
	
	private function onMiddleMouseMove(evt:MouseEvent):Void
	{
		var xLoc:Float = evt.stageX;
		var yLoc:Float = evt.stageY;
		var moveX:Float = xLoc - this._middleMouseX;
		var moveY:Float = yLoc - this._middleMouseY;
		
		this.cameraX -= moveX;
		this.cameraY -= moveY;
		
		this._middleMouseX = xLoc;
		this._middleMouseY = yLoc;
	}
	
	public function advanceTime(time:Float):Void
	{
		this._mouseDownOnObject = false;
	}
	
}
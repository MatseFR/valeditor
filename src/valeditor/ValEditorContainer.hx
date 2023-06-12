package valeditor;

import feathers.data.ArrayCollection;
import haxe.ds.ObjectMap;
import inputAction.InputAction;
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
import valedit.ObjectType;
import valedit.ValEditContainer;
import valedit.ValEditLayer;
import valedit.ValEditObject;
import valedit.util.RegularPropertyName;
import valeditor.events.SelectionEvent;
import valeditor.input.InputActionID;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.UIConfig;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class ValEditorContainer extends ValEditContainer implements IAnimatable
{
	public var isOpen(get, never):Bool;
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
	
	public var viewWidth(get, set):Float;
	private var _viewWidth:Float = 0;
	private function get_viewWidth():Float { return this._viewWidth; }
	private function set_viewWidth(value:Float):Float
	{
		return this._viewWidth = value;
	}
	
	public var viewHeight(get, set):Float;
	private var _viewHeight:Float = 0;
	private function get_viewHeight():Float { return this._viewHeight; }
	private function set_viewHeight(value:Float):Float
	{
		return this._viewHeight = value;
	}
	
	public var viewCenterX(get, set):Float;
	private var _viewCenterX:Float = 0;
	private function get_viewCenterX():Float { return this._viewCenterX; }
	private function set_viewCenterX(value:Float):Float
	{
		this.cameraX = value - this._viewWidth / 2;
		return this._viewCenterX;
	}
	
	public var viewCenterY(get, set):Float;
	private var _viewCenterY:Float = 0;
	private function get_viewCenterY():Float { return this._viewCenterY; }
	private function set_viewCenterY(value:Float):Float
	{
		this.cameraY = value - this._viewHeight / 2;
		return this._viewCenterX;
	}
	
	public var layerCollection(default, null):ArrayCollection<ValEditorLayer> = new ArrayCollection<ValEditorLayer>();
	public var objectCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	
	private var _containerUI:Sprite = new Sprite();
	private var _pivotIndicator:PivotIndicator = new PivotIndicator(UIConfig.CONTAINER_PIVOT_SIZE, UIConfig.CONTAINER_PIVOT_COLOR,
		UIConfig.CONTAINER_PIVOT_ALPHA, UIConfig.CONTAINER_PIVOT_OUTLINE_COLOR, UIConfig.CONTAINER_PIVOT_OUTLINE_ALPHA);
	
	private var _interactiveObjectToValEditObject:ObjectMap<Dynamic, ValEditorObject> = new ObjectMap<Dynamic, ValEditorObject>();
	
	private var _mouseObject:ValEditorObject;
	private var _mouseObjectOffsetX:Float;
	private var _mouseObjectOffsetY:Float;
	private var _mouseObjectRestoreX:Float;
	private var _mouseObjectRestoreY:Float;
	
	private var _selection:ValEditorObjectGroup = new ValEditorObjectGroup();
	
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
		super();
		this._containerUI.addChild(this._pivotIndicator);
		var layer:ValEditorLayer = new ValEditorLayer();
		addLayer(layer);
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
			if (!this._layers.exists(name)) break;
		}
		return name;
	}
	
	override public function addLayer(layer:ValEditLayer):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.add(cast layer);
		super.addLayer(layer);
	}
	
	override public function addLayerAt(layer:ValEditLayer, index:Int):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.addAt(cast layer, index);
		super.addLayerAt(layer, index);
	}
	
	override public function removeLayer(layer:ValEditLayer):Void 
	{
		this.layerCollection.remove(cast layer);
		super.removeLayer(layer);
	}
	
	override public function add(object:ValEditObject):Void 
	{
		super.add(object);
		
		var editorObject:ValEditorObject = cast object;
		
		switch (object.objectType)
		{
			case ObjectType.DISPLAY_OPENFL :
				this._container.addChild(cast editorObject.interactiveObject);
				var dispatcher:EventDispatcher = cast editorObject.interactiveObject;
				dispatcher.addEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
			
			#if starling
			case ObjectType.DISPLAY_STARLING :
				this._containerStarling.addChild(cast editorObject.interactiveObject);
				var starlingDispatcher:starling.events.EventDispatcher = cast editorObject.interactiveObject;
				starlingDispatcher.addEventListener(TouchEvent.TOUCH, onObjectTouch);
			#end
			
			case ObjectType.OTHER :
				// nothing here
			
			default :
				throw new Error("ValEditorContainer.add ::: unknown object type " + object.objectType);
		}
		
		this._interactiveObjectToValEditObject.set(editorObject.interactiveObject, editorObject);
		this.objectCollection.add(editorObject);
	}
	
	override public function remove(object:ValEditObject):Void 
	{
		super.remove(object);
		
		var editorObject:ValEditorObject = cast object;
		
		switch (object.objectType)
		{
			case ObjectType.DISPLAY_OPENFL :
				this._container.removeChild(cast editorObject.interactiveObject);
				var dispatcher:EventDispatcher = cast editorObject.interactiveObject;
				dispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
			
			#if starling
			case ObjectType.DISPLAY_STARLING :
				this._containerStarling.removeChild(cast editorObject.interactiveObject);
				var starlingDispatcher:starling.events.EventDispatcher = cast editorObject.interactiveObject;
				starlingDispatcher.removeEventListener(TouchEvent.TOUCH, onObjectTouch);
			#end
			
			case ObjectType.OTHER :
				// nothing here
			
			default :
				throw new Error("ValEditorContainer.remove ::: unknown object type " + object.objectType);
		}
		
		this._interactiveObjectToValEditObject.remove(editorObject.interactiveObject);
		this.objectCollection.remove(editorObject);
	}
	
	public function open():Void
	{
		if (this._isOpen) return;
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
		Lib.current.stage.addEventListener(MouseEvent.CLICK, onStageMouseClick);
		Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
		
		Juggler.root.add(this);
	}
	
	public function close():Void
	{
		if (!this._isOpen) return;
		
		ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onSelectionChange);
		Lib.current.stage.removeEventListener(MouseEvent.CLICK, onStageMouseClick);
		Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
		
		Juggler.root.remove(this);
	}
	
	private function onObjectMouseDown(evt:MouseEvent):Void
	{
		if (this._mouseDownOnObject) return;
		this._mouseDownOnObject = true;
		
		this._mouseDownWithCtrl = evt.ctrlKey;
		this._mouseDownWithShift = evt.shiftKey;
		
		var object:ValEditorObject = this._interactiveObjectToValEditObject.get(evt.target);
		if (this._mouseObject != null && this._mouseObject != object && !this._mouseDownWithCtrl && !this._mouseDownWithShift)
		{
			ValEditor.selection.object = null;
		}
		this._mouseObject = object;
		this._mouseObject.isMouseDown = true;
		this._selection.isMouseDown = true;
		this._mouseObjectOffsetX = evt.localX;
		this._mouseObjectOffsetY = evt.localY;
		this._mouseObjectRestoreX = this._mouseObject.getProperty(RegularPropertyName.X);
		this._mouseObjectRestoreY = this._mouseObject.getProperty(RegularPropertyName.Y);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		
		cast(this._mouseObject.interactiveObject, EventDispatcher).addEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		cast(this._mouseObject.interactiveObject, EventDispatcher).addEventListener(MouseEvent.RELEASE_OUTSIDE, onObjectMouseUpOutside);
	}
	
	private function onObjectMouseUp(evt:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		cast(this._mouseObject.interactiveObject, EventDispatcher).removeEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		cast(this._mouseObject.interactiveObject, EventDispatcher).removeEventListener(MouseEvent.RELEASE_OUTSIDE, onObjectMouseUpOutside);
		
		if ((this._mouseDownWithCtrl && evt.ctrlKey) || (this._mouseDownWithShift && evt.shiftKey))
		{
			if (this._selection.hasObject(this._mouseObject))
			{
				ValEditor.selection.removeObject(this._mouseObject);
			}
			else
			{
				ValEditor.selection.addObject(this._mouseObject);
			}
		}
		else if (!this._selection.hasObject(this._mouseObject))
		{
			ValEditor.selection.object = this._mouseObject;
		}
		
		this._mouseObject.isMouseDown = false;
		this._selection.isMouseDown = false;
		
		this._mouseObject = null;
		
		for (obj in this._selection)
		{
			obj.selectionBox.objectUpdate(obj);
			obj.pivotIndicator.objectUpdate(obj);
		}
	}
	
	private function onObjectMouseUpOutside(evt:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		cast(this._mouseObject.interactiveObject, EventDispatcher).removeEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		cast(this._mouseObject.interactiveObject, EventDispatcher).removeEventListener(MouseEvent.RELEASE_OUTSIDE, onObjectMouseUpOutside);
		
		this._mouseObject.isMouseDown = false;
		this._selection.isMouseDown = false;
		
		if (!this._selection.hasObject(this._mouseObject))
		{
			ValEditor.selection.object = this._mouseObject;
		}
		
		this._mouseObject.setProperty(RegularPropertyName.X, this._mouseObjectRestoreX);
		this._mouseObject.setProperty(RegularPropertyName.Y, this._mouseObjectRestoreY);
		
		this._mouseObject = null;
	}
	
	private function onObjectMouseMove(evt:MouseEvent):Void
	{
		this._mouseDownWithCtrl = false;
		this._mouseDownWithShift = false;
		
		if (!this._selection.hasObject(this._mouseObject))
		{
			ValEditor.selection.object = null;
			this._mouseObject.setProperty(RegularPropertyName.X, evt.stageX - this._x - this._mouseObjectOffsetX + this._cameraX);
			this._mouseObject.setProperty(RegularPropertyName.Y, evt.stageY - this._y - this._mouseObjectOffsetY + this._cameraY);
		}
		else
		{
			var moveX:Float = evt.stageX - this._x - this._mouseObjectOffsetX + this._cameraX - this._mouseObject.getProperty(RegularPropertyName.X);
			var moveY:Float = evt.stageY - this._y - this._mouseObjectOffsetY + this._cameraY - this._mouseObject.getProperty(RegularPropertyName.Y);
			this._selection.modifyProperty(RegularPropertyName.X, moveX);
			this._selection.modifyProperty(RegularPropertyName.Y, moveY);
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
			this._selection.isMouseDown = true;
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
			this._mouseObjectRestoreX = this._mouseObject.getProperty(RegularPropertyName.X);
			this._mouseObjectRestoreY = this._mouseObject.getProperty(RegularPropertyName.Y);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		}
		else if (touch.phase == TouchPhase.ENDED)
		{
			if (this._mouseObject == null) return;
			
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
			
			if ((this._mouseDownWithCtrl && evt.ctrlKey) || (this._mouseDownWithShift && evt.shiftKey))
			{
				if (this._selection.hasObject(this._mouseObject))
				{
					ValEditor.selection.removeObject(this._mouseObject);
				}
				else
				{
					ValEditor.selection.addObject(this._mouseObject);
				}
			}
			else if (!this._selection.hasObject(this._mouseObject))
			{
				ValEditor.selection.object = this._mouseObject;
			}
			
			this._mouseObject.isMouseDown = false;
			this._selection.isMouseDown = false;
			
			if (ValEditor.isMouseOverUI)
			{
				// release outside
				this._mouseObject.setProperty(RegularPropertyName.X, this._mouseObjectRestoreX);
				this._mouseObject.setProperty(RegularPropertyName.Y, this._mouseObjectRestoreY);
			}
			
			this._mouseObject = null;
			
			for (obj in this._selection)
			{
				obj.selectionBox.objectUpdate(obj);
				obj.pivotIndicator.objectUpdate(obj);
			}
		}
	}
	#end
	
	private function select(object:ValEditorObject):Void
	{
		var box:SelectionBox = SelectionBox.fromPool();
		this._containerUI.addChild(box);
		object.selectionBox = box;
		
		var pivot:PivotIndicator = PivotIndicator.fromPool();
		this._containerUI.addChild(pivot);
		object.pivotIndicator = pivot;
		
		this._selection.addObject(object);
	}
	
	private function unselect(object:ValEditorObject):Void
	{
		var box:SelectionBox = object.selectionBox;
		this._containerUI.removeChild(box);
		object.selectionBox = null;
		box.pool();
		
		var pivot:PivotIndicator = object.pivotIndicator;
		this._containerUI.removeChild(pivot);
		object.pivotIndicator = null;
		pivot.pool();
		
		this._selection.removeObject(object);
	}
	
	private function clearSelection():Void
	{
		for (object in this._selection)
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
		else if (Std.isOfType(evt.object, ValEditorTemplate))
		{
			clearSelection();
		}
		else if (Std.isOfType(evt.object, ValEditorObject))
		{
			var object:ValEditorObject = cast evt.object;
			if (this._selection.hasObject(object))
			{
				for (obj in this._selection)
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
		else // ValEditorGroup
		{
			var group:ValEditorObjectGroup = cast evt.object;
			for (obj in this._selection)
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
				if (!this._selection.hasObject(obj))
				{
					select(obj);
				}
			}
		}
	}
	
	private function onStageMouseClick(evt:MouseEvent):Void
	{
		if (evt.target != Lib.current.stage) return;
		if (this._mouseObject != null) return;
		if (this._selection.numObjects == 0) return;
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
		
		if (this._selection.numObjects != 0)
		{
			var action:InputAction;
			
			// Move down
			if (ValEditor.input.justDid(InputActionID.MOVE_DOWN_1) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.Y, 1.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_DOWN_1);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.Y, 1.0);
				}
			}
			
			if (ValEditor.input.justDid(InputActionID.MOVE_DOWN_10) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.Y, 10.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_DOWN_10);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.Y, 10.0);
				}
			}
			
			// Move left
			if (ValEditor.input.justDid(InputActionID.MOVE_LEFT_1) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.X, -1.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_LEFT_1);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.X, -1.0);
				}
			}
			
			if (ValEditor.input.justDid(InputActionID.MOVE_LEFT_10) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.X, -10.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_LEFT_10);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.X, -10.0);
				}
			}
			
			// Move right
			if (ValEditor.input.justDid(InputActionID.MOVE_RIGHT_1) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.X, 1.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_RIGHT_1);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.X, 1.0);
				}
			}
			
			if (ValEditor.input.justDid(InputActionID.MOVE_RIGHT_10) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.X, 10.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_RIGHT_10);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.X, 10.0);
				}
			}
			
			// Move up
			if (ValEditor.input.justDid(InputActionID.MOVE_UP_1) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.Y, -1.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_UP_1);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.Y, -1.0);
				}
			}
			
			if (ValEditor.input.justDid(InputActionID.MOVE_UP_10) != null)
			{
				this._selection.modifyProperty(RegularPropertyName.Y, -10.0);
			}
			else
			{
				action = ValEditor.input.isDoing(InputActionID.MOVE_UP_10);
				if (action != null && action.canRepeat())
				{
					this._selection.modifyProperty(RegularPropertyName.Y, -10.0);
				}
			}
		}
	}
	
}
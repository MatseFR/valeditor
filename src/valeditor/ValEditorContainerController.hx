package valeditor;

import haxe.ds.ObjectMap;
import juggler.animation.IAnimatable;
import juggler.animation.Juggler;
import openfl.Lib;
import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import valedit.utils.RegularPropertyName;
import valedit.value.base.ExposedValue;
import valeditor.container.IContainerEditable;
import valeditor.container.IContainerOpenFLEditable;
import valeditor.container.IContainerStarlingEditable;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectSelect;
import valeditor.editor.action.object.ObjectUnselect;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.editor.action.selection.SelectionSetObject;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.events.ContainerEvent;
import valeditor.events.SelectionEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;
#if starling
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.events.TouchEvent;
#end

/**
 * ...
 * @author Matse
 */
class ValEditorContainerController implements IAnimatable
{
	public var container(get, never):IContainerEditable;
	public var containerObject(get, set):ValEditorObject;
	public var ignoreRightClick(default, null):Bool;
	public var selection(default, null):ValEditorObjectGroup = new ValEditorObjectGroup();
	
	private var _container:IContainerEditable;
	private function get_container():IContainerEditable { return this._container; }
	
	private var _containerObject:ValEditorObject;
	private function get_containerObject():ValEditorObject { return this._containerObject; }
	private function set_containerObject(value:ValEditorObject):ValEditorObject
	{
		if (this._containerObject == value) return value;
		
		var objects:Array<ValEditorObject> = new Array<ValEditorObject>();
		
		if (this._containerObject != null)
		{
			this._container.removeEventListener(ContainerEvent.OBJECT_ADDED_TO_CONTAINER, onObjectAdded);
			this._container.removeEventListener(ContainerEvent.OBJECT_REMOVED_FROM_CONTAINER, onObjectRemoved);
			
			ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onSelectionChange);
			Lib.current.stage.removeEventListener(MouseEvent.CLICK, onStageMouseClick);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			Lib.current.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseUp);
			
			Juggler.root.remove(this);
			
			this._container.getAllObjects(objects);
			for (object in objects)
			{
				unregisterObject(object);
			}
			objects.resize(0);
			
			this._container = null;
			this._containerOpenFL = null;
			#if starling
			this._containerStarling = null;
			#end
		}
		
		if (value != null)
		{
			this._container = value.object;
			
			this._container.addEventListener(ContainerEvent.OBJECT_ADDED_TO_CONTAINER, onObjectAdded);
			this._container.addEventListener(ContainerEvent.OBJECT_REMOVED_FROM_CONTAINER, onObjectRemoved);
			
			ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
			
			Lib.current.stage.addEventListener(MouseEvent.CLICK, onStageMouseClick);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			Lib.current.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
			
			Juggler.root.add(this);
			
			this._container.getAllObjects(objects);
			for (object in objects)
			{
				registerObject(object);
			}
			objects.resize(0);
			
			if (value.isContainerOpenFL)
			{
				this._containerOpenFL = cast(this._container, IContainerOpenFLEditable).container;
			}
			#if starling
			if (value.isContainerStarling)
			{
				this._containerStarling = cast(this._container, IContainerStarlingEditable).containerStarling;
			}
			#end
		}
		
		return this._containerObject = value;
	}
	
	private var _containerOpenFL:DisplayObjectContainer;
	#if starling
	private var _containerStarling:starling.display.DisplayObjectContainer;
	#end
	
	private var _interactiveObjectToValEditObject:ObjectMap<Dynamic, ValEditorObject> = new ObjectMap<Dynamic, ValEditorObject>();
	
	private var _mouseObject:ValEditorObject;
	private var _mouseObjectOffsetX:Float;
	private var _mouseObjectOffsetY:Float;
	
	private var _mouseDownOnObject:Bool;
	private var _mouseDownWithCtrl:Bool;
	private var _mouseDownWithShift:Bool;
	
	private var _middleMouseX:Float;
	private var _middleMouseY:Float;
	
	private var _ignoreNextStageClick:Bool = false;
	private var _objectsToDeselect:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _pt:Point = new Point();
	
	private var _actionCurrent:MultiAction;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.containerObject = null;
		this.ignoreRightClick = false;
		this._ignoreNextStageClick = false;
		this._interactiveObjectToValEditObject.clear();
		this._mouseObject = null;
		
		this.selection.clear();
		
		if (this._actionCurrent != null)
		{
			this._actionCurrent.pool();
			this._actionCurrent = null;
		}
	}
	
	public function advanceTime(time:Float):Void
	{
		this.ignoreRightClick = false;
		this._mouseDownOnObject = false;
	}
	
	private function registerObject(object:ValEditorObject):Void
	{
		if (object.isDisplayObject)
		{
			if (object.isDisplayObjectOpenFL)
			{
				var dispatcher:EventDispatcher = cast object.interactiveObject;
				dispatcher.addEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
			}
			#if starling
			else if (object.isDisplayObjectStarling)
			{
				var starlingDispatcher:starling.events.EventDispatcher = cast object.interactiveObject;
				starlingDispatcher.addEventListener(TouchEvent.TOUCH, onObjectTouch);
			}
			#end
		}
		
		if (object.isContainer)
		{
			if (object.isContainerOpenFL)
			{
				cast(object.object, IContainerOpenFLEditable).container.addEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
				this._interactiveObjectToValEditObject.set(cast(object.object, IContainerOpenFLEditable).container, object);
			}
			
			#if starling
			if (object.isContainerStarling)
			{
				cast(object.object, IContainerStarlingEditable).containerStarling.addEventListener(TouchEvent.TOUCH, onObjectTouch);
				this._interactiveObjectToValEditObject.set(cast(object.object, IContainerStarlingEditable).containerStarling, object);
			}
			#end
		}
		
		if (object.interactiveObject != null)
		{
			this._interactiveObjectToValEditObject.set(object.interactiveObject, object);
		}
	}
	
	private function unregisterObject(object:ValEditorObject):Void
	{
		if (object.isDisplayObject)
		{
			if (object.isDisplayObjectOpenFL)
			{
				var dispatcher:EventDispatcher = cast object.interactiveObject;
				dispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
			}
			#if starling
			else if (object.isDisplayObjectStarling)
			{
				var starlingDispatcher:starling.events.EventDispatcher = cast object.interactiveObject;
				starlingDispatcher.removeEventListener(TouchEvent.TOUCH, onObjectTouch);
			}
			#end
		}
		
		if (object.isContainer)
		{
			if (object.isContainerOpenFL)
			{
				cast(object.object, IContainerOpenFLEditable).container.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectMouseDown);
				this._interactiveObjectToValEditObject.remove(cast(object.object, IContainerOpenFLEditable).container);
			}
			
			#if starling
			if (object.isContainerStarling)
			{
				cast(object.object, IContainerStarlingEditable).containerStarling.removeEventListener(TouchEvent.TOUCH, onObjectTouch);
				this._interactiveObjectToValEditObject.remove(cast(object.object, IContainerStarlingEditable).containerStarling);
			}
			#end
		}
		
		if (object.interactiveObject != null)
		{
			this._interactiveObjectToValEditObject.remove(object.interactiveObject);
		}
	}
	
	private function onObjectAdded(evt:ContainerEvent):Void
	{
		registerObject(evt.object);
	}
	
	private function onObjectRemoved(evt:ContainerEvent):Void
	{
		unregisterObject(evt.object);
	}
	
	private function onObjectMouseDown(evt:MouseEvent):Void
	{
		if (FeathersWindows.isWindowOpen) return;
		if (this._mouseDownOnObject) return;
		var selectionClear:SelectionClear;
		
		// DEBUG
		if (this._actionCurrent != null)
		{
			throw new Error("ValEditorContainerController : this._actionCurrent should be null");
		}
		this._actionCurrent = MultiAction.fromPool();
		//\DEBUG
		
		this._mouseDownOnObject = true;
		
		this._mouseDownWithCtrl = evt.ctrlKey;
		this._mouseDownWithShift = evt.shiftKey;
		
		var object:ValEditorObject = this._interactiveObjectToValEditObject.get(evt.target);
		if (object == null) object = this._interactiveObjectToValEditObject.get(evt.currentTarget);
		if (!object.isSelectable) return;
		if (this._mouseObject != null && this._mouseObject != object && !this._mouseDownWithCtrl && !this._mouseDownWithShift)
		{
			if (ValEditor.selection.numObjects != 0)
			{
				selectionClear = SelectionClear.fromPool();
				selectionClear.setup(ValEditor.selection);
				this._actionCurrent.add(selectionClear);
			}
		}
		this._mouseObject = object;
		this._mouseObject.isMouseDown = true;
		this.selection.isMouseDown = true;
		
		this._pt.x = evt.stageX;
		this._pt.y = evt.stageY;
		this._pt = this._containerOpenFL.globalToLocal(this._pt);
		this._mouseObjectOffsetX = this._pt.x - this._mouseObject.getProperty(RegularPropertyName.X);
		this._mouseObjectOffsetY = this._pt.y - this._mouseObject.getProperty(RegularPropertyName.Y);
		
		if (this.selection.hasObject(this._mouseObject))
		{
			for (object in this.selection)
			{
				if (object.isDisplayObject || object.isContainer)
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
		var objectSelect:ObjectSelect;
		var objectUnselect:ObjectUnselect;
		var selectionSetObject:SelectionSetObject;
		
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
		
		if ((this._mouseDownWithCtrl && evt.ctrlKey) || (this._mouseDownWithShift && evt.shiftKey))
		{
			if (this.selection.hasObject(this._mouseObject))
			{
				objectUnselect = ObjectUnselect.fromPool();
				objectUnselect.setup();
				objectUnselect.addObject(this._mouseObject);
				this._actionCurrent.add(objectUnselect);
			}
			else
			{
				objectSelect = ObjectSelect.fromPool();
				objectSelect.setup();
				objectSelect.addObject(this._mouseObject);
				this._actionCurrent.add(objectSelect);
			}
		}
		else if (!this.selection.hasObject(this._mouseObject))
		{
			selectionSetObject = SelectionSetObject.fromPool();
			selectionSetObject.setup(this._mouseObject);
			this._actionCurrent.add(selectionSetObject);
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
					if (obj.isDisplayObject || obj.isContainer)
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
		else if (this._mouseObject.getProperty(RegularPropertyName.X) != this._mouseObject.mouseRestoreX || this._mouseObject.getProperty(RegularPropertyName.Y) != this._mouseObject.mouseRestoreY)
		{
			var value:ExposedValue;
			var valueChange:ValueChange;
			var valueUIUpdate:ValueUIUpdate;
			
			if (this.selection.hasObject(this._mouseObject))
			{
				for (obj in this.selection)
				{
					// X
					value = obj.getValue(RegularPropertyName.X);
					if (value.value != obj.mouseRestoreX)
					{
						valueChange = ValueChange.fromPool();
						valueChange.setup(value, value.value, obj.mouseRestoreX);
						this._actionCurrent.add(valueChange);
						
						valueUIUpdate = ValueUIUpdate.fromPool();
						valueUIUpdate.setup(value);
						this._actionCurrent.addPost(valueUIUpdate);
					}
					
					// Y
					value = obj.getValue(RegularPropertyName.Y);
					if (value.value != obj.mouseRestoreY)
					{
						valueChange = ValueChange.fromPool();
						valueChange.setup(value, value.value, obj.mouseRestoreY);
						this._actionCurrent.add(valueChange);
						
						valueUIUpdate = ValueUIUpdate.fromPool();
						valueUIUpdate.setup(value);
						this._actionCurrent.addPost(valueUIUpdate);
					}
				}
			}
			else
			{
				// X
				value = this._mouseObject.getValue(RegularPropertyName.X);
				if (value.value != this._mouseObject.mouseRestoreX)
				{
					valueChange = ValueChange.fromPool();
					valueChange.setup(value, value.value, this._mouseObject.mouseRestoreX);
					this._actionCurrent.add(valueChange);
					
					valueUIUpdate = ValueUIUpdate.fromPool();
					valueUIUpdate.setup(value);
					this._actionCurrent.addPost(valueUIUpdate);
				}
				
				// Y
				value = this._mouseObject.getValue(RegularPropertyName.Y);
				if (value.value != this._mouseObject.mouseRestoreY)
				{
					valueChange = ValueChange.fromPool();
					valueChange.setup(value, value.value, this._mouseObject.mouseRestoreY);
					this._actionCurrent.add(valueChange);
					
					valueUIUpdate = ValueUIUpdate.fromPool();
					valueUIUpdate.setup(value);
					this._actionCurrent.addPost(valueUIUpdate);
				}
			}
		}
		
		this._mouseObject = null;
		
		for (obj in this.selection)
		{
			obj.selectionBox.objectUpdate(obj);
			obj.pivotIndicator.objectUpdate(obj);
		}
		
		if (this._actionCurrent.numActions != 0)
		{
			ValEditor.actionStack.add(this._actionCurrent);
		}
		else
		{
			this._actionCurrent.pool();
		}
		this._actionCurrent = null;
	}
	
	private function onObjectRightMouseUp(evt:MouseEvent):Void
	{
		this._actionCurrent.pool();
		this._actionCurrent = null;
		
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onObjectMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
		
		this.ignoreRightClick = true;
		this._ignoreNextStageClick = true;
		
		this._mouseObject.isMouseDown = false;
		this.selection.isMouseDown = false;
		
		// cancel move
		if (this.selection.hasObject(this._mouseObject))
		{
			for (obj in this.selection)
			{
				if (obj.isDisplayObject || obj.isContainer)
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
		
		var moveX:Float = Lib.current.stage.mouseX - this._container.x - this._mouseObjectOffsetX + this._container.cameraX - this._mouseObject.getProperty(RegularPropertyName.X);
		var moveY:Float = Lib.current.stage.mouseY - this._container.y - this._mouseObjectOffsetY + this._container.cameraY - this._mouseObject.getProperty(RegularPropertyName.Y);
		
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
		if (FeathersWindows.isWindowOpen) return;
		
		var touch:Touch = evt.touches[0];
		var object:ValEditorObject = this._interactiveObjectToValEditObject.get(evt.target);
		if (object == null) object = this._interactiveObjectToValEditObject.get(evt.currentTarget);
		if (touch.phase == TouchPhase.BEGAN)
		{
			if (!object.isSelectable) return;
			if (this._mouseDownOnObject) return;
			var selectionClear:SelectionClear;
			
			// DEBUG
			if (this._actionCurrent != null)
			{
				throw new Error("ValEditorContainerController : this._actionCurrent should be null");
			}
			//\DEBUG
			this._actionCurrent = MultiAction.fromPool();
			
			this._mouseDownOnObject = true;
			
			this._mouseDownWithCtrl = evt.ctrlKey;
			this._mouseDownWithShift = evt.shiftKey;
			
			if (this._mouseObject != null && this._mouseObject != object && !this._mouseDownWithCtrl && !this._mouseDownWithShift)
			{
				if (ValEditor.selection.numObjects != 0)
				{
					selectionClear = SelectionClear.fromPool();
					selectionClear.setup(ValEditor.selection);
					this._actionCurrent.add(selectionClear);
				}
			}
			this._mouseObject = object;
			this._mouseObject.isMouseDown = true;
			this.selection.isMouseDown = true;
			if (object.interactiveObject != null)
			{
				touch.getLocation(this._containerStarling, this._pt);
				this._pt.x -= this._mouseObject.getProperty(RegularPropertyName.X);
				this._pt.y -= this._mouseObject.getProperty(RegularPropertyName.Y);
			}
			else
			{
				if (Std.isOfType(object.object, IContainerEditable))
				{
					touch.getLocation(this._containerStarling, this._pt);
					this._pt.x -= this._mouseObject.getProperty(RegularPropertyName.X);
					this._pt.y -= this._mouseObject.getProperty(RegularPropertyName.Y);
				}
				else
				{
					throw new Error("ValEditorContainerController : object has no interactive object and is not a container");
				}
			}
			
			this._mouseObjectOffsetX = this._pt.x;
			this._mouseObjectOffsetY = this._pt.y;
			
			if (this.selection.hasObject(this._mouseObject))
			{
				for (obj in this.selection)
				{
					if (obj.isDisplayObject || obj.isContainer)
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
			var objectSelect:ObjectSelect;
			var objectUnselect:ObjectUnselect;
			var selectionSetObject:SelectionSetObject;
			
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectMouseMove);
			Lib.current.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onObjectRightMouseUp);
			
			if ((this._mouseDownWithCtrl && evt.ctrlKey) || (this._mouseDownWithShift && evt.shiftKey))
			{
				if (this.selection.hasObject(this._mouseObject))
				{
					objectUnselect = ObjectUnselect.fromPool();
					objectUnselect.setup();
					objectUnselect.addObject(this._mouseObject);
					this._actionCurrent.add(objectUnselect);
				}
				else
				{
					objectSelect = ObjectSelect.fromPool();
					objectSelect.setup();
					objectSelect.addObject(this._mouseObject);
					this._actionCurrent.add(objectSelect);
				}
			}
			else if (!this.selection.hasObject(this._mouseObject))
			{
				selectionSetObject = SelectionSetObject.fromPool();
				selectionSetObject.setup(this._mouseObject);
				this._actionCurrent.add(selectionSetObject);
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
						if (obj.isDisplayObject || obj.isContainer)
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
			else
			{
				var value:ExposedValue;
				var valueChange:ValueChange;
				var valueUIUpdate:ValueUIUpdate;
				
				if (this.selection.hasObject(this._mouseObject))
				{
					for (obj in this.selection)
					{
						// X
						value = obj.getValue(RegularPropertyName.X);
						if (value.value != obj.mouseRestoreX)
						{
							valueChange = ValueChange.fromPool();
							valueChange.setup(value, value.value, obj.mouseRestoreX);
							this._actionCurrent.add(valueChange);
							
							valueUIUpdate = ValueUIUpdate.fromPool();
							valueUIUpdate.setup(value);
							this._actionCurrent.addPost(valueUIUpdate);
						}
						
						// Y
						value = obj.getValue(RegularPropertyName.Y);
						if (value.value != obj.mouseRestoreY)
						{
							valueChange = ValueChange.fromPool();
							valueChange.setup(value, value.value, obj.mouseRestoreY);
							this._actionCurrent.add(valueChange);
							
							valueUIUpdate = ValueUIUpdate.fromPool();
							valueUIUpdate.setup(value);
							this._actionCurrent.addPost(valueUIUpdate);
						}
					}
				}
				else
				{
					// X
					value = this._mouseObject.getValue(RegularPropertyName.X);
					if (value.value != this._mouseObject.mouseRestoreX)
					{
						valueChange = ValueChange.fromPool();
						valueChange.setup(value, value.value, this._mouseObject.mouseRestoreX);
						this._actionCurrent.add(valueChange);
						
						valueUIUpdate = ValueUIUpdate.fromPool();
						valueUIUpdate.setup(value);
						this._actionCurrent.addPost(valueUIUpdate);
					}
					
					// Y
					value = this._mouseObject.getValue(RegularPropertyName.Y);
					if (value.value != this._mouseObject.mouseRestoreY)
					{
						valueChange = ValueChange.fromPool();
						valueChange.setup(value, value.value, this._mouseObject.mouseRestoreY);
						this._actionCurrent.add(valueChange);
						
						valueUIUpdate = ValueUIUpdate.fromPool();
						valueUIUpdate.setup(value);
						this._actionCurrent.addPost(valueUIUpdate);
					}
				}
			}
			
			this._mouseObject = null;
			
			for (obj in this.selection)
			{
				obj.selectionBox.objectUpdate(obj);
				obj.pivotIndicator.objectUpdate(obj);
			}
			
			if (this._actionCurrent.numActions != 0)
			{
				ValEditor.actionStack.add(this._actionCurrent);
			}
			else
			{
				this._actionCurrent.pool();
			}
			this._actionCurrent = null;
		}
	}
	#end
	
	public function selectAllVisible(?action:MultiAction):Void
	{
		var visibleObjects:Array<ValEditorObject> = new Array<ValEditorObject>();
		this._container.getAllVisibleObjects(visibleObjects);
		
		if (action != null)
		{
			if (visibleObjects.length != 0)
			{
				var selectionClear:SelectionClear = SelectionClear.fromPool();
				selectionClear.setup(ValEditor.selection);
				action.add(selectionClear);
				
				var objectSelect:ObjectSelect;
				objectSelect = ObjectSelect.fromPool();
				objectSelect.setup(visibleObjects);
				action.add(objectSelect);
			}
		}
		else
		{
			clearSelection();
			
			for (object in visibleObjects)
			{
				ValEditor.selection.addObject(object);
			}
		}
	}
	
	private function select(object:ValEditorObject):Void
	{
		if (object.isDisplayObject || object.isContainer)
		{
			var box:SelectionBox = SelectionBox.fromPool();
			this._container.containerUI.addChild(box);
			object.selectionBox = box;
			
			var pivot:PivotIndicator = PivotIndicator.fromPool();
			this._container.containerUI.addChild(pivot);
			object.pivotIndicator = pivot;
		}
		
		this.selection.addObject(object);
	}
	
	private function unselect(object:ValEditorObject):Void
	{
		if (object.isDisplayObject || object.isContainer)
		{
			var box:SelectionBox = object.selectionBox;
			if (box != null)
			{
				this._container.containerUI.removeChild(box);
				object.selectionBox = null;
				box.pool();
			}
			
			var pivot:PivotIndicator = object.pivotIndicator;
			if (pivot != null)
			{
				this._container.containerUI.removeChild(pivot);
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
		if (this._ignoreNextStageClick)
		{
			this._ignoreNextStageClick = false;
			return;
		}
		if (evt.target != Lib.current.stage) return;
		if (this._mouseObject != null) return;
		
		if (ValEditor.selection.numObjects != 0)
		{
			var selectionClear:SelectionClear = SelectionClear.fromPool();
			selectionClear.setup(ValEditor.selection);
			ValEditor.actionStack.add(selectionClear);
		}
	}
	
	private function onStageMouseUp(evt:MouseEvent):Void
	{
		if (this._ignoreNextStageClick && ValEditor.isMouseOverUI)
		{
			this._ignoreNextStageClick = false;
		}
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
		
		this._container.cameraX -= moveX;
		this._container.cameraY -= moveY;
		
		this._middleMouseX = xLoc;
		this._middleMouseY = yLoc;
	}
	
}
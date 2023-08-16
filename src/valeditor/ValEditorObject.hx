package valeditor;

import haxe.Constraints.Function;
import openfl.geom.Rectangle;
import valedit.ExposedCollection;
import valedit.value.base.ExposedValue;
import valedit.IValEditContainer;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.events.ValueEvent;
import valeditor.events.ObjectEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class ValEditorObject extends ValEditObject 
{
	static private var _POOL:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	static public function fromPool(clss:ValEditClass, ?id:String):ValEditorObject
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(clss, id);
		return new ValEditorObject(clss, id);
	}
	
	public var container(get, set):IValEditContainer;
	public var getBoundsFunctionName(get, set):String;
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformProperty:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasVisibleProperty:Bool;
	public var hasRadianRotation:Bool;
	public var interactiveObject(get, set):IInteractiveObject;
	public var isMouseDown:Bool;
	public var isSelectable(get, set):Bool;
	public var mouseRestoreX:Float;
	public var mouseRestoreY:Float;
	public var pivotIndicator(get, set):PivotIndicator;
	public var selectionBox(get, set):SelectionBox;
	
	override function set_collection(value:ExposedCollection):ExposedCollection 
	{
		if (value == this._collection) return value;
		if (this._collection != null) this._collection.removeEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		if (value != null) value.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		return super.set_collection(value);
	}
	
	private var _container:IValEditContainer;
	private function get_container():IValEditContainer { return this._container; }
	private function set_container(value:IValEditContainer):IValEditContainer
	{
		if (value == this._container) return value;
		
		return this._container = value;
	}
	
	private var _getBoundsFunctionName:String = "getBounds";
	private function get_getBoundsFunctionName():String { return this._getBoundsFunctionName; }
	private function set_getBoundsFunctionName(value:String):String
	{
		if (value == this._getBoundsFunctionName) return value;
		if (this.object != null && value != null)
		{
			this._boundsFunction = Reflect.field(this.object, value);
		}
		return this._getBoundsFunctionName = value;
	}
	
	override function set_id(value:String):String 
	{
		super.set_id(value);
		ObjectEvent.dispatch(this, ObjectEvent.RENAMED, this);
		return this._id;
	}
	
	private var _interactiveObject:IInteractiveObject;
	private function get_interactiveObject():IInteractiveObject { return this._interactiveObject; }
	private function set_interactiveObject(value:IInteractiveObject):IInteractiveObject
	{
		if (value == this._interactiveObject) return value;
		if (value != null)
		{
			value.objectUpdate(this);
			if (!this._isSelectable) Reflect.setProperty(value, "visible", this._isSelectable);
			value.visibilityLocked = !this._isSelectable;
		}
		return this._interactiveObject = value;
	}
	
	private var _isSelectable:Bool = true;
	private function get_isSelectable():Bool { return this._isSelectable; }
	private function set_isSelectable(value:Bool):Bool
	{
		if (this._isSelectable == value) return value;
		if (this._interactiveObject != null)
		{
			this._interactiveObject.visibilityLocked = !value;
			if (value)
			{
				this._interactiveObject.objectUpdate(this);
			}
			else
			{
				Reflect.setProperty(this._interactiveObject, "visible", value);
			}
			
		}
		return this._isSelectable = value;
	}
	
	private var _pivotIndicator:PivotIndicator;
	private function get_pivotIndicator():PivotIndicator { return this._pivotIndicator; }
	private function set_pivotIndicator(value:PivotIndicator):PivotIndicator
	{
		if (value == this._pivotIndicator) return value;
		if (value != null)
		{
			value.objectUpdate(this);
		}
		return this._pivotIndicator = value;
	}
	
	private var _selectionBox:SelectionBox;
	private function get_selectionBox():SelectionBox { return this._selectionBox; }
	private function set_selectionBox(value:SelectionBox):SelectionBox
	{
		if (value == this._selectionBox) return value;
		if (value != null)
		{
			value.objectUpdate(this);
		}
		return this._selectionBox = value;
	}
	
	private var _boundsFunction:Function;
	
	public function new(clss:ValEditClass, ?id:String) 
	{
		super(clss, id);
	}
	
	override public function clear():Void 
	{
		super.clear();
		
		this.isSelectable = true;
		
		if (this._interactiveObject != null)
		{
			this._interactiveObject.pool();
			this._interactiveObject = null;
		}
		if (this._pivotIndicator != null)
		{
			this._pivotIndicator.pool();
			this._pivotIndicator = null;
		}
		if (this._selectionBox != null)
		{
			this._selectionBox.pool();
			this._selectionBox = null;
		}
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function ready():Void 
	{
		super.ready();
		this._boundsFunction = Reflect.field(this.object, this.getBoundsFunctionName);
	}
	
	public function valueChange(propertyName:String):Void
	{
		// this value changed on object, reflect changes on interactiveObject & realObject if needed
		this._regularPropertyName = this.propertyMap.getRegularPropertyName(propertyName);
		if (this._regularPropertyName == null) this._regularPropertyName = propertyName;
		
		if (this._interactiveObject != null && this._interactiveObject.hasInterestIn(this._regularPropertyName))
		{
			this._interactiveObject.objectUpdate(this);
		}
		
		if (this._selectionBox != null && this._selectionBox.hasInterestIn(this._regularPropertyName))
		{
			this._selectionBox.objectUpdate(this);
		}
		
		if (this._pivotIndicator != null && this._pivotIndicator.hasInterestIn(this._regularPropertyName))
		{
			this._pivotIndicator.objectUpdate(this);
		}
		
		ObjectEvent.dispatch(this, ObjectEvent.PROPERTY_CHANGE, this, this._regularPropertyName);
	}
	
	private function onValueChange(evt:ValueEvent):Void
	{
		this._regularPropertyName = this.propertyMap.getRegularPropertyName(evt.value.propertyName);
		if (this._regularPropertyName == null) this._regularPropertyName = evt.value.propertyName;
		
		if (this._interactiveObject != null && this._interactiveObject.hasInterestIn(this._regularPropertyName))
		{
			this._interactiveObject.objectUpdate(this);
		}
		
		if (this._selectionBox != null && this._selectionBox.hasInterestIn(this._regularPropertyName))
		{
			this._selectionBox.objectUpdate(this);
		}
		
		if (this._pivotIndicator != null && this._pivotIndicator.hasInterestIn(this._regularPropertyName))
		{
			this._pivotIndicator.objectUpdate(this);
		}
	}
	
	public function modifyProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		Reflect.setProperty(this.object, this._realPropertyName, Reflect.getProperty(this.object, this._realPropertyName) + value);
		
		if (dispatchValueChange && this._collection != null)
		{
			var value:ExposedValue = this._collection.getValue(this._realPropertyName);
			value.valueChanged();
			this._collection.readValues();
		}
		
		if (!objectOnly)
		{
			if (this._interactiveObject != null && this._interactiveObject.hasInterestIn(regularPropertyName))
			{
				this._interactiveObject.objectUpdate(this);
			}
			
			if (!this.isMouseDown)
			{
				if (this._selectionBox != null && this._selectionBox.hasInterestIn(regularPropertyName))
				{
					this._selectionBox.objectUpdate(this);
				}
			}
			
			if (this._pivotIndicator != null && this._pivotIndicator.hasInterestIn(regularPropertyName))
			{
				this._pivotIndicator.objectUpdate(this);
			}
		}
	}
	
	public function setProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		Reflect.setProperty(this.object, this._realPropertyName, value);
		
		if (dispatchValueChange && this._collection != null)
		{
			var value:ExposedValue = this._collection.getValue(this._realPropertyName);
			value.valueChanged();
			this._collection.readValues();
		}
		
		if (!objectOnly)
		{
			if (this._interactiveObject != null && this._interactiveObject.hasInterestIn(regularPropertyName))
			{
				this._interactiveObject.objectUpdate(this);
			}
			
			if (!this.isMouseDown)
			{
				if (this._selectionBox != null && this._selectionBox.hasInterestIn(regularPropertyName))
				{
					this._selectionBox.objectUpdate(this);
				}
			}
			
			if (this._pivotIndicator != null && this._pivotIndicator.hasInterestIn(regularPropertyName))
			{
				this._pivotIndicator.objectUpdate(this);
			}
		}
	}
	
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		return Reflect.callMethod(this.object, this._boundsFunction, [targetSpace]);
	}
	
}
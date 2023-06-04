package valeditor;

import haxe.Constraints.Function;
import openfl.geom.Rectangle;
import valedit.ExposedCollection;
import valedit.ExposedValue;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.events.ValueEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class ValEditorObject extends ValEditObject 
{
	public var collection(get, set):ExposedCollection;
	private var _collection:ExposedCollection;
	private function get_collection():ExposedCollection { return this._collection; }
	private function set_collection(value:ExposedCollection):ExposedCollection
	{
		if (value == this._collection) return value;
		if (this._collection != null) this._collection.removeEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		if (value != null) value.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		return this._collection = value;
	}
	
	public var getBoundsFunctionName(get, set):String;
	private var _getBoundsFunctionName:String = "getBounds";
	private function get_getBoundsFunctionName():String { return this._getBoundsFunctionName; }
	private function set_getBoundsFunctionName(value:String):String
	{
		if (value == this._getBoundsFunctionName) return value;
		if (this.object != null)
		{
			this._boundsFunction = Reflect.field(this.object, value);
		}
		return this._getBoundsFunctionName = value;
	}
	
	public var interactiveObject(get, set):IInteractiveObject;
	private var _interactiveObject:IInteractiveObject;
	private function get_interactiveObject():IInteractiveObject { return this._interactiveObject; }
	private function set_interactiveObject(value:IInteractiveObject):IInteractiveObject
	{
		if (value == this._interactiveObject) return value;
		if (value != null)
		{
			value.objectUpdate(this);
		}
		return this._interactiveObject = value;
	}
	
	public var pivotIndicator(get, set):PivotIndicator;
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
	
	public var selectionBox(get, set):SelectionBox;
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
	
	public var hasPivotProperties:Bool;
	public var hasTransformProperty:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasRadianRotation:Bool;
	
	public var isMouseDown:Bool;
	
	private var _boundsFunction:Function;
	
	public function new(clss:ValEditClass, ?id:String) 
	{
		super(clss, id);
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
			this._collection.uiCollection.update(value.uiControl);
		}
		
		if (!objectOnly)
		{
			if (this.realObject != this.object)
			{
				this._realPropertyName = this.realPropertyMap.getObjectPropertyName(regularPropertyName);
				if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
				Reflect.setProperty(this.realObject, this._realPropertyName, Reflect.getProperty(this.realObject, this._realPropertyName) + value);
			}
			
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
				
				if (this._pivotIndicator != null && this._pivotIndicator.hasInterestIn(regularPropertyName))
				{
					this._pivotIndicator.objectUpdate(this);
				}
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
			this._collection.uiCollection.update(value.uiControl);
		}
		
		if (!objectOnly)
		{
			if (this.realObject != this.object)
			{
				this._realPropertyName = this.realPropertyMap.getObjectPropertyName(regularPropertyName);
				if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
				Reflect.setProperty(this.realObject, this._realPropertyName, value);
			}
			
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
				
				if (this._pivotIndicator != null && this._pivotIndicator.hasInterestIn(regularPropertyName))
				{
					this._pivotIndicator.objectUpdate(this);
				}
			}
		}
	}
	
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		return Reflect.callMethod(this.object, this._boundsFunction, [targetSpace]);
	}
	
}
package valeditor.ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import openfl.events.Event;
import valedit.value.base.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
@:styleContext
@:access(valedit.value.base.ExposedValue)
abstract class ValueUI extends LayoutGroup implements IValueUI
{
	public var exposedValue(get, set):ExposedValue;
	
	private var _exposedValue:ExposedValue;
	private function get_exposedValue():ExposedValue { return _exposedValue; }
	private function set_exposedValue(value:ExposedValue):ExposedValue
	{
		if (this._exposedValue == value) return value;
		if (this._exposedValue != null) 
		{
			this._exposedValue.removeEventListener(ValueEvent.ACCESS_CHANGE, onValueAccessChange);
			this._exposedValue.removeEventListener(ValueEvent.EDITABLE_CHANGE, onValueEditableChange);
			this._exposedValue.removeEventListener(ValueEvent.OBJECT_CHANGE, onValueObjectChange);
			this._exposedValue.removeEventListener(ValueEvent.PROPERTY_CHANGE, onValuePropertyChange);
		}
		this._exposedValue = value;
		if (this._exposedValue != null)
		{
			this._exposedValue.addEventListener(ValueEvent.ACCESS_CHANGE, onValueAccessChange);
			this._exposedValue.addEventListener(ValueEvent.EDITABLE_CHANGE, onValueEditableChange);
			this._exposedValue.addEventListener(ValueEvent.OBJECT_CHANGE, onValueObjectChange);
			this._exposedValue.addEventListener(ValueEvent.PROPERTY_CHANGE, onValuePropertyChange);
			initExposedValue();
			updateExposedValue();
		}
		return this._exposedValue;
	}
	
	private var _controlsEnabled:Bool = false;
	private var _readOnly:Bool = false;
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		this.exposedValue = null;
		controlsDisable();
		if (this.parent != null) this.parent.removeChild(this);
	}
	
	abstract public function pool():Void;
	
	override function layoutGroup_addedToStageHandler(event:Event):Void 
	{
		super.layoutGroup_addedToStageHandler(event);
		
		controlsEnable();
	}
	
	override function layoutGroup_removedFromStageHandler(event:Event):Void 
	{
		super.layoutGroup_removedFromStageHandler(event);
		
		controlsDisable();
	}
	
	private function controlsDisable():Void
	{
		if (this._readOnly) return;
		this._controlsEnabled = false;
	}
	
	private function controlsEnable():Void
	{
		if (this._readOnly) return;
		this._controlsEnabled = true;
	}
	
	public function initExposedValue():Void
	{
		this._readOnly = this._exposedValue.isReadOnly || this._exposedValue.isReadOnlyInternal;
	}
	
	public function updateExposedValue(exceptControl:IValueUI = null):Void
	{
		
	}
	
	private function onValueAccessChange(evt:ValueEvent):Void
	{
		if ((evt.value.isReadOnly || evt.value.isReadOnlyInternal) && this._controlsEnabled)
		{
			controlsDisable();
		}
		initExposedValue();
	}
	
	private function onValueEditableChange(evt:ValueEvent):Void
	{
		
	}
	
	private function onValueObjectChange(evt:ValueEvent):Void
	{
		updateExposedValue();
	}
	
	private function onValuePropertyChange(evt:ValueEvent):Void
	{
		updateExposedValue();
	}
	
}
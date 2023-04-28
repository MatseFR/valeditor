package ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import openfl.events.Event;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
@:styleContext
class ValueUI extends LayoutGroup implements IValueUI
{
	public var exposedValue(get, set):ExposedValue;
	
	private var _exposedValue:ExposedValue;
	private function get_exposedValue():ExposedValue { return _exposedValue; }
	private function set_exposedValue(value:ExposedValue):ExposedValue
	{
		if (_exposedValue == value) return value;
		if (_exposedValue != null) 
		{
			_exposedValue.removeEventListener(ValueEvent.EDITABLE_CHANGE, onValueEditableChange);
			_exposedValue.removeEventListener(ValueEvent.OBJECT_CHANGE, onValueObjectChange);
		}
		_exposedValue = value;
		if (_exposedValue != null)
		{
			_exposedValue.addEventListener(ValueEvent.EDITABLE_CHANGE, onValueEditableChange);
			_exposedValue.addEventListener(ValueEvent.OBJECT_CHANGE, onValueObjectChange);
		}
		initExposedValue();
		updateExposedValue();
		return _exposedValue;
	}
	
	private var _controlsEnabled:Bool = false;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		
	}
	
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
		_controlsEnabled = false;
	}
	
	private function controlsEnable():Void
	{
		_controlsEnabled = true;
	}
	
	public function initExposedValue():Void
	{
		
	}
	
	public function updateExposedValue(exceptControl:IValueUI = null):Void
	{
		
	}
	
	private function onValueEditableChange(evt:ValueEvent):Void
	{
		
	}
	
	private function onValueObjectChange(evt:ValueEvent):Void
	{
		updateExposedValue();
	}
	
}
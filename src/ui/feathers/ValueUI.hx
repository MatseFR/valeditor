package ui.feathers;

import feathers.controls.LayoutGroup;
import openfl.events.Event;
import valedit.ExposedValue;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class ValueUI extends LayoutGroup implements IValueUI
{
	public var exposedValue(get, set):ExposedValue;
	
	private var _exposedValue:ExposedValue;
	private function get_exposedValue():ExposedValue { return _exposedValue; }
	private function set_exposedValue(value:ExposedValue):ExposedValue
	{
		if (_exposedValue == value) return value;
		if (_exposedValue != null) _exposedValue.removeEventListener(Event.CHANGE, onValueChange);
		_exposedValue = value;
		if (_exposedValue != null) _exposedValue.addEventListener(Event.CHANGE, onValueChange);
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
	
	public function updateExposedValue(exceptControl:IValueUI = null):Void
	{
		
	}
	
	private function onValueChange(evt:Event):Void
	{
		updateExposedValue();
	}
	
}
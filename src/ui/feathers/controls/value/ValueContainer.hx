package ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import openfl.errors.Error;
import valedit.ui.IGroupUI;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class ValueContainer extends LayoutGroup implements IGroupUI 
{
	private var _controls:Array<IValueUI> = new Array<IValueUI>();
	
	/**
	   
	**/
	public function new() 
	{
		super();
		
	}
	
	public function addExposedControl(control:IValueUI):Void 
	{
		_controls.push(control);
		addChild(cast control);
	}
	
	public function addExposedControlAfter(control:IValueUI, afterControl:IValueUI):Void
	{
		var index:Int = _controls.indexOf(afterControl);
		if (index == -1)
		{
			throw new Error("ValueContainer.addExposedControlAfter ::: afterControl cannot be found");
		}
		_controls.insert(index + 1, control);
		addChildAt(cast control, index + 1);
	}
	
	public function addExposedControlBefore(control:IValueUI, beforeControl:IValueUI):Void
	{
		var index:Int = _controls.indexOf(beforeControl);
		if (index == -1)
		{
			throw new Error("ValueContainer.addExposedControlBefore ::: beforeControl cannot be found");
		}
		_controls.insert(index, control);
		addChildAt(cast control, index);
	}
	
	public function removeExposedControl(control:IValueUI):Void 
	{
		_controls.remove(control);
		removeChild(cast control);
	}
	
	public function updateExposedValues():Void
	{
		for (control in _controls)
		{
			control.updateExposedValue();
		}
	}
	
}
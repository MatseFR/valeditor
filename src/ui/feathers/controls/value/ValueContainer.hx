package ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
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
package valeditor.ui.feathers.controls.value;

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
	static private var _POOL:Array<ValueContainer> = new Array<ValueContainer>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():ValueContainer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValueContainer();
	}
	
	private var _controls:Array<IValueUI> = new Array<IValueUI>();
	
	/**
	   
	**/
	public function new() 
	{
		super();
	}
	
	public function clearContent():Void
	{
		removeChildren();
		this._controls.resize(0);
	}
	
	public function pool():Void
	{
		clearContent();
		_POOL[_POOL.length] = this;
	}
	
	public function addExposedControl(control:IValueUI):Void 
	{
		this._controls.push(control);
		addChild(cast control);
	}
	
	public function addExposedControlAfter(control:IValueUI, afterControl:IValueUI):Void
	{
		var index:Int = this._controls.indexOf(afterControl);
		if (index == -1)
		{
			throw new Error("ValueContainer.addExposedControlAfter ::: afterControl cannot be found");
		}
		this._controls.insert(index + 1, control);
		addChildAt(cast control, index + 1);
	}
	
	public function addExposedControlBefore(control:IValueUI, beforeControl:IValueUI):Void
	{
		var index:Int = this._controls.indexOf(beforeControl);
		if (index == -1)
		{
			throw new Error("ValueContainer.addExposedControlBefore ::: beforeControl cannot be found");
		}
		this._controls.insert(index, control);
		addChildAt(cast control, index);
	}
	
	public function removeExposedControl(control:IValueUI):Void 
	{
		this._controls.remove(control);
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
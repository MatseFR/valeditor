package ui.feathers.controls;

import feathers.controls.LayoutGroup;

/**
 * ...
 * @author Matse
 */
@:styleContext
class SelectionBox extends LayoutGroup 
{
	static private var _POOL:Array<SelectionBox> = new Array<SelectionBox>();
	
	static public function fromPool():SelectionBox
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SelectionBox();
	}
	
	static public function toPool(box:SelectionBox):Void
	{
		_POOL.push(box);
	}
	
	public function new() 
	{
		super();
	}
	
}
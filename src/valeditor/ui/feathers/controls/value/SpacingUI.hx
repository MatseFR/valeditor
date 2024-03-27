package valeditor.ui.feathers.controls.value;
import valeditor.ui.feathers.controls.value.base.ValueUI;

/**
 * ...
 * @author Matse
 */
@:styleContext
class SpacingUI extends ValueUI 
{
	static private var _POOL:Array<SpacingUI> = new Array<SpacingUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():SpacingUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SpacingUI();
	}

	public function new() 
	{
		super();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}
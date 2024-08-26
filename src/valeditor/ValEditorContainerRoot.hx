package valeditor;
import valeditor.container.TimeLineContainerOpenFLStarlingEditable;

/**
 * ...
 * @author Matse
 */
class ValEditorContainerRoot extends TimeLineContainerOpenFLStarlingEditable 
{
	static private var _POOL:Array<ValEditorContainerRoot> = new Array<ValEditorContainerRoot>();
	
	static public function fromPool():ValEditorContainerRoot
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorContainerRoot();
	}
	
	public function new() 
	{
		super();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}
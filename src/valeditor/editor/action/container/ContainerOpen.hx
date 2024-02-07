package valeditor.editor.action.container;

import openfl.errors.Error;
import valeditor.ValEditorContainer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ContainerOpen extends ValEditorAction 
{
	static private var _POOL:Array<ContainerOpen> = new Array<ContainerOpen>();
	
	static public function fromPool():ContainerOpen
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ContainerOpen();
	}
	
	public var container:ValEditorContainer;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.container = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(container:ValEditorContainer):Void
	{
		this.container = container;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ContainerOpen already applied");
		}
		
		// TODO
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ContainerOpen already cancelled");
		}
		
		// TODO
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
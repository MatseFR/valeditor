package valeditor.editor.action.object;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ObjectCreate extends ValEditorAction 
{
	static private var _POOL:Array<ObjectCreate> = new Array<ObjectCreate>();
	
	static public function fromPool():ObjectCreate
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectCreate();
	}
	
	public var object:ValEditorObject;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			this.object.pool();
		}
		this.object = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(object:ValEditorObject):Void
	{
		this.object = object;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectCreate already applied");
		}
		
		// do nothing
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectCreate already cancelled");
		}
		
		// do nothing
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
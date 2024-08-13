package valeditor.editor.action.object;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ObjectAdd extends ValEditorAction 
{
	static private var _POOL:Array<ObjectAdd> = new Array<ObjectAdd>();
	
	static public function fromPool():ObjectAdd
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectAdd();
	}
	
	public var object:ValEditorObject;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.object.unregisterAction(this);
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			if (this.object.canBeDestroyed())
			{
				ValEditor.destroyObject(this.object);
			}
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
		this.object.registerAction(this);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectAdd already applied");
		}
		
		ValEditor.currentContainer.addObject(this.object);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectAdd already cancelled");
		}
		
		ValEditor.currentContainer.removeObject(this.object);
		this.status = ValEditorActionStatus.UNDONE; 
	}
	
}
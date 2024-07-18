package valeditor.editor.action.object;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ObjectRename extends ValEditorAction 
{
	static private var _POOL:Array<ObjectRename> = new Array<ObjectRename>();
	
	static public function fromPool():ObjectRename
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectRename();
	}
	
	public var object:ValEditorObject;
	public var newID:String;
	public var previousID:String;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.object = null;
		this.newID = null;
		this.previousID = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(object:ValEditorObject, newID:String):Void
	{
		this.object = object;
		this.newID = newID;
		this.previousID = this.object.objectID;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectRename already applied");
		}
		this.object.objectID = this.newID;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectRename already cancelled");
		}
		this.object.objectID = this.previousID;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
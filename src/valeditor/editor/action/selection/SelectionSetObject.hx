package valeditor.editor.action.selection;

import openfl.errors.Error;
import valeditor.editor.Selection;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class SelectionSetObject extends ValEditorAction 
{
	static private var _POOL:Array<SelectionSetObject> = new Array<SelectionSetObject>();
	
	static public function fromPool():SelectionSetObject
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SelectionSetObject();
	}
	
	public var object:Dynamic;
	public var selection:Selection = new Selection();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.object = null;
		this.selection.clear();
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(object:Dynamic):Void
	{
		this.object = object;
		this.selection.copyFrom(ValEditor.selection);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("SelectionSetObject already applied");
		}
		
		ValEditor.selection.object = this.object;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("SelectionSetObject already cancelled");
		}
		
		ValEditor.selection.copyFrom(this.selection);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.selection;

import openfl.errors.Error;
import valeditor.editor.Selection;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class SelectionClear extends ValEditorAction 
{
	static private var _POOL:Array<SelectionClear> = new Array<SelectionClear>();
	
	static public function fromPool():SelectionClear
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SelectionClear();
	}
	
	public var selection:Selection;
	public var restoreSelection:Selection = new Selection();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.selection = null;
		this.restoreSelection.clear();
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(selection:Selection):Void
	{
		this.selection = selection;
		this.restoreSelection.copyFrom(this.selection);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("SelectionClear already applied");
		}
		
		this.selection.clear();
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("SelectionClear already cancelled");
		}
		
		this.selection.copyFrom(this.restoreSelection);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
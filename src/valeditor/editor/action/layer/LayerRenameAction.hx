package valeditor.editor.action.layer;

import openfl.errors.Error;
import valeditor.ValEditorLayer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class LayerRenameAction extends ValEditorAction 
{
	static private var _POOL:Array<LayerRenameAction> = new Array<LayerRenameAction>();
	
	static public function fromPool():LayerRenameAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerRenameAction();
	}
	
	public var layer:ValEditorLayer;
	public var newName:String;
	public var previousName:String;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.layer = null;
		this.newName = null;
		this.previousName = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(layer:ValEditorLayer, newName:String):Void
	{
		this.layer = layer;
		this.newName = newName;
		this.previousName = this.layer.name;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerRenameAction already applied");
		}
		
		this.layer.name = this.newName;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerRenameAction already cancelled");
		}
		
		this.layer.name = this.previousName;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
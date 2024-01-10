package valeditor.editor.action.template;

import openfl.errors.Error;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TemplateRename extends ValEditorAction 
{
	static private var _POOL:Array<TemplateRename> = new Array<TemplateRename>();
	
	static public function fromPool():TemplateRename
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TemplateRename();
	}
	
	public var template:ValEditorTemplate;
	public var newID:String;
	public var previousID:String;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.template = null;
		this.newID = null;
		this.previousID = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(template:ValEditorTemplate, newID:String):Void
	{
		this.template = template;
		this.newID = newID;
		this.previousID = this.template.id;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TemplateRename already applied");
		}
		this.template.id = this.newID;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TemplateRename already cancelled");
		}
		this.template.id = this.previousID;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
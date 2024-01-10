package valeditor.editor.action.template;

import openfl.errors.Error;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TemplateAdd extends ValEditorAction 
{
	static private var _POOL:Array<TemplateAdd> = new Array<TemplateAdd>();
	
	static public function fromPool():TemplateAdd
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TemplateAdd();
	}
	
	public var template:ValEditorTemplate;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			this.template.pool();
		}
		this.template = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(template:ValEditorTemplate):Void
	{
		this.template = template;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TemplateAdd already applied");
		}
		
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TemplateAdd already cancelled");
		}
		
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
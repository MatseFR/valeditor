package valeditor.editor.action.template;

import valeditor.ValEditorTemplate;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TemplateAddAction extends ValEditorAction 
{
	static private var _POOL:Array<TemplateAddAction> = new Array<TemplateAddAction>();
	
	static public function fromPool():TemplateAddAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TemplateAddAction();
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
	
	
	
}
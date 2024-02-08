package valeditor.editor.action.template;

import openfl.errors.Error;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class TemplateSelect extends ValEditorAction 
{
	static private var _POOL:Array<TemplateSelect> = new Array<TemplateSelect>();
	
	static public function fromPool():TemplateSelect
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TemplateSelect();
	}
	
	public var numTemplates(get, never):Int;
	public var templates:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	private function get_numTemplates():Int { return this.templates.length; }
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.templates.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(?templates:Array<ValEditorTemplate>):Void
	{
		if (templates != null)
		{
			for (template in templates)
			{
				this.templates[this.templates.length] = template;
			}
		}
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		this.templates[this.templates.length] = template;
	}
	
	public function addTemplates(templates:Array<ValEditorTemplate>):Void
	{
		for (template in templates)
		{
			this.templates[this.templates.length] = template;
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TemplateSelect already applied");
		}
		
		ValEditor.selection.addTemplates(this.templates);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TemplateSelect already canelled");
		}
		
		ValEditor.selection.removeTemplates(this.templates);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
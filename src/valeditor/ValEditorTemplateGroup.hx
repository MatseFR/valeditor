package valeditor;
import haxe.iterators.ArrayIterator;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.template.TemplateRemove;

/**
 * ...
 * @author Matse
 */
class ValEditorTemplateGroup 
{
	public var numTemplates(get, never):Int;
	
	private function get_numTemplates():Int { return this._templates.length; }
	
	private var _templates:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();

	public function new() 
	{
		
	}
	
	public function iterator():ArrayIterator<ValEditorTemplate>
	{
		return this._templates.iterator();
	}
	
	public function clear():Void
	{
		this._templates.resize(0);
	}
	
	public function copyFrom(group:ValEditorTemplateGroup):Void
	{
		addTemplates(group._templates);
	}
	
	public function deleteTemplates(?action:MultiAction):Void
	{
		var templatesToDelete:Array<ValEditorTemplate> = this._templates.copy();
		if (action == null)
		{
			for (template in templatesToDelete)
			{
				ValEditor.destroyTemplate(template);
			}
		}
		else
		{
			var templateRemove:TemplateRemove;
			for (template in templatesToDelete)
			{
				templateRemove = TemplateRemove.fromPool();
				templateRemove.setup(template);
				action.add(templateRemove);
			}
		}
		clear();
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		if (this._templates.indexOf(template) != -1) return;
		this._templates.push(template);
	}
	
	public function addTemplates(templates:Array<ValEditorTemplate>):Void
	{
		for (template in templates)
		{
			addTemplate(template);
		}
	}
	
	public function getTemplateAt(index:Int):ValEditorTemplate
	{
		return this._templates[index];
	}
	
	public function hasTemplate(template:ValEditorTemplate):Bool
	{
		return this._templates.indexOf(template) != -1;
	}
	
	public function removeTemplate(template:ValEditorTemplate):Bool
	{
		return this._templates.remove(template);
	}
	
}
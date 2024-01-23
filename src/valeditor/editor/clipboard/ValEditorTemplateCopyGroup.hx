package valeditor.editor.clipboard;
import haxe.iterators.ArrayIterator;
import valeditor.ValEditorTemplate;

/**
 * ...
 * @author Matse
 */
class ValEditorTemplateCopyGroup 
{
	public var isRealClipboard:Bool = false;
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
		if (this.isRealClipboard)
		{
			for (template in this._templates)
			{
				template.isInClipboard = false;
				if (template.canBeDestroyed())
				{
					ValEditor.destroyTemplate(template);
				}
			}
		}
		this._templates.resize(0);
	}
	
	public function copyFrom(group:ValEditorTemplateCopyGroup):Void
	{
		for (template in group._templates)
		{
			addTemplate(template);
		}
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		if (this._templates.indexOf(template) != -1) return;
		if (this.isRealClipboard) template.isInClipboard = true;
		this._templates.push(template);
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
		var result:Bool = this._templates.remove(template);
		if (result && this.isRealClipboard)
		{
			template.isInClipboard = false;
			if (template.canBeDestroyed())
			{
				ValEditor.destroyTemplate(template);
			}
		}
		return result;
	}
	
}
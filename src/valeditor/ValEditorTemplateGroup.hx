package valeditor;
import haxe.iterators.ArrayIterator;

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
	
	public function deleteTemplates():Void
	{
		var templatesToDelete:Array<ValEditorTemplate> = this._templates.copy();
		for (template in templatesToDelete)
		{
			ValEditor.destroyTemplate(template);
		}
		clear();
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		if (this._templates.indexOf(template) != -1) return;
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
		return this._templates.remove(template);
	}
	
}
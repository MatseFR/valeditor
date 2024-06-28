package valeditor.editor.data;
import valeditor.ValEditorTemplate;

/**
 * ...
 * @author Matse
 */
class ContainerSaveData 
{
	static private var _POOL:Array<ContainerSaveData> = new Array<ContainerSaveData>();
	
	static public function fromPool(template:ValEditorTemplate):ContainerSaveData
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(template);
		return new ContainerSaveData(template);
	}
	
	public var dependencies:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	public var template:ValEditorTemplate;
	
	public function new(template:ValEditorTemplate) 
	{
		this.template = template;
	}
	
	public function clear():Void
	{
		this.dependencies.resize(0);
		this.template = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(template:ValEditorTemplate):ContainerSaveData
	{
		this.template = template;
		return this;
	}
	
	public function addDependency(template:ValEditorTemplate):Void
	{
		this.dependencies.push(template);
	}
	
	public function hasDependency(template:ValEditorTemplate):Bool
	{
		return this.dependencies.indexOf(template) != -1;
	}
	
}
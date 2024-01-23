package valeditor.editor.action.template;

import openfl.errors.Error;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.action.object.ObjectUnselect;

/**
 * ...
 * @author Matse
 */
class TemplateRemove extends ValEditorAction 
{
	static private var _POOL:Array<TemplateRemove> = new Array<TemplateRemove>();
	
	static public function fromPool():TemplateRemove
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TemplateRemove();
	}
	
	public var template:ValEditorTemplate;
	public var action:MultiAction = new MultiAction();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			this.template.pool();
		}
		this.template = null;
		
		this.action.clear();
		
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
		var unselect:ObjectUnselect;
		for (instance in this.template.instances)
		{
			if (ValEditor.selection.hasObject(cast instance))
			{
				unselect = ObjectUnselect.fromPool();
				unselect.setup();
				unselect.addObject(cast instance);
				this.action.add(unselect);
			}
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("TemplateRemove already applied");
		}
		
		ValEditor.unregisterTemplate(this.template);
		this.template.unregisterInstances();
		this.action.apply();
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("TemplateRemove already cancelled");
		}
		
		ValEditor.registerTemplate(this.template);
		this.template.registerInstances();
		this.action.cancel();
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.object;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ObjectSelect extends ValEditorAction 
{
	static private var _POOL:Array<ObjectSelect> = new Array<ObjectSelect>();
	
	static public function fromPool():ObjectSelect
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectSelect();
	}
	
	public var numObjects(get, never):Int;
	public var objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	private function get_numObjects():Int { return this.objects.length; }
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.objects.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(?objects:Array<ValEditorObject>):Void
	{
		if (objects != null)
		{
			for (object in objects)
			{
				this.objects[this.objects.length] = object;
			}
		}
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		this.objects[this.objects.length] = object;
	}
	
	public function addObjects(objects:Array<ValEditorObject>):Void
	{
		for (object in objects)
		{
			this.objects[this.objects.length] = object;
		}
	}
	
	public function apply():Void 
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectSelect already applied");
		}
		
		ValEditor.selection.addObjects(this.objects);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectSelect already cancelled");
		}
		
		ValEditor.selection.removeObjects(this.objects);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.object;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ObjectUnselect extends ValEditorAction 
{
	static private var _POOL:Array<ObjectUnselect> = new Array<ObjectUnselect>();
	
	static public function fromPool():ObjectUnselect
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectUnselect();
	}
	
	public var objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
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
			throw new Error("ObjectUnselect already applied");
		}
		
		ValEditor.selection.removeObjects(this.objects);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectUnselect already cancelled");
		}
		
		ValEditor.selection.addObjects(this.objects);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
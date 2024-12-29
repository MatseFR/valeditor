package valeditor.editor.action.object;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.container.ITimeLineContainerEditable;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.action.ValEditorActionStatus;

/**
 * ...
 * @author Matse
 */
class ObjectAddToLibrary extends ValEditorAction 
{
	static private var _POOL:Array<ObjectAddToLibrary> = new Array<ObjectAddToLibrary>();
	
	static public function fromPool():ObjectAddToLibrary
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectAddToLibrary();
	}
	
	public var object:ValEditorObject;
	public var container:ITimeLineContainerEditable;

	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.object.unregisterAction(this);
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			if (this.object.canBeDestroyed())
			{
				ValEditor.destroyObject(this.object);
			}
		}
		this.object = null;
		this.container = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(object:ValEditorObject, container:ITimeLineContainerEditable):Void
	{
		this.object = object;
		this.container = container;
		
		this.object.registerAction(this);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectAddToLibrary already applied");
		}
		
		this.container.objectLibrary.addObject(this.object);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectAddToLibrary already cancelled");
		}
		
		this.container.objectLibrary.removeObject(this.object);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
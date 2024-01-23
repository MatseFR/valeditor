package valeditor.editor.action.clipboard;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.clipboard.ValEditorClipboard;

/**
 * ...
 * @author Matse
 */
class ClipboardAddObject extends ValEditorAction 
{
	static private var _POOL:Array<ClipboardAddObject> = new Array<ClipboardAddObject>();
	
	static public function fromPool():ClipboardAddObject
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClipboardAddObject();
	}
	
	public var clipboard:ValEditorClipboard;
	public var numObjects(get, never):Int;
	public var objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	private function get_numObjects():Int { return this.objects.length; }
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.clipboard = null;
		this.objects.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(clipboard:ValEditorClipboard, ?objects:Array<ValEditorObject>):Void
	{
		this.clipboard = clipboard;
		if (objects != null)
		{
			for (object in objects)
			{
				this.objects.push(object);
			}
		}
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		this.objects.push(object);
	}
	
	public function addObjects(objects:Array<ValEditorObject>):Void
	{
		for (object in objects)
		{
			this.objects.push(object);
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ClipboardAddObject already applied");
		}
		
		this.clipboard.addObjects(this.objects);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ClipboardAddObject already cancelled");
		}
		
		this.clipboard.removeObjects(this.objects);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
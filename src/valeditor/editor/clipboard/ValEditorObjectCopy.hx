package valeditor.editor.clipboard;
import valedit.ExposedCollection;
import valeditor.ValEditorObject;

/**
 * ...
 * @author Matse
 */
class ValEditorObjectCopy 
{
	static public var _POOL:Array<ValEditorObjectCopy> = new Array<ValEditorObjectCopy>();
	
	static public function fromPool(object:ValEditorObject, collection:ExposedCollection):ValEditorObjectCopy
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(object, collection);
		return new ValEditorObjectCopy(object, collection);
	}
	
	public var object:ValEditorObject;
	public var collection:ExposedCollection;

	public function new(object:ValEditorObject = null, collection:ExposedCollection = null) 
	{
		this.object = object;
		this.collection = collection;
	}
	
	public function clear():Void
	{
		this.object = null;
		if (this.collection != null)
		{
			this.collection.pool();
			this.collection = null;
		}
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(object:ValEditorObject, collection:ExposedCollection):ValEditorObjectCopy
	{
		this.object = object;
		this.collection = collection;
		return this;
	}
	
}
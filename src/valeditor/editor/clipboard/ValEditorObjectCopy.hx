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
	
	public function clear(poolCollection:Bool = true):Void
	{
		this.object = null;
		if (poolCollection && this.collection != null)
		{
			this.collection.pool();
			this.collection = null;
		}
	}
	
	public function clone(?copy:ValEditorObjectCopy):ValEditorObjectCopy
	{
		if (copy == null)
		{
			return fromPool(this.object, this.collection);
		}
		else
		{
			copy.object = this.object;
			copy.collection = this.collection;
			return copy;
		}
	}
	
	public function pool(poolCollection:Bool = true):Void
	{
		clear(poolCollection);
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(object:ValEditorObject, collection:ExposedCollection):ValEditorObjectCopy
	{
		this.object = object;
		this.collection = collection;
		return this;
	}
	
}
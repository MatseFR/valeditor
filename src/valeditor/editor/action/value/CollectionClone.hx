package valeditor.editor.action.value;

import openfl.errors.Error;
import valedit.ExposedCollection;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class CollectionClone extends ValEditorAction 
{
	static private var _POOL:Array<CollectionClone> = new Array<CollectionClone>();
	
	static public function fromPool():CollectionClone
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new CollectionClone();
	}
	
	public var collection:ExposedCollection;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.collection != null)
		{
			this.collection.pool();
			this.collection = null;
		}
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(collection:ExposedCollection):Void
	{
		this.collection = collection;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("CollectionClone already applied");
		}
		
		//nothing here
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("CollectionClone already cancelled");
		}
		
		//nothing here
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
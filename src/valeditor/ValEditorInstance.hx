package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditInstance;

/**
 * ...
 * @author Matse
 */
class ValEditorInstance extends ValEditInstance 
{
	static private var _POOL:Array<ValEditorInstance> = new Array<ValEditorInstance>();
	
	static public function fromPool(object:ValEditorObject, collection:ExposedCollection):ValEditorInstance
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(object, collection);
		return new ValEditorInstance(object, collection);
	}
	
	public function new(object:ValEditorObject, collection:ExposedCollection) 
	{
		super(object, collection);
	}
	
	override public function clear():Void 
	{
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function activate():Void 
	{
		super.activate();
		this.collection.object = this.object;
	}
	
}
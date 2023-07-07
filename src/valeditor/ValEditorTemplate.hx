package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditTemplate;
import valeditor.events.TemplateEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorTemplate extends ValEditTemplate 
{
	static private var _POOL:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	static public function fromPool(clss:ValEditClass, ?id:String, ?object:Dynamic, ?collection:ExposedCollection,
									?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(clss, id, object, collection, constructorCollection);
		return new ValEditorTemplate(clss, id, object, collection, constructorCollection);
	}
	
	override function set_id(value:String):String 
	{
		super.set_id(value);
		TemplateEvent.dispatch(this, TemplateEvent.RENAMED, this);
		return this._id;
	}

	public function new(clss:ValEditClass, ?id:String, ?object:Dynamic, ?collection:ExposedCollection, ?constructorCollection:ExposedCollection) 
	{
		super(clss, id, object, collection, constructorCollection);
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}
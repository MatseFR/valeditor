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
	
}
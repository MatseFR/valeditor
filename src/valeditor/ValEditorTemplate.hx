package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditTemplate;

/**
 * ...
 * @author Matse
 */
class ValEditorTemplate extends ValEditTemplate 
{

	public function new(clss:ValEditClass, ?id:String, ?object:Dynamic, ?collection:ExposedCollection, ?constructorCollection:ExposedCollection) 
	{
		super(clss, id, object, collection, constructorCollection);
	}
	
}
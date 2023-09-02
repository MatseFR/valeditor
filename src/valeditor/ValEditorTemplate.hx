package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
import valedit.value.ExposedFunction;
import valedit.value.base.ExposedValue;
import valeditor.events.ObjectEvent;
import valeditor.events.TemplateEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorTemplate extends ValEditTemplate 
{
	static private var _POOL:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	static public function fromPool(clss:ValEditClass, ?id:String, ?collection:ExposedCollection,
									?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(clss, id, collection, constructorCollection);
		return new ValEditorTemplate(clss, id, collection, constructorCollection);
	}
	
	override function set_id(value:String):String 
	{
		super.set_id(value);
		TemplateEvent.dispatch(this, TemplateEvent.RENAMED, this);
		return this._id;
	}
	
	override function set_object(value:Dynamic):Dynamic 
	{
		if (this._object == value) return value;
		
		if (this._object != null)
		{
			this._object.removeEventListener(ObjectEvent.PROPERTY_CHANGE, onTemplateObjectPropertyChange);
			this._object.removeEventListener(ObjectEvent.FUNCTION_CALLED, onTemplateObjectFunctionCalled);
		}
		
		if (value != null)
		{
			value.addEventListener(ObjectEvent.PROPERTY_CHANGE, onTemplateObjectPropertyChange);
			value.addEventListener(ObjectEvent.FUNCTION_CALLED, onTemplateObjectFunctionCalled);
		}
		
		return super.set_object(value);
	}

	public function new(clss:ValEditClass, ?id:String, ?collection:ExposedCollection, ?constructorCollection:ExposedCollection) 
	{
		super(clss, id, collection, constructorCollection);
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
	
	override public function addInstance(instance:ValEditObject):Void 
	{
		super.addInstance(instance);
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_ADDED, this);
	}
	
	override public function removeInstance(instance:ValEditObject):Void 
	{
		super.removeInstance(instance);
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_REMOVED, this);
	}
	
	private function onTemplateObjectPropertyChange(evt:ObjectEvent):Void
	{
		var templateValue:ExposedValue = evt.object.collection.getValue(evt.propertyName);
		
		// check for corresponding constructor value
		if (this.constructorCollection != null)
		{
			var value:ExposedValue = this.constructorCollection.getValue(templateValue.propertyName);
			if (value != null)
			{
				value.value = templateValue.value;
			}
		}
		
		for (instance in this._instances)
		{
			templateValue.applyToObject(instance.object);
			cast(instance, ValEditorObject).registerForChangeUpdate();
		}
	}
	
	private function onTemplateObjectFunctionCalled(evt:ObjectEvent):Void
	{
		var func:ExposedFunction;
		for (instance in this._instances)
		{
			func = cast instance.collection.getValue(evt.propertyName);
			func.executeWithParameters(evt.parameters);
		}
	}
	
}
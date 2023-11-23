package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
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
	
	public var isInClipboard:Bool = false;
	public var isInLibrary:Bool = false;
	public var lockInstanceUpdates:Bool = false;
	
	override function set_id(value:String):String 
	{
		if (this._id == value) return value;
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
		this.isInClipboard = false;
		this.isInLibrary = false;
		this.lockInstanceUpdates = false;
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function canBeDestroyed():Bool 
	{
		return super.canBeDestroyed() && !this.isInLibrary && !this.isInClipboard;
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
	
	@:access(valedit.value.base.ExposedValue)
	private function onTemplateObjectPropertyChange(evt:ObjectEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		var templateValue:ExposedValue = evt.object.currentCollection.getValue(evt.propertyName);
		
		// check for corresponding constructor value
		if (this.constructorCollection != null)
		{
			var value:ExposedValue = this.constructorCollection.getValue(templateValue.propertyName);
			if (value != null)
			{
				templateValue.cloneValue(value);
			}
		}
		
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).templatePropertyChange(templateValue);
		}
	}
	
	private function onTemplateObjectFunctionCalled(evt:ObjectEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).templateFunctionCall(evt.propertyName, evt.parameters);
		}
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.id = json.id;
		this.collection.fromJSONSave(json.collection);
		this.collection.apply();
		this.constructorCollection.fromJSONSave(json.constructorCollection);
		
		var instance:ValEditorObject;
		var instances:Array<Dynamic> = json.instances;
		for (node in instances)
		{
			instance = ValEditor.createObjectWithTemplate(this, node.id);
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		json.id = this.id;
		json.collection = this.collection.toJSONSave();
		json.constructorCollection = this.constructorCollection.toJSONSave();
		
		var instances:Array<Dynamic> = [];
		for (instance in this._instances)
		{
			instances.push(cast(instance, ValEditorObject).toJSONSave());
		}
		json.instances = instances;
		
		return json;
	}
	
}
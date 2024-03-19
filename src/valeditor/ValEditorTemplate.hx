package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
import valedit.utils.ReverseIterator;
import valedit.value.base.ExposedValue;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
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
	
	private var _suspendedInstances:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	override function set_id(value:String):String 
	{
		if (this._id == value) return value;
		var oldID:String = this._id;
		super.set_id(value);
		
		if (oldID != null)
		{
			this._instanceMap.clear();
			var objID:String = oldID + "-";
			for (instance in this._instances)
			{
				if (instance.id.indexOf(objID) == 0)
				{
					instance.id = this._id + "-" + instance.id.substr(objID.length);
				}
				this._instanceMap.set(instance.id, instance);
			}
		}
		
		RenameEvent.dispatch(this, RenameEvent.RENAMED, oldID);
		return this._id;
	}
	
	override function get_numInstances():Int { return this._instances.length - this._suspendedInstances.length; }
	
	override function set_object(value:ValEditObject):ValEditObject 
	{
		if (this._object == value) return value;
		
		if (this._object != null)
		{
			this._object.removeEventListener(ObjectPropertyEvent.CHANGE, onTemplateObjectPropertyChange);
			this._object.removeEventListener(ObjectFunctionEvent.CALLED, onTemplateObjectFunctionCalled);
		}
		
		if (value != null)
		{
			value.addEventListener(ObjectPropertyEvent.CHANGE, onTemplateObjectPropertyChange);
			value.addEventListener(ObjectFunctionEvent.CALLED, onTemplateObjectFunctionCalled);
		}
		
		return super.set_object(value);
	}
	
	private var _objectIDIndex:Int = -1;

	public function new(clss:ValEditClass, ?id:String, ?collection:ExposedCollection, ?constructorCollection:ExposedCollection) 
	{
		super(clss, id, collection, constructorCollection);
	}
	
	override public function clear():Void 
	{
		this.isInClipboard = false;
		this.isInLibrary = false;
		this.lockInstanceUpdates = false;
		this._objectIDIndex = -1;
		
		if (this.object != null)
		{
			ValEditor.destroyObject(cast this.object);
			this.object = null;
		}
		
		for (i in new ReverseIterator(this._instances.length - 1, 0))
		{
			ValEditor.destroyObject(cast this._instances[i]);
		}
		
		this._suspendedInstances.resize(0);
		
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
	
	public function registerInstances():Void
	{
		for (instance in this._instances)
		{
			ValEditor.registerObject(cast instance);
			cast(instance, ValEditorObject).restoreKeyFrames();
		}
	}
	
	public function unregisterInstances():Void
	{
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).backupKeyFrames();
			ValEditor.unregisterObject(cast instance);
		}
	}
	
	public function suspendInstance(instance:ValEditorObject):Void
	{
		this._suspendedInstances.push(instance);
		instance.isSuspended = true;
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_SUSPENDED, this);
	}
	
	public function unsuspendInstance(instance:ValEditorObject):Void
	{
		this._suspendedInstances.remove(instance);
		instance.isSuspended = false;
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_UNSUSPENDED, this);
	}
	
	public function makeObjectID():String
	{
		var objID:String = null;
		while (true)
		{
			this._objectIDIndex++;
			objID = this.id + "-" + this._objectIDIndex;
			if (!this._instanceMap.exists(objID)) break;
		}
		return objID;
	}
	
	public function objectIDExists(id:String):Bool
	{
		return this._instanceMap.exists(id);
	}
	
	@:access(valedit.value.base.ExposedValue)
	private function onTemplateObjectPropertyChange(evt:ObjectPropertyEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		var templateValue:ExposedValue = evt.object.currentCollection.getValueDeep(evt.propertyNames);
		if (!templateValue.visible) return;
		
		// check for corresponding constructor value
		if (this.constructorCollection != null)
		{
			var value:ExposedValue = this.constructorCollection.getValueDeep(evt.propertyNames);
			if (value != null)
			{
				templateValue.cloneValue(value);
			}
		}
		
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).templatePropertyChange(templateValue, evt.propertyNames);
		}
	}
	
	private function onTemplateObjectFunctionCalled(evt:ObjectFunctionEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).templateFunctionCall(evt.functionName, evt.parameters);
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
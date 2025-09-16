package valeditor;
import feathers.data.ArrayCollection;
import openfl.events.EventDispatcher;
import valeditor.events.LoadEvent;
import valeditor.events.RenameEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorObjectLibrary extends EventDispatcher
{
	static private var _POOL:Array<ValEditorObjectLibrary> = new Array<ValEditorObjectLibrary>();
	
	static public function fromPool():ValEditorObjectLibrary
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorObjectLibrary();
	}
	
	public var isLoaded(get, never):Bool;
	public var numObjects(get, never):Int;
	public var objectCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	
	private function get_isLoaded():Bool { return this._objectsLoadStack.length == 0; }
	
	private function get_numObjects():Int { return this._objects.length; }
	
	private var _objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _objectMap:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
	
	private var _objectsLoadStack:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		for (object in this._objectsLoadStack)
		{
			object.removeEventListener(LoadEvent.COMPLETE, object_loaded);
		}
		this._objectsLoadStack.resize(0);
		
		for (object in this._objects)
		{
			unregisterObject(object);
		}
		this._objects.resize(0);
		this.objectCollection.removeAll();
		this._objectsLoadStack.resize(0);
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		this._objects[this._objects.length] = object;
		this.objectCollection.add(object);
		registerObject(object);
	}
	
	public function addObjectAt(object:ValEditorObject, index:Int):Void
	{
		this._objects.insert(index, object);
		this.objectCollection.addAt(object, index);
		registerObject(object);
	}
	
	public function getObject(objectID:String):ValEditorObject
	{
		return this._objectMap.get(objectID);
	}
	
	public function getObjectAt(index:Int):ValEditorObject
	{
		return this._objects[index];
	}
	
	public function getObjectsWithClass(clss:Class<Dynamic>, objects:Array<ValEditorObject> = null):Array<ValEditorObject>
	{
		if (objects == null) objects = new Array<ValEditorObject>();
		
		for (object in this._objects)
		{
			if (Std.isOfType(object.object, clss))
			{
				objects[objects.length] = object;
			}
		}
		
		return objects;
	}
	
	public function hasObject(object:ValEditorObject):Bool
	{
		return this._objectMap.exists(object.objectID);
	}
	
	public function hasObjectWithID(objectID:String):Bool
	{
		return this._objectMap.exists(objectID);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		removeObjectAt(this._objects.indexOf(object));
	}
	
	public function removeObjectAt(index:Int):Void
	{
		var object:ValEditorObject = this._objects.splice(index, 1)[0];
		this.objectCollection.removeAt(index);
		unregisterObject(object);
	}
	
	private function registerObject(object:ValEditorObject):Void
	{
		this._objectMap.set(object.objectID, object);
		object.isInLibrary = true;
		object.addEventListener(RenameEvent.RENAMED, object_renamed);
	}
	
	private function unregisterObject(object:ValEditorObject):Void
	{
		this._objectMap.remove(object.objectID);
		object.isInLibrary = false;
		object.removeEventListener(RenameEvent.RENAMED, object_renamed);
		if (object.canBeDestroyed())
		{
			ValEditor.destroyObject(object);
		}
	}
	
	private function object_loaded(evt:LoadEvent):Void
	{
		var object:ValEditorObject = evt.target;
		this._objectsLoadStack.remove(object);
		if (this._objectsLoadStack.length == 0) LoadEvent.dispatch(this, LoadEvent.COMPLETE);
	}
	
	private function object_renamed(evt:RenameEvent):Void
	{
		var object:ValEditorObject = cast evt.target;
		this._objectMap.remove(evt.previousNameOrID);
		this._objectMap.set(object.objectID, object);
		this.objectCollection.updateAt(this.objectCollection.indexOf(object));
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		var className:String;
		var valClass:ValEditorClass;
		var object:ValEditorObject;
		var params:Array<Dynamic>;
		var data:Array<Dynamic> = json.objects;
		for (node in data)
		{
			className = node.clss;
			valClass = ValEditor.getClassByName(className);
			object = ValEditorObject.fromPool(valClass);
			object.fromJSONSave(node);
			if (!object.isExternal)
			{
				if (object.constructorCollection != null)
				{
					params = object.constructorCollection.toValueArray();
				}
				else
				{
					params = null;
				}
				ValEditor.createObjectWithClassName(className, object.id, params, object.defaultCollection, object.objectID != object.id ? object.objectID : null, null, object);
			}
			addObject(object);
			if (!object.isExternal && object.isCreationAsync && !object.isLoaded)
			{
				object.addEventListener(LoadEvent.COMPLETE, object_loaded);
				object.loadSetup();
				this._objectsLoadStack[this._objectsLoadStack.length] = object;
			}
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		var data:Array<Dynamic> = [];
		for (object in this._objects)
		{
			//if (object.isExternal) continue;
			data.push(object.toJSONSave());
		}
		json.objects = data;
		
		return json;
	}
	
}
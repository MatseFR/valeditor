package valeditor.editor.visibility;
import valedit.ExposedCollection;
import valedit.value.base.ExposedValue;

/**
 * ...
 * @author Matse
 */
class ClassVisibilityCollection 
{
	static private var _POOL:Array<ClassVisibilityCollection> = new Array<ClassVisibilityCollection>();
	
	static public function fromPool():ClassVisibilityCollection
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClassVisibilityCollection();
	}
	
	public var classID:String;
	public var numValues(get, never):Int;
	public var valueList(get, never):Array<ClassValueVisibility>;
	
	private function get_numValues():Int { return this._valueList.length; }
	
	private var _valueList:Array<ClassValueVisibility> = new Array<ClassValueVisibility>();
	private function get_valueList():Array<ClassValueVisibility> { return this._valueList; }
	
	private var _valueMap:Map<String, ClassValueVisibility> = new Map<String, ClassValueVisibility>();

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.classID = null;
		for (value in this._valueList)
		{
			value.pool();
		}
		this._valueList.resize(0);
		this._valueMap.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function iterator():Iterator<ClassValueVisibility>
	{
		return this._valueList.iterator();
	}
	
	public function applyToObjectCollection(collection:ExposedCollection):Void
	{
		var value:ExposedValue;
		for (visibility in this._valueList)
		{
			value = collection.getValue(visibility.propertyName);
			value.visible = visibility.objectVisible;
		}
		collection.checkGroupsVisibility(false);
		collection.updateUI();
	}
	
	public function applyToTemplateCollection(collection:ExposedCollection):Void
	{
		var value:ExposedValue;
		for (visibility in this._valueList)
		{
			value = collection.getValue(visibility.propertyName);
			value.visible = visibility.templateVisible;
		}
		collection.checkGroupsVisibility(false);
		collection.updateUI();
	}
	
	public function applyToTemplateObjectCollection(collection:ExposedCollection):Void
	{
		var value:ExposedValue;
		for (visibility in this._valueList)
		{
			value = collection.getValue(visibility.propertyName);
			value.visible = visibility.templateObjectVisible;
		}
		collection.checkGroupsVisibility(false);
		collection.updateUI();
	}
	
	public function add(visibility:ClassValueVisibility):Void
	{
		this._valueList[this._valueList.length] = visibility;
		this._valueMap.set(visibility.propertyName, visibility);
	}
	
	public function get(propertyName:String):ClassValueVisibility
	{
		return this._valueMap.get(propertyName);
	}
	
	public function has(propertyName:String):Bool
	{
		return this._valueMap.exists(propertyName);
	}
	
	public function isDifferentFrom(collection:ClassVisibilityCollection):Bool
	{
		var otherValue:ClassValueVisibility;
		for (value in this._valueList)
		{
			otherValue = collection.get(value.propertyName);
			if (value.isDifferentFrom(otherValue)) return true;
		}
		return false;
	}
	
	public function remove(visibility:ClassValueVisibility):Void
	{
		this._valueList.remove(visibility);
		this._valueMap.remove(visibility.propertyName);
	}
	
	public function removeByName(propertyName:String):Void
	{
		var visibility:ClassValueVisibility = this._valueMap.get(propertyName);
		remove(visibility);
	}
	
	public function populateFromExposedCollection(collection:ExposedCollection):Void
	{
		var visibility:ClassValueVisibility;
		for (value in collection)
		{
			if (!this._valueMap.exists(value.propertyName))
			{
				visibility = ClassValueVisibility.fromPool(value.propertyName);
				add(visibility);
			}
		}
	}
	
	public function clone(?toCollection:ClassVisibilityCollection):ClassVisibilityCollection
	{
		if (toCollection == null) toCollection = fromPool();
		
		toCollection.classID = this.classID;
		for (value in this._valueList)
		{
			toCollection.add(value.clone());
		}
		
		return toCollection;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.classID = json.id;
		var data:Array<Dynamic> = json.values;
		var value:ClassValueVisibility;
		for (node in data)
		{
			value = ClassValueVisibility.fromPool();
			value.fromJSON(node);
			add(value);
		}
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.id = this.classID;
		var data:Array<Dynamic> = [];
		for (value in this._valueList)
		{
			data.push(value.toJSON());
		}
		json.values = data;
		
		return json;
	}
	
}
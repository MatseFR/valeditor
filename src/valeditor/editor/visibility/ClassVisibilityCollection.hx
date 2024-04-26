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
	
	public var numValues(get, never):Int;
	
	private function get_numValues():Int { return this._valueList.length; }
	
	private var _valueList:Array<ClassValueVisibility> = new Array<ClassValueVisibility>();
	private var _valueMap:Map<String, ClassValueVisibility> = new Map<String, ClassValueVisibility>();

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
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
	}
	
	public function applyToTemplateCollection(collection:ExposedCollection):Void
	{
		var value:ExposedValue;
		for (visibility in this._valueList)
		{
			value = collection.getValue(visibility.propertyName);
			value.visible = visibility.templateVisible;
		}
	}
	
	public function applyToTemplateObjectCollection(collection:ExposedCollection):Void
	{
		var value:ExposedValue;
		for (visibility in this._valueList)
		{
			value = collection.getValue(visibility.propertyName);
			value.visible = visibility.templateObjectVisible;
		}
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
	
	public function fromJSON(json:Dynamic):Void
	{
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
		
		var data:Array<Dynamic> = [];
		for (value in this._valueList)
		{
			data.push(value.toJSON());
		}
		json.values = data;
		
		return json;
	}
	
}
package valeditor.editor.visibility;
import valedit.ExposedCollection;
import valedit.value.base.ExposedValue;

/**
 * ...
 * @author Matse
 */
class TemplateVisibilityCollection 
{
	static private var _POOL:Array<TemplateVisibilityCollection> = new Array<TemplateVisibilityCollection>();
	
	static public function fromPool():TemplateVisibilityCollection
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TemplateVisibilityCollection();
	}
	
	public var numValues(get, never):Int;
	public var valueList(get, never):Array<TemplateValueVisibility>;
	
	private function get_numValues():Int { return this._valueList.length; }
	
	private var _valueList:Array<TemplateValueVisibility> = new Array<TemplateValueVisibility>();
	private function get_valueList():Array<TemplateValueVisibility> { return this._valueList; }
	
	private var _valueMap:Map<String, TemplateValueVisibility> = new Map<String, TemplateValueVisibility>();
	
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
	
	public function iterator():Iterator<TemplateValueVisibility>
	{
		return this._valueList.iterator();
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
	
	public function add(visibility:TemplateValueVisibility):Void
	{
		this._valueList[this._valueList.length] = visibility;
		this._valueMap.set(visibility.propertyName, visibility);
	}
	
	public function get(propertyName:String):TemplateValueVisibility
	{
		return this._valueMap.get(propertyName);
	}
	
	public function has(propertyName:String):Bool
	{
		return this._valueMap.exists(propertyName);
	}
	
	public function isDifferentFrom(collection:TemplateVisibilityCollection):Bool
	{
		var otherValue:TemplateValueVisibility;
		for (value in this._valueList)
		{
			otherValue = collection.get(value.propertyName);
			if (value.isDifferentFrom(otherValue)) return true;
		}
		return false;
	}
	
	public function remove(visibility:TemplateValueVisibility):Void
	{
		this._valueList.remove(visibility);
		this._valueMap.remove(visibility.propertyName);
	}
	
	public function removeByName(propertyName:String):Void
	{
		var visibility:TemplateValueVisibility = this._valueMap.get(propertyName);
		remove(visibility);
	}
	
	public function populateFromClassVisibilityCollection(collection:ClassVisibilityCollection):Void
	{
		var visibility:TemplateValueVisibility;
		for (visi in collection)
		{
			visibility = TemplateValueVisibility.fromPool(visi.propertyName, visi.templateVisible, visi.templateObjectVisible);
			add(visibility);
		}
	}
	
	public function populateFromExposedCollection(collection:ExposedCollection):Void
	{
		var visibility:TemplateValueVisibility;
		for (value in collection)
		{
			if (!this._valueMap.exists(value.propertyName))
			{
				visibility = TemplateValueVisibility.fromPool(value.propertyName);
				add(visibility);
			}
		}
	}
	
	public function clone(?toCollection:TemplateVisibilityCollection):TemplateVisibilityCollection
	{
		if (toCollection == null) toCollection = fromPool();
		
		for (value in this._valueList)
		{
			toCollection.add(value.clone());
		}
		
		return toCollection;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		var data:Array<Dynamic> = json.values;
		var value:TemplateValueVisibility;
		for (node in data)
		{
			value = TemplateValueVisibility.fromPool();
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
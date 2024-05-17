package valeditor.editor.visibility;

/**
 * ...
 * @author Matse
 */
class ClassVisibilitiesCollection 
{
	static private var _POOL:Array<ClassVisibilitiesCollection> = new Array<ClassVisibilitiesCollection>();
	
	static public function fromPool():ClassVisibilitiesCollection
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClassVisibilitiesCollection();
	}
	
	public var classCollectionList(get, never):Array<ClassVisibilityCollection>;
	public var numClasses(get, never):Int;
	
	private function get_classCollectionList():Array<ClassVisibilityCollection> { return this._classCollectionList; }
	private function get_numClasses():Int { return this._classCollectionList.length; }
	
	private var _classCollectionList:Array<ClassVisibilityCollection> = new Array<ClassVisibilityCollection>();
	private var _classCollectionMap:Map<String, ClassVisibilityCollection> = new Map<String, ClassVisibilityCollection>();

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		for (collection in this._classCollectionList)
		{
			collection.pool();
		}
		this._classCollectionList.resize(0);
		this._classCollectionMap.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function iterator():Iterator<ClassVisibilityCollection>
	{
		return this._classCollectionList.iterator();
	}
	
	public function add(collection:ClassVisibilityCollection):Void
	{
		this._classCollectionList.push(collection);
		this._classCollectionMap.set(collection.classID, collection);
	}
	
	public function get(classID:String):ClassVisibilityCollection
	{
		return this._classCollectionMap.get(classID);
	}
	
	public function has(classID:String):Bool
	{
		return this._classCollectionMap.exists(classID);
	}
	
	public function remove(collection:ClassVisibilityCollection, poolCollection:Bool = true):Void
	{
		this._classCollectionList.remove(collection);
		this._classCollectionMap.remove(collection.classID);
		if (poolCollection)
		{
			collection.pool();
		}
	}
	
	public function removeByClassID(classID:String, poolCollection:Bool = true):Void
	{
		var collection:ClassVisibilityCollection = this._classCollectionMap.get(classID);
		if (collection != null)
		{
			remove(collection, poolCollection);
		}
	}
	
	public function clone(?toVisibilities:ClassVisibilitiesCollection):ClassVisibilitiesCollection
	{
		if (toVisibilities == null) toVisibilities = fromPool();
		
		for (collection in this._classCollectionList)
		{
			toVisibilities.add(collection.clone());
		}
		
		return toVisibilities;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		var collection:ClassVisibilityCollection;
		var data:Array<Dynamic> = json.collections;
		for (node in data)
		{
			collection = ClassVisibilityCollection.fromPool();
			collection.fromJSON(node);
			add(collection);
		}
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		var data:Array<Dynamic> = [];
		for (collection in this._classCollectionList)
		{
			data.push(collection.toJSON());
		}
		json.collections = data;
		
		return json;
	}
	
}
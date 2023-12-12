package valeditor;
import haxe.iterators.ArrayIterator;

/**
 * ...
 * @author Matse
 */
class ValEditorObjectGroup 
{
	public var isMouseDown(get, set):Bool;
	public var numObjects(get, never):Int;
	
	private var _isMouseDown:Bool;
	private function get_isMouseDown():Bool { return this._isMouseDown; }
	private function set_isMouseDown(value:Bool):Bool
	{
		for (object in this._objects)
		{
			object.isMouseDown = value;
		}
		return this._isMouseDown = value;
	}
	
	private function get_numObjects():Int { return this._objects.length; }
	
	private var _objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	public function new() 
	{
		
	}
	
	public function iterator():ArrayIterator<ValEditorObject>
	{
		return this._objects.iterator();
	}
	
	public function clear():Void
	{
		this._objects.resize(0);
	}
	
	public function deleteObjects():Void
	{
		var objectsToDelete:Array<ValEditorObject> = this._objects.copy();
		for (object in objectsToDelete)
		{
			if (object.currentKeyFrame != null)
			{
				object.currentKeyFrame.remove(object);
			}
			if (object.canBeDestroyed())
			{
				ValEditor.destroyObject(object);
			}
		}
		this._objects.resize(0);
		clear();
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		if (this._objects.indexOf(object) != -1) return;
		this._objects.push(object);
	}
	
	public function getObjectAt(index:Int):ValEditorObject
	{
		return this._objects[index];
	}
	
	public function hasObject(object:ValEditorObject):Bool
	{
		return this._objects.indexOf(object) != -1;
	}
	
	public function removeObject(object:ValEditorObject):Bool
	{
		return this._objects.remove(object);
	}
	
	public function modifyDisplayProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		for (object in this._objects)
		{
			if (object.isDisplayObject)
			{
				object.modifyProperty(regularPropertyName, value, objectOnly, dispatchValueChange);
			}
		}
	}
	
	public function modifyProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		for (object in this._objects)
		{
			object.modifyProperty(regularPropertyName, value, objectOnly, dispatchValueChange);
		}
	}
	
	public function setDisplayProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		for (object in this._objects)
		{
			if (object.isDisplayObject)
			{
				object.setProperty(regularPropertyName, value, objectOnly, dispatchValueChange);
			}
		}
	}
	
	public function setProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		for (object in this._objects)
		{
			object.setProperty(regularPropertyName, value, objectOnly, dispatchValueChange);
		}
	}
	
}
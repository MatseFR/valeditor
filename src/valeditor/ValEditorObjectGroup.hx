package valeditor;
import haxe.iterators.ArrayIterator;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectRemove;
import valeditor.editor.action.object.ObjectRemoveKeyFrame;

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
	
	public function copyFrom(group:ValEditorObjectGroup):Void
	{
		addObjects(group._objects);
	}
	
	public function deleteObjects(?action:MultiAction):Void
	{
		var objectsToDelete:Array<ValEditorObject> = this._objects.copy();
		if (action == null)
		{
			if (Std.isOfType(ValEditor.currentContainer, IValEditorTimeLineContainer))
			{
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
			}
			else
			{
				for (object in objectsToDelete)
				{
					ValEditor.currentContainer.removeObject(object);
					if (object.canBeDestroyed())
					{
						ValEditor.destroyObject(object);
					}
				}
			}
		}
		else
		{
			if (Std.isOfType(ValEditor.currentContainer, IValEditorTimeLineContainer))
			{
				var objectRemoveKeyFrame:ObjectRemoveKeyFrame;
				for (object in objectsToDelete)
				{
					objectRemoveKeyFrame = ObjectRemoveKeyFrame.fromPool();
					objectRemoveKeyFrame.setup(object, cast object.currentKeyFrame);
					action.add(objectRemoveKeyFrame);
				}
			}
			else
			{
				var objectRemove:ObjectRemove;
				for (object in objectsToDelete)
				{
					objectRemove = ObjectRemove.fromPool();
					objectRemove.setup(object);
					action.add(objectRemove);
				}
			}
		}
		clear();
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		if (this._objects.indexOf(object) != -1) return;
		this._objects.push(object);
	}
	
	public function addObjects(objects:Array<ValEditorObject>):Void
	{
		for (object in objects)
		{
			addObject(object);
		}
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
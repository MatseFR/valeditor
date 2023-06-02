package valeditor.editor;
import valeditor.events.SelectionEvent;
import openfl.events.EventDispatcher;
import valedit.ValEditObject;
import valedit.ValEditObjectGroup;
import valedit.ValEditTemplate;

/**
 * ...
 * @author Matse
 */
class SelectionController extends EventDispatcher
{
	private var _group:ValEditObjectGroup = new ValEditObjectGroup();
	
	public var object(get, set):Dynamic;
	private function get_object():Dynamic 
	{
		if (this._template != null) return this._template;
		if (this._group.numObjects == 0) return null;
		if (this._group.numObjects == 1) return this._group.getObjectAt(0);
		return this._group;
	}
	private function set_object(value:Dynamic):Dynamic
	{
		if (value == null && this._template == null && this._group.numObjects == 0) return value;
		if (this._template != null && this._template == value) return value;
		if (this._group.numObjects == 1 && this._group.getObjectAt(0) == value) return value;
		this._template = null;
		this._group.clear();
		if (value != null)
		{
			if (Std.isOfType(value, ValEditObject))
			{
				this._group.addObject(cast value);
			}
			else if (Std.isOfType(value, ValEditTemplate))
			{
				this._template = cast value;
			}
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		return value;
	}
	
	public var numObjects(get, never):Int;
	private function get_numObjects():Int
	{
		if (this._template != null) return 1;
		return this._group.numObjects;
	}
	
	private var _template:ValEditTemplate;

	public function new() 
	{
		super();
	}
	
	public function addObject(object:ValEditObject):Void
	{
		if (object == null) return;
		this._template = null;
		this._group.addObject(object);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addObjects(objects:Array<ValEditObject>):Void
	{
		if (objects == null || objects.length == 0) return;
		this._template = null;
		for (object in objects)
		{
			this._group.addObject(object);
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function hasObject(object:ValEditObject):Bool
	{
		return this._group.hasObject(object);
	}
	
	public function removeObject(object:ValEditObject):Void
	{
		var removed:Bool = this._group.removeObject(object);
		if (removed)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
	public function removeObjects(objects:Array<ValEditObject>):Void
	{
		var objectRemoved:Bool = false;
		var removed:Bool;
		for (object in objects)
		{
			removed = this._group.removeObject(object);
			if (removed) objectRemoved = true;
		}
		
		if (objectRemoved)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
}
package valeditor.editor;
import openfl.events.EventDispatcher;
import valeditor.events.SelectionEvent;

/**
 * ...
 * @author Matse
 */
class Selection extends EventDispatcher
{
	public var object(get, set):Dynamic;
	private function get_object():Dynamic 
	{
		if (this._objectGroup.numObjects == 0 && this._templateGroup.numTemplates == 0) return null;
		if (this._objectGroup.numObjects == 1) return this._objectGroup.getObjectAt(0);
		if (this._templateGroup.numTemplates == 1) return this._templateGroup.getTemplateAt(0);
		if (this._objectGroup.numObjects != 0) return this._objectGroup;
		return this._templateGroup;
	}
	private function set_object(value:Dynamic):Dynamic
	{
		if (value == null && this._objectGroup.numObjects == 0 && this._templateGroup.numTemplates == 0) return value;
		if (this._objectGroup.numObjects == 1 && this._objectGroup.getObjectAt(0) == value) return value;
		if (this._templateGroup.numTemplates == 1 && this._templateGroup.getTemplateAt(0) == value) return value;
		this._objectGroup.clear();
		this._templateGroup.clear();
		if (value != null)
		{
			if (Std.isOfType(value, ValEditorObject))
			{
				this._objectGroup.addObject(cast value);
			}
			else if (Std.isOfType(value, ValEditorTemplate))
			{
				this._templateGroup.addTemplate(cast value);
			}
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		return value;
	}
	
	public var numObjects(get, never):Int;
	private function get_numObjects():Int
	{
		if (this._templateGroup.numTemplates != 0) return this._templateGroup.numTemplates;
		return this._objectGroup.numObjects;
	}
	
	private var _objectGroup:ValEditorObjectGroup = new ValEditorObjectGroup();
	private var _templateGroup:ValEditorTemplateGroup = new ValEditorTemplateGroup();

	public function new() 
	{
		super();
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		if (object == null) return;
		this._templateGroup.clear();
		this._objectGroup.addObject(object);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addObjects(objects:Array<ValEditorObject>):Void
	{
		if (objects == null || objects.length == 0) return;
		this._templateGroup.clear();
		for (object in objects)
		{
			this._objectGroup.addObject(object);
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		if (template == null) return;
		this._objectGroup.clear();
		this._templateGroup.addTemplate(template);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addTemplates(templates:Array<ValEditorTemplate>):Void
	{
		if (templates == null || templates.length == 0) return;
		this._objectGroup.clear();
		for (template in templates)
		{
			this._templateGroup.addTemplate(template);
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function hasObject(object:ValEditorObject):Bool
	{
		return this._objectGroup.hasObject(object);
	}
	
	public function hasTemplate(template:ValEditorTemplate):Bool
	{
		return this._templateGroup.hasTemplate(template);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		var removed:Bool = this._objectGroup.removeObject(object);
		if (removed)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
	public function removeObjects(objects:Array<ValEditorObject>):Void
	{
		var objectRemoved:Bool = false;
		var removed:Bool;
		for (object in objects)
		{
			removed = this._objectGroup.removeObject(object);
			if (removed) objectRemoved = true;
		}
		
		if (objectRemoved)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
	public function removeTemplate(template:ValEditorTemplate):Void
	{
		var removed:Bool = this._templateGroup.removeTemplate(template);
		if (removed)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
	public function removeTemplates(templates:Array<ValEditorTemplate>):Void
	{
		var templateRemoved:Bool = false;
		var removed:Bool;
		for (template in templates)
		{
			removed = this._templateGroup.removeTemplate(template);
			if (removed) templateRemoved = true;
		}
		
		if (templateRemoved)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
	public function delete():Void
	{
		if (this._templateGroup.numTemplates != 0)
		{
			this._templateGroup.deleteTemplates();
		}
		else
		{
			this._objectGroup.deleteObjects();
		}
	}
	
}
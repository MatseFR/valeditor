package valeditor.editor;
import openfl.events.EventDispatcher;
import valedit.ValEditKeyFrame;
import valeditor.ValEditorFrameGroup;
import valeditor.editor.clipboard.ValEditorClipboard;
import valeditor.events.SelectionEvent;

/**
 * ...
 * @author Matse
 */
class Selection extends EventDispatcher
{
	public var numObjects(get, never):Int;
	public var object(get, set):Dynamic;
	
	private function get_numObjects():Int
	{
		if (this._frameGroup.numFrames != 0) return this._frameGroup.numFrames;
		if (this._templateGroup.numTemplates != 0) return this._templateGroup.numTemplates;
		return this._objectGroup.numObjects;
	}
	
	private function get_object():Dynamic 
	{
		if (this._frameGroup.numFrames == 0 && this._objectGroup.numObjects == 0 && this._templateGroup.numTemplates == 0) return null;
		if (this._frameGroup.numFrames == 1) return this._frameGroup.getFrameAt(0);
		if (this._objectGroup.numObjects == 1) return this._objectGroup.getObjectAt(0);
		if (this._templateGroup.numTemplates == 1) return this._templateGroup.getTemplateAt(0);
		if (this._frameGroup.numFrames != 0) return this._frameGroup;
		if (this._objectGroup.numObjects != 0) return this._objectGroup;
		return this._templateGroup;
	}
	private function set_object(value:Dynamic):Dynamic
	{
		if (value == null && this._frameGroup.numFrames == 0 && this._objectGroup.numObjects == 0 && this._templateGroup.numTemplates == 0) return value;
		if (this._frameGroup.numFrames == 1 && this._frameGroup.getFrameAt(0) == value) return value;
		if (this._objectGroup.numObjects == 1 && this._objectGroup.getObjectAt(0) == value) return value;
		if (this._templateGroup.numTemplates == 1 && this._templateGroup.getTemplateAt(0) == value) return value;
		this._frameGroup.clear();
		this._objectGroup.clear();
		this._templateGroup.clear();
		if (value != null)
		{
			if (Std.isOfType(value, ValEditKeyFrame))
			{
				this._frameGroup.addFrame(cast value);
			}
			else if (Std.isOfType(value, ValEditorObject))
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
	
	private var _frameGroup:ValEditorFrameGroup = new ValEditorFrameGroup();
	private var _objectGroup:ValEditorObjectGroup = new ValEditorObjectGroup();
	private var _templateGroup:ValEditorTemplateGroup = new ValEditorTemplateGroup();

	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		this._frameGroup.clear();
		this._objectGroup.clear();
		this._templateGroup.clear();
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, null);
	}
	
	public function addFrame(frame:ValEditorKeyFrame):Void
	{
		if (frame == null) return;
		this._objectGroup.clear();
		this._templateGroup.clear();
		this._frameGroup.addFrame(frame);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addFrames(frames:Array<ValEditorKeyFrame>):Void
	{
		if (frames == null || frames.length == 0) return;
		this._objectGroup.clear();
		this._templateGroup.clear();
		for (frame in frames)
		{
			this._frameGroup.addFrame(frame);
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		if (object == null) return;
		this._frameGroup.clear();
		this._templateGroup.clear();
		this._objectGroup.addObject(object);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addObjects(objects:Array<ValEditorObject>):Void
	{
		if (objects == null || objects.length == 0) return;
		this._frameGroup.clear();
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
		this._frameGroup.clear();
		this._objectGroup.clear();
		this._templateGroup.addTemplate(template);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function addTemplates(templates:Array<ValEditorTemplate>):Void
	{
		if (templates == null || templates.length == 0) return;
		this._frameGroup.clear();
		this._objectGroup.clear();
		for (template in templates)
		{
			this._templateGroup.addTemplate(template);
		}
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function clearFrames():Void
	{
		if (this._frameGroup.numFrames == 0) return;
		this._frameGroup.clear();
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function clearObjects():Void
	{
		if (this._objectGroup.numObjects == 0) return;
		this._objectGroup.clear();
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function clearTemplates():Void
	{
		if (this._templateGroup.numTemplates == 0) return;
		this._templateGroup.clear();
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
	}
	
	public function copyToClipboard(clipboard:ValEditorClipboard):Void
	{
		for (frame in this._frameGroup)
		{
			clipboard.addFrame(frame);
		}
		for (object in this._objectGroup)
		{
			clipboard.addObject(object);
		}
		for (template in this._templateGroup)
		{
			clipboard.addTemplate(template);
		}
	}
	
	public function cutToClipboard(clipboard:ValEditorClipboard):Void
	{
		for (frame in this._frameGroup)
		{
			clipboard.addFrame(frame);
		}
		for (object in this._objectGroup)
		{
			clipboard.addObject(object);
			object.currentKeyFrame.remove(object);
		}
		for (template in this._templateGroup)
		{
			clipboard.addTemplate(template);
		}
	}
	
	public function hasFrame(frame:ValEditorKeyFrame):Bool
	{
		return this._frameGroup.hasFrame(frame);
	}
	
	public function hasObject(object:ValEditorObject):Bool
	{
		return this._objectGroup.hasObject(object);
	}
	
	public function hasTemplate(template:ValEditorTemplate):Bool
	{
		return this._templateGroup.hasTemplate(template);
	}
	
	public function removeFrame(frame:ValEditorKeyFrame):Void
	{
		var removed:Bool = this._frameGroup.removeFrame(frame);
		if (removed)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
	public function removeFrames(frames:Array<ValEditorKeyFrame>):Void
	{
		var frameRemoved:Bool = false;
		var removed:Bool;
		for (frame in frames)
		{
			removed = this._frameGroup.removeFrame(frame);
			if (removed) frameRemoved = true;
		}
		
		if (frameRemoved)
		{
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
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
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
		else if (this._objectGroup.numObjects != 0)
		{
			this._objectGroup.deleteObjects();
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
}
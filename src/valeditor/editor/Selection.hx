package valeditor.editor;
import openfl.events.EventDispatcher;
import valeditor.ValEditorFrameGroup;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.clipboard.ClipboardAddFrame;
import valeditor.editor.action.clipboard.ClipboardAddObject;
import valeditor.editor.action.clipboard.ClipboardAddTemplate;
import valeditor.editor.action.object.ObjectRemoveKeyFrame;
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
			if (Std.isOfType(value, ValEditorKeyFrame))
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
	
	public function copyFrom(selection:Selection, clear:Bool = true):Void
	{
		if (clear)
		{
			this._frameGroup.clear();
			this._objectGroup.clear();
			this._templateGroup.clear();
		}
		this._frameGroup.copyFrom(selection._frameGroup);
		this._objectGroup.copyFrom(selection._objectGroup);
		this._templateGroup.copyFrom(selection._templateGroup);
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
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
	
	public function copyToClipboard(clipboard:ValEditorClipboard, ?action:MultiAction):Void
	{
		if (action != null)
		{
			var frameAdd:ClipboardAddFrame = ClipboardAddFrame.fromPool();
			var objectAdd:ClipboardAddObject = ClipboardAddObject.fromPool();
			var templateAdd:ClipboardAddTemplate = ClipboardAddTemplate.fromPool();
			
			frameAdd.setup(clipboard);
			for (frame in this._frameGroup)
			{
				frameAdd.addFrame(frame);
			}
			if (frameAdd.numFrames == 0)
			{
				frameAdd.pool();
			}
			else
			{
				action.add(frameAdd);
			}
			
			objectAdd.setup(clipboard);
			for (object in this._objectGroup)
			{
				objectAdd.addObject(object);
			}
			if (objectAdd.numObjects == 0)
			{
				objectAdd.pool();
			}
			else
			{
				action.add(objectAdd);
			}
			
			templateAdd.setup(clipboard);
			for (template in this._templateGroup)
			{
				templateAdd.addTemplate(template);
			}
			if (templateAdd.numTemplates == 0)
			{
				templateAdd.pool();
			}
			else
			{
				action.add(templateAdd);
			}
		}
		else
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
	}
	
	public function cutToClipboard(clipboard:ValEditorClipboard, ?action:MultiAction):Void
	{
		if (action != null)
		{
			var frameAdd:ClipboardAddFrame = ClipboardAddFrame.fromPool();
			var objectAdd:ClipboardAddObject;
			var objectRemoveKeyFrame:ObjectRemoveKeyFrame;
			var templateAdd:ClipboardAddTemplate = ClipboardAddTemplate.fromPool();
			
			frameAdd.setup(clipboard);
			for (frame in this._frameGroup)
			{
				frameAdd.addFrame(frame);
			}
			if (frameAdd.numFrames == 0)
			{
				frameAdd.pool();
			}
			else
			{
				action.add(frameAdd);
			}
			
			for (object in this._objectGroup)
			{
				objectAdd = ClipboardAddObject.fromPool();
				objectAdd.setup(clipboard);
				objectAdd.addObject(object);
				action.add(objectAdd);
				objectRemoveKeyFrame = ObjectRemoveKeyFrame.fromPool();
				objectRemoveKeyFrame.setup(object, object.currentKeyFrame);
				action.add(objectRemoveKeyFrame);
			}
			
			templateAdd.setup(clipboard);
			for (template in this._templateGroup)
			{
				templateAdd.addTemplate(template);
			}
			if (templateAdd.numTemplates == 0)
			{
				templateAdd.pool();
			}
			else
			{
				action.add(templateAdd);
			}
		}
		else
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
	
	public function erase(action:MultiAction):Void
	{
		if (this._templateGroup.numTemplates != 0)
		{
			this._templateGroup.deleteTemplates(action);
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
		else if (this._objectGroup.numObjects != 0)
		{
			this._objectGroup.deleteObjects(action);
			SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this.object);
		}
	}
	
}
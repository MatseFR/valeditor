package valeditor.editor.clipboard;
import valedit.ExposedCollection;
import valedit.ValEditObject;
import valeditor.ValEditorFrameGroup;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorObject;
import valeditor.ValEditorObjectGroup;
import valeditor.ValEditorTemplate;
import valeditor.ValEditorTemplateGroup;
import valeditor.ui.feathers.FeathersWindows;

/**
 * ...
 * @author Matse
 */
class ValEditorClipboard 
{
	public var numObjects(get, never):Int;
	public var object(get, set):Dynamic;
	
	private function get_numObjects():Int
	{
		if (this._frameGroup.numFrames != 0) return this._frameGroup.numFrames;
		if (this._templateGroup.numTemplates != 0) return this._templateGroup.numTemplates;
		return this._objectGroup.numCopies;
	}
	
	private function get_object():Dynamic
	{
		if (this._frameGroup.numFrames == 0 && this._objectGroup.numCopies == 0 && this._templateGroup.numTemplates == 0) return null;
		if (this._frameGroup.numFrames == 1) return this._frameGroup.getFrameAt(0);
		if (this._objectGroup.numCopies == 1) return this._objectGroup.getCopyAt(0);
		if (this._templateGroup.numTemplates == 1) return this._templateGroup.getTemplateAt(0);
		if (this._frameGroup.numFrames != 0) return this._frameGroup;
		if (this._objectGroup.numCopies != 0) return this._objectGroup;
		return this._templateGroup;
	}
	private function set_object(value:Dynamic):Dynamic
	{
		if (value == null && this._frameGroup.numFrames == 0 && this._objectGroup.numCopies == 0 && this._templateGroup.numTemplates == 0) return value;
		var copy:ValEditorObjectCopy;
		var object:ValEditorObject;
		if (this._frameGroup.numFrames == 1 && this._frameGroup.getFrameAt(0) == value) return value;
		if (this._objectGroup.numCopies == 1)// && this._objectGroup.getCopyAt(0) == value) return value;
		{
			copy = this._objectGroup.getCopyAt(0);
			if (copy.object == value && copy.object.currentCollection == copy.collection)
			{
				return value;
			}
		}
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
				object = cast value;
				copy = ValEditorObjectCopy.fromPool(object, object.currentCollection);
				this._objectGroup.addCopy(copy);
			}
			else if (Std.isOfType(value, ValEditorTemplate))
			{
				this._templateGroup.addTemplate(cast value);
			}
		}
		return value;
	}
	
	private var _frameGroup:ValEditorFrameCopyGroup = new ValEditorFrameCopyGroup();
	private var _objectGroup:ValEditorObjectCopyGroup = new ValEditorObjectCopyGroup();
	private var _templateGroup:ValEditorTemplateCopyGroup = new ValEditorTemplateCopyGroup();
	
	private var _pasteCount:Int;
	private var _pasteIndex:Int;

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._frameGroup.clear();
		this._objectGroup.clear();
		this._templateGroup.clear();
	}
	
	public function addFrame(frame:ValEditorKeyFrame):Void
	{
		if (frame == null) return;
		this._objectGroup.clear();
		this._templateGroup.clear();
		this._frameGroup.addFrame(frame);
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
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		if (object == null) return;
		this._frameGroup.clear();
		this._templateGroup.clear();
		var copy:ValEditorObjectCopy = ValEditorObjectCopy.fromPool(object, object.currentCollection.clone(true));
		copy.collection.object = copy.object.object;
		this._objectGroup.addCopy(copy);
	}
	
	public function addObjects(objects:Array<ValEditorObject>):Void
	{
		if (objects == null || objects.length == 0) return;
		this._frameGroup.clear();
		this._templateGroup.clear();
		var copy:ValEditorObjectCopy;
		for (object in objects)
		{
			copy = ValEditorObjectCopy.fromPool(object, object.currentCollection.clone(true));
			copy.collection.object = copy.object.object;
			this._objectGroup.addCopy(copy);
		}
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		if (template == null) return;
		this._frameGroup.clear();
		this._objectGroup.clear();
		this._templateGroup.addTemplate(template);
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
	}
	
	public function paste():Void
	{
		if (this._frameGroup.numFrames != 0)
		{
			pasteFrames();
		}
		else if (this._objectGroup.numCopies != 0)
		{
			pasteObjects();
		}
		else if (this._templateGroup.numTemplates != 0)
		{
			pasteTemplates();
		}
	}
	
	private function pasteFrames():Void
	{
		
	}
	
	private function pasteObjects():Void
	{
		this._pasteCount = this._objectGroup.numCopies;
		this._pasteIndex = -1;
		
		if (this._pasteCount != 0)
		{
			ValEditor.selection.clear();
			pasteNextObject();
		}
	}
	
	private function pasteNextObject():Void
	{
		this._pasteIndex++;
		if (this._pasteIndex >= this._pasteCount) return;
		
		var copy:ValEditorObjectCopy = this._objectGroup.getCopyAt(this._pasteIndex);
		// look for reusable objects
		var reusableObjects:Array<ValEditObject> = cast(ValEditor.currentContainer.currentLayer.timeLine, ValEditorTimeLine).getReusableObjectsWithTemplateForKeyFrame(copy.object.template, ValEditor.currentContainer.currentLayer.timeLine.frameCurrent);
		if (reusableObjects.length != 0)
		{
			FeathersWindows.showObjectAddWindow(reusableObjects, onNewObject, onReuseObject, onCancelObject);
		}
		else
		{
			onNewObject();
		}
	}
	
	private function onCancelObject():Void
	{
		pasteNextObject();
	}
	
	private function onNewObject():Void
	{
		var copy:ValEditorObjectCopy = this._objectGroup.getCopyAt(this._pasteIndex);
		var object:ValEditorObject = ValEditor.createObjectWithTemplate(cast copy.object.template, null, copy.collection.clone(true));
		
		ValEditor.currentContainer.add(object);
		ValEditor.selection.addObject(object);
		
		pasteNextObject();
	}
	
	private function onReuseObject(object:ValEditorObject):Void
	{
		var copy:ValEditorObjectCopy = this._objectGroup.getCopyAt(this._pasteIndex);
		
		ValEditor.currentContainer.currentLayer.timeLine.frameCurrent.add(object);
		var collection:ExposedCollection = object.getCollectionForKeyFrame(ValEditor.currentContainer.currentLayer.timeLine.frameCurrent);
		collection.copyValuesFrom(copy.collection);
		
		ValEditor.selection.addObject(object);
		
		pasteNextObject();
	}
	
	private function pasteTemplates():Void
	{
		
	}
	
}
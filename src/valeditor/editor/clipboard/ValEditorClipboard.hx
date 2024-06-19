package valeditor.editor.clipboard;
import valedit.ExposedCollection;
import valedit.ValEditObject;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectAdd;
import valeditor.editor.action.object.ObjectAddKeyFrame;
import valeditor.editor.action.object.ObjectCreate;
import valeditor.editor.action.object.ObjectSelect;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.ui.feathers.FeathersWindows;

/**
 * ...
 * @author Matse
 */
class ValEditorClipboard 
{
	public var isRealClipboard(get, set):Bool;
	public var numObjects(get, never):Int;
	public var object(get, set):Dynamic;
	
	private var _isRealClipboard:Bool = false;
	private function get_isRealClipboard():Bool { return this._isRealClipboard; }
	private function set_isRealClipboard(value:Bool):Bool
	{
		this._frameGroup.isRealClipboard = value;
		this._objectGroup.isRealClipboard = value;
		this._templateGroup.isRealClipboard = value;
		return this._isRealClipboard = value;
	}
	
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
	private var _pasteAction:MultiAction;

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._frameGroup.clear();
		this._objectGroup.clear();
		this._templateGroup.clear();
	}
	
	public function copyFrom(clipboard:ValEditorClipboard):Void
	{
		this._frameGroup.copyFrom(clipboard._frameGroup);
		this._objectGroup.copyFrom(clipboard._objectGroup);
		this._templateGroup.copyFrom(clipboard._templateGroup);
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
	
	public function removeFrame(frame:ValEditorKeyFrame):Void
	{
		this._frameGroup.removeFrame(frame);
	}
	
	public function removeFrames(frames:Array<ValEditorKeyFrame>):Void
	{
		for (frame in frames)
		{
			this._frameGroup.removeFrame(frame);
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
	
	public function removeObject(object:ValEditorObject):Void
	{
		this._objectGroup.removeCopyForObject(object);
	}
	
	public function removeObjects(objects:Array<ValEditorObject>):Void
	{
		for (object in objects)
		{
			this._objectGroup.removeCopyForObject(object);
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
	
	public function removeTemplate(template:ValEditorTemplate):Void
	{
		this._templateGroup.removeTemplate(template);
	}
	
	public function removeTemplates(templates:Array<ValEditorTemplate>):Void
	{
		for (template in templates)
		{
			this._templateGroup.removeTemplate(template);
		}
	}
	
	public function paste(action:MultiAction):Void
	{
		if (this._frameGroup.numFrames != 0)
		{
			pasteFrames(action);
		}
		else if (this._objectGroup.numCopies != 0)
		{
			pasteObjects(action);
		}
		else if (this._templateGroup.numTemplates != 0)
		{
			pasteTemplates(action);
		}
	}
	
	private function pasteFrames(action:MultiAction):Void
	{
		// TODO : paste frames
	}
	
	private function pasteObjects(action:MultiAction):Void
	{
		this._pasteAction = action;
		this._pasteCount = this._objectGroup.numCopies;
		this._pasteIndex = -1;
		
		if (this._pasteCount != 0)
		{
			if (this._pasteAction != null)
			{
				if (ValEditor.selection.numObjects != 0)
				{
					var selectionClear:SelectionClear = SelectionClear.fromPool();
					selectionClear.setup(ValEditor.selection);
					this._pasteAction.add(selectionClear);
				}
			}
			else
			{
				ValEditor.selection.clear();
			}
			pasteNextObject();
		}
	}
	
	private function pasteNextObject():Void
	{
		this._pasteIndex++;
		if (this._pasteIndex >= this._pasteCount)
		{
			if (this._pasteAction != null)
			{
				//ValEditor.actionStack.add(this._pasteAction);
				this._pasteAction = null;
			}
			return;
		}
		
		var copy:ValEditorObjectCopy = this._objectGroup.getCopyAt(this._pasteIndex);
		
		if (ValEditor.currentTimeLineContainer != null)
		{
			// look for reusable objects
			var reusableObjects:Array<ValEditObject> = cast(ValEditor.currentTimeLineContainer.currentLayer.timeLine, ValEditorTimeLine).getReusableObjectsWithTemplateForKeyFrame(copy.object.template, ValEditor.currentTimeLineContainer.currentLayer.timeLine.frameCurrent);
			if (reusableObjects.length != 0)
			{
				FeathersWindows.showObjectAddWindow(reusableObjects, onNewObject, onReuseObject, onCancelObject);
			}
			else
			{
				onNewObject();
			}
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
		
		if (this._pasteAction != null)
		{
			var objectCreate:ObjectCreate = ObjectCreate.fromPool();
			objectCreate.setup(object);
			this._pasteAction.add(objectCreate);
			
			if (ValEditor.currentTimeLineContainer != null)
			{
				var objectAddKeyFrame:ObjectAddKeyFrame = ObjectAddKeyFrame.fromPool();
				objectAddKeyFrame.setup(object, cast ValEditor.currentTimeLineContainer.currentLayer.timeLine.frameCurrent);
				this._pasteAction.add(objectAddKeyFrame);
			}
			else
			{
				var objectAdd:ObjectAdd = ObjectAdd.fromPool();
				objectAdd.setup(object);
				this._pasteAction.add(objectAdd);
			}
			
			var objectSelect:ObjectSelect = ObjectSelect.fromPool();
			objectSelect.setup();
			objectSelect.addObject(object);
			this._pasteAction.add(objectSelect);
		}
		else
		{
			ValEditor.currentContainer.addObject(object);
			ValEditor.selection.addObject(object);
		}
		
		pasteNextObject();
	}
	
	private function onReuseObject(object:ValEditorObject):Void
	{
		var copy:ValEditorObjectCopy = this._objectGroup.getCopyAt(this._pasteIndex);
		var collection:ExposedCollection;
		
		if (this._pasteAction != null)
		{
			collection = object.createCollectionForKeyFrame(ValEditor.currentTimeLineContainer.currentLayer.timeLine.frameCurrent);
			
			var objectAdd:ObjectAddKeyFrame = ObjectAddKeyFrame.fromPool();
			objectAdd.setup(object, cast ValEditor.currentTimeLineContainer.currentLayer.timeLine.frameCurrent, collection);
			this._pasteAction.add(objectAdd);
			
			collection.copyValuesFrom(copy.collection, this._pasteAction);
			
			var objectSelect:ObjectSelect = ObjectSelect.fromPool();
			objectSelect.setup();
			objectSelect.addObject(object);
			this._pasteAction.add(objectSelect);
		}
		else
		{
			ValEditor.currentTimeLineContainer.currentLayer.timeLine.frameCurrent.add(object);
			collection = object.getCollectionForKeyFrame(ValEditor.currentTimeLineContainer.currentLayer.timeLine.frameCurrent);
			collection.copyValuesFrom(copy.collection);
			
			ValEditor.selection.addObject(object);
		}
		
		pasteNextObject();
	}
	
	private function pasteTemplates(action:MultiAction):Void
	{
		// TODO : paste templates
	}
	
}
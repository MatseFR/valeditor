package valeditor.editor.drag;
import openfl.Lib;
import openfl.errors.Error;
import openfl.events.MouseEvent;
import valedit.ValEditObject;
import valedit.utils.RegularPropertyName;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectAddKeyFrame;
import valeditor.editor.action.object.ObjectCreate;
import valeditor.editor.action.selection.SelectionSetObject;
import valeditor.ui.InteractiveObjectVisible;
import valeditor.ui.feathers.FeathersWindows;

/**
 * ...
 * @author Matse
 */
class LibraryDragManager 
{
	public var isDragging(default, null):Bool;
	public var object(default, null):ValEditorObject;
	public var objectIndicator(default, null):InteractiveObjectVisible = new InteractiveObjectVisible();
	public var template(default, null):ValEditorTemplate;
	
	private var _mouseX:Float;
	private var _mouseY:Float;

	public function new() 
	{
		
	}
	
	public function startDrag(template:ValEditorTemplate):Void
	{
		if (this.isDragging)
		{
			throw new Error("LibraryDragManager is already dragging");
		}
		this.isDragging = true;
		this.template = template;
		var wasUpdateLocked:Bool = template.lockInstanceUpdates;
		if (!wasUpdateLocked) template.lockInstanceUpdates = true;
		this.objectIndicator.objectUpdate(cast this.template.object);
		template.lockInstanceUpdates = wasUpdateLocked;
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
	}
	
	public function stopDrag():Void
	{
		if (!this.isDragging) return;
		this.isDragging = false;
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.removeEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
		
		if (this.objectIndicator.parent != null)
		{
			ValEditor.rootScene.removeChild(this.objectIndicator);
		}
		
		if (this.object != null)
		{
			ValEditor.destroyObject(this.object);
			this.object = null;
		}
	}
	
	private function onMouseMove(evt:MouseEvent):Void
	{
		if (ValEditor.viewPort.rect.contains(evt.stageX, evt.stageY))
		{
			if (ValEditor.currentContainer.canAddObject())
			{
				if (this.objectIndicator.parent == null)
				{
					ValEditor.rootScene.addChild(this.objectIndicator);
				}
				this.objectIndicator.x = evt.stageX;
				this.objectIndicator.y = evt.stageY;
			}
			else
			{
				// TODO : show some "forbidden" icon, message or something
			}
		}
		else
		{
			if (this.objectIndicator.parent != null)
			{
				ValEditor.rootScene.removeChild(this.objectIndicator);
			}
		}
	}
	
	private function onMouseUp(evt:MouseEvent):Void
	{
		if (ValEditor.viewPort.rect.contains(evt.stageX, evt.stageY) && ValEditor.currentContainer.canAddObject())
		{
			this._mouseX = evt.stageX;
			this._mouseY = evt.stageY;
			
			// look for reusable objects
			var reusableObjects:Array<ValEditObject> = cast(ValEditor.currentContainer.currentLayer.timeLine, ValEditorTimeLine).getReusableObjectsWithTemplateForKeyFrame(this.template, ValEditor.currentContainer.currentLayer.timeLine.frameCurrent);
			
			if (reusableObjects.length != 0)
			{
				FeathersWindows.showObjectAddWindow(reusableObjects, onNewObject, onReuseObject, onCancelObject);
			}
			else
			{
				onNewObject();
			}
		}
		
		stopDrag();
	}
	
	private function onNewObject():Void
	{
		var action:MultiAction = MultiAction.fromPool();
		var objectCreate:ObjectCreate;
		var objectAdd:ObjectAddKeyFrame;
		var selectionSetObject:SelectionSetObject;
		
		this.object = ValEditor.createObjectWithTemplate(this.template);
		objectCreate = ObjectCreate.fromPool();
		objectCreate.setup(this.object);
		action.add(objectCreate);
		
		if (this.object.isDisplayObject)
		{
			this.object.setProperty(RegularPropertyName.X, this._mouseX - ValEditor.viewPort.x + ValEditor.currentContainer.cameraX);
			this.object.setProperty(RegularPropertyName.Y, this._mouseY - ValEditor.viewPort.y + ValEditor.currentContainer.cameraY);
		}
		
		//ValEditor.currentContainer.add(this.object);
		objectAdd = ObjectAddKeyFrame.fromPool();
		objectAdd.setup(this.object, cast ValEditor.currentContainer.currentLayer.timeLine.frameCurrent);
		action.add(objectAdd);
		
		//ValEditor.selection.object = this.object;
		selectionSetObject = SelectionSetObject.fromPool();
		selectionSetObject.setup(this.object);
		action.add(selectionSetObject);
		
		this.object = null;
		Lib.current.stage.focus = null;
		
		ValEditor.actionStack.add(action);
	}
	
	private function onReuseObject(object:ValEditorObject):Void
	{
		var action:MultiAction = MultiAction.fromPool();
		var objectAdd:ObjectAddKeyFrame;
		var selectionSetObject:SelectionSetObject;
		
		//ValEditor.currentContainer.currentLayer.timeLine.frameCurrent.add(object);
		objectAdd = ObjectAddKeyFrame.fromPool();
		objectAdd.setup(object, cast ValEditor.currentContainer.currentLayer.timeLine.frameCurrent);
		action.add(objectAdd);
		
		if (object.isDisplayObject)
		{
			object.setProperty(RegularPropertyName.X, this._mouseX - ValEditor.viewPort.x + ValEditor.currentContainer.cameraX);
			object.setProperty(RegularPropertyName.Y, this._mouseY - ValEditor.viewPort.y + ValEditor.currentContainer.cameraY);
		}
		
		selectionSetObject = SelectionSetObject.fromPool();
		selectionSetObject.setup(object);
		action.add(selectionSetObject);
		
		Lib.current.stage.focus = null;
		
		ValEditor.actionStack.add(action);
	}
	
	private function onCancelObject():Void
	{
		
	}
	
	private function onRightClick(evt:MouseEvent):Void
	{
		stopDrag();
	}
	
}
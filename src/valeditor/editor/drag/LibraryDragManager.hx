package valeditor.editor.drag;
import openfl.Lib;
import openfl.errors.Error;
import openfl.events.MouseEvent;
import valedit.ValEditObject;
import valedit.utils.RegularPropertyName;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.ValEditorTimeLine;
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
		this.object = ValEditor.createObjectWithTemplate(this.template);
		if (this.object.isDisplayObject)
		{
			this.object.setProperty(RegularPropertyName.X, this._mouseX - ValEditor.viewPort.x + ValEditor.currentContainer.cameraX);
			this.object.setProperty(RegularPropertyName.Y, this._mouseY - ValEditor.viewPort.y + ValEditor.currentContainer.cameraY);
		}
		
		ValEditor.currentContainer.add(this.object);
		ValEditor.selection.object = this.object;
		this.object = null;
		Lib.current.stage.focus = null;
	}
	
	private function onReuseObject(object:ValEditorObject):Void
	{
		ValEditor.currentContainer.currentLayer.timeLine.frameCurrent.add(object);
		
		if (object.isDisplayObject)
		{
			object.setProperty(RegularPropertyName.X, this._mouseX - ValEditor.viewPort.x + ValEditor.currentContainer.cameraX);
			object.setProperty(RegularPropertyName.Y, this._mouseY - ValEditor.viewPort.y + ValEditor.currentContainer.cameraY);
		}
	}
	
	private function onCancelObject():Void
	{
		
	}
	
	private function onRightClick(evt:MouseEvent):Void
	{
		stopDrag();
	}
	
}
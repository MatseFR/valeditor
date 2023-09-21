package valeditor.editor.drag;
import openfl.Lib;
import openfl.errors.Error;
import openfl.events.MouseEvent;
import valedit.utils.RegularPropertyName;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.ui.InteractiveObjectVisible;

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
		this.objectIndicator.objectUpdate(cast this.template.object);
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
			this.object = ValEditor.createObjectWithTemplate(this.template);
			if (this.object.isDisplayObject)
			{
				this.object.setProperty(RegularPropertyName.X, evt.stageX - ValEditor.viewPort.x + ValEditor.currentContainer.cameraX);
				this.object.setProperty(RegularPropertyName.Y, evt.stageY - ValEditor.viewPort.y + ValEditor.currentContainer.cameraY);
			}
			
			ValEditor.currentContainer.add(this.object);
			ValEditor.selection.object = this.object;
			this.object = null;
			Lib.current.stage.focus = null;
		}
		
		stopDrag();
	}
	
	private function onRightClick(evt:MouseEvent):Void
	{
		stopDrag();
	}
	
}
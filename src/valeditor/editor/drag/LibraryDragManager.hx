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
		this.object = ValEditor.createObjectWithTemplate(this.template);
		this.objectIndicator.objectUpdate(this.object);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	public function stopDrag():Void
	{
		if (!this.isDragging) return;
		this.isDragging = false;
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
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
		trace("" + evt.stageX + ", " + evt.stageY);
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
				
				if (this.object.isDisplayObject)
				{
					this.object.setProperty(RegularPropertyName.X, evt.stageX - ValEditor.viewPort.x + ValEditor.currentContainer.cameraX);
					this.object.setProperty(RegularPropertyName.Y, evt.stageY - ValEditor.viewPort.y + ValEditor.currentContainer.cameraY);
				}
			}
			else
			{
				// TODO : show some "forbidden" icon or something
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
			ValEditor.currentContainer.add(this.object);
			ValEditor.selection.object = this.object;
			this.object = null;
		}
		
		stopDrag();
	}
	
}
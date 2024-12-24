package valeditor.ui.feathers.window.base;

import feathers.controls.Panel;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Matse
 */
class PanelWindow extends Panel 
{

	public function new() 
	{
		super();
		//this.addEventListener(MouseEvent.CLICK, onMouseEvent);
		//this.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseEvent);
		//this.addEventListener(MouseEvent.MIDDLE_CLICK, onMouseEvent);
		//this.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseEvent);
		//this.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseEvent);
		//this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
		//this.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
		//this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);
		//this.addEventListener(MouseEvent.RIGHT_CLICK, onMouseEvent);
		//this.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent);
		//this.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent);
		//this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
		//this.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
	}
	
	private function onKeyboardEvent(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onMouseEvent(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
}
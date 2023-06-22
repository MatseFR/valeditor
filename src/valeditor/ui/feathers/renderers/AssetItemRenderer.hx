package valeditor.ui.feathers.renderers;

import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Matse
 */
@:styleContext
class AssetItemRenderer extends LayoutGroupItemRenderer 
{

	public function new() 
	{
		super();
		this.addEventListener(MouseEvent.CLICK, onMouseClick);
	}
	
	override public function dispose():Void 
	{
		this.removeEventListener(MouseEvent.CLICK, onMouseClick);
		super.dispose();
	}
	
	private function onMouseClick(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
}
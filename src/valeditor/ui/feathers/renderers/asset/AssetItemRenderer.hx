package valeditor.ui.feathers.renderers.asset;

import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Matse
 */
@:styleContext
abstract class AssetItemRenderer extends LayoutGroupItemRenderer 
{

	public function new() 
	{
		super();
		this.addEventListener(MouseEvent.CLICK, onMouseClick);
	}
	
	abstract public function pool():Void;
	
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
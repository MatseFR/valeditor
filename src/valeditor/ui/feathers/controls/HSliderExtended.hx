package valeditor.ui.feathers.controls;

import feathers.controls.HSlider;
import openfl.events.Event;
import openfl.events.MouseEvent;
import valeditor.events.ValueUIEvent;

/**
 * ...
 * @author Matse
 */
class HSliderExtended extends HSlider 
{

	public function new(value:Float=0.0, minimum:Float=0.0, maximum:Float=1.0, ?changeListener:(Event)->Void) 
	{
		super(value, minimum, maximum, changeListener);
	}
	
	override function thumbSkin_mouseDownHandler(event:MouseEvent):Void 
	{
		super.thumbSkin_mouseDownHandler(event);
		
		ValueUIEvent.dispatch(this, ValueUIEvent.CHANGE_BEGIN);
	}
	
	override function thumbSkin_stage_mouseUpHandler(event:MouseEvent):Void 
	{
		super.thumbSkin_stage_mouseUpHandler(event);
		
		ValueUIEvent.dispatch(this, ValueUIEvent.CHANGE_END);
	}
	
	override function trackSkin_mouseDownHandler(event:MouseEvent):Void 
	{
		super.trackSkin_mouseDownHandler(event);
		
		ValueUIEvent.dispatch(this, ValueUIEvent.CHANGE_BEGIN);
	}
	
	override function trackSkin_stage_mouseUpHandler(event:MouseEvent):Void 
	{
		super.trackSkin_stage_mouseUpHandler(event);
		
		ValueUIEvent.dispatch(this, ValueUIEvent.CHANGE_END);
	}
	
}
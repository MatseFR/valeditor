package ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.value.ExposedFunction;

/**
 * ...
 * @author Matse
 */
class FunctionUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		_func = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _func:ExposedFunction;
	
	private var _button:Button;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.paddingTop = hLayout.paddingBottom = Padding.DEFAULT;
		hLayout.paddingLeft = hLayout.paddingRight = Padding.DEFAULT * 2;
		this.layout = hLayout;
		
		_button = new Button();
		addChild(_button);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_button.text = _func.name;
		updateEditable();
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_button.enabled = _exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_button.removeEventListener(TriggerEvent.TRIGGER, onButton);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_button.addEventListener(TriggerEvent.TRIGGER, onButton);
	}
	
	private function onButton(evt:TriggerEvent):Void
	{
		_func.execute();
	}
	
}
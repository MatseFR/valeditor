package ui.feathers.controls.value;

import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import valedit.ui.IValueUI;
import valedit.value.ExposedIntRange;

/**
 * ...
 * @author Matse
 */
class IntRangeUI extends ValueUI 
{
	private var _label:Label;
	private var _slider:HSlider;
	private var _input:TextInput;
	
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
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this.layout = hLayout;
		
		_label = new Label();
		//_label.layoutData = new HorizontalLayoutData(25);
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_slider = new HSlider();
		_slider.layoutData = new HorizontalLayoutData(50);
		addChild(_slider);
		
		_input = new TextInput();
		_input.layoutData = new HorizontalLayoutData(50);
		addChild(_input);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
		_slider.minimum = cast(_exposedValue, ExposedIntRange).min;
		_slider.maximum = cast(_exposedValue, ExposedIntRange).max;
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_slider.value = _exposedValue.value;
			_slider.enabled = _exposedValue.isEditable;
			_input.text = Std.string(_exposedValue.value);
			_input.enabled = _exposedValue.isEditable;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	override function controlsDisable():Void
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_slider.removeEventListener(Event.CHANGE, onSliderChange);
		_input.removeEventListener(Event.CHANGE, onInputChange);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_slider.addEventListener(Event.CHANGE, onSliderChange);
		_input.addEventListener(Event.CHANGE, onInputChange);
	}
	
	private function onInputChange(evt:Event):Void
	{
		_exposedValue.value = Std.parseInt(_input.text);
		_slider.value = _exposedValue.value;
	}
	
	private function onSliderChange(evt:Event):Void
	{
		_exposedValue.value = Std.int(_slider.value);
		_input.text = Std.string(_exposedValue.value);
	}
	
}
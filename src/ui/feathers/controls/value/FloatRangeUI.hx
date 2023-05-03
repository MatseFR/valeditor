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
import ui.feathers.variant.TextInputVariant;
import utils.MathUtil;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFloatRange;

/**
 * ...
 * @author Matse
 */
class FloatRangeUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			_floatRange = null;
		}
		else
		{
			_floatRange = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _floatRange:ExposedFloatRange;
	
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
		hLayout.paddingRight = Padding.VALUE;
		this.layout = hLayout;
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_slider = new HSlider();
		_slider.layoutData = new HorizontalLayoutData(100);
		addChild(_slider);
		
		_input = new TextInput();
		_input.variant = TextInputVariant.NUMERIC_MEDIUM;
		addChild(_input);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
		_input.variant = _floatRange.inputVariant;
		_slider.minimum = _floatRange.min;
		_slider.maximum = _floatRange.max;
		_slider.step = _floatRange.step;
		_slider.snapInterval = _floatRange.step;
		if (_floatRange.min < 0)
		{
			_input.restrict = "0123456789.-";
		}
		else
		{
			_input.restrict = "0123456789.";
		}
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_slider.value = _exposedValue.value;
			_input.text = Std.string(MathUtil.roundToPrecision(_exposedValue.value, _floatRange.precision));
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_label.enabled = _exposedValue.isEditable;
		_slider.enabled = _exposedValue.isEditable;
		_input.enabled = _exposedValue.isEditable;
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
		_exposedValue.value = MathUtil.roundToPrecision(Std.parseFloat(_input.text), cast(_exposedValue, ExposedFloatRange).precision);
		_slider.value = MathUtil.roundToPrecision(_exposedValue.value, cast(_exposedValue, ExposedFloatRange).precision);
	}
	
	private function onSliderChange(evt:Event):Void
	{
		_exposedValue.value = MathUtil.roundToPrecision(_slider.value, cast(_exposedValue, ExposedFloatRange).precision);
		_input.text = Std.string(MathUtil.roundToPrecision(_exposedValue.value, cast(_exposedValue, ExposedFloatRange).precision));
	}
	
}
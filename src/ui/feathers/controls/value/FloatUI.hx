package ui.feathers.controls.value;

import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import ui.feathers.variant.TextInputVariant;
import utils.MathUtil;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFloat;
import valedit.value.NumericMode;

/**
 * ...
 * @author Matse
 */
class FloatUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		//if (value == null)
		//{
			//_floatValue = null;
		//}
		//else
		//{
			_floatValue = cast value;
		//}
		return super.set_exposedValue(value);
	}
	
	private var _floatValue:ExposedFloat;
	
	private var _label:Label;
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
		
		_input = new TextInput();
		_input.variant = TextInputVariant.FULL_WIDTH;
		addChild(_input);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
		_input.variant = _floatValue.inputVariant;
		switch (_floatValue.numericMode)
		{
			case NumericMode.Positive :
				_input.restrict = "0123456789.";
			
			default :
				_input.restrict = "0123456789.-";
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
			_input.text = Std.string(MathUtil.roundToPrecision(_exposedValue.value, cast(_exposedValue, ExposedFloat).precision));
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_label.enabled = _exposedValue.isEditable;
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
		_input.removeEventListener(Event.CHANGE, onInputChange);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_input.addEventListener(Event.CHANGE, onInputChange);
	}
	
	private function onInputChange(evt:Event):Void
	{
		_exposedValue.value = MathUtil.roundToPrecision(Std.parseFloat(_input.text), cast(_exposedValue, ExposedFloat).precision);
	}
	
}
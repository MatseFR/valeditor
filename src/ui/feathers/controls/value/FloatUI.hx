package ui.feathers.controls.value;

import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.ValueUI;
import ui.feathers.variant.LabelVariant;
import utils.MathUtil;
import valedit.ui.IValueUI;
import valedit.value.ExposedFloat;

/**
 * ...
 * @author Matse
 */
class FloatUI extends ValueUI 
{
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
		this.layout = hLayout;
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_input = new TextInput();
		_input.restrict = "0123456789.";
		addChild(_input);
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_label.text = _exposedValue.name;
			_input.editable = _exposedValue.isEditable;
			_input.text = Std.string(MathUtil.roundToPrecision(_exposedValue.value, cast(_exposedValue, ExposedFloat).precision));
			if (controlsEnabled) controlsEnable();
		}
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
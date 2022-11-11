package ui.feathers.controls.value;

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
import valedit.value.ExposedString;

/**
 * ...
 * @author Matse
 */
class StringUI extends ValueUI 
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
		_input.layoutData = new HorizontalLayoutData(100);
		addChild(_input);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
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
			_input.restrict = cast(_exposedValue, ExposedString).restrict;
			_input.text = _exposedValue.value;
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
		_exposedValue.value = _input.text;
	}
	
}
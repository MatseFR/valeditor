package ui.feathers.controls.value;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class BoolUI extends ValueUI 
{
	private var _label:Label;
	private var _check:Check;
	
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
		
		_check = new Check();
		addChild(_check);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		_label.text = _exposedValue.name;
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_check.enabled = _exposedValue.isEditable;
			_check.selected = _exposedValue.value;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_check.removeEventListener(Event.CHANGE, onCheckChange);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_check.addEventListener(Event.CHANGE, onCheckChange);
	}
	
	private function onCheckChange(evt:Event):Void
	{
		_exposedValue.value = _check.selected;
	}
	
}
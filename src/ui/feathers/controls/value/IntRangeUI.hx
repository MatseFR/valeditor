package ui.feathers.controls.value;

import feathers.controls.Button;
import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import ui.feathers.variant.TextInputVariant;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedIntRange;

/**
 * ...
 * @author Matse
 */
class IntRangeUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._intRange = null;
		}
		else
		{
			this._intRange = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _intRange:ExposedIntRange;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _slider:HSlider;
	private var _input:TextInput;
	
	private var _nullGroup:LayoutGroup;
	private var _wedge:ValueWedge;
	private var _nullButton:Button;
	
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
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.MINIMAL;
		vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		this._mainGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._mainGroup.layout = hLayout;
		addChild(this._mainGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._mainGroup.addChild(this._label);
		
		this._slider = new HSlider();
		this._slider.layoutData = new HorizontalLayoutData(100);
		this._mainGroup.addChild(this._slider);
		
		this._input = new TextInput();
		this._input.variant = TextInputVariant.NUMERIC_MEDIUM;
		this._input.prompt = "null";
		this._mainGroup.addChild(this._input);
		
		this._nullGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._nullGroup.layout = hLayout;
		
		this._wedge = new ValueWedge();
		this._nullGroup.addChild(this._wedge);
		
		this._nullButton = new Button("set to null");
		this._nullButton.layoutData = new HorizontalLayoutData(100);
		this._nullGroup.addChild(this._nullButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		this._label.text = this._exposedValue.name;
		this._slider.minimum = this._intRange.min;
		this._slider.maximum = this._intRange.max;
		this._slider.step = this._intRange.step;
		this._slider.snapInterval = this._intRange.step;
		this._input.variant = this._intRange.inputVariant;
		if (this._intRange.min < 0)
		{
			this._input.restrict = "-0123456789";
		}
		else
		{
			this._input.restrict = "0123456789";
		}
		if (this._exposedValue.isNullable)
		{
			if (this._nullGroup.parent == null)
			{
				addChild(this._nullGroup);
			}
		}
		else
		{
			if (this._nullGroup.parent != null)
			{
				removeChild(this._nullGroup);
			}
		}
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			var controlsEnabled:Bool = this._controlsEnabled;
			if (controlsEnabled) controlsDisable();
			if (this._exposedValue.value == null)
			{
				this._input.text = "";
			}
			else
			{
				this._slider.value = this._exposedValue.value;
				this._input.text = Std.string(this._exposedValue.value);
			}
				
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._slider.enabled = this._exposedValue.isEditable;
		this._input.enabled = this._exposedValue.isEditable;
		this._nullButton.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._slider.removeEventListener(Event.CHANGE, onSliderChange);
		this._input.removeEventListener(Event.CHANGE, onInputChange);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._slider.addEventListener(Event.CHANGE, onSliderChange);
		this._input.addEventListener(Event.CHANGE, onInputChange);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onInputChange(evt:Event):Void
	{
		if (this._input.text == "") return;
		this._exposedValue.value = Std.parseInt(this._input.text);
		this._slider.value = this._exposedValue.value;
	}
	
	private function onSliderChange(evt:Event):Void
	{
		this._exposedValue.value = Std.int(this._slider.value);
		this._input.text = Std.string(this._exposedValue.value);
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		this._exposedValue.value = null;
		this._input.text = "";
	}
	
}
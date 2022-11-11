package ui.feathers.controls.value;

import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.RectangleSkin;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import ui.feathers.variant.LayoutGroupVariant;
import utils.ColorUtil;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class ColorUI extends ValueUI 
{
	private var _previewGroup:LayoutGroup;
	private var _label:Label;
	private var _preview:LayoutGroup;
	private var _previewSkin:RectangleSkin;
	
	private var _hexGroup:LayoutGroup;
	private var _hexLabel:Label;
	private var _hexInput:TextInput;
	
	private var _redGroup:LayoutGroup;
	private var _redLabel:Label;
	private var _redSlider:HSlider;
	private var _redInput:TextInput;
	
	private var _greenGroup:LayoutGroup;
	private var _greenLabel:Label;
	private var _greenSlider:HSlider;
	private var _greenInput:TextInput;
	
	private var _blueGroup:LayoutGroup;
	private var _blueLabel:Label;
	private var _blueSlider:HSlider;
	private var _blueInput:TextInput;
	
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
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		// Preview
		_previewGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		_previewGroup.layout = hLayout;
		addChild(_previewGroup);
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		_previewGroup.addChild(_label);
		
		_preview = new LayoutGroup();
		_preview.variant = LayoutGroupVariant.COLOR_PREVIEW;
		_previewSkin = new RectangleSkin(FillStyle.SolidColor(0xffffff, 1), LineStyle.SolidColor(2, 0x000000, 1));
		_preview.backgroundSkin = _previewSkin;
		_previewGroup.addChild(_preview);
		
		// Hexa
		_hexGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		_hexGroup.layout = hLayout;
		addChild(_hexGroup);
		
		_hexLabel = new Label("hexa");
		_hexLabel.variant = LabelVariant.SUBVALUE_NAME;
		_hexGroup.addChild(_hexLabel);
		
		_hexInput = new TextInput();
		_hexInput.restrict = "0123456789abcdef";
		_hexInput.maxChars = 6;
		_hexInput.text = "ffffff";
		_hexGroup.addChild(_hexInput);
		
		// Red
		_redGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		_redGroup.layout = hLayout;
		addChild(_redGroup);
		
		_redLabel = new Label("red");
		_redLabel.variant = LabelVariant.SUBVALUE_NAME;
		_redGroup.addChild(_redLabel);
		
		_redSlider = new HSlider();
		_redSlider.layoutData = new HorizontalLayoutData(75);
		_redSlider.minimum = 0;
		_redSlider.maximum = 255;
		_redSlider.step = 1;
		_redSlider.value = 255;
		_redGroup.addChild(_redSlider);
		
		_redInput = new TextInput();
		_redInput.layoutData = new HorizontalLayoutData(25);
		_redInput.restrict = "0123456789";
		_redInput.maxChars = 3;
		_redInput.text = "255";
		_redGroup.addChild(_redInput);
		
		// Green
		_greenGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		_greenGroup.layout = hLayout;
		addChild(_greenGroup);
		
		_greenLabel = new Label("green");
		_greenLabel.variant = LabelVariant.SUBVALUE_NAME;
		_greenGroup.addChild(_greenLabel);
		
		_greenSlider = new HSlider();
		_greenSlider.layoutData = new HorizontalLayoutData(75);
		_greenSlider.minimum = 0;
		_greenSlider.maximum = 255;
		_greenSlider.step = 1;
		_greenSlider.value = 255;
		_greenGroup.addChild(_greenSlider);
		
		_greenInput = new TextInput();
		_greenInput.layoutData = new HorizontalLayoutData(25);
		_greenInput.restrict = "0123456789";
		_greenInput.maxChars = 3;
		_greenInput.text = "255";
		_greenGroup.addChild(_greenInput);
		
		// Blue
		_blueGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		_blueGroup.layout = hLayout;
		addChild(_blueGroup);
		
		_blueLabel = new Label("blue");
		_blueLabel.variant = LabelVariant.SUBVALUE_NAME;
		_blueGroup.addChild(_blueLabel);
		
		_blueSlider = new HSlider();
		_blueSlider.layoutData = new HorizontalLayoutData(75);
		_blueSlider.minimum = 0;
		_blueSlider.maximum = 255;
		_blueSlider.step = 1;
		_blueSlider.value = 255;
		_blueGroup.addChild(_blueSlider);
		
		_blueInput = new TextInput();
		_blueInput.layoutData = new HorizontalLayoutData(25);
		_blueInput.restrict = "0123456789";
		_blueInput.maxChars = 3;
		_blueInput.text = "255";
		_blueGroup.addChild(_blueInput);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			colorUpdate();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_label.enabled = _exposedValue.isEditable;
		_preview.enabled = _exposedValue.isEditable;
		_hexLabel.enabled = _exposedValue.isEditable;
		_hexInput.enabled = _exposedValue.isEditable;
		_redLabel.enabled = _exposedValue.isEditable;
		_redSlider.enabled = _exposedValue.isEditable;
		_redInput.enabled = _exposedValue.isEditable;
		_greenLabel.enabled = _exposedValue.isEditable;
		_greenSlider.enabled = _exposedValue.isEditable;
		_greenInput.enabled = _exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	private function colorUpdate():Void
	{
		var controlsEnabled:Bool = _controlsEnabled;
		if (controlsEnabled) controlsDisable();
		var value:Int = _exposedValue.value;
		_previewSkin.fill = FillStyle.SolidColor(value, 1);
		_hexInput.text = ColorUtil.RGBtoHexString(value);
		_redInput.text = Std.string(ColorUtil.getRed(value));
		_redSlider.value = ColorUtil.getRed(value);
		_greenInput.text = Std.string(ColorUtil.getGreen(value));
		_greenSlider.value = ColorUtil.getGreen(value);
		_blueInput.text = Std.string(ColorUtil.getBlue(value));
		_blueSlider.value = ColorUtil.getBlue(value);
		if (controlsEnabled) controlsEnable();
	}
	
	override function controlsDisable():Void
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_hexInput.removeEventListener(Event.CHANGE, onHexInputChange);
		_redSlider.removeEventListener(Event.CHANGE, onRedSliderChange);
		_redInput.removeEventListener(Event.CHANGE, onRedInputChange);
		_greenSlider.removeEventListener(Event.CHANGE, onGreenSliderChange);
		_greenInput.removeEventListener(Event.CHANGE, onGreenInputChange);
		_blueSlider.removeEventListener(Event.CHANGE, onBlueSliderChange);
		_blueInput.removeEventListener(Event.CHANGE, onBlueInputChange);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_hexInput.addEventListener(Event.CHANGE, onHexInputChange);
		_redSlider.addEventListener(Event.CHANGE, onRedSliderChange);
		_redInput.addEventListener(Event.CHANGE, onRedInputChange);
		_greenSlider.addEventListener(Event.CHANGE, onGreenSliderChange);
		_greenInput.addEventListener(Event.CHANGE, onGreenInputChange);
		_blueSlider.addEventListener(Event.CHANGE, onBlueSliderChange);
		_blueInput.addEventListener(Event.CHANGE, onBlueInputChange);
	}
	
	private function onHexInputChange(evt:Event):Void
	{
		_exposedValue.value = Std.parseInt("0x" + _hexInput.text);
		colorUpdate();
	}
	
	private function onRedSliderChange(evt:Event):Void
	{
		_exposedValue.value = ColorUtil.setRed(_exposedValue.value, Std.int(_redSlider.value));
		colorUpdate();
	}
	
	private function onRedInputChange(evt:Event):Void
	{
		_exposedValue.value = ColorUtil.setRed(_exposedValue.value, Std.parseInt(_redInput.text));
		colorUpdate();
	}
	
	private function onGreenSliderChange(evt:Event):Void
	{
		_exposedValue.value = ColorUtil.setGreen(_exposedValue.value, Std.int(_greenSlider.value));
		colorUpdate();
	}
	
	private function onGreenInputChange(evt:Event):Void
	{
		_exposedValue.value = ColorUtil.setGreen(_exposedValue.value, Std.parseInt(_greenInput.text));
		colorUpdate();
	}
	
	private function onBlueSliderChange(evt:Event):Void
	{
		_exposedValue.value = ColorUtil.setBlue(_exposedValue.value, Std.int(_blueSlider.value));
		colorUpdate();
	}
	
	private function onBlueInputChange(evt:Event):Void
	{
		_exposedValue.value = ColorUtil.setBlue(_exposedValue.value, Std.parseInt(_blueInput.text));
		colorUpdate();
	}
	
}
package valeditor.ui.feathers.controls.value;

import feathers.controls.Button;
import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.graphics.FillStyle;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.RectangleSkin;
import openfl.events.Event;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valeditor.ui.feathers.variant.TextInputVariant;
import valeditor.utils.ColorUtil;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valeditor.ui.feathers.Padding;

/**
 * ...
 * @author Matse
 */
class ColorUI extends ValueUI 
{
	private var _previewGroup:LayoutGroup;
	private var _label:Label;
	private var _preview:LayoutGroup;
	private var _previewColor:LayoutGroup;
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
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		// Preview
		this._previewGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._previewGroup.layout = hLayout;
		addChild(this._previewGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._previewGroup.addChild(this._label);
		
		this._preview = new LayoutGroup();
		this._preview.variant = LayoutGroupVariant.COLOR_PREVIEW_CONTAINER;
		this._previewGroup.addChild(this._preview);
		
		this._previewColor = new LayoutGroup();
		this._previewColor.variant = LayoutGroupVariant.COLOR_PREVIEW;
		this._previewSkin = new RectangleSkin(FillStyle.SolidColor(0xffffff));
		this._previewColor.backgroundSkin = this._previewSkin;
		this._preview.addChild(this._previewColor);
		
		// Hexa
		this._hexGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._hexGroup.layout = hLayout;
		addChild(this._hexGroup);
		
		this._hexLabel = new Label("hexa");
		this._hexLabel.variant = LabelVariant.SUBVALUE_NAME;
		this._hexGroup.addChild(this._hexLabel);
		
		this._hexInput = new TextInput();
		this._hexInput.variant = TextInputVariant.FULL_WIDTH;
		this._hexInput.restrict = "0123456789abcdef";
		this._hexInput.maxChars = 6;
		this._hexInput.text = "ffffff";
		this._hexInput.prompt = "null";
		this._hexGroup.addChild(this._hexInput);
		
		// Red
		this._redGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._redGroup.layout = hLayout;
		addChild(this._redGroup);
		
		this._redLabel = new Label("red");
		this._redLabel.variant = LabelVariant.SUBVALUE_NAME;
		this._redGroup.addChild(this._redLabel);
		
		this._redSlider = new HSlider();
		this._redSlider.layoutData = new HorizontalLayoutData(100);
		this._redSlider.minimum = 0;
		this._redSlider.maximum = 255;
		this._redSlider.step = 1;
		this._redSlider.value = 255;
		this._redGroup.addChild(_redSlider);
		
		this._redInput = new TextInput();
		this._redInput.variant = TextInputVariant.NUMERIC_SMALL;
		this._redInput.restrict = "0123456789";
		this._redInput.maxChars = 3;
		this._redInput.text = "255";
		this._redGroup.addChild(this._redInput);
		
		// Green
		this._greenGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._greenGroup.layout = hLayout;
		addChild(this._greenGroup);
		
		this._greenLabel = new Label("green");
		this._greenLabel.variant = LabelVariant.SUBVALUE_NAME;
		this._greenGroup.addChild(this._greenLabel);
		
		this._greenSlider = new HSlider();
		this._greenSlider.layoutData = new HorizontalLayoutData(100);
		this._greenSlider.minimum = 0;
		this._greenSlider.maximum = 255;
		this._greenSlider.step = 1;
		this._greenSlider.value = 255;
		this._greenGroup.addChild(this._greenSlider);
		
		this._greenInput = new TextInput();
		this._greenInput.variant = TextInputVariant.NUMERIC_SMALL;
		this._greenInput.restrict = "0123456789";
		this._greenInput.maxChars = 3;
		this._greenInput.text = "255";
		this._greenGroup.addChild(this._greenInput);
		
		// Blue
		this._blueGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._blueGroup.layout = hLayout;
		addChild(this._blueGroup);
		
		this._blueLabel = new Label("blue");
		this._blueLabel.variant = LabelVariant.SUBVALUE_NAME;
		this._blueGroup.addChild(this._blueLabel);
		
		this._blueSlider = new HSlider();
		this._blueSlider.layoutData = new HorizontalLayoutData(100);
		this._blueSlider.minimum = 0;
		this._blueSlider.maximum = 255;
		this._blueSlider.step = 1;
		this._blueSlider.value = 255;
		this._blueGroup.addChild(this._blueSlider);
		
		this._blueInput = new TextInput();
		this._blueInput.variant = TextInputVariant.NUMERIC_SMALL;
		this._blueInput.restrict = "0123456789";
		this._blueInput.maxChars = 3;
		this._blueInput.text = "255";
		this._blueGroup.addChild(this._blueInput);
		
		this._nullGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
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
		
		if (this._exposedValue != null)
		{
			colorUpdate();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._preview.enabled = this._exposedValue.isEditable;
		this._hexLabel.enabled = this._exposedValue.isEditable;
		this._hexInput.enabled = this._exposedValue.isEditable;
		this._redLabel.enabled = this._exposedValue.isEditable;
		this._redSlider.enabled = this._exposedValue.isEditable;
		this._redInput.enabled = this._exposedValue.isEditable;
		this._greenLabel.enabled = this._exposedValue.isEditable;
		this._greenSlider.enabled = this._exposedValue.isEditable;
		this._greenInput.enabled = this._exposedValue.isEditable;
		this._nullButton.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	private function colorUpdate():Void
	{
		var controlsEnabled:Bool = this._controlsEnabled;
		if (controlsEnabled) controlsDisable();
		if (this._exposedValue.value == null)
		{
			this._previewSkin.fill = FillStyle.None;
			this._hexInput.text = "";
		}
		else
		{
			var value:Int = this._exposedValue.value;
			this._previewSkin.fill = FillStyle.SolidColor(value);
			this._hexInput.text = ColorUtil.RGBtoHexString(value);
			this._redInput.text = Std.string(ColorUtil.getRed(value));
			this._redSlider.value = ColorUtil.getRed(value);
			this._greenInput.text = Std.string(ColorUtil.getGreen(value));
			this._greenSlider.value = ColorUtil.getGreen(value);
			this._blueInput.text = Std.string(ColorUtil.getBlue(value));
			this._blueSlider.value = ColorUtil.getBlue(value);
		}
		if (controlsEnabled) controlsEnable();
	}
	
	override function controlsDisable():Void
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._hexInput.removeEventListener(Event.CHANGE, onHexInputChange);
		this._redSlider.removeEventListener(Event.CHANGE, onRedSliderChange);
		this._redInput.removeEventListener(Event.CHANGE, onRedInputChange);
		this._greenSlider.removeEventListener(Event.CHANGE, onGreenSliderChange);
		this._greenInput.removeEventListener(Event.CHANGE, onGreenInputChange);
		this._blueSlider.removeEventListener(Event.CHANGE, onBlueSliderChange);
		this._blueInput.removeEventListener(Event.CHANGE, onBlueInputChange);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		this._hexInput.addEventListener(Event.CHANGE, onHexInputChange);
		this._redSlider.addEventListener(Event.CHANGE, onRedSliderChange);
		this._redInput.addEventListener(Event.CHANGE, onRedInputChange);
		this._greenSlider.addEventListener(Event.CHANGE, onGreenSliderChange);
		this._greenInput.addEventListener(Event.CHANGE, onGreenInputChange);
		this._blueSlider.addEventListener(Event.CHANGE, onBlueSliderChange);
		this._blueInput.addEventListener(Event.CHANGE, onBlueInputChange);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onHexInputChange(evt:Event):Void
	{
		this._exposedValue.value = Std.parseInt("0x" + this._hexInput.text);
		colorUpdate();
	}
	
	private function onRedSliderChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setRed(this._exposedValue.value, Std.int(this._redSlider.value));
		colorUpdate();
	}
	
	private function onRedInputChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setRed(this._exposedValue.value, Std.parseInt(this._redInput.text));
		colorUpdate();
	}
	
	private function onGreenSliderChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setGreen(this._exposedValue.value, Std.int(this._greenSlider.value));
		colorUpdate();
	}
	
	private function onGreenInputChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setGreen(this._exposedValue.value, Std.parseInt(this._greenInput.text));
		colorUpdate();
	}
	
	private function onBlueSliderChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setBlue(this._exposedValue.value, Std.int(this._blueSlider.value));
		colorUpdate();
	}
	
	private function onBlueInputChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setBlue(this._exposedValue.value, Std.parseInt(this._blueInput.text));
		colorUpdate();
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		this._exposedValue.value = null;
		colorUpdate();
	}
	
}
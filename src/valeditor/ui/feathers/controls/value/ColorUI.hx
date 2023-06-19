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
import openfl.events.KeyboardEvent;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.NumericDragger;
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
	private var _redDragger:NumericDragger;
	
	private var _greenGroup:LayoutGroup;
	private var _greenLabel:Label;
	private var _greenDragger:NumericDragger;
	
	private var _blueGroup:LayoutGroup;
	private var _blueLabel:Label;
	private var _blueDragger:NumericDragger;
	
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
		
		this._redDragger = new NumericDragger(255, 0, 255);
		this._redDragger.isIntValue = true;
		this._redDragger.layoutData = new HorizontalLayoutData(100);
		hLayout = new HorizontalLayout();
		this._redDragger.layout = hLayout;
		this._redDragger.inputLayoutData = new HorizontalLayoutData(100);
		this._redGroup.addChild(this._redDragger);
		
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
		
		this._greenDragger = new NumericDragger(255, 0, 255);
		this._greenDragger.isIntValue = true;
		this._greenDragger.layoutData = new HorizontalLayoutData(100);
		hLayout = new HorizontalLayout();
		this._greenDragger.layout = hLayout;
		this._greenDragger.inputLayoutData = new HorizontalLayoutData(100);
		this._greenGroup.addChild(this._greenDragger);
		
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
		
		this._blueDragger = new NumericDragger(255, 0, 255);
		this._blueDragger.isIntValue = true;
		this._blueDragger.layoutData = new HorizontalLayoutData(100);
		hLayout = new HorizontalLayout();
		this._blueDragger.layout = hLayout;
		this._blueDragger.inputLayoutData = new HorizontalLayoutData(100);
		this._blueGroup.addChild(this._blueDragger);
		
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
		this._redDragger.enabled = this._exposedValue.isEditable;
		this._greenLabel.enabled = this._exposedValue.isEditable;
		this._greenDragger.enabled = this._exposedValue.isEditable;
		this._blueLabel.enabled = this._exposedValue.isEditable;
		this._blueDragger.enabled = this._exposedValue.isEditable;
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
			this._redDragger.value = ColorUtil.getRed(value);
			this._greenDragger.value = ColorUtil.getGreen(value);
			this._blueDragger.value = ColorUtil.getBlue(value);
		}
		if (controlsEnabled) controlsEnable();
	}
	
	override function controlsDisable():Void
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._hexInput.removeEventListener(Event.CHANGE, onHexInputChange);
		this._redDragger.removeEventListener(Event.CHANGE, onRedDraggerChange);
		this._redDragger.removeEventListener(KeyboardEvent.KEY_DOWN, onRedDraggerKeyDown);
		this._redDragger.removeEventListener(KeyboardEvent.KEY_UP, onRedDraggerKeyUp);
		this._greenDragger.removeEventListener(Event.CHANGE, onGreenDraggerChange);
		this._greenDragger.removeEventListener(KeyboardEvent.KEY_DOWN, onGreenDraggerKeyDown);
		this._greenDragger.removeEventListener(KeyboardEvent.KEY_UP, onGreenDraggerKeyUp);
		this._blueDragger.removeEventListener(Event.CHANGE, onBlueDraggerChange);
		this._blueDragger.removeEventListener(KeyboardEvent.KEY_DOWN, onGreenDraggerKeyDown);
		this._blueDragger.removeEventListener(KeyboardEvent.KEY_UP, onGreenDraggerKeyUp);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		this._hexInput.addEventListener(Event.CHANGE, onHexInputChange);
		this._redDragger.addEventListener(Event.CHANGE, onRedDraggerChange);
		this._redDragger.addEventListener(KeyboardEvent.KEY_DOWN, onRedDraggerKeyDown);
		this._redDragger.addEventListener(KeyboardEvent.KEY_UP, onRedDraggerKeyUp);
		this._greenDragger.addEventListener(Event.CHANGE, onGreenDraggerChange);
		this._greenDragger.addEventListener(KeyboardEvent.KEY_DOWN, onGreenDraggerKeyDown);
		this._greenDragger.addEventListener(KeyboardEvent.KEY_UP, onGreenDraggerKeyUp);
		this._blueDragger.addEventListener(Event.CHANGE, onBlueDraggerChange);
		this._blueDragger.addEventListener(KeyboardEvent.KEY_DOWN, onGreenDraggerKeyDown);
		this._blueDragger.addEventListener(KeyboardEvent.KEY_UP, onGreenDraggerKeyUp);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
	}
	
	private function onHexInputChange(evt:Event):Void
	{
		this._exposedValue.value = Std.parseInt("0x" + this._hexInput.text);
		colorUpdate();
	}
	
	private function onRedDraggerChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setRed(this._exposedValue.value, Std.int(this._redDragger.value));
		colorUpdate();
	}
	
	private function onRedDraggerKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onRedDraggerKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onGreenDraggerChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setGreen(this._exposedValue.value, Std.int(this._greenDragger.value));
		colorUpdate();
	}
	
	private function onGreenDraggerKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onGreenDraggerKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onBlueDraggerChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setBlue(this._exposedValue.value, Std.int(this._blueDragger.value));
		colorUpdate();
	}
	
	private function onBlueDraggerKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onBlueDraggerKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		this._exposedValue.value = null;
		colorUpdate();
	}
	
}
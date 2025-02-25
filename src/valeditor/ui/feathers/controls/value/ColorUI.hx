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
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valedit.value.ExposedColor;
import valedit.value.base.ExposedValue;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.events.ValueUIEvent;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.NumericDragger;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;
import valeditor.ui.feathers.theme.variant.TextInputVariant;
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
	static private var _POOL:Array<ColorUI> = new Array<ColorUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():ColorUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ColorUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue
	{
		this._colorValue = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _colorValue:ExposedColor;
	private var _previousValue:Int;
	
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
	
	private var _action:MultiAction;
	private var _valueChangeAction:ValueChange;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		if (this._action != null)
		{
			this._action.pool();
			this._action = null;
			this._valueChangeAction = null;
		}
		
		super.clear();
		this._colorValue = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
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
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		
		this._redDragger.liveDragging = this._colorValue.liveDragging;
		this._redDragger.liveTyping = this._colorValue.liveTyping;
		this._greenDragger.liveDragging = this._colorValue.liveDragging;
		this._greenDragger.liveTyping = this._colorValue.liveTyping;
		this._blueDragger.liveDragging = this._colorValue.liveDragging;
		this._blueDragger.liveTyping = this._colorValue.liveTyping;
		
		if (this._readOnly)
		{
			if (this._redGroup.parent != null)
			{
				removeChild(this._redGroup);
				removeChild(this._greenGroup);
				removeChild(this._blueGroup);
			}
		}
		else
		{
			if (this._redGroup.parent == null)
			{
				addChild(this._redGroup);
				addChild(this._greenGroup);
				addChild(this._blueGroup);
			}
		}
		
		if (this._nullGroup.parent != null) removeChild(this._nullGroup);
		if (this._exposedValue.isNullable && !this._readOnly)
		{
			addChild(this._nullGroup);
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
		this._redLabel.enabled = this._exposedValue.isEditable;
		this._greenLabel.enabled = this._exposedValue.isEditable;
		this._blueLabel.enabled = this._exposedValue.isEditable;
		this._hexInput.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._redDragger.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._greenDragger.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._blueDragger.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._nullButton.enabled = !this._readOnly && this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	private function colorUpdate(updateText:Bool = true):Void
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
			if (updateText)
			{
				this._hexInput.text = ColorUtil.RGBtoHexString(value);
			}
			this._redDragger.value = ColorUtil.getRed(value);
			this._greenDragger.value = ColorUtil.getGreen(value);
			this._blueDragger.value = ColorUtil.getBlue(value);
		}
		if (controlsEnabled) controlsEnable();
	}
	
	override function controlsDisable():Void
	{
		if (this._readOnly) return;
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
		
		this._hexInput.removeEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._hexInput.removeEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
		this._hexInput.removeEventListener(KeyboardEvent.KEY_DOWN, input_keyDownHandler);
		this._hexInput.removeEventListener(KeyboardEvent.KEY_UP, input_keyUpHandler);
		this._redDragger.removeEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._redDragger.removeEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
		this._greenDragger.removeEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._greenDragger.removeEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
		this._blueDragger.removeEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._blueDragger.removeEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
	}
	
	override function controlsEnable():Void
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
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
		
		this._hexInput.addEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._hexInput.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
		this._hexInput.addEventListener(KeyboardEvent.KEY_DOWN, input_keyDownHandler);
		this._hexInput.addEventListener(KeyboardEvent.KEY_UP, input_keyUpHandler);
		this._redDragger.addEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._redDragger.addEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
		this._greenDragger.addEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._greenDragger.addEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
		this._blueDragger.addEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._blueDragger.addEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
	}
	
	private function onHexInputChange(evt:Event):Void
	{
		if (!this._colorValue.liveTyping) return;
		
		this._exposedValue.value = Std.parseInt("0x" + this._hexInput.text);
		colorUpdate(false);
	}
	
	private function onRedDraggerChange(evt:Event):Void
	{
		this._exposedValue.value = ColorUtil.setRed(this._exposedValue.value, Std.int(this._redDragger.value));
		colorUpdate();
	}
	
	private function onRedDraggerKeyDown(evt:KeyboardEvent):Void
	{
		if (evt.ctrlKey)
		{
			if (evt.keyCode == Keyboard.A || evt.keyCode == Keyboard.C || evt.keyCode == Keyboard.X || evt.keyCode == Keyboard.V)
			{
				return;
			}
		}
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
		if (evt.ctrlKey)
		{
			if (evt.keyCode == Keyboard.A || evt.keyCode == Keyboard.C || evt.keyCode == Keyboard.X || evt.keyCode == Keyboard.V)
			{
				return;
			}
		}
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
		if (evt.ctrlKey)
		{
			if (evt.keyCode == Keyboard.A || evt.keyCode == Keyboard.C || evt.keyCode == Keyboard.X || evt.keyCode == Keyboard.V)
			{
				return;
			}
		}
		evt.stopPropagation();
	}
	
	private function onBlueDraggerKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		if (this._exposedValue.useActions)
		{
			if (this._exposedValue.value != null)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var valueChange:ValueChange = ValueChange.fromPool();
				valueChange.setup(this._exposedValue, null);
				action.add(valueChange);
				
				var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
				valueUIUpdate.setup(this._exposedValue);
				action.addPost(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._exposedValue.value = null;
			colorUpdate();
		}
	}
	
	private function onValueChangeBegin(evt:ValueUIEvent):Void
	{
		this._previousValue = this._exposedValue.value;
		
		if (!this._exposedValue.useActions) return;
		
		if (this._action != null)
		{
			throw new Error("ColorUI ::: action should be null");
		}
		
		this._action = MultiAction.fromPool();
		
		this._valueChangeAction = ValueChange.fromPool();
		this._valueChangeAction.setup(this._exposedValue, this._exposedValue.value, this._exposedValue.value);
		this._action.add(this._valueChangeAction);
		
		var valueUIUpdate:ValueUIUpdate = ValueUIUpdate.fromPool();
		valueUIUpdate.setup(this._exposedValue);
		this._action.addPost(valueUIUpdate);
	}
	
	private function onValueChangeEnd(evt:ValueUIEvent):Void
	{
		if (!this._exposedValue.useActions) return;
		
		if (this._action == null)
		{
			throw new Error("ColorUI ::: action should not be null");
		}
		
		this._valueChangeAction.newValue = this._exposedValue.value;
		if (this._valueChangeAction.newValue == this._valueChangeAction.previousValue)
		{
			this._action.pool();
		}
		else
		{
			ValEditor.actionStack.add(this._action);
		}
		this._action = null;
		this._valueChangeAction = null;
	}
	
	private function input_focusInHandler(evt:FocusEvent):Void
	{
		onValueChangeBegin(null);
	}
	
	private function input_focusOutHandler(evt:FocusEvent):Void
	{
		if (!this._colorValue.liveTyping)
		{
			this._exposedValue.value = Std.parseInt("0x" + this._hexInput.text);
		}
		colorUpdate();
		onValueChangeEnd(null);
	}
	
	private function input_keyDownHandler(evt:KeyboardEvent):Void
	{
		if (evt.ctrlKey)
		{
			if (evt.keyCode == Keyboard.A || evt.keyCode == Keyboard.C || evt.keyCode == Keyboard.X || evt.keyCode == Keyboard.V)
			{
				return;
			}
		}
		evt.stopPropagation();
	}
	
	private function input_keyUpHandler(evt:KeyboardEvent):Void
	{
		if (evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.NUMPAD_ENTER)
		{
			if (this.focusManager != null)
			{
				this.focusManager.focus = null;
			}
			else if (this.stage != null)
			{
				this.stage.focus = null;
			}
		}
		else if (evt.keyCode == Keyboard.ESCAPE)
		{
			this._exposedValue.value = this._previousValue;
			this._hexInput.text = ColorUtil.RGBtoHexString(this._exposedValue.value);
			if (this._colorValue.liveTyping)
			{
				colorUpdate();
			}
			if (this.focusManager != null)
			{
				this.focusManager.focus = null;
			}
			else if (this.stage != null)
			{
				this.stage.focus = null;
			}
		}
		evt.stopPropagation();
	}
	
}
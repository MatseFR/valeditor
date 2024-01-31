package valeditor.ui.feathers.controls.value;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.FocusEvent;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.events.ValueUIEvent;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.variant.TextInputVariant;
import valeditor.utils.MathUtil;
import valedit.value.base.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFloat;
import valedit.value.NumericMode;
import valeditor.ui.feathers.Padding;

/**
 * ...
 * @author Matse
 */
class FloatUI extends ValueUI 
{
	static private var _POOL:Array<FloatUI> = new Array<FloatUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():FloatUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FloatUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._floatValue = null;
		}
		else
		{
			this._floatValue = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _floatValue:ExposedFloat;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _input:TextInput;
	
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
		this._floatValue = null;
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
		
		this._input = new TextInput();
		this._input.variant = TextInputVariant.FULL_WIDTH;
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
		
		this._input.variant = this._floatValue.inputVariant;
		switch (this._floatValue.numericMode)
		{
			case NumericMode.Positive :
				this._input.restrict = "0123456789.";
			
			default :
				this._input.restrict = "-0123456789.";
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
				this._input.text = Std.string(MathUtil.roundToPrecision(this._exposedValue.value, this._floatValue.precision));
			}
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._input.enabled = this._exposedValue.isEditable;
		this._input.editable = !this._readOnly; 
		this._nullButton.enabled = !this._readOnly && this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void
	{
		if (this._readOnly) return;
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._input.removeEventListener(Event.CHANGE, onInputChange);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
		
		this._input.removeEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._input.removeEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
	}
	
	override function controlsEnable():Void
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._input.addEventListener(Event.CHANGE, onInputChange);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
		
		this._input.addEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._input.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
	}
	
	private function onInputChange(evt:Event):Void
	{
		if (this._input.text == "") return;
		this._exposedValue.value = MathUtil.roundToPrecision(Std.parseFloat(this._input.text), this._floatValue.precision);
	}
	
	private function onNullButton(evt:TriggerEvent):Void
	{
		if (!this._exposedValue.isConstructor)
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
			this._input.text = "";
		}
	}
	
	private function onValueChangeBegin(evt:ValueUIEvent):Void
	{
		if (this._exposedValue.isConstructor) return;
		
		if (this._action != null)
		{
			throw new Error("FloatDraggerUI ::: action should be null");
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
		if (this._exposedValue.isConstructor) return;
		
		if (this._action == null)
		{
			throw new Error("FloatDraggerUI ::: action should not be null");
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
		onValueChangeEnd(null);
	}
	
}
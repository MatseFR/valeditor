package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextArea;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.events.ValueUIEvent;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;
import valedit.value.base.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedText;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ValueWedge;

/**
 * ...
 * @author Matse
 */
class TextUI extends ValueUI 
{
	static private var _POOL:Array<TextUI> = new Array<TextUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():TextUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		this._textValue = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _textValue:ExposedText;
	private var _previousValue:String;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _textArea:TextArea;
	
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
		this._textValue = null;
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
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.DEFAULT;
		this._mainGroup.layout = hLayout;
		addChild(this._mainGroup);
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		this._mainGroup.addChild(this._label);
		
		this._textArea = new TextArea();
		this._textArea.layoutData = new HorizontalLayoutData(100);
		this._mainGroup.addChild(this._textArea);
		
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
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
		this._textArea.restrict = this._textValue.restrict;
		this._textArea.maxChars = this._textValue.maxChars;
		
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
			this._textArea.text = this._exposedValue.value;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this._textArea.enabled = this._exposedValue.isEditable;
		this._textArea.editable = !this._readOnly;
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
		this._textArea.removeEventListener(Event.CHANGE, onInputChange);
		this._textArea.removeEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
		this._textArea.removeEventListener(KeyboardEvent.KEY_UP, onInputKeyUp);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
		
		this._textArea.removeEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._textArea.removeEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
	}
	
	override function controlsEnable():Void
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._textArea.addEventListener(Event.CHANGE, onInputChange);
		this._textArea.addEventListener(KeyboardEvent.KEY_DOWN, onInputKeyDown);
		this._textArea.addEventListener(KeyboardEvent.KEY_UP, onInputKeyUp);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
		
		this._textArea.addEventListener(FocusEvent.FOCUS_IN, input_focusInHandler);
		this._textArea.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
	}
	
	private function onInputChange(evt:Event):Void
	{
		if (!this._textValue.liveTyping) return;
		this._exposedValue.value = this._textArea.text;
	}
	
	private function onInputKeyDown(evt:KeyboardEvent):Void
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
	
	private function onInputKeyUp(evt:KeyboardEvent):Void
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
			this._textArea.text = this._exposedValue.value;
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
				action.add(valueUIUpdate);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			this._textArea.text = "";
			this._exposedValue.value = null;
		}
	}
	
	private function onValueChangeBegin(evt:ValueUIEvent):Void
	{
		this._previousValue = this._exposedValue.value;
		
		if (!this._exposedValue.useActions) return;
		
		if (this._action != null)
		{
			throw new Error("TextUI ::: action should be null");
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
			throw new Error("TextUI ::: action should not be null");
		}
		
		this._valueChangeAction.newValue = this._exposedValue.value;
		if (this._valueChangeAction.newValue == this._valueChangeAction.previousValue || (this._valueChangeAction.newValue == "" && this._valueChangeAction.previousValue == null))
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
		if (!this._textValue.liveTyping)
		{
			this._exposedValue.value = this._textArea.text;
		}
		onValueChangeEnd(null);
	}
	
}
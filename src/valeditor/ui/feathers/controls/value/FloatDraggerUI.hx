package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.utils.MathUtil;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valedit.value.base.ExposedValue;
import valedit.ui.IValueUI;
import valedit.value.ExposedFloatDrag;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.value.ValueChange;
import valeditor.editor.action.value.ValueUIUpdate;
import valeditor.events.ValueUIEvent;
import valeditor.ui.feathers.controls.NumericDragger;
import valeditor.ui.feathers.controls.ValueWedge;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
class FloatDraggerUI extends ValueUI 
{
	static private var _POOL:Array<FloatDraggerUI> = new Array<FloatDraggerUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():FloatDraggerUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FloatDraggerUI();
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
	
	private var _floatValue:ExposedFloatDrag;
	
	private var _mainGroup:LayoutGroup;
	private var _label:Label;
	private var _dragger:NumericDragger;
	
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
		
		this._dragger = new NumericDragger();
		this._dragger.layoutData = new HorizontalLayoutData(100);
		hLayout = new HorizontalLayout();
		this._dragger.layout = hLayout;
		this._dragger.inputLayoutData = new HorizontalLayoutData(100);
		this._mainGroup.addChild(this._dragger);
		
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
		
		this._dragger.minimum = this._floatValue.minimum;
		this._dragger.maximum = this._floatValue.maximum;
		this._dragger.dragScaleFactor = this._floatValue.dragScaleFactor;
		this._dragger.step = this._floatValue.step;
		this._dragger.liveDragging = this._floatValue.liveDragging;
		this._dragger.liveTyping = this._floatValue.liveTyping;
		
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
				this._dragger.value = 0;
			}
			else
			{
				this._dragger.value = MathUtil.roundToNearest(this._floatValue.value, this._floatValue.step);
			}
			if (controlsEnabled) controlsEnable();
		}
	}
	
	override function updateEditable():Void 
	{
		super.updateEditable();
		
		var enabled:Bool = this._exposedValue.isEditable && !this._exposedValue.isReadOnly;
		
		this.enabled = enabled;
		this._label.enabled = enabled;
		this._dragger.enabled = enabled;
		this._nullButton.enabled = enabled;
	}
	
	override function controlsDisable():Void 
	{
		if (this._readOnly) return;
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._dragger.removeEventListener(Event.CHANGE, onDraggerChange);
		this._dragger.removeEventListener(KeyboardEvent.KEY_DOWN, onDraggerKeyDown);
		this._dragger.removeEventListener(KeyboardEvent.KEY_UP, onDraggerKeyUp);
		this._nullButton.removeEventListener(TriggerEvent.TRIGGER, onNullButton);
		
		this._dragger.removeEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._dragger.removeEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._dragger.addEventListener(Event.CHANGE, onDraggerChange);
		this._dragger.addEventListener(KeyboardEvent.KEY_DOWN, onDraggerKeyDown);
		this._dragger.addEventListener(KeyboardEvent.KEY_UP, onDraggerKeyUp);
		this._nullButton.addEventListener(TriggerEvent.TRIGGER, onNullButton);
		
		this._dragger.addEventListener(ValueUIEvent.CHANGE_BEGIN, onValueChangeBegin);
		this._dragger.addEventListener(ValueUIEvent.CHANGE_END, onValueChangeEnd);
	}
	
	private function onDraggerChange(evt:Event):Void
	{
		this._exposedValue.value = this._dragger.value;
	}
	
	private function onDraggerKeyDown(evt:KeyboardEvent):Void
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
	
	private function onDraggerKeyUp(evt:KeyboardEvent):Void
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
		}
	}
	
	private function onValueChangeBegin(evt:ValueUIEvent):Void
	{
		if (!this._exposedValue.useActions) return;
		
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
		if (!this._exposedValue.useActions) return;
		
		if (this._action == null)
		{
			return;
			//throw new Error("FloatDraggerUI ::: action should not be null");
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
	
}
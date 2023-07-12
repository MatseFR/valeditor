package valeditor.ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ToggleCustom;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valedit.value.base.ExposedValue;
import valedit.ValEdit;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFunction;
import valeditor.ui.feathers.Padding;

/**
 * ...
 * @author Matse
 */
class FunctionUI extends ValueUI 
{
	static private var _POOL:Array<FunctionUI> = new Array<FunctionUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():FunctionUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FunctionUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		_func = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _func:ExposedFunction;
	
	private var _button:Button;
	
	private var _parameterGroup:ToggleCustom;
	private var _arrowDown:LayoutGroup;
	private var _arrowRight:LayoutGroup;
	
	private var _bottomGroup:LayoutGroup;
	private var _trailGroup:LayoutGroup;
	private var _valueGroup:ValueContainer;
	
	private var _parameterControls:Array<IValueUI> = new Array<IValueUI>();
	
	/**
	   
	**/
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		super.clear();
		this._valueGroup.clearContent();
		for (control in this._parameterControls)
		{
			control.pool();
		}
		this._parameterControls.resize(0);
		this._func = null;
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
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.paddingBottom = vLayout.paddingTop = Padding.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		this._button = new Button();
		addChild(this._button);
		
		this._parameterGroup = new ToggleCustom();
		this._parameterGroup.labelVariant = LabelVariant.OBJECT_NAME;
		this._parameterGroup.text = "Parameters";
		
		this._arrowDown = new LayoutGroup();
		this._arrowDown.variant = LayoutGroupVariant.ARROW_DOWN_OBJECT;
		this._parameterGroup.selectedIcon = this._arrowDown;
		
		this._arrowRight = new LayoutGroup();
		this._arrowRight.variant = LayoutGroupVariant.ARROW_RIGHT_OBJECT;
		this._parameterGroup.icon = this._arrowRight;
		
		this._bottomGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._bottomGroup.layout = hLayout;
		
		this._trailGroup = new LayoutGroup();
		this._trailGroup.variant = LayoutGroupVariant.OBJECT_TRAIL;
		this._bottomGroup.addChild(this._trailGroup);
		
		this._valueGroup = new ValueContainer();
		this._valueGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Spacing.VERTICAL_GAP;
		this._valueGroup.layout = vLayout;
		_bottomGroup.addChild(this._valueGroup);
		
		this._valueGroup.addEventListener(Event.RESIZE, onParametersResize);
	}
	
	private function onParametersResize(evt:Event):Void
	{
		this._trailGroup.height = this._valueGroup.height;
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._button.text = this._func.name;
		
		if (this._parameterGroup.parent != null)
		{
			this._parameterGroup.removeChildren();
			removeChild(this._parameterGroup);
		}
		this._parameterControls.resize(0);
		
		var exposedValues:Array<ExposedValue> = this._func.getExposedValueParameters();
		if (exposedValues.length != 0)
		{
			var uiControl:IValueUI;
			for (exposedValue in exposedValues)
			{
				uiControl = ValEdit.toUIControl(exposedValue);
				this._valueGroup.addChild(cast uiControl);
				this._parameterControls.push(uiControl);
			}
			addChild(this._parameterGroup);
		}
		
		updateEditable();
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._parameterGroup.enabled = this._exposedValue.isEditable;
		this._trailGroup.enabled = this._exposedValue.isEditable;
		this._valueGroup.enabled = this._exposedValue.isEditable;
		this._button.enabled = !this._readOnly && this._exposedValue.isEditable;
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
		this._button.removeEventListener(TriggerEvent.TRIGGER, onButton);
		this._parameterGroup.removeEventListener(Event.CHANGE, onParameterGroupChange);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (_controlsEnabled) return;
		super.controlsEnable();
		this._button.addEventListener(TriggerEvent.TRIGGER, onButton);
		this._parameterGroup.addEventListener(Event.CHANGE, onParameterGroupChange);
	}
	
	private function onButton(evt:TriggerEvent):Void
	{
		this._func.execute();
	}
	
	private function onParameterGroupChange(evt:Event):Void
	{
		if (this._parameterGroup.selected)
		{
			addChild(this._bottomGroup);
		}
		else
		{
			removeChild(this._bottomGroup);
		}
	}
	
}
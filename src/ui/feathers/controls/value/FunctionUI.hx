package ui.feathers.controls.value;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.controls.ToggleLayoutGroup;
import ui.feathers.variant.LabelVariant;
import ui.feathers.variant.LayoutGroupVariant;
import valedit.ExposedValue;
import valedit.ValEdit;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedFunction;

/**
 * ...
 * @author Matse
 */
class FunctionUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		_func = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _func:ExposedFunction;
	
	private var _button:Button;
	
	private var _parameterGroup:ToggleLayoutGroup;
	private var _arrowDown:LayoutGroup;
	private var _arrowRight:LayoutGroup;
	
	private var _bottomGroup:LayoutGroup;
	private var _trailGroup:LayoutGroup;
	private var _valueGroup:ValueContainer;
	
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
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.paddingBottom = vLayout.paddingTop = Padding.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.VALUE;
		this.layout = vLayout;
		
		_button = new Button();
		addChild(_button);
		
		_parameterGroup = new ToggleLayoutGroup();
		_parameterGroup.labelVariant = LabelVariant.OBJECT_NAME;
		_parameterGroup.text = "Parameters";
		
		_arrowDown = new LayoutGroup();
		_arrowDown.variant = LayoutGroupVariant.ARROW_DOWN_OBJECT;
		_parameterGroup.selectedIcon = _arrowDown;
		
		_arrowRight = new LayoutGroup();
		_arrowRight.variant = LayoutGroupVariant.ARROW_RIGHT_OBJECT;
		_parameterGroup.icon = _arrowRight;
		
		_bottomGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		_bottomGroup.layout = hLayout;
		
		_trailGroup = new LayoutGroup();
		_trailGroup.variant = LayoutGroupVariant.OBJECT_TRAIL;
		_bottomGroup.addChild(_trailGroup);
		
		_valueGroup = new ValueContainer();
		_valueGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Spacing.VERTICAL_GAP;
		_valueGroup.layout = vLayout;
		_bottomGroup.addChild(_valueGroup);
		
		_valueGroup.addEventListener(Event.RESIZE, onParametersResize);
	}
	
	private function onParametersResize(evt:Event):Void
	{
		_trailGroup.height = _valueGroup.height;
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_button.text = _func.name;
		
		var exposedValues:Array<ExposedValue> = _func.getExposedValueParameters();
		if (exposedValues.length != 0)
		{
			var uiControl:IValueUI;
			for (exposedValue in exposedValues)
			{
				uiControl = ValEdit.toUIControl(exposedValue);
				_valueGroup.addChild(cast uiControl);
			}
			addChild(_parameterGroup);
		}
		else
		{
			if (_parameterGroup.parent != null)
			{
				_parameterGroup.removeChildren();
				removeChild(_parameterGroup);
			}
		}
		
		updateEditable();
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_button.enabled = _exposedValue.isEditable;
		_parameterGroup.enabled = _exposedValue.isEditable;
		_trailGroup.enabled = _exposedValue.isEditable;
		_valueGroup.enabled = _exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_button.removeEventListener(TriggerEvent.TRIGGER, onButton);
		_parameterGroup.removeEventListener(Event.CHANGE, onParameterGroupChange);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_button.addEventListener(TriggerEvent.TRIGGER, onButton);
		_parameterGroup.addEventListener(Event.CHANGE, onParameterGroupChange);
	}
	
	private function onButton(evt:TriggerEvent):Void
	{
		_func.execute();
	}
	
	private function onParameterGroupChange(evt:Event):Void
	{
		if (_parameterGroup.selected)
		{
			addChild(_bottomGroup);
		}
		else
		{
			removeChild(_bottomGroup);
		}
	}
	
}
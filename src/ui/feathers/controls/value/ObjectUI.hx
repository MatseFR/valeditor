package ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;
import feathers.core.InvalidationFlag;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.ValueUI;
import ui.feathers.controls.ToggleLayoutGroup;
import ui.feathers.variant.LabelVariant;
import ui.feathers.variant.LayoutGroupVariant;
import ui.feathers.variant.ToggleButtonVariant;
import valedit.ExposedValue;
import valedit.ValEdit;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class ObjectUI extends ValueUI 
{
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			ValEdit.edit(null, _valueGroup);
		}
		else
		{
			ValEdit.edit(value.value, _valueGroup, value);
		}
		return super.set_exposedValue(value);
	}
	
	//private var _topButton:ToggleButton;
	private var _topButton:ToggleLayoutGroup;
	private var _arrowDown:LayoutGroup;
	private var _arrowRight:LayoutGroup;
	
	private var _bottomGroup:LayoutGroup;
	private var _trailGroup:LayoutGroup;
	private var _valueGroup:LayoutGroup;
	
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
		
		var vLayout:VerticalLayout;
		var hLayout:HorizontalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.layout = vLayout;
		
		_topButton = new ToggleLayoutGroup();
		_topButton.labelVariant = LabelVariant.OBJECT_NAME;
		addChild(_topButton);
		
		_arrowDown = new LayoutGroup();
		_arrowDown.variant = LayoutGroupVariant.ARROW_DOWN_OBJECT;
		_topButton.selectedIcon = _arrowDown;
		
		_arrowRight = new LayoutGroup();
		_arrowRight.variant = LayoutGroupVariant.ARROW_RIGHT_OBJECT;
		_topButton.icon = _arrowRight;
		
		_bottomGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		_bottomGroup.layout = hLayout;
		
		_trailGroup = new LayoutGroup();
		_trailGroup.variant = LayoutGroupVariant.OBJECT_TRAIL;
		_bottomGroup.addChild(_trailGroup);
		
		_valueGroup = new LayoutGroup();
		_valueGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Spacing.VERTICAL_GAP;
		_valueGroup.layout = vLayout;
		_bottomGroup.addChild(_valueGroup);
		
		_valueGroup.addEventListener(Event.RESIZE, onContentResize);
	}
	
	/**
	   
	   @param	evt
	**/
	private function onContentResize(evt:Event):Void
	{
		_trailGroup.height = _valueGroup.height;
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			_topButton.text = _exposedValue.name;
			ValEdit.edit(_exposedValue.value, _valueGroup, _exposedValue);
		}
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_topButton.removeEventListener(Event.CHANGE, onTopButtonChange);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_topButton.addEventListener(Event.CHANGE, onTopButtonChange);
	}
	
	private function onTopButtonChange(evt:Event):Void
	{
		if (_topButton.selected)
		{
			//this.setInvalid(InvalidationFlag.SIZE);
			addChild(_bottomGroup);
		}
		else
		{
			removeChild(_bottomGroup);
		}
	}
	
}
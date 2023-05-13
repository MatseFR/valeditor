package ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.controls.ToggleCustom;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import ui.feathers.variant.LayoutGroupVariant;
import valedit.ExposedValue;
import valedit.ValEdit;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedObject;

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
			_exposedObject = null;
			ValEdit.edit(null, _valueGroup);
		}
		else
		{
			_exposedObject = cast value;
			ValEdit.edit(value.value, _valueGroup, value);
		}
		return super.set_exposedValue(value);
	}
	
	private var _exposedObject:ExposedObject;
	
	private var _topButton:ToggleCustom;
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
		
		var vLayout:VerticalLayout;
		var hLayout:HorizontalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.layout = vLayout;
		
		_topButton = new ToggleCustom();
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
		
		_valueGroup = new ValueContainer();
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
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		_topButton.text = _exposedValue.name;
		ValEdit.edit(_exposedValue.value, _valueGroup, _exposedValue);
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			if (_exposedObject.storeValue)
			{
				_exposedObject.reloadObject();
			}
			else
			{
				_valueGroup.updateExposedValues();
			}
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_topButton.enabled = _exposedValue.isEditable;
		_trailGroup.enabled = _exposedValue.isEditable;
		_valueGroup.enabled = _exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function onValueObjectChange(evt:ValueEvent):Void 
	{
		ValEdit.edit(_exposedValue.value, _valueGroup, _exposedValue);
		super.onValueObjectChange(evt);
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
			addChild(_bottomGroup);
		}
		else
		{
			removeChild(_bottomGroup);
		}
	}
	
}
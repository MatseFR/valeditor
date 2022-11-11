package ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.feathers.Spacing;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LayoutGroupVariant;
import ui.feathers.variant.ToggleButtonVariant;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IGroupUI;
import valedit.ui.IValueUI;
import valedit.value.ExposedGroup;

/**
 * ...
 * @author Matse
 */
class GroupUI extends ValueUI implements IGroupUI
{
	private var _controls:Array<IValueUI> = new Array<IValueUI>();
	private var _group:ExposedGroup;
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		_group = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _topButton:ToggleButton;
	private var _arrowDown:LayoutGroup;
	private var _arrowRight:LayoutGroup;
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
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		this.layout = vLayout;
		
		_topButton = new ToggleButton();
		_topButton.variant = ToggleButtonVariant.GROUP_HEADER;
		addChild(_topButton);
		
		_arrowDown = new LayoutGroup();
		_arrowDown.variant = LayoutGroupVariant.ARROW_DOWN_GROUP;
		
		_arrowRight = new LayoutGroup();
		_arrowRight.variant = LayoutGroupVariant.ARROW_RIGHT_GROUP;
		
		_valueGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		_valueGroup.layout = vLayout;
	}
	
	public function addExposedControl(control:IValueUI):Void
	{
		_controls.push(control);
		_valueGroup.addChild(cast control);
	}
	
	public function removeExposedControl(control:IValueUI):Void
	{
		_controls.remove(control);
		_valueGroup.removeChild(cast control);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		_topButton.text = _group.name;
		
		if (_group.isCollapsable)
		{
			_topButton.icon = _arrowRight;
			_topButton.selectedIcon = _arrowDown;
			
			if (_group.isCollapsedDefault)
			{
				_topButton.selected = false;
				if (_valueGroup.parent != null)
				{
					removeChild(_valueGroup);
				}
			}
			else
			{
				_topButton.selected = true;
				if (_valueGroup.parent == null)
				{
					addChild(_valueGroup);
				}
			}
		}
		else
		{
			_topButton.icon = null;
			_topButton.selectedIcon = null;
			if (_valueGroup.parent == null)
			{
				addChild(_valueGroup);
			}
		}
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _group != null)
		{
			for (control in _controls)
			{
				if (control == exceptControl) continue;
				control.updateExposedValue(exceptControl);
			}
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_topButton.enabled = _exposedValue.isEditable;
		_arrowDown.enabled = _exposedValue.isEditable;
		_arrowRight.enabled = _exposedValue.isEditable;
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
		if (_group != null && !_group.isCollapsable) return;
		
		if (_topButton.selected)
		{
			addChild(_valueGroup);
		}
		else
		{
			removeChild(_valueGroup);
		}
	}
	
}
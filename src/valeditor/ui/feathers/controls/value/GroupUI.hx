package valeditor.ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.errors.Error;
import openfl.events.Event;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;
import valeditor.ui.feathers.theme.variant.ToggleButtonVariant;
import valedit.value.base.ExposedValue;
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
	static private var _POOL:Array<GroupUI> = new Array<GroupUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():GroupUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new GroupUI();
	}
	
	private var _controls:Array<IValueUI> = new Array<IValueUI>();
	private var _group:ExposedGroup;
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		this._group = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _topButton:ToggleButton;
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
	
	override public function clear():Void 
	{
		super.clear();
		
		this._valueGroup.removeChildren();
		for (control in this._controls)
		{
			control.pool();
		}
		this._controls.resize(0);
		this._group = null;
		
		this._topButton.selected = false;
		if (this._bottomGroup.parent != null)
		{
			removeChild(this._bottomGroup);
		}
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
		this.layout = vLayout;
		
		this._topButton = new ToggleButton();
		this._topButton.variant = ToggleButtonVariant.GROUP_HEADER;
		addChild(this._topButton);
		
		this._arrowDown = new LayoutGroup();
		this._arrowDown.variant = LayoutGroupVariant.ARROW_DOWN_GROUP;
		this._topButton.selectedIcon = this._arrowDown;
		
		this._arrowRight = new LayoutGroup();
		this._arrowRight.variant = LayoutGroupVariant.ARROW_RIGHT_GROUP;
		this._topButton.icon = this._arrowRight;
		
		this._bottomGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._bottomGroup.layout = hLayout;
		
		this._trailGroup = new LayoutGroup();
		this._trailGroup.variant = LayoutGroupVariant.OBJECT_TRAIL;
		this._bottomGroup.addChild(this._trailGroup);
		
		this._valueGroup = new LayoutGroup();
		this._valueGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Padding.SMALL;
		this._valueGroup.layout = vLayout;
		this._bottomGroup.addChild(this._valueGroup);
		
		this._valueGroup.addEventListener(Event.RESIZE, onContentResize);
	}
	
	private function onContentResize(evt:Event):Void
	{
		this._trailGroup.height = this._valueGroup.height;
	}
	
	public function addExposedControl(control:IValueUI):Void
	{
		this._controls.push(control);
		this._valueGroup.addChild(cast control);
	}
	
	public function addExposedControls(controls:Array<IValueUI>):Void
	{
		for (control in controls)
		{
			this._controls.push(control);
			this._valueGroup.addChild(cast control);
		}
	}
	
	public function addExposedControlAfter(control:IValueUI, afterControl:IValueUI):Void
	{
		var index:Int = this._controls.indexOf(afterControl);
		if (index == -1)
		{
			throw new Error("GroupUI.addExposedControlAfter ::: afterControl cannot be found");
		}
		this._controls.insert(index + 1, control);
		this._valueGroup.addChildAt(cast control, index + 1);
	}
	
	public function addExposedControlBefore(control:IValueUI, beforeControl:IValueUI):Void
	{
		var index:Int = this._controls.indexOf(beforeControl);
		if (index == -1)
		{
			throw new Error("GroupUI.addExposedControlBefore ::: beforeControl cannot be found");
		}
		this._controls.insert(index, control);
		this._valueGroup.addChildAt(cast control, index);
	}
	
	public function removeExposedControl(control:IValueUI):Void
	{
		this._controls.remove(control);
		this._valueGroup.removeChild(cast control);
	}
	
	public function removeAllExposedControls():Void
	{
		for (control in this._controls)
		{
			this._valueGroup.removeChild(cast control);
		}
		this._controls.resize(0);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._topButton.text = this._group.name;
		this._topButton.toolTip = this._group.toolTip;
		
		if (this._group.isUIOpen)
		{
			if (this._bottomGroup.parent == null)
			{
				addChild(this._bottomGroup);
			}
		}
		else
		{
			if (this._bottomGroup.parent != null)
			{
				removeChild(this._bottomGroup);
			}
		}
		
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._group != null)
		{
			for (control in this._controls)
			{
				if (control == exceptControl) continue;
				control.updateExposedValue(exceptControl);
			}
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._topButton.enabled = this._exposedValue.isEditable;
		this._arrowDown.enabled = this._exposedValue.isEditable;
		this._arrowRight.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._topButton.removeEventListener(Event.CHANGE, onTopButtonChange);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._topButton.addEventListener(Event.CHANGE, onTopButtonChange);
	}
	
	private function onTopButtonChange(evt:Event):Void
	{
		if (this._topButton.selected)
		{
			addChild(this._bottomGroup);
			this._group.isUIOpen = true;
		}
		else
		{
			removeChild(this._bottomGroup);
			this._group.isUIOpen = false;
		}
	}
	
}
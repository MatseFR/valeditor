package valeditor.ui.feathers.controls.value;

import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedObject;
import valedit.value.base.ExposedValue;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ToggleCustom;
import valeditor.ui.feathers.controls.value.base.ValueContainer;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
class ObjectUI extends ValueUI 
{
	static private var _POOL:Array<ObjectUI> = new Array<ObjectUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():ObjectUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			this._exposedObject = null;
			ValEditor.edit(null, this._valueGroup);
		}
		else
		{
			this._exposedObject = cast value;
			if (this._exposedObject.childCollection.uiContainer == null)
			{
				ValEditor.edit(value.value, this._exposedObject.childCollection, this._valueGroup, this._exposedObject);
			}
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
	
	override public function clear():Void 
	{
		super.clear();
		if (this._exposedObject != null)
		{
			if (this._exposedObject.childCollection.uiContainer != null)
			{
				ValEditor.edit(null, this._valueGroup);
			}
			this._exposedObject = null;
		}
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
		
		this._topButton = new ToggleCustom();
		this._topButton.labelVariant = LabelVariant.OBJECT_NAME;
		addChild(this._topButton);
		
		this._arrowDown = new LayoutGroup();
		this._arrowDown.variant = LayoutGroupVariant.ARROW_DOWN_OBJECT;
		this._topButton.selectedIcon = this._arrowDown;
		
		this._arrowRight = new LayoutGroup();
		this._arrowRight.variant = LayoutGroupVariant.ARROW_RIGHT_OBJECT;
		this._topButton.icon = this._arrowRight;
		
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
		this._bottomGroup.addChild(this._valueGroup);
		
		this._valueGroup.addEventListener(Event.RESIZE, onContentResize);
	}
	
	/**
	   
	   @param	evt
	**/
	private function onContentResize(evt:Event):Void
	{
		this._trailGroup.height = this._valueGroup.height;
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._topButton.text = this._exposedValue.name;
		
		if (this._exposedObject.isUIOpen)
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
		
		if (this._exposedObject.childCollection.uiContainer == null)
		{
			// this is needed in case ExposedObject didn't have an object when this.exposedValue was set
			ValEditor.edit(this._exposedValue.value, this._exposedObject.childCollection, this._valueGroup, this._exposedObject);
		}
		
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			if (this._exposedObject.storeValue)
			{
				this._exposedObject.reloadObject();
			}
			else
			{
				this._valueGroup.updateExposedValues();
			}
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._topButton.enabled = this._exposedValue.isEditable;
		this._trailGroup.enabled = this._exposedValue.isEditable;
		this._valueGroup.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function onValueObjectChange(evt:ValueEvent):Void 
	{
		if (this._exposedObject.childCollection.uiContainer == null)
		{
			ValEditor.edit(this._exposedObject.value, this._exposedObject.childCollection, this._valueGroup, this._exposedObject);
		}
		else
		{
			this._exposedObject.childCollection.readAndSetObject(this._exposedObject.value);
		}
		super.onValueObjectChange(evt);
	}
	
	override function controlsDisable():Void 
	{
		if (this._readOnly) return;
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._topButton.removeEventListener(Event.CHANGE, onTopButtonChange);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._topButton.addEventListener(Event.CHANGE, onTopButtonChange);
	}
	
	private function onTopButtonChange(evt:Event):Void
	{
		if (this._topButton.selected)
		{
			addChild(this._bottomGroup);
			this._exposedObject.isUIOpen = true;
		}
		else
		{
			removeChild(this._bottomGroup);
			this._exposedObject.isUIOpen = false;
		}
	}
	
}
package ui.feathers.controls.value;

import feathers.controls.Label;
import feathers.controls.PopUpListView;
import feathers.data.ArrayCollection;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.variant.LabelVariant;
import valedit.ExposedValue;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valedit.value.ExposedSelect;

/**
 * ...
 * @author Matse
 */
class SelectUI extends ValueUI 
{
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		if (value == null)
		{
			_select = null;
		}
		else
		{
			_select = cast value;
		}
		return super.set_exposedValue(value);
	}
	
	private var _select:ExposedSelect;
	
	private var _label:Label;
	private var _list:PopUpListView;
	private var _collection:ArrayCollection<Dynamic> = new ArrayCollection<Dynamic>();
	
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
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
		this.layout = hLayout;
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_list = new PopUpListView(_collection);
		_list.layoutData = new HorizontalLayoutData(100);
		_list.itemToText = function(item:Dynamic):String { return item.text; };
		addChild(_list);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		_label.text = _exposedValue.name;
		cast(_list.layoutData, HorizontalLayoutData).percentWidth = _select.listPercentWidth;
		_collection.removeAll();
		var count:Int = _select.choiceList.length;
		for (i in 0...count)
		{
			_collection.add({text:_select.choiceList[i], value:_select.valueList[i]});
		}
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			_list.selectedIndex = cast(_exposedValue, ExposedSelect).valueList.indexOf(_exposedValue.value);
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = _exposedValue.isEditable;
		_label.enabled = _exposedValue.isEditable;
		_list.enabled = _exposedValue.isEditable;
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
		_list.removeEventListener(Event.CHANGE, onListChange);
	}
	
	override function controlsEnable():Void
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_list.addEventListener(Event.CHANGE, onListChange);
	}
	
	private function onListChange(evt:Event):Void
	{
		if (_list.selectedItem == null) return;
		_exposedValue.value = _list.selectedItem.value;
	}
	
}
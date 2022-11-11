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
import valedit.ui.IValueUI;
import valedit.value.ExposedSelect;

/**
 * ...
 * @author Matse
 */
class SelectUI extends ValueUI 
{
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
		this.layout = hLayout;
		
		_label = new Label();
		//_label.layoutData = new HorizontalLayoutData(25);
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
		_collection.removeAll();
		var choiceList:Array<String> = cast(_exposedValue, ExposedSelect).choiceList;
		var valueList:Array<Dynamic> = cast(_exposedValue, ExposedSelect).valueList;
		var count:Int = choiceList.length;
		for (i in 0...count)
		{
			//if (valueList[i] == _exposedValue.value)
			//{
				//selectedIndex = i;
			//}
			_collection.add({text:choiceList[i], value:valueList[i]});
		}
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			
			//var selectedIndex:Int = -1;
			//
			//
			//if (selectedIndex != -1)
			//{
				//_list.selectedIndex = selectedIndex;
			//}
			_list.selectedIndex = cast(_exposedValue, ExposedSelect).valueList.indexOf(_exposedValue.value);
			if (controlsEnabled) controlsEnable();
		}
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
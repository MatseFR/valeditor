package ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import openfl.events.Event;
import ui.feathers.Padding;
import utils.ArraySort;
import valedit.ValEdit;
import valedit.ValEditObject;

/**
 * ...
 * @author Matse
 */
class ObjectSelectWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	public var confirmCallback(get, set):Dynamic->Void;
	private var _confirmCallback:Dynamic->Void;
	private function get_confirmCallback():Dynamic->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Dynamic->Void):Dynamic->Void
	{
		return this._confirmCallback = value;
	}
	
	public var title(get, set):String;
	private var _title:String = "";
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (value == null) value = "";
		if (_initialized)
		{
			_titleLabel.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:LayoutGroup;
	private var _titleLabel:Label;
	
	private var _footerGroup:LayoutGroup;
	private var _confirmButton:Button;
	private var _cancelButton:Button;
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classPicker:ComboBox;
	private var _classCollection:ArrayCollection<String> = new ArrayCollection<String>();
	private var _classList:Array<String> = new Array<String>();
	
	private var _objectGroup:LayoutGroup;
	private var _objectLabel:Label;
	private var _objectGrid:GridView;
	private var _objectCollection:ArrayCollection<ValEditObject> = new ArrayCollection<ValEditObject>();
	
	private var _excludeObjects:Array<Dynamic>;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this._headerGroup = new LayoutGroup();
		this._headerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._headerGroup.layout = hLayout;
		this.header = this._headerGroup;
		
		this._titleLabel = new Label(this._title);
		this._headerGroup.addChild(_titleLabel);
		
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._confirmButton = new Button("confirm", onConfirmButton);
		this._confirmButton.enabled = false;
		this._footerGroup.addChild(this._confirmButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
		this.layout = new AnchorLayout();
		
		this._classGroup = new LayoutGroup();
		this._classGroup.layoutData = new AnchorLayoutData(Padding.DEFAULT * 2, Padding.DEFAULT * 2, null, Padding.DEFAULT * 2);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._classGroup.layout = vLayout;
		addChild(this._classGroup);
		
		this._classLabel = new Label("Object Class");
		this._classGroup.addChild(this._classLabel);
		
		this._classPicker = new ComboBox(this._classCollection, onClassChange);
		this._classGroup.addChild(this._classPicker);
		
		this._objectGroup = new LayoutGroup();
		this._objectGroup.layoutData = new AnchorLayoutData(new Anchor(Padding.DEFAULT * 2, this._classGroup), Padding.DEFAULT * 2, Padding.DEFAULT * 2, Padding.DEFAULT * 2);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._objectGroup.layout = vLayout;
		addChild(this._objectGroup);
		
		this._objectLabel = new Label("Select Object");
		this._objectGroup.addChild(this._objectLabel);
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			new GridViewColumn("id", (item)->item.id),
			new GridViewColumn("class", (item)->item.className)
		]);
		
		this._objectGrid = new GridView(this._objectCollection, columns, onObjectChange);
		this._objectGrid.layoutData = new VerticalLayoutData(100, 100);
		this._objectGroup.addChild(this._objectGrid);
	}
	
	public function reset(allowedClassNames:Array<String> = null, excludeObjects:Array<Dynamic> = null):Void
	{
		var classNames:Array<String>;
		this._classList.resize(0);
		var selectedItem:String = this._classPicker.selectedItem;
		this._classCollection.array = null;
		
		this._objectCollection.removeAll();
		this._excludeObjects = excludeObjects;
		if (this._excludeObjects != null && this._excludeObjects.length != 0)
		{
			this._objectCollection.filterFunction = filterObject;
		}
		else
		{
			this._objectCollection.filterFunction = null;
		}
		
		if (allowedClassNames != null && allowedClassNames.length != 0)
		{
			for (allowedName in allowedClassNames)
			{
				classNames = ValEdit.getClassListForBaseClass(allowedName);
				for (className in classNames)
				{
					if (this._classList.indexOf(className) == -1)
					{
						this._classList.push(className);
					}
				}
			}
		}
		else
		{
			// allow all classes
			this._classCollection.addAll(ValEdit.classCollection);
		}
		this._classList.sort(ArraySort.alphabetical);
		this._classCollection.array = this._classList;
		if (selectedItem != null)
		{
			var index:Int = this._classCollection.indexOf(selectedItem);
			this._classPicker.selectedIndex = index;
		}
		if (this._classPicker.selectedIndex == -1 && this._classCollection.length != 0)
		{
			this._classPicker.selectedIndex = 0;
		}
	}
	
	private function onClassChange(evt:Event):Void
	{
		this._objectCollection.removeAll();
		if (this._classPicker.selectedItem != null)
		{
			this._objectCollection.addAll(ValEdit.getObjectCollectionForClassName(this._classPicker.selectedItem));
		}
	}
	
	private function onObjectChange(evt:Event):Void
	{
		this._confirmButton.enabled = this._objectGrid.selectedItem != null;
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		this._confirmCallback(this._objectGrid.selectedItem);
	}
	
	private function filterObject(object:ValEditObject):Bool
	{
		return this._excludeObjects.indexOf(object.object) == -1;
	}
	
}
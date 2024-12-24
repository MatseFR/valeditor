package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
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
import valedit.ValEdit;
import valeditor.ValEditorObject;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;
import valeditor.utils.ArraySort;

/**
 * ...
 * @author Matse
 */
class ObjectSelectWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	public var confirmCallback(get, set):ValEditorObject->Void;
	public var sourceObjectCollection(get, set):ArrayCollection<ValEditorObject>;
	public var title(get, set):String;
	
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	private var _confirmCallback:ValEditorObject->Void;
	private function get_confirmCallback():ValEditorObject->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:ValEditorObject->Void):ValEditorObject->Void
	{
		return this._confirmCallback = value;
	}
	
	private var _sourceObjectCollection:ArrayCollection<ValEditorObject>;
	private function get_sourceObjectCollection():ArrayCollection<ValEditorObject> { return this._sourceObjectCollection; }
	private function set_sourceObjectCollection(value:ArrayCollection<ValEditorObject>):ArrayCollection<ValEditorObject>
	{
		this._objectCollection.removeAll();
		if (value != null)
		{
			this._objectCollection.addAll(value);
		}
		return this._sourceObjectCollection = value;
	}
	
	private var _title:String = "";
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (value == null) value = "";
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _confirmButton:Button;
	private var _cancelButton:Button;
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classPicker:ComboBox;
	private var _classCollection:ArrayCollection<StringData> = new ArrayCollection<StringData>();
	private var _classList:Array<StringData> = new Array<StringData>();
	
	private var _objectGroup:LayoutGroup;
	private var _objectLabel:Label;
	private var _objectGrid:GridView;
	private var _objectCollection:ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	
	private var _excludeObjects:Array<Dynamic>;
	
	private var _selectedClassName:String;
	
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
		
		this._headerGroup = new Header(this._title);
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
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
		
		//var recycler = DisplayObjectRecycler.withFunction(()->{
			//var renderer:ItemRenderer = new ItemRenderer();
			//renderer.icon = new Bitmap();
			//return renderer;
		//});
		//
		//recycler.update = (renderer:ItemRenderer, state:ListViewItemState) -> {
			//cast(renderer.icon, Bitmap).bitmapData = state.data.iconBitmapData;
			//renderer.text = state.data.className;
		//};
		
		this._classPicker = new ComboBox(this._classCollection, onClassChange);
		this._classPicker.itemToText = function(item:Dynamic):String {
			return item.value;
		};
		//this._classPicker.itemRendererRecycler = recycler;
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
			new GridViewColumn("id", (item)->cast(item, ValEditorObject).objectID),
			new GridViewColumn("class", (item)->item.className)
		]);
		
		this._objectGrid = new GridView(this._objectCollection, columns, onObjectChange);
		this._objectGrid.layoutData = new VerticalLayoutData(100, 100);
		this._objectGroup.addChild(this._objectGrid);
	}
	
	public function reset(allowedClassNames:Array<String> = null, excludeObjects:Array<Dynamic> = null):Void
	{
		var classNames:Array<String>;
		var stringData:StringData;
		
		this._classList.resize(0);
		var selectedItem:StringData = this._classPicker.selectedItem;
		this._classCollection.array = null;
		
		//this._objectCollection.removeAll();
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
				classNames = ValEditor.getClassListForBaseClass(allowedName);
				if (classNames != null)
				{
					for (className in classNames)
					{
						stringData = ValEditor.getClassStringData(className);
						if (this._classList.indexOf(stringData) == -1)
						{
							this._classList.push(stringData);
						}
					}
				}
			}
		}
		else
		{
			// allow all classes
			this._classCollection.addAll(ValEditor.classNameCollection);
		}
		this._classList.sort(ArraySort.stringData);
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
		//this._objectCollection.removeAll();
		//if (this._classPicker.selectedItem != null)
		//{
			//this._objectCollection.addAll(ValEditor.getObjectUICollectionForClassName(this._classPicker.selectedItem.value));
		//}
		
		this._selectedClassName = this._classPicker.selectedItem.value;
		this._objectCollection.refresh();
	}
	
	private function onObjectChange(evt:Event):Void
	{
		this._confirmButton.enabled = this._objectGrid.selectedItem != null;
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		this._confirmCallback(this._objectGrid.selectedItem);
	}
	
	private function filterObject(object:ValEditorObject):Bool
	{
		if (this._excludeObjects.indexOf(object.object) != -1) return false;
		return object.clss.className == this._selectedClassName || object.clss.superClassNames.indexOf(this._selectedClassName) != -1;
	}
	
}
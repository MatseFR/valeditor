package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.FeathersEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.Bitmap;
import openfl.events.Event;
import valeditor.ValEditorClass;
import valeditor.editor.visibility.ClassVisibilitiesCollection;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class ClassVisibilitiesWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	public var confirmCallback(get, set):Void->Void;
	public var title(get, set):String;
	public var visibilitiesCollection(get, set):ClassVisibilitiesCollection;
	public var visibilitiesCollectionDefault(get, set):ClassVisibilitiesCollection;
	
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	private var _confirmCallback:Void->Void;
	private function get_confirmCallback():Void->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Void->Void):Void->Void
	{
		return this._confirmCallback = value;
	}
	
	private var _title:String;
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (this._title == value) return value;
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _visibilitiesCollection:ClassVisibilitiesCollection;
	private function get_visibilitiesCollection():ClassVisibilitiesCollection { return this._visibilitiesCollection; }
	private function set_visibilitiesCollection(value:ClassVisibilitiesCollection):ClassVisibilitiesCollection
	{
		this._editCollection.clear();
		if (value != null)
		{
			value.clone(this._editCollection);
			this._listCollection.updateAll();
		}
		reset();
		return this._visibilitiesCollection = value;
	}
	
	private var _visibilitiesCollectionDefault:ClassVisibilitiesCollection;
	private function get_visibilitiesCollectionDefault():ClassVisibilitiesCollection { return this._visibilitiesCollectionDefault; }
	private function set_visibilitiesCollectionDefault(value:ClassVisibilitiesCollection):ClassVisibilitiesCollection
	{
		return this._visibilitiesCollectionDefault = value;
	}
	
	private var _headerGroup:Header;
	private var _footerGroup:LayoutGroup;
	private var _restoreDefaultsButton:Button;
	private var _cancelButton:Button;
	private var _confirmButton:Button;
	
	private var _categoryGroup:LayoutGroup;
	private var _categoryLabel:Label;
	private var _categoryControlsGroup:LayoutGroup;
	private var _categoryPicker:ComboBox;
	private var _categoryClearButton:Button;
	private var _categoryCollection:ArrayCollection<StringData> = new ArrayCollection<StringData>();
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classControlsGroup:LayoutGroup;
	private var _classPicker:ComboBox;
	private var _classCollection:ArrayCollection<ValEditorClass> = new ArrayCollection<ValEditorClass>();
	private var _classAddEditButton:Button;
	
	private var _listGroup:LayoutGroup;
	private var _listLabel:Label;
	private var _listControlsGroup:LayoutGroup;
	private var _list:ListView;
	private var _listCollection:ArrayCollection<ClassVisibilityCollection>;
	private var _listButtonsGroup:LayoutGroup;
	private var _visibilityEditButton:Button;
	private var _visibilityRemoveButton:Button;
	
	private var _editCollection:ClassVisibilitiesCollection;
	private var _valEditorClass:ValEditorClass;
	
	private var _classVisibilityToAdd:ClassVisibilityCollection;

	public function new() 
	{
		super();
		this._editCollection = ClassVisibilitiesCollection.fromPool();
		this._listCollection = new ArrayCollection<ClassVisibilityCollection>(this._editCollection.classCollectionList);
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		var maxRows:Int = 12;
		
		// header
		this._headerGroup = new Header(this._title);
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		// footer
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._restoreDefaultsButton = new Button("defaults", onRestoreDefaultsButton);
		this._footerGroup.addChild(this._restoreDefaultsButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
		this._confirmButton = new Button("confirm", onConfirmButton);
		this._footerGroup.addChild(this._confirmButton);
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		vLayout.setPadding(Padding.DEFAULT * 2);
		this.layout = vLayout;
		
		// category
		this._categoryGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._categoryGroup.layout = vLayout;
		addChild(this._categoryGroup);
		
		this._categoryLabel = new Label("Category");
		this._categoryGroup.addChild(this._categoryLabel);
		
		this._categoryControlsGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._categoryControlsGroup.layout = hLayout;
		this._categoryGroup.addChild(this._categoryControlsGroup);
		
		this._categoryPicker = new ComboBox(this._categoryCollection, onCategoryChange);
		this._categoryPicker.listViewFactory = function():ListView
		{
			var layout:VerticalListLayout = new VerticalListLayout();
			layout.requestedRowCount = Std.int(Math.min(this._categoryCollection.length, maxRows));
			var listView:ListView = new ListView();
			listView.layout = layout;
			return listView;
		};
		this._categoryPicker.layoutData = new HorizontalLayoutData(100);
		this._categoryPicker.itemToText = function(item:Dynamic):String
		{
			return item.value;
		};
		this._categoryControlsGroup.addChild(this._categoryPicker);
		
		this._categoryClearButton = new Button("X", onCategoryClear);
		this._categoryClearButton.enabled = false;
		this._categoryControlsGroup.addChild(this._categoryClearButton);
		
		// class
		this._classGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._classGroup.layout = vLayout;
		addChild(this._classGroup);
		
		this._classLabel = new Label("Class");
		this._classGroup.addChild(this._classLabel);
		
		this._classControlsGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.MINIMAL;
		this._classControlsGroup.layout = vLayout;
		this._classGroup.addChild(this._classControlsGroup);
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.icon = new Bitmap();
			return renderer;
		});
		
		recycler.update = (renderer:ItemRenderer, state:ListViewItemState) -> {
			cast(renderer.icon, Bitmap).bitmapData = state.data.iconBitmapData;
			renderer.text = state.data.className;
		};
		
		this._classPicker = new ComboBox(this._classCollection, onClassChange);
		this._classPicker.listViewFactory = function():ListView
		{
			var layout:VerticalListLayout = new VerticalListLayout();
			layout.requestedRowCount = Std.int(Math.min(this._classCollection.length, maxRows));
			var listView:ListView = new ListView();
			listView.layout = layout;
			return listView;
		};
		this._classPicker.itemToText = function(item:Dynamic):String
		{
			return item.className;
		};
		this._classPicker.itemRendererRecycler = recycler;
		this._classControlsGroup.addChild(this._classPicker);
		
		this._classAddEditButton = new Button("add/edit", onAddEditButton);
		this._classAddEditButton.enabled = false;
		this._classControlsGroup.addChild(this._classAddEditButton);
		
		// list
		this._listGroup = new LayoutGroup();
		this._listGroup.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._listGroup.layout = vLayout;
		addChild(this._listGroup);
		
		this._listLabel = new Label("Custom visibilities");
		this._listGroup.addChild(this._listLabel);
		
		this._listControlsGroup = new LayoutGroup();
		this._listControlsGroup.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.MINIMAL;
		this._listControlsGroup.layout = vLayout;
		this._listGroup.addChild(this._listControlsGroup);
		
		this._list = new ListView(this._listCollection, onVisibilityChange);
		this._list.itemToText = function(item:Dynamic):String
		{
			return item.classID;
		};
		this._list.layoutData = new VerticalLayoutData(100, 100);
		this._listControlsGroup.addChild(this._list);
		
		this._listButtonsGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this._listButtonsGroup.layout = hLayout;
		this._listControlsGroup.addChild(this._listButtonsGroup);
		
		this._visibilityRemoveButton = new Button("remove", onVisibilityRemoveButton);
		this._visibilityRemoveButton.enabled = false;
		this._listButtonsGroup.addChild(this._visibilityRemoveButton);
		
		this._visibilityEditButton = new Button("edit", onVisibilityEditButton);
		this._visibilityEditButton.enabled = false;
		this._listButtonsGroup.addChild(this._visibilityEditButton);
	}
	
	private function reset():Void
	{
		onCategoryChange(null);
	}
	
	private function getDefaultVisibility(classID:String):ClassVisibilityCollection
	{
		var defaultCollection:ClassVisibilityCollection = null;
		if (this._visibilitiesCollectionDefault != null)
		{
			defaultCollection = this._visibilitiesCollectionDefault.get(classID);
		}
		if (defaultCollection == null)
		{
			defaultCollection = ValEditor.classVisibilities.get(classID);
		}
		return defaultCollection;
	}
	
	private function onAddEditButton(evt:TriggerEvent):Void
	{
		var defaultCollection:ClassVisibilityCollection = getDefaultVisibility(this._valEditorClass.className);
		
		if (this._editCollection.has(this._valEditorClass.className))
		{
			var collection:ClassVisibilityCollection = this._editCollection.get(this._valEditorClass.className);
			FeathersWindows.showClassVisibilityWindow(collection, defaultCollection, this._valEditorClass.className + " visibility");
		}
		else
		{
			this._classVisibilityToAdd = ClassVisibilityCollection.fromPool();
			this._valEditorClass.visibilityCollectionCurrent.clone(this._classVisibilityToAdd);
			FeathersWindows.showClassVisibilityWindow(this._classVisibilityToAdd, defaultCollection, this._valEditorClass.className, onAddConfirm, onAddCancel);
		}
	}
	
	private function onAddCancel():Void
	{
		this._classVisibilityToAdd.pool();
		this._classVisibilityToAdd = null;
	}
	
	private function onAddConfirm():Void
	{
		var defaultCollection:ClassVisibilityCollection = getDefaultVisibility(this._valEditorClass.className);
		if (this._classVisibilityToAdd.isDifferentFrom(defaultCollection))
		{
			this._editCollection.add(this._classVisibilityToAdd);
			this._listCollection.updateAt(this._listCollection.length - 1);
		}
		else
		{
			this._classVisibilityToAdd.pool();
		}
		this._classVisibilityToAdd = null;
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onCategoryChange(evt:Event):Void
	{
		this._categoryClearButton.enabled = this._categoryPicker.selectedItem != null;
		
		if (this._categoryPicker.selectedItem == null)
		{
			this._classCollection.removeAll();
			this._classCollection.addAll(ValEditor.classCollection);
		}
	}
	
	private function onCategoryClear(evt:TriggerEvent):Void
	{
		this._categoryPicker.selectedIndex = -1;
	}
	
	private function onClassChange(evt:Event):Void
	{
		this._valEditorClass = this._classPicker.selectedItem;
		this._classAddEditButton.enabled = this._valEditorClass != null;
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		this._visibilitiesCollection.clear();
		this._editCollection.clone(this._visibilitiesCollection);
		FeathersWindows.closeWindow(this);
		if (this._confirmCallback != null) this._confirmCallback();
	}
	
	private function onRestoreDefaultsButton(evt:TriggerEvent):Void
	{
		this._editCollection.clear();
		this._listCollection.updateAll();
	}
	
	private function onVisibilityChange(evt:Event):Void
	{
		this._visibilityEditButton.enabled = this._list.selectedItem != null;
		this._visibilityRemoveButton.enabled = this._list.selectedItem != null;
	}
	
	private function onVisibilityEditButton(evt:TriggerEvent):Void
	{
		var defaultCollection:ClassVisibilityCollection = getDefaultVisibility(this._list.selectedItem.classID);
		FeathersWindows.showClassVisibilityWindow(this._list.selectedItem, defaultCollection, this._list.selectedItem.classID + " visibility", onVisibilityEditConfirmed, onVisibilityEditCancelled);
	}
	
	private function onVisibilityEditCancelled():Void
	{
		// nothing ?
	}
	
	private function onVisibilityEditConfirmed():Void
	{
		var defaultCollection:ClassVisibilityCollection = getDefaultVisibility(this._list.selectedItem.classID);
		if (!defaultCollection.isDifferentFrom(this._list.selectedItem))
		{
			onVisibilityRemoveButton(null);
		}
	}
	
	private function onVisibilityRemoveButton(evt:TriggerEvent):Void
	{
		var collection:ClassVisibilityCollection = this._list.selectedItem;
		this._editCollection.remove(collection);
		collection.pool();
		FeathersEvent.dispatch(this._listCollection, Event.CHANGE);
	}
	
}
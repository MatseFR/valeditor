package ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import openfl.events.Event;
import valedit.ValEdit;
import valedit.ValEditClass;
import valedit.ValEditTemplate;

/**
 * ...
 * @author Matse
 */
class ObjectCreationFromTemplateView extends LayoutGroup 
{
	public var confirmButton(get, set):Button;
	private var _confirmButton:Button;
	private function get_confirmButton():Button { return this._confirmButton; }
	private function set_confirmButton(value:Button):Button
	{
		return this._confirmButton = value;
	}
	
	private var _categoryGroup:LayoutGroup;
	private var _categoryLabel:Label;
	private var _categoryControlsGroup:LayoutGroup;
	private var _categoryPicker:ComboBox;
	private var _categoryClearButton:Button;
	private var _categoryCollection:ArrayCollection<String> = new ArrayCollection<String>();
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classControlsGroup:LayoutGroup;
	private var _classPicker:ComboBox;
	private var _classClearButton:Button;
	private var _classCollection:ArrayCollection<String> = new ArrayCollection<String>();
	
	private var _templateGroup:LayoutGroup;
	private var _templateLabel:Label;
	private var _templateGrid:GridView;
	private var _templateCollection:ArrayCollection<ValEditTemplate> = new ArrayCollection<ValEditTemplate>();
	private var _selectedTemplate:ValEditTemplate;
	
	private var _nameGroup:LayoutGroup;
	private var _nameLabel:Label;
	private var _nameInput:TextInput;
	
	private var _valEditClass:ValEditClass;

	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
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
		
		this._categoryPicker = new ComboBox(ValEdit.categoryCollection, onCategoryChange);
		this._categoryPicker.layoutData = new HorizontalLayoutData(100);
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
		
		this._classLabel = new Label("Template Class");
		this._classGroup.addChild(this._classLabel);
		
		this._classControlsGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._classControlsGroup.layout = hLayout;
		this._classGroup.addChild(this._classControlsGroup);
		
		this._classCollection.addAll(ValEdit.classCollection);
		this._classPicker = new ComboBox(this._classCollection);
		this._classPicker.selectedIndex = -1;
		this._classPicker.addEventListener(Event.CHANGE, onClassChange);
		this._classPicker.layoutData = new HorizontalLayoutData(100);
		this._classControlsGroup.addChild(this._classPicker);
		
		this._classClearButton = new Button("X", onClassClear);
		this._classClearButton.enabled = false;
		this._classControlsGroup.addChild(this._classClearButton);
		
		// template
		this._templateGroup = new LayoutGroup();
		this._templateGroup.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._templateGroup.layout = vLayout;
		addChild(this._templateGroup);
		
		this._templateLabel = new Label("Template");
		this._templateGroup.addChild(this._templateLabel);
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			new GridViewColumn("name", (item)->item.name),
			new GridViewColumn("class", (item)->item.className),
			new GridViewColumn("#", (item)->Std.string(item.numInstances))
		]);
		
		this._templateGrid = new GridView(this._templateCollection, columns, onTemplateChange);
		this._templateGrid.layoutData = new VerticalLayoutData(100, 100);
		this._templateGroup.addChild(this._templateGrid);
		
		// name
		this._nameGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._nameGroup.layout = vLayout;
		addChild(this._nameGroup);
		
		this._nameLabel = new Label("Object Name (optionnal)");
		this._nameGroup.addChild(this._nameLabel);
		
		this._nameInput = new TextInput("", null, onNameInputChange);
		this._nameGroup.addChild(this._nameInput);
	}
	
	private function onAddedToStage(evt:Event):Void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		
		if (this._initialized)
		{
			checkValid();
		}
	}
	
	private function onRemovedFromStage(evt:Event):Void
	{
		this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	public function confirm():Dynamic
	{
		var name:String = null;
		if (this._nameInput.text != "") name = this._nameInput.text;
		var object:Dynamic = ValEdit.createObjectWithTemplate(this._templateGrid.selectedItem, name);
		return object;
	}
	
	public function reset():Void
	{
		updateClassCollection();
		updateTemplateCollection();
		checkValid();
	}
	
	private function checkValid():Void
	{
		var isValid:Bool = true;
		if (this._selectedTemplate == null)
		{
			isValid = false;
		}
		else if (this._nameInput.text != "")
		{
			if (this._valEditClass.objectNameExists(this._nameInput.text))
			{
				isValid = false;
				this._nameInput.errorString = "name already in use";
			}
			else
			{
				this._nameInput.errorString = null;
			}
		}
		else
		{
			this._nameInput.errorString = null;
		}
		this._confirmButton.enabled = isValid;
	}
	
	private function updateClassCollection():Void
	{
		var selectedItem:String = this._classPicker.selectedItem;
		this._classCollection.removeAll();
		if (this._categoryPicker.selectedItem == null)
		{
			this._classCollection.addAll(ValEdit.classCollection);
		}
		else
		{
			this._classCollection.addAll(ValEdit.getClassCollectionForCategory(this._categoryPicker.selectedItem));
		}
		
		if (selectedItem != null)
		{
			var index:Int = this._classCollection.indexOf(selectedItem);
			this._classPicker.selectedIndex = index;
		}
	}
	
	private function updateTemplateCollection():Void
	{
		var selectedItem:ValEditTemplate = this._templateGrid.selectedItem;
		if (this._categoryPicker.selectedItem == null)
		{
			if (this._classPicker.selectedItem == null)
			{
				this._templateGrid.dataProvider = ValEdit.templateCollection;
			}
			else
			{
				this._templateGrid.dataProvider = ValEdit.getTemplateCollectionForClassName(this._classPicker.selectedItem);
			}
		}
		else
		{
			if (this._classPicker.selectedItem == null)
			{
				this._templateGrid.dataProvider = ValEdit.getTemplateCollectionForCategory(this._categoryPicker.selectedItem);
			}
			else
			{
				this._templateGrid.dataProvider = ValEdit.getTemplateCollectionForClassName(this._classPicker.selectedItem);
			}
		}
		
		if (selectedItem != null)
		{
			var index:Int = this._templateGrid.dataProvider.indexOf(selectedItem);
			this._templateGrid.selectedIndex = index;
		}
	}
	
	private function onCategoryChange(evt:Event):Void
	{
		this._categoryClearButton.enabled = this._categoryPicker.selectedIndex != -1;
		updateClassCollection();
		//updateTemplateCollection();
	}
	
	private function onCategoryClear(evt:TriggerEvent):Void
	{
		this._categoryPicker.selectedIndex = -1;
	}
	
	private function onClassChange(evt:Event):Void
	{
		this._classClearButton.enabled = this._classPicker.selectedIndex != -1;
		updateTemplateCollection();
	}
	
	private function onClassClear(evt:TriggerEvent):Void
	{
		this._classPicker.selectedIndex = -1;
	}
	
	private function onNameInputChange(evt:Event):Void
	{
		checkValid();
	}
	
	private function onTemplateChange(evt:Event):Void
	{
		this._selectedTemplate = _templateGrid.selectedItem;
		if (this._selectedTemplate != null)
		{
			this._valEditClass = ValEdit.getValEditClassByClassName(this._selectedTemplate.className);
		}
		else
		{
			this._valEditClass = null;
		}
		checkValid();
	}
	
}
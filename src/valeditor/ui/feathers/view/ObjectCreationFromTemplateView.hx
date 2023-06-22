package valeditor.ui.feathers.view;

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
import valeditor.ValEditorObject;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.theme.simple.variants.LayoutGroupVariant;

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
	private var _templateCollection:ArrayCollection<ValEditorTemplate> = new ArrayCollection<ValEditorTemplate>();
	private var _selectedTemplate:ValEditorTemplate;
	
	private var _idGroup:LayoutGroup;
	private var _idLabel:Label;
	private var _idInput:TextInput;
	
	private var _valEditClass:ValEditorClass;

	public function new() 
	{
		super();
		this.variant = LayoutGroupVariant.WITH_BORDER;
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
		
		this._categoryPicker = new ComboBox(ValEditor.categoryCollection, onCategoryChange);
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
		
		this._classCollection.addAll(ValEditor.classCollection);
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
		this._idGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._idGroup.layout = vLayout;
		addChild(this._idGroup);
		
		this._idLabel = new Label("Object ID (optionnal)");
		this._idGroup.addChild(this._idLabel);
		
		this._idInput = new TextInput("", null, onIDInputChange);
		this._idGroup.addChild(this._idInput);
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
	
	public function confirm():ValEditorObject
	{
		var id:String = null;
		if (this._idInput.text != "") id = this._idInput.text;
		var object:ValEditorObject = ValEditor.createObjectWithTemplate(this._templateGrid.selectedItem, id);
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
		else if (this._idInput.text != "")
		{
			if (this._valEditClass.objectIDExists(this._idInput.text))
			{
				isValid = false;
				this._idInput.errorString = "ID already in use";
			}
			else
			{
				this._idInput.errorString = null;
			}
		}
		else
		{
			this._idInput.errorString = null;
		}
		this._confirmButton.enabled = isValid;
	}
	
	private function updateClassCollection():Void
	{
		var selectedItem:String = this._classPicker.selectedItem;
		this._classCollection.removeAll();
		if (this._categoryPicker.selectedItem == null)
		{
			this._classCollection.addAll(ValEditor.classCollection);
		}
		else
		{
			this._classCollection.addAll(ValEditor.getClassCollectionForCategory(this._categoryPicker.selectedItem));
		}
		
		if (selectedItem != null)
		{
			var index:Int = this._classCollection.indexOf(selectedItem);
			this._classPicker.selectedIndex = index;
		}
	}
	
	private function updateTemplateCollection():Void
	{
		var selectedItem:ValEditorTemplate = this._templateGrid.selectedItem;
		if (this._categoryPicker.selectedItem == null)
		{
			if (this._classPicker.selectedItem == null)
			{
				this._templateGrid.dataProvider = ValEditor.templateCollection;
			}
			else
			{
				this._templateGrid.dataProvider = ValEditor.getTemplateCollectionForClassName(this._classPicker.selectedItem);
			}
		}
		else
		{
			if (this._classPicker.selectedItem == null)
			{
				this._templateGrid.dataProvider = ValEditor.getTemplateCollectionForCategory(this._categoryPicker.selectedItem);
			}
			else
			{
				this._templateGrid.dataProvider = ValEditor.getTemplateCollectionForClassName(this._classPicker.selectedItem);
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
	
	private function onIDInputChange(evt:Event):Void
	{
		checkValid();
	}
	
	private function onTemplateChange(evt:Event):Void
	{
		this._selectedTemplate = _templateGrid.selectedItem;
		if (this._selectedTemplate != null)
		{
			this._valEditClass = ValEditor.getValEditClassByClassName(this._selectedTemplate.className);
		}
		else
		{
			this._valEditClass = null;
		}
		checkValid();
	}
	
}
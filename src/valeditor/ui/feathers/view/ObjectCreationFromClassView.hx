package valeditor.ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
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
import valedit.ExposedCollection;
import valedit.ValEdit;
import valeditor.ValEditorObject;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.theme.simple.variants.LayoutGroupVariant;
import valeditor.ui.feathers.theme.simple.variants.ScrollContainerVariant;

/**
 * ...
 * @author Matse
 */
class ObjectCreationFromClassView extends LayoutGroup 
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
	private var _categoryCollection:ArrayCollection<StringData> = new ArrayCollection<StringData>();
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classPicker:ComboBox;
	private var _classCollection:ArrayCollection<StringData> = new ArrayCollection<StringData>();
	
	private var _idGroup:LayoutGroup;
	private var _idLabel:Label;
	private var _idInput:TextInput;
	
	private var _constructorGroup:LayoutGroup;
	private var _constructorLabel:Label;
	private var _constructorContainer:ScrollContainer;
	private var _constructorButtonGroup:LayoutGroup;
	private var _constructorDefaultsButton:Button;
	
	private var _valEditClass:ValEditorClass;
	private var _constructorCollection:ExposedCollection;
	
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
		
		this._categoryPicker = new ComboBox(ValEditor.categoryCollection);
		this._categoryPicker.layoutData = new HorizontalLayoutData(100);
		this._categoryPicker.itemToText = function(item:Dynamic):String {
			return item.value;
		};
		this._categoryPicker.selectedIndex = -1;
		this._categoryPicker.addEventListener(Event.CHANGE, onCategoryChange);
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
		
		this._classCollection.addAll(ValEditor.classCollection);
		this._classPicker = new ComboBox(this._classCollection);
		this._classPicker.itemToText = function(item:Dynamic):String {
			return item.value;
		};
		this._classPicker.selectedIndex = -1;
		this._classPicker.addEventListener(Event.CHANGE, onClassChange);
		this._classGroup.addChild(this._classPicker);
		
		// ID
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
		
		// constructor
		this._constructorGroup = new LayoutGroup();
		this._constructorGroup.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._constructorGroup.layout = vLayout;
		addChild(this._constructorGroup);
		
		this._constructorLabel = new Label("Constructor values");
		this._constructorGroup.addChild(this._constructorLabel);
		
		this._constructorContainer = new ScrollContainer();
		this._constructorContainer.variant = ScrollContainerVariant.WITH_BORDER;
		this._constructorContainer.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		this._constructorContainer.layout = vLayout;
		this._constructorGroup.addChild(this._constructorContainer);
		
		this._constructorButtonGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.paddingTop = Spacing.VERTICAL_GAP;
		this._constructorButtonGroup.layout = vLayout;
		this._constructorGroup.addChild(this._constructorButtonGroup);
		
		this._constructorDefaultsButton = new Button("Restore constructor defaults", onConstructorDefaultsButton);
		this._constructorButtonGroup.addChild(this._constructorDefaultsButton);
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
		var params:Array<Dynamic> = null;
		if (this._idInput.text != "") id = this._idInput.text;
		if (this._constructorCollection != null) params = this._constructorCollection.toValueArray();
		var object:ValEditorObject = ValEditor.createObjectWithClassName(this._valEditClass.className, id, params);
		return object;
	}
	
	public function reset():Void
	{
		updateClassCollection();
		checkValid();
	}
	
	private function checkValid():Void
	{
		var isValid:Bool = true;
		if (this._valEditClass == null)
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
		this._constructorDefaultsButton.enabled = this._constructorCollection != null;
		this._confirmButton.enabled = isValid;
	}
	
	private function updateClassCollection():Void
	{
		var selectedItem:StringData = this._classPicker.selectedItem;
		this._classCollection.removeAll();
		if (this._categoryPicker.selectedItem == null)
		{
			this._classCollection.addAll(ValEditor.classCollection);
		}
		else
		{
			this._classCollection.addAll(ValEditor.getClassCollectionForCategory(this._categoryPicker.selectedItem.value));
		}
		
		if (selectedItem != null)
		{
			var index:Int = this._classCollection.indexOf(selectedItem);
			this._classPicker.selectedIndex = index;
		}
	}
	
	private function onCategoryChange(evt:Event):Void
	{
		_categoryClearButton.enabled = _categoryPicker.selectedItem != null;
		updateClassCollection();
	}
	
	private function onCategoryClear(evt:TriggerEvent):Void
	{
		this._categoryPicker.selectedIndex = -1;
	}
	
	private function onClassChange(evt:Event):Void
	{
		if (this._classPicker.selectedIndex != -1)
		{
			this._valEditClass = ValEditor.getValEditClassByClassName(this._classPicker.selectedItem.value);
			this._constructorCollection = ValEdit.editConstructor(this._valEditClass.className, this._constructorContainer);
		}
		else
		{
			ValEdit.editConstructor(null, this._constructorContainer);
			this._constructorCollection = null;
			this._valEditClass = null;
		}
		checkValid();
	}
	
	private function onIDInputChange(evt:Event):Void
	{
		checkValid();
	}
	
	private function onConstructorDefaultsButton(evt:TriggerEvent):Void
	{
		this._constructorCollection.restoreDefaultValues();
	}
	
}
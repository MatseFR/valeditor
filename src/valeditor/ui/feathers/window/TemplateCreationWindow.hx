package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.controls.TextInput;
import feathers.core.PopUpManager;
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
import valeditor.ValEditorTemplate;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;
import valeditor.ui.feathers.theme.simple.variants.ScrollContainerVariant;

/**
 * ...
 * @author Matse
 */
class TemplateCreationWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	public var confirmCallback(get, set):ValEditorTemplate->Void;
	private var _confirmCallback:ValEditorTemplate->Void;
	private function get_confirmCallback():ValEditorTemplate->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:ValEditorTemplate->Void):ValEditorTemplate->Void
	{
		return this._confirmCallback = value;
	}
	
	public var title(get, set):String;
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
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
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
		
		this._confirmButton = new Button("confirm", onConfirmButton);
		this._footerGroup.addChild(this._confirmButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
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
		
		this._categoryPicker = new ComboBox(this._categoryCollection, onCategoryChange);
		this._categoryPicker.layoutData = new HorizontalLayoutData(100);
		this._categoryPicker.itemToText = function(item:Dynamic):String {
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
		
		this._classLabel = new Label("Template Class");
		this._classGroup.addChild(this._classLabel);
		
		this._classPicker = new ComboBox(this._classCollection, onClassChange);
		this._classPicker.itemToText = function(item:Dynamic):String {
			return item.value;
		};
		this._classGroup.addChild(this._classPicker);
		
		// ID
		this._idGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._idGroup.layout = vLayout;
		addChild(this._idGroup);
		
		this._idLabel = new Label("Template ID (optionnal)");
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
	
	public function reset(?allowedClassNames:Array<StringData>, ?allowedCategories:Array<StringData>):Void
	{
		var selectedItem:StringData = this._classPicker.selectedItem;
		if (allowedClassNames != null && allowedClassNames.length != 0)
		{
			this._classCollection.array = allowedClassNames;
		}
		else
		{
			// allow all classes
			this._classCollection.removeAll();
			this._classCollection.addAll(ValEditor.classCollection);
		}
		if (selectedItem != null)
		{
			var index:Int = this._classCollection.indexOf(selectedItem);
			this._classPicker.selectedIndex = index;
		}
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
	
	private function onCategoryChange(evt:Event):Void
	{
		if (_categoryPicker.selectedItem != null)
		{
			_categoryClearButton.enabled = true;
		}
		else
		{
			_categoryClearButton.enabled = false;
		}
	}
	
	private function onCategoryClear(evt:TriggerEvent):Void
	{
		this._categoryPicker.selectedIndex = -1;
	}
	
	private function onClassChange(evt:Event):Void
	{
		if (this._classPicker.selectedItem != null)
		{
			this._valEditClass = ValEditor.getValEditClassByClassName(this._classPicker.selectedItem.value);
			this._constructorCollection = ValEditor.editConstructor(this._valEditClass.className, this._constructorContainer);
			this._idInput.prompt = this._valEditClass.makeTemplateIDPreview();
		}
		else
		{
			ValEditor.editConstructor(null, this._constructorContainer);
			this._constructorCollection = null;
			this._valEditClass = null;
			this._idInput.prompt = null;
		}
		checkValid();
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		var id:String = null;
		if (this._idInput.text != "") id = this._idInput.text;
		
		var constructorCollection:ExposedCollection;
		if (this._constructorCollection != null)
		{
			constructorCollection = this._constructorCollection.clone(true);
		}
		else
		{
			constructorCollection = null;
		}
		
		var template:ValEditorTemplate = ValEditor.createTemplateWithClassName(this._valEditClass.className, id, constructorCollection);
		
		PopUpManager.removePopUp(this);
		if (this._confirmCallback != null) this._confirmCallback(template);
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
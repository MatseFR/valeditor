package ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.ComboBox;
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
import valedit.ValEditClass;
import valedit.ValEditTemplate;

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
	
	public var confirmCallback(get, set):ValEditTemplate->Void;
	private var _confirmCallback:ValEditTemplate->Void;
	private function get_confirmCallback():ValEditTemplate->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:ValEditTemplate->Void):Dynamic->Void
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
			this._titleLabel.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:LayoutGroup;
	private var _titleLabel:Label;
	
	private var _footerGroup:LayoutGroup;
	private var _confirmButton:Button;
	private var _cancelButton:Button;
	
	private var _categoryGroup:LayoutGroup;
	private var _categoryLabel:Label;
	private var _categoryControlsGroup:LayoutGroup;
	private var _categoryPicker:ComboBox;
	private var _categoryClearButton:Button;
	private var _categoryCollection:ArrayCollection<String> = new ArrayCollection<String>();
	
	private var _classGroup:LayoutGroup;
	private var _classLabel:Label;
	private var _classPicker:ComboBox;
	private var _classCollection:ArrayCollection<String> = new ArrayCollection<String>();
	
	private var _nameGroup:LayoutGroup;
	private var _nameLabel:Label;
	private var _nameInput:TextInput;
	
	private var _constructorGroup:LayoutGroup;
	private var _constructorLabel:Label;
	private var _constructorContainer:ScrollContainer;
	
	private var _valEditClass:ValEditClass;
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
		addChild(this._categoryControlsGroup);
		
		this._categoryPicker = new ComboBox(this._categoryCollection, onCategoryChange);
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
		
		this._classLabel = new Label("Object Class");
		this._classGroup.addChild(this._classLabel);
		
		this._classPicker = new ComboBox(this._classCollection, onClassChange);
		this._classGroup.addChild(this._classPicker);
		
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
		this._constructorContainer.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		this._constructorContainer.layout = vLayout;
		this._constructorGroup.addChild(this._constructorContainer);
	}
	
	public function reset(?allowedClassNames:Array<String>, ?allowedCategories:Array<String>):Void
	{
		var selectedItem:String = this._classPicker.selectedItem;
		if (allowedClassNames != null && allowedClassNames.length != 0)
		{
			this._classCollection.array = allowedClassNames;
		}
		else
		{
			// allow all classes
			this._classCollection.removeAll();
			this._classCollection.addAll(ValEdit.classCollection);
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
			this._valEditClass = ValEdit.getValEditClassByClassName(this._classPicker.selectedItem);
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
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		var name:String = null;
		if (this._nameInput.text != "") name = this._nameInput.text;
		
		var constructorCollection:ExposedCollection;
		if (this._constructorCollection != null)
		{
			constructorCollection = this._constructorCollection.clone(true);
		}
		else
		{
			constructorCollection = null;
		}
		
		var template:ValEditTemplate = ValEdit.createTemplateWithClassName(this._valEditClass.className, name, constructorCollection);
		
		PopUpManager.removePopUp(this);
		if (this._confirmCallback != null) this._confirmCallback(template);
	}
	
	private function onNameInputChange(evt:Event):Void
	{
		checkValid();
	}
	
}
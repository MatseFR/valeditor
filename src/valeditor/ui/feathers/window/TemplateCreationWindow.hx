package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.ComboBox;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
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
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valedit.ExposedCollection;
import valedit.events.ValueEvent;
import valeditor.ValEditorClass;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.template.TemplateAdd;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.TextInputIcon;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.renderers.ClassItemRenderer;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;
import valeditor.ui.feathers.theme.simple.variants.LayoutGroupVariant;

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
	private var _classInput:TextInputIcon;
	private var _classCollection:ArrayCollection<ValEditorClass> = new ArrayCollection<ValEditorClass>();
	
	private var _idGroup:LayoutGroup;
	private var _idLabel:Label;
	private var _idInput:TextInput;
	
	private var _constructorGroup:LayoutGroup;
	private var _constructorLabel:Label;
	private var _constructorContainerGroup:LayoutGroup;
	private var _constructorContainer:ScrollContainer;
	private var _constructorButtonGroup:LayoutGroup;
	private var _constructorDefaultsButton:Button;
	
	private var _valEditorClass:ValEditorClass;
	private var _constructorCollection:ExposedCollection;
	
	private var _textToClass:Map<String, ValEditorClass> = new Map<String, ValEditorClass>();
	
	public function new() 
	{
		super();
		initializeNow();
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
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
		this._categoryPicker.addEventListener(KeyboardEvent.KEY_DOWN, onComboKeyDown);
		this._categoryPicker.addEventListener(KeyboardEvent.KEY_UP, onComboKeyUp);
		this._categoryPicker.listViewFactory = function():ListView
		{
			var layout:VerticalListLayout = new VerticalListLayout();
			layout.requestedRowCount = Std.int(Math.min(this._categoryCollection.length, maxRows));
			var listView:ListView = new ListView();
			listView.layout = layout;
			return listView;
		};
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
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return ClassItemRenderer.fromPool();
		});
		
		recycler.update = (renderer:ClassItemRenderer, state:ListViewItemState) -> {
			renderer.clss = state.data;
		};
		
		recycler.destroy = (renderer:ClassItemRenderer) -> {
			renderer.pool();
		};
		
		this._classPicker = new ComboBox(this._classCollection, onClassChange);
		this._classPicker.addEventListener(FocusEvent.FOCUS_OUT, onClassFocusOut);
		this._classPicker.addEventListener(KeyboardEvent.KEY_DOWN, onComboKeyDown);
		this._classPicker.addEventListener(KeyboardEvent.KEY_UP, onComboKeyUp);
		this._classPicker.allowCustomUserValue = false;
		this._classPicker.listViewFactory = function():ListView
		{
			var layout:VerticalListLayout = new VerticalListLayout();
			layout.requestedRowCount = Std.int(Math.min(this._classCollection.length, maxRows));
			var listView:ListView = new ListView();
			listView.layout = layout;
			return listView;
		};
		this._classPicker.textInputFactory = () ->
		{
			this._classInput = new TextInputIcon();
			this._classInput.addEventListener(KeyboardEvent.KEY_UP, onClassInputKeyUp);
			this._classInput.leftView = new Bitmap();
			return this._classInput;
		};
		this._classPicker.itemToText = function(item:Dynamic):String {
			return cast(item, ValEditorClass).exportClassName;
		};
		this._classPicker.itemRendererRecycler = recycler;
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
		this._idInput.addEventListener(KeyboardEvent.KEY_DOWN, onIDInputKeyDown);
		this._idInput.addEventListener(KeyboardEvent.KEY_UP, onIDInputKeyUp);
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
		
		this._constructorContainerGroup = new LayoutGroup();
		this._constructorContainerGroup.variant = LayoutGroupVariant.WITH_BORDER;
		this._constructorContainerGroup.layoutData = new VerticalLayoutData(100, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.setPadding(1);
		this._constructorContainerGroup.layout = vLayout;
		this._constructorGroup.addChild(this._constructorContainerGroup);
		
		this._constructorContainer = new ScrollContainer();
		this._constructorContainer.layoutData = new VerticalLayoutData(null, 100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Padding.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.MINIMAL;
		this._constructorContainer.layout = vLayout;
		this._constructorContainerGroup.addChild(this._constructorContainer);
		
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
	
	public function reset(?allowedClasses:Array<ValEditorClass>, ?allowedCategories:Array<StringData>):Void
	{
		var selectedItem:ValEditorClass = this._classPicker.selectedItem;
		this._textToClass.clear();
		if (allowedClasses != null && allowedClasses.length != 0)
		{
			this._classCollection.array = allowedClasses;
		}
		else
		{
			// allow all classes
			this._classCollection.removeAll();
			this._classCollection.addAll(ValEditor.classCollection);
		}
		
		for (clss in this._classCollection)
		{
			this._textToClass.set(clss.exportClassName, clss);
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
		if (this._valEditorClass == null)
		{
			isValid = false;
		}
		else if (this._idInput.text != "")
		{
			if (this._valEditorClass.templateIDExists(this._idInput.text))
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
		if (isValid && this._constructorCollection != null)
		{
			isValid = this._constructorCollection.validateMandatory();
		}
		this._confirmButton.enabled = isValid;
	}
	
	private function onAddedToStage(evt:Event):Void
	{
		ValEditor.actionStack.pushSession();
	}
	
	private function onRemovedFromStage(evt:Event):Void
	{
		ValEditor.actionStack.popSession();
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onCategoryChange(evt:Event):Void
	{
		this._categoryClearButton.enabled = this._categoryPicker.selectedItem != null;
	}
	
	private function onCategoryClear(evt:TriggerEvent):Void
	{
		this._categoryPicker.selectedIndex = -1;
	}
	
	private function onClassChange(evt:Event):Void
	{
		var bmp:Bitmap = cast this._classInput.leftView;
		var change:Bool = false;
		
		if (this._constructorCollection != null)
		{
			this._constructorCollection.removeEventListener(ValueEvent.VALUE_CHANGE, onConstructorCollectionChange);
		}
		
		if (this._classPicker.selectedItem != null && Std.isOfType(this._classPicker.selectedItem, ValEditorClass))
		{
			this._valEditorClass = this._classPicker.selectedItem;
			this._constructorCollection = ValEditor.editConstructor(this._valEditorClass.className, this._constructorContainer);
			if (this._constructorCollection != null)
			{
				this._constructorCollection.addEventListener(ValueEvent.VALUE_CHANGE, onConstructorCollectionChange);
			}
			this._idInput.prompt = this._valEditorClass.makeTemplateIDPreview();
			
			if (bmp.bitmapData != this._valEditorClass.iconBitmapData)
			{
				bmp.bitmapData = this._valEditorClass.iconBitmapData;
				change = true;
			}
		}
		else
		{
			ValEditor.editConstructor(null, this._constructorContainer);
			this._constructorCollection = null;
			this._valEditorClass = null;
			this._idInput.prompt = null;
			
			if (bmp.bitmapData != null)
			{
				bmp.bitmapData = null;
				change = true;
			}
		}
		
		if (change)
		{
			this._classInput.setInvalid(InvalidationFlag.LAYOUT);
		}
		
		checkValid();
	}
	
	private function onClassFocusOut(evt:FocusEvent):Void
	{
		var item:ValEditorClass = this._classPicker.selectedItem;
		var bmp:Bitmap = cast this._classInput.leftView;
		var change:Bool = false;
		
		if (item == null)
		{
			if (bmp.bitmapData != null)
			{
				bmp.bitmapData = null;
				change = true;
			}
		}
		else
		{
			if (bmp.bitmapData != item.iconBitmapData)
			{
				bmp.bitmapData = item.iconBitmapData;
				change = true;
			}
		}
		
		if (change)
		{
			this._classInput.setInvalid(InvalidationFlag.LAYOUT);
		}
	}
	
	private function onClassInputKeyUp(evt:KeyboardEvent):Void
	{
		var item:ValEditorClass;
		var bmp:Bitmap = cast this._classInput.leftView;
		var change:Bool = false;
		
		if (evt.keyCode == Keyboard.ESCAPE)
		{
			item = this._classPicker.selectedItem;
			if (item == null)
			{
				if (bmp.bitmapData != null)
				{
					bmp.bitmapData = null;
					change = true;
				}
			}
			else
			{
				if (bmp.bitmapData != item.iconBitmapData)
				{
					bmp.bitmapData = item.iconBitmapData;
					change = true;
				}
			}
		}
		else
		{
			var txt:String = this._classInput.text;
			item = this._textToClass.get(txt);
			
			if (item == null)
			{
				if (bmp.bitmapData != null)
				{
					bmp.bitmapData = null;
					change = true;
				}
			}
			else
			{
				if (bmp.bitmapData != item.iconBitmapData)
				{
					bmp.bitmapData = item.iconBitmapData;
					change = true;
				}
			}
		}
		
		if (change)
		{
			this._classInput.setInvalid(InvalidationFlag.LAYOUT);
		}
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		var id:String = null;
		if (this._idInput.text != "") 
		{
			id = this._idInput.text;
		}
		if (id == null)
		{
			id = this._valEditorClass.makeTemplateID();
		}
		
		var constructorCollection:ExposedCollection;
		if (this._constructorCollection != null)
		{
			constructorCollection = this._constructorCollection.clone(true);
		}
		else
		{
			constructorCollection = null;
		}
		
		var template:ValEditorTemplate = ValEditor.createTemplateWithClassName(this._valEditorClass.className, id, constructorCollection);
		var action:TemplateAdd = TemplateAdd.fromPool();
		action.setup(template);
		ValEditor.actionStack.add(action);
		
		FeathersWindows.closeWindow(this);
		if (this._confirmCallback != null) this._confirmCallback(template);
	}
	
	private function onConstructorCollectionChange(evt:ValueEvent):Void
	{
		checkValid();
	}
	
	private function onConstructorDefaultsButton(evt:TriggerEvent):Void
	{
		this._constructorCollection.restoreDefaultValues();
	}
	
	private function onComboKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onComboKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onIDInputChange(evt:Event):Void
	{
		checkValid();
	}
	
	private function onIDInputKeyDown(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onIDInputKeyUp(evt:KeyboardEvent):Void
	{
		if (evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.NUMPAD_ENTER)
		{
			if (this.focusManager != null)
			{
				this.focusManager.focus = null;
			}
			else if (this.stage != null)
			{
				this.stage.focus = null;
			}
		}
		else if (evt.keyCode == Keyboard.ESCAPE)
		{
			if (this.focusManager != null)
			{
				this.focusManager.focus = null;
			}
			else if (this.stage != null)
			{
				this.stage.focus = null;
			}
		}
		evt.stopPropagation();
	}
	
}
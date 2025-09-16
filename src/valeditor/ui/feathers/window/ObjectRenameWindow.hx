package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.TextInput;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valeditor.ValEditorObject;
import valeditor.editor.action.object.ObjectRename;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class ObjectRenameWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	public var confirmCallback(get, set):Void->Void;
	private var _confirmCallback:Void->Void;
	private function get_confirmCallback():Void->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Void->Void):Void->Void
	{
		return this._confirmCallback = value;
	}
	
	public var object(get, set):ValEditorObject;
	private var _object:ValEditorObject;
	private function get_object():ValEditorObject { return this._object; }
	private function set_object(value:ValEditorObject):ValEditorObject
	{
		this._object = value;
		if (this._initialized && this._object != null)
		{
			this._nameInput.text = this._object.objectID;
		}
		return this._object;
	}
	
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _confirmButton:Button;
	private var _cancelButton:Button;
	
	private var _nameGroup:LayoutGroup;
	private var _nameLabel:Label;
	private var _nameInput:TextInput;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this._headerGroup = new Header("Rename Object");
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
		this._footerGroup.addChild(this._confirmButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(this._cancelButton);
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		vLayout.setPadding(Padding.DEFAULT);
		vLayout.paddingBottom += Padding.DEFAULT * 2;
		vLayout.paddingTop += Padding.DEFAULT * 2;
		this.layout = vLayout;
		
		this._nameGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._nameGroup.layout = vLayout;
		addChild(this._nameGroup);
		
		this._nameLabel = new Label("new ID");
		this._nameGroup.addChild(this._nameLabel);
		
		this._nameInput = new TextInput();
		this._nameInput.addEventListener(Event.CHANGE, onNameInputChange);
		this._nameInput.addEventListener(KeyboardEvent.KEY_DOWN, onNameInputKeyDown);
		this._nameInput.addEventListener(KeyboardEvent.KEY_UP, onNameInputKeyUp);
		if (this._object != null)
		{
			this._nameInput.text = this._object.id;
		}
		this._nameGroup.addChild(this._nameInput);
	}
	
	private function checkValid():Void
	{
		if (this._object == null) return;
		var isValid:Bool = true;
		
		if (this._nameInput.text == "")
		{
			isValid = false;
			this._nameInput.errorString = "Object must have an ID";
		}
		else
		{
			if (this._nameInput.text == this._object.objectID || !ValEditor.currentContainer.hasObject(this._nameInput.text))
			{
				this._nameInput.errorString = null;
			}
			else
			{
				isValid = false;
				this._nameInput.errorString = "ID already in use";
			}
		}
		this._confirmButton.enabled = isValid;
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		var action:ObjectRename = ObjectRename.fromPool();
		action.setup(this._object, this._nameInput.text);
		ValEditor.actionStack.add(action);
		
		FeathersWindows.closeWindow(this);
		if (this._confirmCallback != null) this._confirmCallback();
	}
	
	private function onNameInputChange(evt:Event):Void
	{
		checkValid();
	}
	
	private function onNameInputKeyDown(evt:KeyboardEvent):Void
	{
		if (evt.keyCode == Keyboard.ENTER || evt.keyCode == Keyboard.NUMPAD_ENTER)
		{
			if (this._confirmButton.enabled)
			{
				onConfirmButton(null);
			}
		}
		
		evt.stopPropagation();
	}
	
	private function onNameInputKeyUp(evt:KeyboardEvent):Void
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
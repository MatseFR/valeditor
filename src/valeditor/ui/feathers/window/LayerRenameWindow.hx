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
import valeditor.ValEditorLayer;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class LayerRenameWindow extends Panel 
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
	
	public var layer(get, set):ValEditorLayer;
	private var _layer:ValEditorLayer;
	private function get_layer():ValEditorLayer { return this._layer; }
	private function set_layer(value:ValEditorLayer):ValEditorLayer
	{
		this._layer = value;
		if (this._initialized && this._layer != null)
		{
			this._nameInput.text = this._layer.name;
		}
		return this._layer;
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
		
		this._headerGroup = new Header("Rename Layer");
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
		
		this._nameLabel = new Label("new name");
		this._nameGroup.addChild(this._nameLabel);
		
		this._nameInput = new TextInput();
		this._nameInput.addEventListener(Event.CHANGE, onNameInputChange);
		if (this._layer != null)
		{
			this._nameInput.text = this._layer.name;
		}
		this._nameGroup.addChild(this._nameInput);
	}
	
	private function checkValid():Void
	{
		if (this._layer == null) return;
		var isValid:Bool = true;
		
		if (this._nameInput.text == "")
		{
			isValid = false;
			this._nameInput.errorString = "Layer must have a name";
		}
		else
		{
			if (this._nameInput.text == this._layer.name || !cast(this._layer.container, IValEditorContainer).layerNameExists(this._nameInput.text))
			{
				this._nameInput.errorString = null;
			}
			else
			{
				isValid = false;
				this._nameInput.errorString = "Name already in use";
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
		this._layer.name = this._nameInput.text;
		FeathersWindows.closeWindow(this);
		if (this._confirmCallback != null) this._confirmCallback();
	}
	
	private function onNameInputChange(evt:Event):Void
	{
		checkValid();
	}
}
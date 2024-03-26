package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class ObjectEditWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	public var confirmCallback(get, set):Void->Void;
	public var editContainer(get, never):ScrollContainer;
	public var editObject(get, set):Dynamic;
	public var title(get, set):String;
	
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
	
	private function get_editContainer():ScrollContainer { return this._contentGroup; }
	
	private var _editObject:Dynamic;
	private function get_editObject():Dynamic { return this._editObject; }
	private function set_editObject(value:Dynamic):Dynamic
	{
		if (this._editObject == value) return value;
		if (this._initialized)
		{
			ValEditor.edit(value, this._contentGroup);
		}
		return this._editObject = value;
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
	
	private var _contentGroup:ScrollContainer;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this.layout = new AnchorLayout();
		
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
		this.footer = _footerGroup;
		
		this._confirmButton = new Button("confirm", onConfirmButton);
		this._footerGroup.addChild(_confirmButton);
		
		this._cancelButton = new Button("cancel", onCancelButton);
		this._footerGroup.addChild(_cancelButton);
		
		this._contentGroup = new ScrollContainer();
		this._contentGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingTop = Spacing.DEFAULT;
		vLayout.paddingBottom = Spacing.DEFAULT;
		vLayout.paddingLeft = vLayout.paddingRight = Padding.DEFAULT;
		this._contentGroup.layout = vLayout;
		addChild(this._contentGroup);
		
		if (this._editObject != null)
		{
			ValEditor.edit(this._editObject, this._contentGroup);
		}
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
		this.editObject = null;
		this._confirmCallback();
	}
	
}
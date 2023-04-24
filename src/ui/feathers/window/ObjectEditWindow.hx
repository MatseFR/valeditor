package ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.core.PopUpManager;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import ui.feathers.Padding;
import ui.feathers.Spacing;
import valedit.ValEdit;

/**
 * ...
 * @author Matse
 */
class ObjectEditWindow extends Panel 
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
	
	public var editContainer(get, never):ScrollContainer;
	private function get_editContainer():ScrollContainer { return this._contentGroup; }
	
	public var editObject(get, set):Dynamic;
	private var _editObject:Dynamic;
	private function get_editObject():Dynamic { return this._editObject; }
	private function set_editObject(value:Dynamic):Dynamic
	{
		if (_initialized)
		{
			ValEdit.edit(value, this._contentGroup);
		}
		return this._editObject = value;
	}
	
	public var title(get, set):String;
	private var _title:String = "";
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (value == null) value = "";
		if (_initialized)
		{
			_titleLabel.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:LayoutGroup;
	private var _titleLabel:Label;
	
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
		
		_headerGroup = new LayoutGroup();
		_headerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		_headerGroup.layout = hLayout;
		this.header = _headerGroup;
		
		_titleLabel = new Label(this._title);
		_headerGroup.addChild(_titleLabel);
		
		_footerGroup = new LayoutGroup();
		_footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		_footerGroup.layout = hLayout;
		this.footer = _footerGroup;
		
		_confirmButton = new Button("confirm", onConfirmButton);
		_footerGroup.addChild(_confirmButton);
		
		_cancelButton = new Button("cancel", onCancelButton);
		_footerGroup.addChild(_cancelButton);
		
		_contentGroup = new ScrollContainer();
		_contentGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = Spacing.DEFAULT;
		_contentGroup.layout = vLayout;
		addChild(_contentGroup);
		
		if (this._editObject != null)
		{
			ValEdit.edit(this._editObject, this._contentGroup);
		}
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		this._confirmCallback();
	}
	
}
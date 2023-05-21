package ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import ui.feathers.Padding;
import ui.feathers.view.ObjectCreationFromClassView;
import ui.feathers.view.ObjectCreationFromTemplateView;

/**
 * ...
 * @author Matse
 */
class ObjectCreationWindow extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	public var confirmCallback(get, set):Dynamic->Void;
	private var _confirmCallback:Dynamic->Void;
	private function get_confirmCallback():Dynamic->Void { return this._confirmCallback; }
	private function set_confirmCallback(value:Dynamic->Void):Dynamic->Void
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
	
	private var _navigator:TabNavigator;
	private var _classView:ObjectCreationFromClassView;
	private var _templateView:ObjectCreationFromTemplateView;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		
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
		
		this.layout = new AnchorLayout();
		
		this._classView = new ObjectCreationFromClassView();
		this._classView.confirmButton = this._confirmButton;
		this._templateView = new ObjectCreationFromTemplateView();
		this._templateView.confirmButton = this._confirmButton;
		
		var views:ArrayCollection<TabItem> = new ArrayCollection<TabItem>([
			TabItem.withDisplayObject("Class", this._classView),
			TabItem.withDisplayObject("Template", this._templateView)
		]);
		
		this._navigator = new TabNavigator(views);
		this._navigator.layoutData = new AnchorLayoutData(Padding.DEFAULT * 2, Padding.DEFAULT * 2, Padding.DEFAULT * 2, Padding.DEFAULT * 2);
		addChild(this._navigator);
	}
	
	public function reset():Void
	{
		this._classView.reset();
		this._templateView.reset();
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onConfirmButton(evt:TriggerEvent):Void
	{
		var object:Dynamic;
		if (this._navigator.activeItemView == this._classView)
		{
			object = this._classView.confirm();
		}
		else //if (this._navigator.activeItemView == this._templateView)
		{
			object = this._templateView.confirm();
		}
		PopUpManager.removePopUp(this);
		if (this._confirmCallback != null) this._confirmCallback(object);
	}
	
}
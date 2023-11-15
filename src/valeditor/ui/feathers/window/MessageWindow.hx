package valeditor.ui.feathers.window;

import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.Panel;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class MessageWindow extends Panel 
{
	public var message(get, set):String;
	public var title(get, set):String;
	
	private var _message:String;
	private function get_message():String { return this._message; }
	private function set_message(value:String):String
	{
		if (this._initialized)
		{
			this._label.text = value;
		}
		return this._message = value;
	}
	
	private var _title:String;
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:Header;
	private var _label:Label;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._headerGroup = new Header(this._title);
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.CENTER;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		vLayout.setPadding(Padding.DEFAULT);
		this.layout = vLayout;
		
		this._label = new Label(this._message);
		this._label.wordWrap = true;
		addChild(this._label);
	}
	
}
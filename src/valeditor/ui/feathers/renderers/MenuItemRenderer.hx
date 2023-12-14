package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
@:styleContext
class MenuItemRenderer extends LayoutGroupItemRenderer 
{
	public var iconBitmapData(get, set):BitmapData;
	public var text(get, set):String;
	public var shortcutText(get, set):String;
	
	override function set_enabled(value:Bool):Bool 
	{
		if (this._enabled == value) return value;
		if (this._initialized)
		{
			this._label.enabled = value;
			this._shortcutLabel.enabled = value;
		}
		return super.set_enabled(value);
	}
	
	private var _iconBitmapData:BitmapData;
	private function get_iconBitmapData():BitmapData { return this._iconBitmapData; }
	private function set_iconBitmapData(value:BitmapData):BitmapData
	{
		if (this._initialized)
		{
			this._icon.bitmapData = value;
			if (value == null)
			{
				if (this._icon.parent != null) removeChild(this._icon);
			}
			else
			{
				if (this._icon.parent == null) addChildAt(this._icon, 0);
			}
		}
		return this._iconBitmapData = value;
	}
	
	private var _text:String;
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (this._initialized)
		{
			this._label.text = value;
		}
		return this._text = value;
	}
	
	private var _shortcutText:String;
	private function get_shortcutText():String { return this._shortcutText; }
	private function set_shortcutText(value:String):String
	{
		if (this._initialized)
		{
			this._shortcutLabel.text = value;
			if (value == null)
			{
				if (this._shortcutLabel.parent != null) removeChild(this._shortcutLabel);
			}
			else
			{
				if (this._shortcutLabel.parent == null) addChild(this._shortcutLabel);
			}
		}
		return this._shortcutText = value;
	}
	
	private var _icon:Bitmap;
	private var _label:Label;
	private var _shortcutLabel:Label;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hData:HorizontalLayoutData;
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.paddingTop = hLayout.paddingBottom = Padding.MINIMAL;
		hLayout.paddingLeft = hLayout.paddingRight = Padding.SMALL;
		hLayout.gap = Spacing.BIG;
		this.layout = hLayout;
		
		this._icon = new Bitmap(this._iconBitmapData, PixelSnapping.AUTO, true);
		if (this._iconBitmapData != null) addChild(this._icon);
		
		this._label = new Label(this._text);
		this._label.variant = LabelVariant.MENU_ITEM_TEXT;
		this._label.enabled = this._enabled;
		addChild(this._label);
		
		this._shortcutLabel = new Label(this._shortcutText);
		this._shortcutLabel.variant = LabelVariant.MENU_ITEM_SHORTCUT;
		this._shortcutLabel.enabled = this._enabled;
		hData = new HorizontalLayoutData(100);
		this._shortcutLabel.layoutData = hData;
		if (this._shortcutText != null) addChild(this._shortcutLabel);
	}
	
}
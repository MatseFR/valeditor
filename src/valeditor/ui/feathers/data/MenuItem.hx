package valeditor.ui.feathers.data;
import openfl.display.BitmapData;

/**
 * ...
 * @author Matse
 */
class MenuItem 
{
	public var id:String;
	public var text:String;
	public var enabled:Bool;
	public var shortcutText:String;
	public var iconBitmapData:BitmapData;
	
	public function new(id:String, text:String, enabled:Bool = true, shortcutText:String = null, iconBitmapData:BitmapData = null) 
	{
		this.id = id;
		this.text = text;
		this.enabled = enabled;
		this.shortcutText = shortcutText;
		this.iconBitmapData = iconBitmapData;
	}
	
}
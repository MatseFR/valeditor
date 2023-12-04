package valeditor.ui.feathers.data;

/**
 * ...
 * @author Matse
 */
class AssetMenuItem 
{
	public var id:String;
	public var text:String;
	public var enabled:Bool;
	
	public function new(id:String, text:String, enabled:Bool = true) 
	{
		this.id = id;
		this.text = text;
		this.enabled = enabled;
	}
	
}
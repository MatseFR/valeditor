package valeditor.ui.feathers.data;

/**
 * ...
 * @author Matse
 */
class AssetMenuItem 
{
	public var id:String;
	public var name:String;
	public var enabled:Bool;
	
	public function new(id:String, name:String, enabled:Bool = true) 
	{
		this.id = id;
		this.name = name;
		this.enabled = enabled;
	}
	
}
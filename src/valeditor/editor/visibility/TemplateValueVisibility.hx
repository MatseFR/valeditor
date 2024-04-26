package valeditor.editor.visibility;

/**
 * ...
 * @author Matse
 */
class TemplateValueVisibility 
{
	static private var _POOL:Array<TemplateValueVisibility> = new Array<TemplateValueVisibility>();
	
	static public function fromPool(propertyName:String = null, templateVisible:Bool = false, templateObjectVisible:Bool = true):TemplateValueVisibility
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(propertyName, templateVisible, templateObjectVisible);
		return new TemplateValueVisibility(propertyName, templateVisible, templateObjectVisible);
	}
	
	public var propertyName:String;
	public var templateObjectVisible:Bool;
	public var templateVisible:Bool;
	
	public function new(propertyName:String = null, templateVisible:Bool = false, templateObjectVisible:Bool = true) 
	{
		this.propertyName = propertyName;
		this.templateVisible = templateVisible;
		this.templateObjectVisible = templateObjectVisible;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	public function clone(?visibility:TemplateValueVisibility):TemplateValueVisibility
	{
		if (visibility == null)
		{
			visibility = fromPool(this.propertyName, this.templateVisible, this.templateObjectVisible);
		}
		else
		{
			visibility.setTo(this.propertyName, this.templateVisible, this.templateObjectVisible);
		}
		return visibility;
	}
	
	private function setTo(propertyName:String, templateVisible:Bool, templateObjectVisible:Bool):TemplateValueVisibility
	{
		this.propertyName = propertyName;
		this.templateVisible = templateVisible;
		this.templateObjectVisible = templateObjectVisible;
		return this;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.propertyName = json.pn;
		this.templateVisible = json.tv;
		this.templateObjectVisible = json.tov;
	}
	
	public function toJSON():Dynamic
	{
		return {pn:this.propertyName, tv:this.templateVisible, tov:this.templateObjectVisible};
	}
	
}
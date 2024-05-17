package valeditor.editor.visibility;

/**
 * ...
 * @author Matse
 */
class ClassValueVisibility 
{
	static private var _POOL:Array<ClassValueVisibility> = new Array<ClassValueVisibility>();
	
	static public function fromPool(propertyName:String = null, templateVisible:Bool = false, templateObjectVisible:Bool = true, objectVisible:Bool = true):ClassValueVisibility
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(propertyName, templateVisible, templateObjectVisible, objectVisible);
		return new ClassValueVisibility(propertyName, templateVisible, templateObjectVisible, objectVisible);
	}
	
	public var propertyName:String;
	public var objectVisible:Bool;
	public var templateObjectVisible:Bool;
	public var templateVisible:Bool;
	
	public function new(propertyName:String = null, templateVisible:Bool = false, templateObjectVisible:Bool = true, objectVisible:Bool = true) 
	{
		this.propertyName = propertyName;
		this.templateVisible = templateVisible;
		this.templateObjectVisible = templateObjectVisible;
		this.objectVisible = objectVisible;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	public function clone(?visibility:ClassValueVisibility):ClassValueVisibility
	{
		if (visibility == null)
		{
			visibility = fromPool(this.propertyName, this.templateVisible, this.templateObjectVisible, this.objectVisible);
		}
		else
		{
			visibility.setTo(this.propertyName, this.templateVisible, this.templateObjectVisible, this.objectVisible);
		}
		
		return visibility;
	}
	
	public function isDifferentFrom(visibility:ClassValueVisibility):Bool
	{
		if (this.objectVisible != visibility.objectVisible) return true;
		if (this.templateObjectVisible != visibility.templateObjectVisible) return true;
		if (this.templateVisible != visibility.templateVisible) return true;
		return false;
	}
	
	private function setTo(propertyName:String, templateVisible:Bool, templateObjectVisible:Bool, objectVisible:Bool):ClassValueVisibility
	{
		this.propertyName = propertyName;
		this.templateVisible = templateVisible;
		this.templateObjectVisible = templateObjectVisible;
		this.objectVisible = objectVisible;
		return this;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.propertyName = json.pn;
		this.templateVisible = json.tv;
		this.templateObjectVisible = json.tov;
		this.objectVisible = json.ov;
	}
	
	public function toJSON():Dynamic
	{
		return {pn:this.propertyName, tv:this.templateVisible, tov:this.templateObjectVisible, ov:this.objectVisible};
	}
	
}
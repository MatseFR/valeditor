package valeditor;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import valedit.ExposedCollection;
import valedit.ValEditClass;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClass extends ValEditClass 
{
	static private var _POOL:Array<ValEditorClass> = new Array<ValEditorClass>();
	
	static public function fromPool(classReference:Class<Dynamic>):ValEditorClass
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(classReference);
		return new ValEditorClass(classReference);
	}
	
	public var canBeCreated:Bool;
	public var categories(default, null):Array<String> = new Array<String>();
	public var classNameShort:String;
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasTransformProperty:Bool;
	public var hasVisibleProperty:Bool;	
	public var hasRadianRotation:Bool;
	public var iconBitmapData:BitmapData;
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	public var usePivotScaling:Bool;

	public function new(classReference:Class<Dynamic>)
	{
		super(classReference);
	}
	
	override public function clear():Void 
	{
		this.canBeCreated = false;
		this.categories.resize(0);
		this.classNameShort = null;
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasTransformationMatrixProperty = false;
		this.hasTransformProperty = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.iconBitmapData = null;
		this.interactiveFactory = null;
		this.usePivotScaling = false;
		
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function makeTemplateIDPreview():String
	{
		var templateID:String = null;
		var num:Int = this._templateIDIndex;
		while (true)
		{
			num++;
			templateID = this.classNameShort + num;
			if (!this._IDToTemplate.exists(templateID)) break;
		}
		return templateID;
	}
	
	public function reset():Void
	{
		var containers:Array<DisplayObjectContainer> = [];
		// object containers
		for (container in this._containers.keys())
		{
			containers.push(container);
		}
		for (container in containers)
		{
			removeContainer(container);
		}
		containers.resize(0);
		
		// constructor containers
		for (container in this._constructorContainers.keys())
		{
			containers.push(container);
		}
		for (container in containers)
		{
			removeConstructorContainer(container);
		}
		containers.resize(0);
		
		// template containers
		for (container in this._templateContainers.keys())
		{
			containers.push(container);
		}
		for (container in containers)
		{
			removeTemplateContainer(container);
		}
		containers.resize(0);
		
		for (template in this._IDToTemplate)
		{
			ValEditor.destroyTemplate(cast template);
		}
		this._IDToTemplate.clear();
		
		for (object in this._IDToObject)
		{
			ValEditor.destroyObject(cast object);
		}
		this._IDToObject.clear();
		this._objectToValEditObject.clear();
		
		this._objectIDIndex = -1;
		this._templateIDIndex = -1;
		
		for (collection in this._collectionsToPool)
		{
			collection.pool();
		}
		this._collectionsToPool.clear();
	}
	
	public function addCategory(category:String):Void
	{
		this.categories.push(category);
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		var constructorCollection:ExposedCollection = null;
		var template:ValEditorTemplate;
		var templates:Array<Dynamic> = json.templates;
		for (node in templates)
		{
			if (this.constructorCollection != null && node.constructorCollection != null)
			{
				constructorCollection = this.constructorCollection.clone();
				constructorCollection.fromJSONSave(node.constructorCollection);
			}
			template = ValEditor.createTemplateWithClassName(this.className, node.id, constructorCollection);
			template.fromJSONSave(node);
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.clss = this.className;
		
		var templates:Array<Dynamic> = [];
		for (template in this._IDToTemplate)
		{
			templates.push(cast(template, ValEditorTemplate).toJSONSave());
		}
		json.templates = templates;
		
		return json;
	}
	
}
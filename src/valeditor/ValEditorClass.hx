package valeditor;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditTemplate;
import valedit.value.base.ExposedValueWithCollection;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.events.ClassEvent;
import valeditor.events.RenameEvent;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClass extends ValEditClass implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorClass> = new Array<ValEditorClass>();
	
	static public function fromPool(classReference:Class<Dynamic>, className:String, collection:ExposedCollection, constructorCollection:ExposedCollection = null):ValEditorClass
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(classReference, className, collection, constructorCollection);
		return new ValEditorClass(classReference, className, collection, constructorCollection);
	}
	
	public var canBeCreated:Bool;
	public var categories(default, null):Array<String> = new Array<String>();
	public var classNameShort:String;
	public var exportClassName:String;
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasTransformProperty:Bool;
	public var hasVisibleProperty:Bool;	
	public var hasRadianRotation:Bool;
	public var iconBitmapData:BitmapData;
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	public var templates(default, null):Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	/* if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height */
	public var useBounds:Bool;
	public var usePivotScaling:Bool;
	public var visibilityCollectionCurrent(default, null):ClassVisibilityCollection;
	public var visibilityCollectionDefault(get, set):ClassVisibilityCollection;
	public var visibilityCollectionFile(get, set):ClassVisibilityCollection;
	public var visibilityCollectionSettings(get, set):ClassVisibilityCollection;
	
	private var _visibilityCollectionDefault:ClassVisibilityCollection;
	private function get_visibilityCollectionDefault():ClassVisibilityCollection { return this._visibilityCollectionDefault; }
	private function set_visibilityCollectionDefault(value:ClassVisibilityCollection):ClassVisibilityCollection
	{
		if (this._visibilityCollectionDefault == value) return value;
		this._visibilityCollectionDefault = value;
		updateVisibilityCollection();
		return this._visibilityCollectionDefault;
	}
	
	private var _visibilityCollectionFile:ClassVisibilityCollection;
	private function get_visibilityCollectionFile():ClassVisibilityCollection { return this._visibilityCollectionDefault; }
	private function set_visibilityCollectionFile(value:ClassVisibilityCollection):ClassVisibilityCollection
	{
		this._visibilityCollectionFile = value;
		updateVisibilityCollection();
		return this._visibilityCollectionFile;
	}
	
	private var _visibilityCollectionSettings:ClassVisibilityCollection;
	private function get_visibilityCollectionSettings():ClassVisibilityCollection { return this._visibilityCollectionSettings; }
	private function set_visibilityCollectionSettings(value:ClassVisibilityCollection):ClassVisibilityCollection
	{
		this._visibilityCollectionSettings = value;
		updateVisibilityCollection();
		return this._visibilityCollectionSettings;
	}
	
	private var _suspendedInstances:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _suspendedTemplates:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	private var _containers:Map<DisplayObjectContainer, ExposedCollection> = new Map<DisplayObjectContainer, ExposedCollection>();
	private var _constructorContainers:Map<DisplayObjectContainer, ExposedCollection> = new Map<DisplayObjectContainer, ExposedCollection>();
	private var _templateContainers:Map<DisplayObjectContainer, ValEditTemplate> = new Map<DisplayObjectContainer, ValEditTemplate>();
	
	private var _collectionsToPool:Map<ExposedCollection, ExposedCollection> = new Map<ExposedCollection, ExposedCollection>();
	
	override function get_numInstances():Int 
	{
		return this._numObjects - this._suspendedInstances.length;
	}
	
	override function get_numTemplates():Int 
	{
		return this._numTemplates - this._suspendedTemplates.length;
	}

	public function new(classReference:Class<Dynamic>, className:String, collection:ExposedCollection, constructorCollection:ExposedCollection = null)
	{
		super(classReference, className, collection, constructorCollection);
	}
	
	override public function clear():Void 
	{
		this.canBeCreated = false;
		this.categories.resize(0);
		this.classNameShort = null;
		this.exportClassName = null;
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasTransformationMatrixProperty = false;
		this.hasTransformProperty = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.iconBitmapData = null;
		this.interactiveFactory = null;
		this.useBounds = false;
		this.usePivotScaling = false;
		
		this.templates.resize(0);
		
		this.visibilityCollectionCurrent = null;
		if (this._visibilityCollectionDefault != null)
		{
			this._visibilityCollectionDefault.pool();
			this._visibilityCollectionDefault = null;
		}
		this._visibilityCollectionFile = null;
		this._visibilityCollectionSettings = null;
		
		this._containers.clear();
		this._constructorContainers.clear();
		this._templateContainers.clear();
		
		for (collection in this._collectionsToPool)
		{
			collection.pool();
		}
		this._collectionsToPool.clear();
		
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function updateVisibilityCollection():Void
	{
		var newVisibility:ClassVisibilityCollection;
		if (this._visibilityCollectionFile != null)
		{
			newVisibility = this._visibilityCollectionFile;
		}
		else if (this._visibilityCollectionSettings != null)
		{
			newVisibility = this._visibilityCollectionSettings;
		}
		else
		{
			newVisibility = this._visibilityCollectionDefault;
		}
		
		this.visibilityCollectionCurrent = newVisibility;
		ValEditor.registerForChangeUpdate(this);
	}
	
	public function changeUpdate():Void
	{
		applyVisibility();
	}
	
	private function applyVisibility():Void
	{
		var template:ValEditorTemplate;
		var object:ValEditorObject;
		var visibility:TemplateVisibilityCollection;
		
		for (tpl in this._IDToTemplate)
		{
			template = cast tpl;
			visibility = template.visibilityCollectionDefault;
			visibility.clear();
			visibility.populateFromClassVisibilityCollection(this.visibilityCollectionCurrent);
			if (visibility == template.visibilityCollectionCurrent)
			{
				template.applyVisibility();
			}
		}
		
		for (obj in this._IDToObject)
		{
			if (obj.template != null) continue;
			object = cast obj;
			object.applyClassVisibility(this.visibilityCollectionCurrent);
		}
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
	
	public function makeTemplateID():String
	{
		var templateID:String = null;
		while (true)
		{
			this._templateIDIndex++;
			templateID = this.classNameShort + this._templateIDIndex;
			if (!this._IDToTemplate.exists(templateID)) break;
		}
		return templateID;
	}
	
	public function prepareForReset():Void
	{
		var object:ValEditorObject;
		for (template in this._IDToTemplate)
		{
			object = cast template.object;
			template.object = null;
			ValEditor.destroyObject(object);
		}
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
	
	override public function addTemplate(template:ValEditTemplate):Void 
	{
		super.addTemplate(template);
		
		this.templates.push(cast template);
		
		template.addEventListener(RenameEvent.RENAMED, onTemplateRenamed);
	}
	
	override public function removeTemplate(template:ValEditTemplate):Void 
	{
		super.removeTemplate(template);
		
		this.templates.remove(cast template);
		
		if (cast(template, ValEditorTemplate).isSuspended)
		{
			this._suspendedTemplates.remove(cast template);
			cast(template, ValEditorTemplate).isSuspended = false;
		}
		
		template.removeEventListener(RenameEvent.RENAMED, onTemplateRenamed);
	}
	
	public function suspendTemplate(template:ValEditorTemplate):Void
	{
		this._suspendedTemplates.push(template);
		template.isSuspended = true;
		ClassEvent.dispatch(this, ClassEvent.TEMPLATE_SUSPENDED, this);
	}
	
	public function unsuspendTemplate(template:ValEditorTemplate):Void
	{
		this._suspendedTemplates.remove(template);
		template.isSuspended = false;
		ClassEvent.dispatch(this, ClassEvent.TEMPLATE_UNSUSPENDED, this);
	}
	
	private function onTemplateRenamed(evt:RenameEvent):Void
	{
		var template:ValEditorTemplate = cast evt.target;
		this._IDToTemplate.remove(evt.previousNameOrID);
		this._IDToTemplate.set(template.id, template);
	}
	
	public function addContainer(container:DisplayObjectContainer, object:Dynamic, collection:ExposedCollection = null, parentValue:ExposedValueWithCollection = null):ExposedCollection
	{
		if (collection == null)
		{
			if (this._pool.length != 0) 
			{
				collection = this._pool.pop();
			}
			else
			{
				collection = this.collection.clone();
			}
			this._collectionsToPool.set(collection, collection);
			if (Std.isOfType(object, ValEditorObject))
			{
				collection.readAndSetObject(cast(object, ValEditorObject).object);
			}
			else
			{
				collection.readAndSetObject(object);
			}
		}
		this._containers[container] = collection;
		collection.parentValue = parentValue;
		collection.uiContainer = container;
		
		return collection;
	}
	
	public function addConstructorContainer(container:DisplayObjectContainer):ExposedCollection
	{
		var collection:ExposedCollection;
		if (this._constructorPool.length != 0)
		{
			collection = this._constructorPool.pop();
		}
		else
		{
			collection = this.constructorCollection.clone();
		}
		
		this._constructorContainers[container] = collection;
		collection.uiContainer = container;
		
		return collection;
	}
	
	public function addTemplateContainer(container:DisplayObjectContainer, template:ValEditTemplate):Void
	{
		this._templateContainers[container] = template;
		template.collection.uiContainer = container;
	}
	
	public function removeContainer(container:DisplayObjectContainer):Void
	{
		var collection:ExposedCollection = this._containers[container];
		if (collection != null)
		{
			this._containers.remove(container);
			collection.parentValue = null;
			collection.uiContainer = null;
			if (this._collectionsToPool.exists(collection))
			{
				collection.object = null;
				this._collectionsToPool.remove(collection);
				this._pool.push(collection);
			}
			return;
		}
		
		if (this._constructorContainers.exists(container))
		{
			removeConstructorContainer(container);
			return;
		}
		
		if (this._templateContainers.exists(container))
		{
			removeTemplateContainer(container);
			return;
		}
	}
	
	public function removeConstructorContainer(container:DisplayObjectContainer):Void
	{
		var collection:ExposedCollection = this._constructorContainers[container];
		if (collection != null)
		{
			this._constructorContainers.remove(container);
			collection.uiContainer = null;
			this._constructorPool.push(collection);
		}
	}
	
	public function removeTemplateContainer(container:DisplayObjectContainer):Void
	{
		var template:ValEditTemplate = this._templateContainers[container];
		if (template != null)
		{
			this._templateContainers.remove(container);
			template.collection.uiContainer = null;
		}
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		var constructorCollection:ExposedCollection = null;
		var template:ValEditorTemplate;
		var templates:Array<Dynamic> = json.templates;
		for (node in templates)
		{
			if (this.constructorCollection != null)
			{
				constructorCollection = this.constructorCollection.clone(true);
				if (node.constructorCollection != null)
				{
					constructorCollection.fromJSONSave(node.constructorCollection);
				}
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
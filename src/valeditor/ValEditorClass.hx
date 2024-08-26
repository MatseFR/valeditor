package valeditor;
import haxe.Constraints.Function;
import haxe.ds.ObjectMap;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventDispatcher;
import valedit.DisplayObjectType;
import valedit.ExposedCollection;
import valedit.utils.PropertyMap;
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
class ValEditorClass extends EventDispatcher implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorClass> = new Array<ValEditorClass>();
	
	static public function fromPool(classReference:Class<Dynamic>, className:String, collection:ExposedCollection, constructorCollection:ExposedCollection = null):ValEditorClass
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(classReference, className, collection, constructorCollection);
		return new ValEditorClass(classReference, className, collection, constructorCollection);
	}
	
	/** Dynamic->DisplayObjectContainer->Void */
	public var addToDisplayFunction:Function;
	public var addToDisplayFunctionName:String;
	public var canBeCreated:Bool;
	public var categories(default, null):Array<String> = new Array<String>();
	public var className:String;
	public var classNameShort:String;
	public var classPackage:String;
	public var classReference:Class<Dynamic>;
	public var cloneFromFunctionName:String;
	public var cloneToFunctionName:String;
	public var collection:ExposedCollection;
	public var constructorCollection:ExposedCollection;
	public var creationFunction:Function;
	public var creationFunctionForLoading:Function;
	public var creationFunctionForTemplateInstance:Function;
	/** Dynamic->Void external function reference, to be called on object creation */
	public var creationInitFunction:Function;
	/** Void->Void object function name, to be called on object creation */
	public var creationInitFunctionName:String;
	public var displayObjectType:Int = DisplayObjectType.NONE;
	/** Dynamic->Void external function reference, to be called on object destruction */
	public var disposeFunction:Function;
	/** Void->Void object function name, to be called on object destruction */
	public var disposeFunctionName:String = null;
	public var exportClassName(get, set):String;
	public var exportClassNameShort(get, set):String;
	public var exportClassPackage(get, set):String;
	public var getBoundsFunctionName:String;
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasTransformProperty:Bool;
	public var hasVisibleProperty:Bool;	
	public var hasRadianRotation:Bool;
	public var iconBitmapData:BitmapData;
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	public var isContainer:Bool;
	public var isContainerOpenFL:Bool;
	#if starling
	public var isContainerStarling:Bool;
	#end
	public var isDisplayObject:Bool;
	public var isTimeLineContainer:Bool;
	public var numInstances(get, never):Int;
	public var numTemplates(get, never):Int;
	public var propertyMap:PropertyMap;
	/** Dynamic->DisplayObjectContainer->Void */
	public var removeFromDisplayFunction:Function;
	public var removeFromDisplayFunctionName:String;
	public var superClassNames(default, null):Array<String> = new Array<String>();
	public var templates(default, null):Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	/* if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height */
	public var useBounds:Bool;
	//public var useBoundsForPosition:Bool;
	public var usePivotScaling:Bool;
	public var visibilityCollectionCurrent(default, null):ClassVisibilityCollection;
	public var visibilityCollectionDefault(get, set):ClassVisibilityCollection;
	public var visibilityCollectionFile(get, set):ClassVisibilityCollection;
	public var visibilityCollectionSettings(get, set):ClassVisibilityCollection;
	
	private var _exportClassName:String = null;
	private function get_exportClassName():String { return this._exportClassName != null ? this._exportClassName : this.className; }
	private function set_exportClassName(value:String):String
	{
		return this._exportClassName = value;
	}
	
	private var _exportClassNameShort:String = null;
	private function get_exportClassNameShort():String { return this._exportClassNameShort != null ? this._exportClassNameShort : this.classNameShort; }
	private function set_exportClassNameShort(value:String):String
	{
		return this._exportClassNameShort = value;
	}
	
	private var _exportClassPackage:String = null;
	private function get_exportClassPackage():String { return this._exportClassPackage != null ? this._exportClassPackage : this.classPackage; }
	private function set_exportClassPackage(value:String):String
	{
		return this._exportClassPackage = value;
	}
	
	private var _numObjects:Int = 0;
	private function get_numInstances():Int { return this._numObjects - this._suspendedInstances.length; }
	
	private var _numTemplates:Int = 0;
	private function get_numTemplates():Int { return this._numTemplates - this._suspendedTemplates.length; }
	
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
	
	private var _IDToObject:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
	private var _objectIDIndex:Int = -1;
	private var _objectToValEditObject:ObjectMap<Dynamic, ValEditorObject> = new ObjectMap<Dynamic, ValEditorObject>();
	
	private var _IDToTemplate:Map<String, ValEditorTemplate> = new Map<String, ValEditorTemplate>();
	private var _templateIDIndex:Int = -1;
	
	private var _pool:Array<ExposedCollection> = new Array<ExposedCollection>();
	
	private var _constructorPool:Array<ExposedCollection> = new Array<ExposedCollection>();
	
	private var _suspendedInstances:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _suspendedTemplates:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	private var _containers:Map<DisplayObjectContainer, ExposedCollection> = new Map<DisplayObjectContainer, ExposedCollection>();
	private var _constructorContainers:Map<DisplayObjectContainer, ExposedCollection> = new Map<DisplayObjectContainer, ExposedCollection>();
	private var _templateContainers:Map<DisplayObjectContainer, ValEditorTemplate> = new Map<DisplayObjectContainer, ValEditorTemplate>();
	
	private var _collectionsToPool:Map<ExposedCollection, ExposedCollection> = new Map<ExposedCollection, ExposedCollection>();
	
	public function new(classReference:Class<Dynamic>, className:String, collection:ExposedCollection, constructorCollection:ExposedCollection = null)
	{
		super();
		this.classReference = classReference;
		this.className = className;
		this.collection = collection;
		this.constructorCollection = constructorCollection;
	}
	
	public function clear():Void 
	{
		this.addToDisplayFunction = null;
		this.addToDisplayFunctionName = null;
		this.canBeCreated = false;
		this.categories.resize(0);
		this.className = null;
		this.classNameShort = null;
		this.classPackage = null;
		this.classReference = null;
		this.cloneFromFunctionName = null;
		this.cloneToFunctionName = null;
		if (this.collection != null)
		{
			this.collection.pool();
			this.collection = null;
		}
		if (this.constructorCollection != null)
		{
			this.constructorCollection.pool();
			this.constructorCollection = null;
		}
		this.creationFunction = null;
		this.creationFunctionForLoading = null;
		this.creationFunctionForTemplateInstance = null;
		this.creationInitFunction = null;
		this.creationInitFunctionName = null;
		this.displayObjectType = DisplayObjectType.NONE;
		this.disposeFunction = null;
		this.disposeFunctionName = null;
		this.exportClassName = null;
		this.exportClassNameShort = null;
		this.exportClassPackage = null;
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasTransformationMatrixProperty = false;
		this.hasTransformProperty = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.iconBitmapData = null;
		this.interactiveFactory = null;
		this.isContainer = false;
		this.isContainerOpenFL = false;
		#if starling
		this.isContainerStarling = false;
		#end
		this.isDisplayObject = false;
		this.isTimeLineContainer = false;
		this._numObjects = 0;
		this._numTemplates = 0;
		if (this.propertyMap != null)
		{
			this.propertyMap.pool();
			this.propertyMap = null;
		}
		this.removeFromDisplayFunction = null;
		this.removeFromDisplayFunctionName = null;
		this.superClassNames.resize(0);
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
		
		this._IDToObject.clear();
		this._objectIDIndex = -1;
		this._objectToValEditObject.clear();
		this._IDToTemplate.clear();
		this._templateIDIndex = -1;
		
		for (collection in this._pool)
		{
			collection.pool();
		}
		this._pool.resize(0);
		
		for (collection in this._constructorPool)
		{
			collection.pool();
		}
		this._constructorPool.resize(0);
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(classReference:Class<Dynamic>, className:String, collection:ExposedCollection, constructorCollection:ExposedCollection):ValEditorClass
	{
		this.classReference = classReference;
		this.className = className;
		this.collection = collection;
		this.constructorCollection = constructorCollection;
		return this;
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
		var visibility:TemplateVisibilityCollection;
		
		for (tpl in this._IDToTemplate)
		{
			visibility = tpl.visibilityCollectionDefault;
			visibility.clear();
			visibility.populateFromClassVisibilityCollection(this.visibilityCollectionCurrent);
			if (visibility == tpl.visibilityCollectionCurrent)
			{
				tpl.applyVisibility();
			}
		}
		
		for (obj in this._IDToObject)
		{
			if (obj.template != null) continue;
			obj.applyClassVisibility(this.visibilityCollectionCurrent);
		}
	}
	
	public function addSuperClassName(superClassName:String):Void
	{
		this.superClassNames.push(superClassName);
	}
	
	public function getCollection():ExposedCollection
	{
		var collection:ExposedCollection;
		if (this._pool.length != 0)
		{
			collection = this._pool.pop();
		}
		else
		{
			collection = this.collection.clone();
		}
		return collection;
	}
	
	public function makeObjectID():String
	{
		var objID:String = null;
		while (true)
		{
			this._objectIDIndex++;
			objID = this.exportClassName + this._objectIDIndex;
			if (!this._IDToObject.exists(objID)) break;
		}
		return objID;
	}
	
	public function objectIDExists(name:String):Bool
	{
		return this._IDToObject.exists(name);
	}
	
	public function makeTemplateIDPreview():String
	{
		var templateID:String = null;
		var num:Int = this._templateIDIndex;
		while (true)
		{
			num++;
			templateID = this.exportClassNameShort + num;
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
			templateID = this.exportClassNameShort + this._templateIDIndex;
			if (!this._IDToTemplate.exists(templateID)) break;
		}
		return templateID;
	}
	
	public function templateIDExists(id:String):Bool
	{
		return this._IDToTemplate.exists(id);
	}
	
	public function prepareForReset():Void
	{
		var object:ValEditorObject;
		for (template in this._IDToTemplate)
		{
			object = template.object;
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
			ValEditor.destroyTemplate(template);
		}
		this._IDToTemplate.clear();
		
		for (object in this._IDToObject)
		{
			ValEditor.destroyObject(object);
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
	
	public function addObject(object:ValEditorObject):Void
	{
		if (object.id == null) object.id = makeObjectID();
		this._IDToObject.set(object.id, object);
		this._objectToValEditObject.set(object.object, object);
		this._numObjects++;
	}
	
	public function getObjectByID(id:String):ValEditorObject
	{
		return this._IDToObject.get(id);
	}
	
	public function getObjectList(?objList:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (objList == null) objList = new Array<ValEditorObject>();
		
		for (obj in this._IDToObject)
		{
			objList.push(obj);
		}
		
		return objList;
	}
	
	public function getValEditObjectFromObject(object:Dynamic):ValEditorObject
	{
		return this._objectToValEditObject.get(object);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		this._IDToObject.remove(object.id);
		this._objectToValEditObject.remove(object.object);
		this._numObjects--;
	}
	
	public function removeObjectByID(id:String):Void
	{
		removeObject(this._IDToObject.get(id));
	}
	
	public function addTemplate(template:ValEditorTemplate):Void 
	{
		this._IDToTemplate.set(template.id, template);
		this._numTemplates++;
		
		this.templates.push(template);
		
		template.addEventListener(RenameEvent.RENAMED, onTemplateRenamed);
	}
	
	public function getTemplateByID(id:String):ValEditorTemplate
	{
		return this._IDToTemplate.get(id);
	}
	
	public function getTemplateList(?templateList:Array<ValEditorTemplate>):Array<ValEditorTemplate>
	{
		if (templateList == null) templateList = new Array<ValEditorTemplate>();
		
		for (template in _IDToTemplate)
		{
			templateList.push(template);
		}
		
		return templateList;
	}
	
	public function removeTemplate(template:ValEditorTemplate):Void 
	{
		if (this._IDToTemplate.remove(template.id))
		{
			this._numTemplates--;
		}
		
		this.templates.remove(cast template);
		
		if (template.isSuspended)
		{
			this._suspendedTemplates.remove(cast template);
			template.isSuspended = false;
		}
		
		template.removeEventListener(RenameEvent.RENAMED, onTemplateRenamed);
	}
	
	public function removeTemplateByID(id:String):Void
	{
		removeTemplate(this._IDToTemplate.get(id));
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
	
	public function addTemplateContainer(container:DisplayObjectContainer, template:ValEditorTemplate):Void
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
		var template:ValEditorTemplate = this._templateContainers[container];
		if (template != null)
		{
			this._templateContainers.remove(container);
			template.collection.uiContainer = null;
		}
	}
	
	public function loadComplete():Void
	{
		
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
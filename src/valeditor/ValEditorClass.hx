package valeditor;
import haxe.Constraints.Function;
import haxe.ds.ObjectMap;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.events.EventDispatcher;
import valedit.ExposedCollection;
import valedit.utils.PropertyMap;
import valedit.value.base.ExposedValueWithCollection;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.editor.visibility.TemplateVisibilityCollection;
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
	
	/** This should be set if objects from this class should use a custom function to be added to a DisplayObjectContainer.
	 * Expected function signature is Dynamic->DisplayObjectContainer->Void */
	public var addToDisplayFunction:Function;
	/** This should be set if objects from this class have a function that should be called when adding them to a DisplayObjectContainer. */
	public var addToDisplayFunctionName:String;
	/** Tells whether templates and objects can be created from from this class. */
	public var canBeCreated:Bool;
	/** The categories that this class belongs to. */
	public var categories(default, null):Array<String> = new Array<String>();
	/** The full class name with package (ex: openfl.display.Sprite) */
	public var className:String;
	/** The class name, without package (ex: Sprite) */
	public var classNameShort:String;
	/** The class package, without name (ex: openfl.display) */
	public var classPackage:String;
	/** Reference to the Class itself */
	public var classReference:Class<Dynamic>;
	/** Name of the 'cloneFrom' function on this class objects. If not null, it will be used by ValEditor when creating a template instance.
	 * This is required for container classes so that the container's content can be replicated.
	 * The function's signature should be T->Void */
	public var cloneFromFunctionName:String;
	/** Name of the 'cloneTo' function on this class objects. If not null, it will be used by ValEditor when creating a template instance.
	 * This is required for container classes so that the container's content can be replicated.
	 * The function's signature should be T->Void */
	public var cloneToFunctionName:String;
	/** The collection that will be used by templates and objects from this class. */
	public var collection:ExposedCollection;
	/** The constructor collection that will be used by templates and objects from this class. */
	public var constructorCollection:ExposedCollection;
	/** If not null, this function will be used to create an object from this class, instead of Type.createInstance. 
	 * The function's signature has to match the constructorCollection. */
	public var creationFunction:Function;
	/** If not null, this function will be used to create an object from this class while ValEditor is loading a saved file. 
	 * The function's signature has to match the constructorCollection. */
	public var creationFunctionForLoading:Function;
	/** If not null, this function will be used to create a template instance object from this class (taking priority over creationFunction in this case).
	 * The function's signature has to match the constructorCollection. */
	public var creationFunctionForTemplateInstance:Function;
	/** Dynamic->Void external function reference, to be called on object creation. */
	public var creationInitFunction:Function;
	/** Void->Void object function name, to be called on object creation. */
	public var creationInitFunctionName:String;
	/** Name of the event to listen for after creating the object to know when it's ready to use, if any */
	public var creationReadyEventName:String;
	/** Name of the object's function to call with a callback after creating the object to know when it's ready to use, if any */
	public var creationReadyRegisterFunctionName:String;
	/** Dynamic->Void external function reference, to be called on object destruction. */
	public var disposeFunction:Function;
	/** Void->Void object function name, to be called on object destruction. */
	public var disposeFunctionName:String = null;
	/** The full class name with package, for export. If null, 'className' is returned instead. */
	public var exportClassName(get, set):String;
	/** The class name, without package, for export. If null, 'classNameShort' is returned instead. */
	public var exportClassNameShort(get, set):String;
	/** The class package, without name, for export. If null, 'classPackage' is returned instead. */
	public var exportClassPackage(get, set):String;
	/** Name of the 'getBounds' function on this class objects, if any. */
	public var getBoundsFunctionName:String;
	/** Tells whether objects from this class have pivot properties or not. */
	public var hasPivotProperties:Bool;
	/** Tells whether objects from this class have scale properties or not. */
	public var hasScaleProperties:Bool;
	/** Tells whether objects from this class have a visible property or not. */
	public var hasVisibleProperty:Bool;	
	/** Tells whether objects from this class have their rotation property(ies) in radians or not. */
	public var hasRadianRotation:Bool;
	/** Optionnal BitmapData that will be used as icon for templates and objects from this class. */
	public var iconBitmapData:BitmapData;
	/** The function to call to associate an IInteractiveObject to objects from this class, if any. */
	public var interactiveFactory:ValEditorObject->IInteractiveObject;
	/** Tells whether objects from this class are containers or not. Container classes should not have their 'isDisplayObject' property set to true. */
	public var isContainer:Bool;
	/** Tells whether objects from this class are OpenFL containers or not. Mixed containers can have both their 'isContainerOpenFL' and 'isContainerStarling' properties set to true. */
	public var isContainerOpenFL:Bool;
	#if starling
	/** Tells whether objects from this class are Starling containers or not. Mixed containers can have both their 'isContainerOpenFL' and 'isContainerStarling' properties set to true. */
	public var isContainerStarling:Bool;
	#end
	/** Tells whether objects from this class are display objects. Should be left to false for container classes. */
	public var isDisplayObject:Bool;
	/** Tells whether objects from this class are OpenFL display objects. */
	public var isDisplayObjectOpenFL:Bool;
	#if starling
	/** Tells whether objects from this class are Starling display objects. */
	public var isDisplayObjectStarling:Bool;
	#end
	/** Tells whether objects from this class are timeline containers. */
	public var isTimeLineContainer:Bool;
	/** How many instances from this class are in the current file. */
	public var numInstances(get, never):Int;
	/** How many templates from this class are in the current file. */
	public var numTemplates(get, never):Int;
	/** The map storing custom property names and regular property names associations (ex: having 'posX' considered as 'x') */
	public var propertyMap:PropertyMap;
	/** This should be set if objects from this class should use a custom function to be removed from a DisplayObjectContainer. 
	 * Dynamic->DisplayObjectContainer->Void */
	public var removeFromDisplayFunction:Function;
	/** This should be set if objects from this class have a function that should be called when removing them from a DisplayObjectContainer. */
	public var removeFromDisplayFunctionName:String;
	/** Stores all class names that this class inherits from. Automatically set by ValEditor when registering the class. */
	public var superClassNames(default, null):Array<String> = new Array<String>();
	/** Stores all templates from this class in the current file. */
	public var templates(default, null):Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	/** if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height */
	public var useBounds:Bool;
	/** Set this to true if objects from this class have pivot properties that should be scaled, typically true for starling display objects. */
	public var usePivotScaling:Bool;
	/** The current visibility collection. */
	public var visibilityCollectionCurrent(default, null):ClassVisibilityCollection;
	/** The default visibility collection. */
	public var visibilityCollectionDefault(get, set):ClassVisibilityCollection;
	/** The visibility collection for the current file, if any. Highest priority. */
	public var visibilityCollectionFile(get, set):ClassVisibilityCollection;
	/** The visibility collection from editor settings, if any. Highest priority after 'visibilityCollectionFile'. */
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
	private var _objectToValEditorObject:ObjectMap<Dynamic, ValEditorObject> = new ObjectMap<Dynamic, ValEditorObject>();
	
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
	
	/**
	   Resets the class entirely, destroying objects and pooling collections and visibilities if needed.
	**/
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
		this.creationReadyEventName = null;
		this.creationReadyRegisterFunctionName = null;
		this.disposeFunction = null;
		this.disposeFunctionName = null;
		this.exportClassName = null;
		this.exportClassNameShort = null;
		this.exportClassPackage = null;
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
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
		this.isDisplayObjectOpenFL = false;
		#if starling
		this.isDisplayObjectStarling = false;
		#end
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
		this._objectToValEditorObject.clear();
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
	
	/**
	   Clears class and sends it to pool.
	**/
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	/**
	   Equivalent to the constructor when calling 'fromPool'.
	   @param	classReference
	   @param	className
	   @param	collection
	   @param	constructorCollection
	   @return
	**/
	private function setTo(classReference:Class<Dynamic>, className:String, collection:ExposedCollection, constructorCollection:ExposedCollection):ValEditorClass
	{
		this.classReference = classReference;
		this.className = className;
		this.collection = collection;
		this.constructorCollection = constructorCollection;
		return this;
	}
	
	/**
	   Determines which ClassVisibilityCollection to use as current.
	**/
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
	
	/**
	   Called by ChangeUpdateQueue, applies visibility
	**/
	public function changeUpdate():Void
	{
		applyVisibility();
	}
	
	/**
	   Applies the current ClassVisibilityCollection to templates and objects.
	**/
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
	
	/**
	   adds the specified superClassName
	   @param	superClassName
	**/
	public function addSuperClassName(superClassName:String):Void
	{
		this.superClassNames.push(superClassName);
	}
	
	/**
	   Returns a collection from this class
	   @return
	**/
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
	
	public function getConstructorCollection():ExposedCollection
	{
		if (this.constructorCollection == null) return null;
		
		var collection:ExposedCollection;
		if (this._constructorPool.length != 0)
		{
			collection = this._constructorPool.pop();
		}
		else
		{
			collection = this.constructorCollection.clone();
		}
		return collection;
	}
	
	public function makeObjectIDPreview():String
	{
		var objID:String = null;
		var num:Int = this._objectIDIndex;
		while (true)
		{
			num++;
			objID = this.exportClassName + num;
			if (!this._IDToObject.exists(objID)) break;
		}
		return objID;
	}
	
	/**
	   Creates and returns an object identifier.
	   @return
	**/
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
	
	/**
	   Tells whether the specified object identifier already exists for this class or not.
	   @param	id
	   @return
	**/
	public function objectIDExists(id:String):Bool
	{
		return this._IDToObject.exists(id);
	}
	
	/**
	   Creates and returns a possible template identifier (doesn't increase the internal template identifier index).
	   @return
	**/
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
	
	/**
	   Creates and returns a template identifier.
	   @return
	**/
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
	
	/**
	   Tells whether the specified template identifier already exists for this class or not.
	   @param	id
	   @return
	**/
	public function templateIDExists(id:String):Bool
	{
		return this._IDToTemplate.exists(id);
	}
	
	/**
	   Destroys all templates objects, called by ValEditor.reset before calling the reset function.
	**/
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
	
	/**
	   clears all UI containers, pools related collections, destroys templates and objects. Called by ValEditor.reset.
	**/
	public function reset():Void
	{
		var uiContainers:Array<DisplayObjectContainer> = [];
		// object containers
		for (uiContainer in this._containers.keys())
		{
			uiContainers.push(uiContainer);
		}
		for (uiContainer in uiContainers)
		{
			removeUIContainer(uiContainer);
		}
		uiContainers.resize(0);
		
		// constructor containers
		for (uiContainer in this._constructorContainers.keys())
		{
			uiContainers.push(uiContainer);
		}
		for (uiContainer in uiContainers)
		{
			removeConstructorUIContainer(uiContainer);
		}
		uiContainers.resize(0);
		
		// template containers
		for (uiContainer in this._templateContainers.keys())
		{
			uiContainers.push(uiContainer);
		}
		for (uiContainer in uiContainers)
		{
			removeTemplateUIContainer(uiContainer);
		}
		uiContainers.resize(0);
		
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
		this._objectToValEditorObject.clear();
		
		this._objectIDIndex = -1;
		this._templateIDIndex = -1;
		
		for (collection in this._collectionsToPool)
		{
			collection.pool();
		}
		this._collectionsToPool.clear();
	}
	
	/**
	   Adds the specified category to this class.
	   @param	category
	**/
	public function addCategory(category:String):Void
	{
		this.categories.push(category);
	}
	
	/**
	   Adds the specified object to this class.
	   @param	object
	**/
	public function addObject(object:ValEditorObject):Void
	{
		if (object.id == null) object.id = makeObjectID();
		this._IDToObject.set(object.id, object);
		this._objectToValEditorObject.set(object.object, object);
		this._numObjects++;
	}
	
	/**
	   Return the object with the specified id.
	   @param	id
	   @return
	**/
	public function getObjectByID(id:String):ValEditorObject
	{
		return this._IDToObject.get(id);
	}
	
	/**
	   Returns all objects (not template objects) added to this class
	   @param	objList
	   @return
	**/
	public function getObjectList(?objList:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (objList == null) objList = new Array<ValEditorObject>();
		
		for (obj in this._IDToObject)
		{
			objList.push(obj);
		}
		
		return objList;
	}
	
	/**
	   Returns the ValEditorObject for the specified object.
	   @param	object
	   @return
	**/
	public function getValEditObjectFromObject(object:Dynamic):ValEditorObject
	{
		return this._objectToValEditorObject.get(object);
	}
	
	/**
	   Removes the specified object from this class.
	   @param	object
	**/
	public function removeObject(object:ValEditorObject):Void
	{
		this._IDToObject.remove(object.id);
		this._objectToValEditorObject.remove(object.object);
		this._numObjects--;
	}
	
	/**
	   Removes the object with specified id from this class.
	   @param	id
	**/
	public function removeObjectByID(id:String):Void
	{
		removeObject(this._IDToObject.get(id));
	}
	
	/**
	   Adds specified template to this class.
	   @param	template
	**/
	public function addTemplate(template:ValEditorTemplate):Void 
	{
		this._IDToTemplate.set(template.id, template);
		this._numTemplates++;
		
		this.templates.push(template);
		
		template.addEventListener(RenameEvent.RENAMED, onTemplateRenamed);
	}
	
	/**
	   Returns the template with specified id.
	   @param	id
	   @return
	**/
	public function getTemplateByID(id:String):ValEditorTemplate
	{
		return this._IDToTemplate.get(id);
	}
	
	/**
	   Returns an Array with all templates added to this class.
	   @param	templateList
	   @return
	**/
	public function getTemplateList(?templateList:Array<ValEditorTemplate>):Array<ValEditorTemplate>
	{
		if (templateList == null) templateList = new Array<ValEditorTemplate>();
		
		for (template in _IDToTemplate)
		{
			templateList.push(template);
		}
		
		return templateList;
	}
	
	/**
	   Removes the specified template from this class.
	   @param	template
	**/
	public function removeTemplate(template:ValEditorTemplate):Void 
	{
		if (this._IDToTemplate.remove(template.id))
		{
			this._numTemplates--;
		}
		
		this.templates.remove(cast template);
		
		template.removeEventListener(RenameEvent.RENAMED, onTemplateRenamed);
	}
	
	/**
	   Removes the template with specified id from this class.
	   @param	id
	**/
	public function removeTemplateByID(id:String):Void
	{
		removeTemplate(this._IDToTemplate.get(id));
	}
	
	/**
	   Triggered when a template added to this class dispatches a RenameEvent.
	   @param	evt
	**/
	private function onTemplateRenamed(evt:RenameEvent):Void
	{
		var template:ValEditorTemplate = cast evt.target;
		this._IDToTemplate.remove(evt.previousNameOrID);
		this._IDToTemplate.set(template.id, template);
	}
	
	/**
	   Adds the specified UI container (typically a Feathers ScrollContainer or LayoutGroup) to this class, and assigns the specified collection to it (or creates one if left null).
	   This is used by ValEditor.edit function.
	   @param	container
	   @param	object
	   @param	collection
	   @param	parentValue
	   @return
	**/
	public function addUIContainer(uiContainer:DisplayObjectContainer, object:Dynamic, collection:ExposedCollection = null, parentValue:ExposedValueWithCollection = null):ExposedCollection
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
		this._containers[uiContainer] = collection;
		collection.parentValue = parentValue;
		collection.uiContainer = uiContainer;
		
		return collection;
	}
	
	/**
	   Adds the specified constructor UI container (typically a Feathers ScrollContainer or LayoutGroup) to this class, and assigns a constructor collection to it.
	   This is used by ValEditor.editConstructor function.
	   @param	container
	   @return
	**/
	public function addConstructorUIContainer(uiContainer:DisplayObjectContainer):ExposedCollection
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
		
		this._constructorContainers[uiContainer] = collection;
		collection.uiContainer = uiContainer;
		
		return collection;
	}
	
	/**
	   Adds the specified template UI container (typically a Feathers ScollContainer or LayoutGroup) to this class, and assigns the template's collection to it.
	   This is used by ValEditor.editTemplate function.
	   @param	container
	   @param	template
	**/
	public function addTemplateUIContainer(uiContainer:DisplayObjectContainer, template:ValEditorTemplate):Void
	{
		this._templateContainers[uiContainer] = template;
		template.collection.uiContainer = uiContainer;
	}
	
	/**
	   Removes the specified UI container from this class, whether it's a regular one, a constructor one or a template one. Also pools the associated collection if needed.
	   This is used by ValEditor.clearUIContainer function.
	   @param	uiContainer
	**/
	public function removeUIContainer(uiContainer:DisplayObjectContainer):Void
	{
		var collection:ExposedCollection = this._containers[uiContainer];
		if (collection != null)
		{
			this._containers.remove(uiContainer);
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
		
		if (this._constructorContainers.exists(uiContainer))
		{
			removeConstructorUIContainer(uiContainer);
			return;
		}
		
		if (this._templateContainers.exists(uiContainer))
		{
			removeTemplateUIContainer(uiContainer);
			return;
		}
	}
	
	/**
	   Removes the specified constructor UI container from this class and pools the associated collection.
	   @param	uiContainer
	**/
	public function removeConstructorUIContainer(uiContainer:DisplayObjectContainer):Void
	{
		var collection:ExposedCollection = this._constructorContainers[uiContainer];
		if (collection != null)
		{
			this._constructorContainers.remove(uiContainer);
			collection.uiContainer = null;
			this._constructorPool.push(collection);
		}
	}
	
	/**
	   Removes the specified template UI container from this class.
	   @param	uiContainer
	**/
	public function removeTemplateUIContainer(uiContainer:DisplayObjectContainer):Void
	{
		var template:ValEditorTemplate = this._templateContainers[uiContainer];
		if (template != null)
		{
			this._templateContainers.remove(uiContainer);
			template.collection.uiContainer = null;
		}
	}
	
	public function loadComplete():Void
	{
		
	}
	
	/**
	   Loads templates for this class from json save data.
	   @param	json
	**/
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
	
	/**
	   Saves templates data for this class to json.
	   @param	json
	   @return
	**/
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
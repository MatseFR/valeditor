package valeditor;
import feathers.data.ArrayCollection;
import haxe.Constraints.Function;
import juggler.animation.Juggler;
import openfl.Lib;
import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.EventType;
import valedit.ExposedCollection;
import valedit.DisplayObjectType;
import valedit.ValEdit;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
import valedit.ui.IValueUI;
import valedit.utils.RegularPropertyName;
import valedit.value.base.ExposedValue;
import valedit.value.base.ExposedValueWithChildren;
import valeditor.editor.Selection;
import valeditor.editor.ViewPort;
import inputAction.Input;
import inputAction.controllers.KeyboardController;
import valeditor.editor.change.ChangeUpdateQueue;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.drag.LibraryDragManager;
import valeditor.events.EditorEvent;
import valeditor.events.TemplateEvent;
import valeditor.input.LiveInputActionManager;
import valeditor.ui.InteractiveFactories;
import valeditor.ui.feathers.data.StringData;
import valeditor.utils.ArraySort;

/**
 * ...
 * @author Matse
 */
@:access(valedit.ValEdit)
class ValEditor
{
	static public var currentContainer(get, set):ValEditorContainer;
	static public var eventDispatcher(get, never):EventDispatcher;
	static public var file(default, null):ValEditorFile = new ValEditorFile();
	static public var input(default, null):Input = new Input();
	static public var keyboardController(default, null):KeyboardController;
	static public var libraryDragManager(default, null):LibraryDragManager;
	static public var rootContainer(get, set):ValEditorContainer;
	static public var rootScene(get, set):DisplayObjectContainer;
	#if starling
	static public var rootSceneStarling(get, set):starling.display.DisplayObjectContainer;
	#end
	static public var selection(default, null):Selection = new Selection();
	static public var uiContainerDefault:DisplayObjectContainer;
	static public var viewPort(default, null):ViewPort = new ViewPort();
	
	static public var categoryCollection(default, null):ArrayCollection<StringData> = new ArrayCollection<StringData>();
	static public var classCollection(default, null):ArrayCollection<StringData> = new ArrayCollection<StringData>();
	static public var templateCollection(default, null):ArrayCollection<ValEditorTemplate> = new ArrayCollection<ValEditorTemplate>();
	
	static public var isMouseOverUI:Bool;
	static public var juggler(default, null):Juggler;
	
	static private var _currentContainer:ValEditorContainer;
	static private function get_currentContainer():ValEditorContainer
	{
		if (_currentContainer == null) return _rootContainer;
		return _currentContainer;
	}
	static private function set_currentContainer(value:ValEditorContainer):ValEditorContainer
	{
		if (value == _currentContainer) return value;
		if (_currentContainer != null)
		{
			_currentContainer.close();
			EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_CLOSE, _currentContainer);
		}
		_currentContainer = value;
		if (_currentContainer != null)
		{
			_currentContainer.rootContainer = _rootScene;
			#if starling
			_currentContainer.rootContainerStarling = _rootSceneStarling;
			#end
			_currentContainer.open();
			EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_OPEN, _currentContainer);
		}
		return _currentContainer;
	}
	
	static private var _eventDispatcher:EventDispatcher = new EventDispatcher();
	static private function get_eventDispatcher():EventDispatcher { return _eventDispatcher; }
	
	static private var _rootContainer:ValEditorContainer;
	static private function get_rootContainer():ValEditorContainer { return _rootContainer; }
	static private function set_rootContainer(value:ValEditorContainer):ValEditorContainer
	{
		if (value == _rootContainer) return value;
		if (_rootContainer != null)
		{
			viewPort.removeEventListener(Event.CHANGE, onViewPortChange);
			_rootContainer.close();
			EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_CLOSE, _currentContainer);
		}
		_rootContainer = value;
		if (_rootContainer != null)
		{
			viewPort.addEventListener(Event.CHANGE, onViewPortChange);
			_rootContainer.juggler = juggler;
			_rootContainer.rootContainer = _rootScene;
			#if starling
			_rootContainer.rootContainerStarling = _rootSceneStarling;
			#end
			_rootContainer.x = viewPort.x;
			_rootContainer.y = viewPort.y;
			_rootContainer.viewWidth = viewPort.width;
			_rootContainer.viewHeight = viewPort.height;
			_rootContainer.adjustView();
			_rootContainer.open();
			EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_OPEN, _currentContainer);
		}
		return _rootContainer;
	}
	
	static private var _rootScene:DisplayObjectContainer;
	static private function get_rootScene():DisplayObjectContainer { return _rootScene; }
	static private function set_rootScene(value:DisplayObjectContainer):DisplayObjectContainer
	{
		if (_rootContainer != null)
		{
			_rootContainer.rootContainer = value;
		}
		return _rootScene = value;
	}
	
	#if starling
	static private var _rootSceneStarling:starling.display.DisplayObjectContainer;
	static private function get_rootSceneStarling():starling.display.DisplayObjectContainer { return _rootSceneStarling; }
	static private function set_rootSceneStarling(value:starling.display.DisplayObjectContainer):starling.display.DisplayObjectContainer
	{
		if (_rootContainer != null)
		{
			_rootContainer.rootContainerStarling = value;
		}
		return _rootSceneStarling = value;
	}
	#end
	
	static private function onViewPortChange(evt:Event):Void
	{
		_rootContainer.x = viewPort.x;
		_rootContainer.y = viewPort.y;
		_rootContainer.viewWidth = viewPort.width;
		_rootContainer.viewHeight = viewPort.height;
		_rootContainer.adjustView();
	}
	
	static private var _categoryToClassCollection:Map<String, ArrayCollection<StringData>> = new Map<String, ArrayCollection<StringData>>();
	static private var _categoryToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _categoryToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	static private var _classToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _classToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	
	static private var _categoryToStringData:Map<String, StringData> = new Map<String, StringData>();
	static private var _classNameToStringData:Map<String, StringData> = new Map<String, StringData>();
	
	static private var _classMap:Map<String, ValEditorClass> = new Map<String, ValEditorClass>();
	static private var _displayMap:Map<DisplayObjectContainer, ValEditClass> = new Map<DisplayObjectContainer, ValEditClass>();
	static private var _uiClassMap:Map<String, Void->IValueUI> = new Map<String, Void->IValueUI>();
	
	static private var _liveActionManager:LiveInputActionManager;
	static private var _changeUpdateQueue:ChangeUpdateQueue;
	
	static public function init():Void
	{
		keyboardController = new KeyboardController(Lib.current.stage);
		input.addController(keyboardController);
		_liveActionManager = new LiveInputActionManager();
		_changeUpdateQueue = new ChangeUpdateQueue();
		juggler = new Juggler();
		Juggler.start();
		Juggler.root.add(juggler);
		juggler.add(input);
		juggler.add(_liveActionManager);
		juggler.add(_changeUpdateQueue);
		libraryDragManager = new LibraryDragManager();
		
		categoryCollection.sortCompareFunction = ArraySort.stringData;
		classCollection.sortCompareFunction = ArraySort.stringData;
		templateCollection.sortCompareFunction = ArraySort.template;
	}
	
	/** Creates an empty "new file" but does not clear exposed data */
	static public function reset():Void
	{
		file.clear();
		_rootContainer.clear();
	}
	
	static public function getClassSettings(type:Class<Dynamic>, settings:ValEditorClassSettings = null):ValEditorClassSettings
	{
		if (settings == null) settings = new ValEditorClassSettings();
		
		ValEdit.getClassSettings(type, settings);
		
		getClassInteractiveSettings(type, settings);
		
		#if starling
		if (settings.isDisplayObject && settings.displayObjectType == DisplayObjectType.STARLING)
		{
			settings.hasRadianRotation = true;
		}
		#end
		
		return settings;
	}
	
	static public function getClassInteractiveSettings(type:Class<Dynamic>, settings:ValEditorClassSettings):Void
	{
		if (settings.isDisplayObject)
		{
			switch (settings.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					settings.interactiveFactory = InteractiveFactories.openFL_default;
				
				case DisplayObjectType.STARLING :
					settings.interactiveFactory = InteractiveFactories.starling_default;
				
				default :
					// nothing
			}
		}
	}
	
	static public function registerClass(type:Class<Dynamic>, settings:ValEditorClassSettings):ValEditorClass
	{
		var className:String = Type.getClassName(type);
		if (_classMap.exists(className))
		{
			trace("ValEditor.registerClass ::: Class " + className + " already registered");
			return null;
		}
		
		var strClass:StringData = _classNameToStringData.get(className);
		if (strClass == null)
		{
			strClass = StringData.fromPool(className);
			_classNameToStringData.set(className, strClass);
		}
		
		var v:ValEditorClass = ValEditorClass.fromPool(type);
		
		var result:ValEditClass = ValEdit.registerClass(type, settings, v);
		if (result == null)
		{
			v.pool();
			return null;
		}
		
		_classMap.set(className, v);
		
		v.canBeCreated = settings.canBeCreated;
		for (category in settings.categories)
		{
			v.addCategory(category);
		}
		v.hasRadianRotation = settings.hasRadianRotation;
		v.interactiveFactory = settings.interactiveFactory;
		
		v.hasPivotProperties = checkForClassProperty(v, RegularPropertyName.PIVOT_X);
		v.hasScaleProperties = checkForClassProperty(v, RegularPropertyName.SCALE_X);
		v.hasTransformProperty = checkForClassProperty(v, RegularPropertyName.TRANSFORM);
		v.hasTransformationMatrixProperty = checkForClassProperty(v, RegularPropertyName.TRANSFORMATION_MATRIX);
		v.hasVisibleProperty = checkForClassProperty(v, RegularPropertyName.VISIBLE);
		
		var objCollection:ArrayCollection<ValEditorObject>;
		var strCollection:ArrayCollection<StringData>;
		var templateCollection:ArrayCollection<ValEditorTemplate>;
		var stringData:StringData;
		
		for (category in settings.categories)
		{
			if (!_categoryToClassCollection.exists(category))
			{
				stringData = StringData.fromPool(category);
				_categoryToStringData.set(category, stringData);
				categoryCollection.add(stringData);
				
				strCollection = new ArrayCollection<StringData>();
				strCollection.sortCompareFunction = ArraySort.stringData;
				_categoryToClassCollection.set(category, strCollection);
				
				objCollection = new ArrayCollection<ValEditorObject>();
				objCollection.sortCompareFunction = ArraySort.object;
				_categoryToObjectCollection.set(category, objCollection);
				
				templateCollection = new ArrayCollection<ValEditorTemplate>();
				templateCollection.sortCompareFunction = ArraySort.template;
				_categoryToTemplateCollection.set(category, templateCollection);
			}
			strCollection = _categoryToClassCollection.get(category);
			strCollection.add(strClass);
		}
		
		if (!_classToObjectCollection.exists(className))
		{
			objCollection = new ArrayCollection<ValEditorObject>();
			objCollection.sortCompareFunction = ArraySort.object;
			_classToObjectCollection.set(className, objCollection);
		}
		
		if (!_classToTemplateCollection.exists(className))
		{
			templateCollection = new ArrayCollection<ValEditorTemplate>();
			templateCollection.sortCompareFunction = ArraySort.template;
			_classToTemplateCollection.set(className, templateCollection);
		}
		
		for (superName in v.superClassNames)
		{
			if (!_classNameToStringData.exists(superName))
			{
				_classNameToStringData.set(superName, StringData.fromPool(superName));
			}
			
			if (!_classToObjectCollection.exists(superName))
			{
				objCollection = new ArrayCollection<ValEditorObject>();
				objCollection.sortCompareFunction = ArraySort.object;
				_classToObjectCollection.set(superName, objCollection);
			}
			
			if (!_classToTemplateCollection.exists(superName))
			{
				templateCollection = new ArrayCollection<ValEditorTemplate>();
				templateCollection.sortCompareFunction = ArraySort.template;
				_classToTemplateCollection.set(superName, templateCollection);
			}
		}
		
		if (v.canBeCreated)
		{
			classCollection.add(strClass);
		}
		
		return v;
	}
	
	static public function registerClassSimple(type:Class<Dynamic>, canBeCreated:Bool = true, objectCollection:ExposedCollection, templateCollection:ExposedCollection = null,
											   constructorCollection:ExposedCollection = null, categories:Array<String> = null):ValEditorClass
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		settings.canBeCreated = canBeCreated;
		settings.objectCollection = objectCollection;
		settings.templateCollection = templateCollection;
		settings.constructorCollection = constructorCollection;
		getClassSettings(type, settings);
		
		if (categories != null)
		{
			for (category in categories)
			{
				settings.addCategory(category);
			}
		}
		
		var v:ValEditorClass = registerClass(type, settings);
		
		settings.pool();
		return v;
	}
	
	static public function unregisterClass(type:Class<Dynamic>):Void
	{
		var className:String = Type.getClassName(type);
		if (!_classMap.exists(className))
		{
			trace("ValEditor.unregisterClass ::: Class " + className + " not registered");
			return;
		}
		
		var valClass:ValEditorClass = _classMap.get(className);
		_classMap.remove(className);
		var strClass:StringData = _classNameToStringData.get(className);
		_classNameToStringData.remove(className);
		
		var strCategory:StringData;
		var strCollection:ArrayCollection<StringData>;
		for (category in valClass.categories)
		{
			strCollection = _categoryToClassCollection.get(category);
			strCollection.remove(strClass);
			if (strCollection.length == 0)
			{
				// no more class associated with this category : remove category
				strCategory = _categoryToStringData.get(category);
				categoryCollection.remove(strCategory);
				_categoryToClassCollection.remove(category);
				_categoryToObjectCollection.remove(category);
				_categoryToTemplateCollection.remove(category);
				
				strCategory.pool();
				_categoryToStringData.remove(category);
			}
		}
		
		var objectList:Array<ValEditObject> = valClass.getObjectList();
		
		if (valClass.canBeCreated)
		{
			for (obj in objectList)
			{
				destroyObjectInternal(cast obj);
			}
			
			classCollection.remove(strClass);
			_classToObjectCollection.remove(className);
		}
		else
		{
			for (obj in objectList)
			{
				unregisterObjectInternal(cast obj);
			}
		}
		
		_classNameToStringData.remove(className);
		strClass.pool();
	}
	
	static public function registerUIClass(exposedValueClass:Class<Dynamic>, factory:Void->IValueUI):Void
	{
		var className:String = Type.getClassName(exposedValueClass);
		if (_uiClassMap.exists(className))
		{
			trace("ValEdit.registerUIClass ::: Class " + className + " already registered");
			return;
		}
		
		_uiClassMap[className] = factory;
	}
	
	static public function unregisterUIClass(exposedValueClass:Class<Dynamic>):Void
	{
		var className:String = Type.getClassName(exposedValueClass);
		if (!_uiClassMap.exists(className))
		{
			trace("ValEdit.unregisterUIClass ::: Class " + className + " not registered");
		}
		
		_uiClassMap.remove(className);
	}
	
	/**
	   
	   @param	object	instance of a registered Class
	   @param	uiContainer	if left null uiContainerDefault is used
	**/
	static public function edit(object:Dynamic, ?container:DisplayObjectContainer, ?parentValue:ExposedValueWithChildren):ExposedCollection
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEdit.edit ::: null container");
		}
		
		clearContainer(container);
		
		if (object == null) return null;
		
		var clss:Class<Dynamic> = Type.getClass(object);
		var className:String = Type.getClassName(clss);
		var collection:ExposedCollection = null;
		var valClass:ValEditClass = _classMap[className];
		
		if (Std.isOfType(object, ValEditObject))
		{
			valClass = cast(object, ValEditObject).clss;
			collection = cast(object, ValEditObject).collection;
		}
		else
		{
			clss = Type.getClass(object);
			className = Type.getClassName(clss);
			valClass = _classMap[className];
		}
		
		if (valClass != null)
		{
			_displayMap[container] = valClass;
			return valClass.addContainer(container, object, collection, parentValue);
		}
		else
		{
			while (true)
			{
				clss = Type.getSuperClass(clss);
				if (clss == null) break;
				className = Type.getClassName(clss);
				valClass = _classMap[className];
				if (valClass != null)
				{
					_displayMap[container] = valClass;
					return valClass.addContainer(container, object, collection, parentValue);
				}
			}
			throw new Error("ValEdit.edit ::: unknown Class " + Type.getClassName(Type.getClass(object)));
		}
	}
	
	static public function editConstructor(className:String, ?container:DisplayObjectContainer):ExposedCollection
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEdit.editConstructor ::: null container");
		}
		
		clearContainer(container);
		
		if (className == null) return null;
		
		var valClass:ValEditClass = _classMap[className];
		if (valClass != null)
		{
			if (valClass.constructorCollection != null)
			{
				_displayMap[container] = valClass;
				return valClass.addConstructorContainer(container);
			}
			else
			{
				return null;
			}
		}
		else
		{
			throw new Error("ValEdit.edit ::: unknown Class " + className);
		}
	}
	
	/**
	   
	   @param	a registered Class
	   @param	uiContainer	if left null uiContainerDefault is used
	**/
	static public function editConstructorWithClass<T>(clss:Class<T>, ?container:DisplayObjectContainer):ExposedCollection
	{
		return editConstructor(Type.getClassName(clss), container);
	}
	
	
	static public function editTemplate(template:ValEditTemplate, ?container:DisplayObjectContainer):Void
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEdit.editTemplate ::: null container");
		}
		
		clearContainer(container);
		
		if (template == null) return;
		
		var valClass:ValEditClass = _classMap.get(template.className);
		_displayMap[container] = valClass;
		valClass.addTemplateContainer(container, template);
	}
	
	/**
	   
	   @param	container
	**/
	static public function clearContainer(?container:DisplayObjectContainer):Void
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEdit.clearContainer ::: null container");
		}
		
		var valClass:ValEditClass = _displayMap[container];
		if (valClass != null)
		{
			valClass.removeContainer(container);
			_displayMap.remove(container);
		}
	}
	
	/**
	   
	   @param	exposedValue
	   @return
	**/
	static public function toUIControl<T:ExposedValue>(exposedValue:T):IValueUI
	{
		var clss:Class<T> = Type.getClass(exposedValue);
		var className:String = Type.getClassName(clss);
		var control:IValueUI = _uiClassMap[className]();
		control.exposedValue = cast exposedValue;
		cast(exposedValue, ExposedValue).uiControl = control;
		return control;
	}
	
	static public function createObjectWithClass(clss:Class<Dynamic>, ?id:String, ?params:Array<Dynamic>, ?collection:ExposedCollection):ValEditorObject
	{
		return createObjectWithClassName(Type.getClassName(clss), id, params, collection);
	}
	
	static public function createObjectWithClassName(className:String, ?id:String, ?params:Array<Dynamic>, ?collection:ExposedCollection):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var valObject:ValEditorObject = new ValEditorObject(valClass, id);
		
		ValEdit.createObjectWithClassName(className, id, params, valObject, collection);
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
			valObject.hasPivotProperties = valClass.hasPivotProperties;
			valObject.hasScaleProperties = valClass.hasScaleProperties;
			valObject.hasTransformProperty = valClass.hasTransformProperty;
			valObject.hasTransformationMatrixProperty = valClass.hasTransformationMatrixProperty;
			valObject.hasVisibleProperty = valClass.hasVisibleProperty;
			valObject.hasRadianRotation = valClass.hasRadianRotation;
		}
		
		registerObjectInternal(valObject);
		
		return valObject;
	}
	
	static public function createTemplateWithClass(clss:Class<Dynamic>, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		return createTemplateWithClassName(Type.getClassName(clss), id, constructorCollection);
	}
	
	static public function createTemplateWithClassName(className:String, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var template:ValEditorTemplate = ValEditorTemplate.fromPool(valClass, id, null, constructorCollection);
		
		ValEdit.createTemplateWithClassName(className, id, constructorCollection, template);
		
		template.object = createObjectWithTemplate(template, template.collection, false);
		template.object.collection.readValues();
		
		registerTemplateInternal(template);
		
		return template;
	}
	
	static public function createObjectWithTemplate(template:ValEditorTemplate, ?id:String, ?collection:ExposedCollection, registerToTemplate:Bool = true):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(template.className);
		var valObject:ValEditorObject = new ValEditorObject(valClass, id);
		
		valObject.hasPivotProperties = valClass.hasPivotProperties;
		valObject.hasScaleProperties = valClass.hasScaleProperties;
		valObject.hasTransformProperty = valClass.hasTransformProperty;
		valObject.hasTransformationMatrixProperty = valClass.hasTransformationMatrixProperty;
		valObject.hasVisibleProperty = valClass.hasVisibleProperty;
		valObject.hasRadianRotation = valClass.hasRadianRotation;
		
		ValEdit.createObjectWithTemplate(template, id, valObject, collection, registerToTemplate);
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
		}
		
		registerObjectInternal(valObject);
		
		return valObject;
	}
	
	static public function cloneObject(object:ValEditObject, ?id:String):ValEditObject
	{
		var newObject:ValEditObject;
		if (object.template != null)
		{
			newObject = createObjectWithTemplate(cast object.template, id, object.collection.clone(true));
		}
		else
		{
			newObject = createObjectWithClassName(object.className, id, object.collection.clone(true));
		}
		return newObject;
	}
	
	static private function registerObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.registerObjectInternal(valObject);
		
		var objCollection:ArrayCollection<ValEditorObject> = _classToObjectCollection.get(valObject.className);
		objCollection.add(valObject);
		
		for (className in valObject.clss.superClassNames)
		{
			objCollection = _classToObjectCollection.get(className);
			objCollection.add(valObject);
		}
		
		for (category in cast(valObject.clss, ValEditorClass).categories)
		{
			objCollection = _categoryToObjectCollection.get(category);
			objCollection.add(valObject);
		}
	}
	
	static private function registerTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.registerTemplateInternal(template);
		
		template.addEventListener(TemplateEvent.INSTANCE_ADDED, onTemplateInstanceAdded);
		template.addEventListener(TemplateEvent.INSTANCE_REMOVED, onTemplateInstanceRemoved);
		template.addEventListener(TemplateEvent.RENAMED, onTemplateRenamed);
		templateCollection.add(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.className);
		collection.add(template);
		
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.add(template);
		}
		
		for (category in cast(template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			collection.add(template);
		}
	}
	
	static public function destroyObject(valObject:ValEditorObject):Void
	{
		destroyObjectInternal(valObject);
	}
	
	static private function destroyObjectInternal(valObject:ValEditorObject):Void
	{
		if (valObject.clss.disposeFunctionName != null)
		{
			var func:Function = Reflect.field(valObject.object, valObject.clss.disposeFunctionName);
			Reflect.callMethod(valObject.object, func, []);
		}
		else if (valObject.clss.disposeFunction != null)
		{
			Reflect.callMethod(valObject.clss.disposeFunction, valObject.clss.disposeFunction, [valObject.object]);
		}
		
		if (valObject.template != null)
		{
			valObject.template.removeInstance(valObject);
		}
		
		unregisterObjectInternal(valObject);
		
		valObject.pool();
	}
	
	static private function unregisterObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.unregisterObjectInternal(valObject);
		
		if (valObject.container != null)
		{
			valObject.container.remove(valObject);
		}
		
		var objCollection:ArrayCollection<ValEditorObject> = _classToObjectCollection.get(valObject.className);
		objCollection.remove(valObject);
		
		for (className in valObject.clss.superClassNames)
		{
			objCollection = _classToObjectCollection.get(className);
			objCollection.remove(valObject);
		}
		
		for (category in cast(valObject.clss, ValEditorClass).categories)
		{
			objCollection = _categoryToObjectCollection.get(category);
			objCollection.remove(valObject);
		}
	}
	
	static public function destroyTemplate(template:ValEditorTemplate):Void
	{
		destroyTemplateInternal(template);
	}
	
	static private function destroyTemplateInternal(template:ValEditorTemplate):Void
	{
		destroyObject(cast template.object);
		
		unregisterTemplateInternal(template);
		
		template.pool();
	}
	
	static private function unregisterTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.unregisterTemplateInternal(template);
		
		template.removeEventListener(TemplateEvent.INSTANCE_ADDED, onTemplateInstanceAdded);
		template.removeEventListener(TemplateEvent.INSTANCE_REMOVED, onTemplateInstanceRemoved);
		template.removeEventListener(TemplateEvent.RENAMED, onTemplateRenamed);
		templateCollection.remove(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.className);
		collection.remove(template);
		
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.remove(template);
		}
		
		for (category in cast(template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			collection.remove(template);
		}
	}
	
	static public function checkForClassProperty(clss:ValEditorClass, propertyName:String):Bool
	{
		if (clss.objectCollection.hasValue(propertyName))
		{
			return true;
		}
		else
		{
			return clss.propertyMap.hasPropertyRegular(propertyName);
		}
	}
	
	static public function getCategoryStringData(category:String):StringData
	{
		return _categoryToStringData.get(category);
	}
	
	static public function getClassCollectionForCategory(category:String):ArrayCollection<StringData>
	{
		return _categoryToClassCollection.get(category);
	}
	
	static public function getClassStringData(className:String):StringData
	{
		return _classNameToStringData.get(className);
	}
	
	static public function getValEditClassByClass(clss:Class<Dynamic>):ValEditorClass
	{
		return _classMap.get(Type.getClassName(clss));
	}
	
	static public function getValEditClassByClassName(className:String):ValEditorClass
	{
		return _classMap.get(className);
	}
	
	static public function getObjectCollectionForClass(clss:Class<Dynamic>):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(Type.getClassName(clss));
	}
	
	static public function getObjectCollectionForClassName(className:String):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(className);
	}
	
	static public function getTemplateCollectionForClassName(className:String):ArrayCollection<ValEditorTemplate>
	{
		return _classToTemplateCollection.get(className);
	}
	
	static public function getTemplateCollectionForCategory(category:String):ArrayCollection<ValEditorTemplate>
	{
		return _categoryToTemplateCollection.get(category);
	}
	
	static public function addEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void
	{
		_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	static public function dispatchEvent(event:Event):Void
	{
		_eventDispatcher.dispatchEvent(event);
	}
	
	static public function hasEventListener(type:String):Bool
	{
		return _eventDispatcher.hasEventListener(type);
	}
	
	static public function removeEventListener<T>(type:EventType<T>, listener:T->Void, useCapture:Bool = false):Void
	{
		_eventDispatcher.removeEventListener(type, listener, useCapture);
	}
	
	static public function willTrigger(type:String):Bool
	{
		return _eventDispatcher.willTrigger(type);
	}
	
	static public function createContainer():ValEditorContainer
	{
		var container:ValEditorContainer = ValEditorContainer.fromPool();
		container.numFrames = 120;
		container.frameIndex = 0;
		var layer:ValEditorLayer = createLayer();
		container.addLayer(layer);
		return container;
	}
	
	static public function createLayer():ValEditorLayer
	{
		var layer:ValEditorLayer = ValEditorLayer.fromPool(createTimeLine());
		return layer;
	}
	
	static public function createTimeLine():ValEditorTimeLine
	{
		var timeLine:ValEditorTimeLine = ValEditorTimeLine.fromPool(120);
		timeLine.frameIndex = 0;
		timeLine.insertKeyFrame();
		return timeLine;
	}
	
	static public function insertFrame():Void
	{
		if (currentContainer == null) return;
		if (currentContainer.isPlaying) return;
		if (currentContainer.currentLayer == null) return;
		
		cast(currentContainer.currentLayer.timeLine, ValEditorTimeLine).insertFrame();
	}
	
	static public function insertKeyFrame():Void
	{
		if (currentContainer == null) return;
		if (currentContainer.isPlaying) return;
		if (currentContainer.currentLayer == null) return;
		
		cast(currentContainer.currentLayer.timeLine, ValEditorTimeLine).insertKeyFrame();
	}
	
	static public function removeFrame():Void
	{
		if (currentContainer == null) return;
		if (currentContainer.isPlaying) return;
		if (currentContainer.currentLayer == null) return;
		
		cast(currentContainer.currentLayer.timeLine, ValEditorTimeLine).removeFrame();
	}
	
	static public function removeKeyFrame():Void
	{
		if (currentContainer == null) return;
		if (currentContainer.isPlaying) return;
		if (currentContainer.currentLayer == null) return;
		
		cast(currentContainer.currentLayer.timeLine, ValEditorTimeLine).removeKeyFrame();
	}
	
	static public function firstFrame():Void
	{
		if (currentContainer.isPlaying)
		{
			currentContainer.stop();
		}
		currentContainer.frameIndex = 0;
	}
	
	static public function lastFrame():Void
	{
		if (currentContainer.isPlaying)
		{
			currentContainer.stop();
		}
		currentContainer.frameIndex = currentContainer.lastFrameIndex;
	}
	
	static public function nextFrame():Void
	{
		if (currentContainer.isPlaying)
		{
			currentContainer.stop();
		}
		if (currentContainer.frameIndex < currentContainer.lastFrameIndex)
		{
			currentContainer.frameIndex++;
		}
	}
	
	static public function previousFrame():Void
	{
		if (currentContainer.isPlaying)
		{
			currentContainer.stop();
		}
		if (currentContainer.frameIndex != 0)
		{
			currentContainer.frameIndex--;
		}
	}
	
	static public function playStop():Void
	{
		if (!currentContainer.isPlaying)
		{
			currentContainer.timeLine.updateLastFrameIndex();
			if (currentContainer.frameIndex >= currentContainer.lastFrameIndex)
			{
				currentContainer.frameIndex = 0;
			}
			currentContainer.play();
		}
		else
		{
			currentContainer.stop();
		}
	}
	
	static private function onTemplateInstanceAdded(evt:TemplateEvent):Void
	{
		templateCollection.updateAt(templateCollection.indexOf(cast evt.template));
	}
	
	static private function onTemplateInstanceRemoved(evt:TemplateEvent):Void
	{
		templateCollection.updateAt(templateCollection.indexOf(cast evt.template));
	}
	
	static private function onTemplateRenamed(evt:TemplateEvent):Void
	{
		templateCollection.updateAt(templateCollection.indexOf(cast evt.template));
	}
	
	static public function registerForChangeUpdate(object:IChangeUpdate):Void
	{
		_changeUpdateQueue.add(object);
	}
	
}
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
import valedit.util.RegularPropertyName;
import valeditor.editor.Selection;
import valeditor.editor.ViewPort;
import inputAction.Input;
import inputAction.controllers.KeyboardController;
import valeditor.events.EditorEvent;
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
	static public var rootContainer(get, set):ValEditorContainer;
	static public var rootScene(get, set):DisplayObjectContainer;
	#if starling
	static public var rootSceneStarling(get, set):starling.display.DisplayObjectContainer;
	#end
	static public var selection(default, null):Selection = new Selection();
	static public var viewPort(default, null):ViewPort = new ViewPort();
	
	static public var categoryCollection(default, null):ArrayCollection<StringData> = new ArrayCollection<StringData>();
	static public var classCollection(default, null):ArrayCollection<StringData> = new ArrayCollection<StringData>();
	static public var templateCollection(default, null):ArrayCollection<ValEditorTemplate> = new ArrayCollection<ValEditorTemplate>();
	
	
	
	static public var isMouseOverUI:Bool;
	
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
	
	static public function init():Void
	{
		keyboardController = new KeyboardController(Lib.current.stage);
		input.addController(keyboardController);
		Juggler.start();
		Juggler.root.add(input);
		
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
	
	static public function registerClass(type:Class<Dynamic>, collection:ExposedCollection, canBeCreated:Bool = true, ?isDisplayObject:Bool, ?displayObjectType:Int, ?constructorCollection:ExposedCollection, ?settings:ValEditorClassSettings, ?categoryList:Array<String>):ValEditorClass
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
		
		var v:ValEditorClass = new ValEditorClass();
		
		var result:ValEditClass = ValEdit.registerClass(type, collection, canBeCreated, isDisplayObject, displayObjectType, constructorCollection, settings, categoryList, v);
		if (result == null) return null;
		
		_classMap.set(className, v);
		
		if (settings != null)
		{
			v.interactiveFactory = settings.interactiveFactory;
			v.hasRadianRotation = settings.hasRadianRotation;
		}
		else
		{
			v.hasRadianRotation = v.isDisplayObject && v.displayObjectType == DisplayObjectType.STARLING;
		}
		
		if (v.isDisplayObject && v.interactiveFactory == null)
		{
			switch (v.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					v.interactiveFactory = InteractiveFactories.openFL_default;
				
				#if starling
				case DisplayObjectType.STARLING :
					v.interactiveFactory = InteractiveFactories.starling_default;
				#end
				
				default :
					throw new Error("ValEditor.registerClass ::: unknown display object type " + v.displayObjectType);
			}
		}
		
		v.hasPivotProperties = checkForClassProperty(v, RegularPropertyName.PIVOT_X);
		v.hasScaleProperties = checkForClassProperty(v, RegularPropertyName.SCALE_X);
		v.hasTransformProperty = checkForClassProperty(v, RegularPropertyName.TRANSFORM);
		v.hasTransformationMatrixProperty = checkForClassProperty(v, RegularPropertyName.TRANSFORMATION_MATRIX);
		
		var objCollection:ArrayCollection<ValEditorObject>;
		var strCollection:ArrayCollection<StringData>;
		var templateCollection:ArrayCollection<ValEditorTemplate>;
		var stringData:StringData;
		
		if (categoryList != null)
		{
			for (category in categoryList)
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
		
		if (canBeCreated)
		{
			classCollection.add(strClass);
		}
		
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
	
	static public function createObjectWithClass(clss:Class<Dynamic>, ?id:String, ?params:Array<Dynamic>):ValEditorObject
	{
		return createObjectWithClassName(Type.getClassName(clss), id, params);
	}
	
	static public function createObjectWithClassName(className:String, ?id:String, ?params:Array<Dynamic>):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var valObject:ValEditorObject = new ValEditorObject(valClass, id);
		
		ValEdit.createObjectWithClassName(className, id, params, valObject);
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
			valObject.hasPivotProperties = valClass.hasPivotProperties;
			valObject.hasScaleProperties = valClass.hasScaleProperties;
			valObject.hasTransformProperty = valClass.hasTransformProperty;
			valObject.hasTransformationMatrixProperty = valClass.hasTransformationMatrixProperty;
			valObject.hasRadianRotation = valClass.hasRadianRotation;
		}
		
		registerObjectInternal(valObject);
		
		selection.object = valObject;
		
		return valObject;
	}
	
	static public function createTemplateWithClass(clss:Class<Dynamic>, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		return createTemplateWithClassName(Type.getClassName(clss), id, constructorCollection);
	}
	
	static public function createTemplateWithClassName(className:String, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var template:ValEditorTemplate = new ValEditorTemplate(valClass, id);
		
		ValEdit.createTemplateWithClassName(className, id, constructorCollection, template);
		
		registerTemplateInternal(template);
		
		return template;
	}
	
	static public function createObjectWithTemplate(template:ValEditorTemplate, ?id:String):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(template.className);
		var valObject:ValEditorObject = new ValEditorObject(valClass, id);
		
		ValEdit.createObjectWithTemplate(template, id, valObject);
		
		valObject.interactiveObject = valClass.interactiveFactory(valObject);
		
		registerObjectInternal(valObject);
		
		return valObject;
	}
	
	static private function registerObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.registerObjectInternal(valObject);
		
		//objectCollection.add(valObject);
		
		var objCollection:ArrayCollection<ValEditorObject> = _classToObjectCollection.get(valObject.className);
		objCollection.add(valObject);
		
		for (className in valObject.clss.superClassNames)
		{
			objCollection = _classToObjectCollection.get(className);
			objCollection.add(valObject);
		}
		
		for (category in valObject.clss.categories)
		{
			objCollection = _categoryToObjectCollection.get(category);
			objCollection.add(valObject);
		}
		
		if (currentContainer != null)
		{
			currentContainer.add(valObject);
		}
	}
	
	static private function registerTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.registerTemplateInternal(template);
		
		templateCollection.add(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.className);
		collection.add(template);
		
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.add(template);
		}
		
		for (category in template.clss.categories)
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
			var func:Function = Reflect.field(valObject.realObject, valObject.clss.disposeFunctionName);
			Reflect.callMethod(valObject.realObject, func, []);
		}
		else if (valObject.clss.disposeCustom != null)
		{
			Reflect.callMethod(valObject.clss.disposeCustom, valObject.clss.disposeCustom, [valObject.realObject]);
		}
		
		unregisterObjectInternal(valObject);
	}
	
	static private function unregisterObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.unregisterObjectInternal(valObject);
		
		//objectCollection.remove(valObject);
		
		valObject.container.remove(valObject);
		
		var objCollection:ArrayCollection<ValEditorObject> = _classToObjectCollection.get(valObject.className);
		objCollection.remove(valObject);
		
		for (className in valObject.clss.superClassNames)
		{
			objCollection = _classToObjectCollection.get(className);
			objCollection.remove(valObject);
		}
		
		for (category in valObject.clss.categories)
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
		unregisterTemplateInternal(template);
	}
	
	static private function unregisterTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.unregisterTemplateInternal(template);
		
		templateCollection.remove(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.className);
		collection.remove(template);
		
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.remove(template);
		}
		
		for (category in template.clss.categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			collection.remove(template);
		}
	}
	
	static public function checkForClassProperty(clss:ValEditorClass, propertyName:String):Bool
	{
		if (clss.sourceCollection.hasValue(propertyName))
		{
			return true;
		}
		else
		{
			if (clss.proxyPropertyMap != null)
			{
				return clss.proxyPropertyMap.hasPropertyRegular(propertyName);
			}
			else
			{
				return clss.propertyMap.hasPropertyRegular(propertyName);
			}
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
	
}
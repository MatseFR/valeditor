package valeditor;
import feathers.data.ArrayCollection;
import haxe.Constraints.Function;
import haxe.Json;
import haxe.crypto.Crc32;
import haxe.ds.List;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.macro.Compiler;
import haxe.zip.Entry;
import haxe.zip.Writer;
import inputAction.Input;
import inputAction.controllers.KeyboardController;
import juggler.animation.Juggler;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.EventType;
import openfl.utils.ByteArray;
import valedit.DisplayObjectType;
import valedit.ExposedCollection;
import valedit.ValEdit;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valeditor.ValEditorContainerController;
import valedit.animation.ValEditUpdater;
import valedit.asset.AssetLib;
import valedit.asset.AssetSource;
import valedit.ui.IValueUI;
import valedit.utils.RegularPropertyName;
import valedit.utils.ZipUtil;
import valedit.value.base.ExposedValue;
import valedit.value.base.ExposedValueWithCollection;
import valeditor.editor.Selection;
import valeditor.editor.ViewPort;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.ValEditorActionStack;
import valeditor.editor.action.clipboard.ClipboardClear;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.editor.change.ChangeUpdateQueue;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.clipboard.ValEditorClipboard;
import valeditor.editor.data.ContainerSaveData;
import valeditor.editor.drag.LibraryDragManager;
import valeditor.editor.file.ZipSaveLoader;
import valeditor.editor.settings.EditorSettings;
import valeditor.editor.settings.ExportSettings;
import valeditor.editor.settings.FileSettings;
import valeditor.editor.visibility.ClassVisibilitiesCollection;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.events.EditorEvent;
import valeditor.events.ObjectEvent;
import valeditor.events.RenameEvent;
import valeditor.events.TemplateEvent;
import valeditor.input.LiveInputActionManager;
import valeditor.ui.InteractiveFactories;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.utils.ArraySort;
#if desktop
import valeditor.utils.file.asset.AssetFilesLoaderDesktop;
#else
import valeditor.utils.file.asset.AssetFilesLoader;
#end

/**
 * ...
 * @author Matse
 */
@:access(valedit.ValEdit)
class ValEditor
{
	static public var VERSION:String = Compiler.getDefine("valeditor");
	
	static public var actionStack:ValEditorActionStack;
	#if desktop
	static public var assetFileLoader:AssetFilesLoaderDesktop;
	#else
	static public var assetFileLoader:AssetFilesLoader;
	#end
	static public var clipboard:ValEditorClipboard = new ValEditorClipboard();
	static public var containerController(default, null):ValEditorContainerController = new ValEditorContainerController();
	static public var currentContainer(get, set):IValEditorContainer;
	static public var currentTimeLineContainer(get, never):IValEditorTimeLineContainer;
	static public var editorSettings(default, null):EditorSettings = new EditorSettings();
	static public var eventDispatcher(get, never):EventDispatcher;
	static public var exportSettings(default, null):ExportSettings = new ExportSettings();
	static public var fileDescription:String = "ValEditor Source file (*.ves)";
	static public var fileExtension:String = "ves";
	static public var fileSettings(default, null):FileSettings = new FileSettings();
	static public var input(default, null):Input = new Input();
	static public var isLoadingFile(get, set):Bool;
	static public var isNewFile(default, null):Bool = false;
	static public var keyboardController(default, null):KeyboardController;
	static public var libraryDragManager(default, null):LibraryDragManager;
	static public var openedContainers(default, null):Array<ValEditorObject> = new Array<ValEditorObject>();
	static public var rootContainer(get, set):IValEditorContainer;
	static public var rootScene(get, set):DisplayObjectContainer;
	#if starling
	static public var rootSceneStarling(get, set):starling.display.DisplayObjectContainer;
	#end
	/** can be either the root container or an open container template */
	static public var sceneContainer(get, set):IValEditorContainer;
	static public var selection(default, null):Selection = new Selection();
	static public var theme:ValEditorTheme;
	static public var themeDefaultValues:ExposedCollection;
	static public var uiContainerDefault:DisplayObjectContainer;
	static public var viewPort(default, null):ViewPort = new ViewPort();
	
	static public var categoryCollection(default, null):ArrayCollection<StringData> = new ArrayCollection<StringData>();
	static public var classCollection(default, null):ArrayCollection<ValEditorClass> = new ArrayCollection<ValEditorClass>();
	static public var classNameCollection(default, null):ArrayCollection<StringData> = new ArrayCollection<StringData>();
	static public var openedContainerCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	static public var templateCollection(default, null):ArrayCollection<ValEditorTemplate> = new ArrayCollection<ValEditorTemplate>();
	
	static public var classVisibilities(default, null):ClassVisibilitiesCollection = new ClassVisibilitiesCollection();
	
	static public var isMouseOverUI:Bool;
	static public var juggler(default, null):Juggler;
	
	static private var _currentContainer:IValEditorContainer;
	static private function get_currentContainer():IValEditorContainer
	{
		return _currentContainer;
	}
	static private function set_currentContainer(value:IValEditorContainer):IValEditorContainer
	{
		if (value == _currentContainer) return value;
		
		if (_currentContainer != null)
		{
			if (_currentTimeLineContainer != null)
			{
				_currentTimeLineContainer.juggler = null;
				_currentTimeLineContainer = null;
			}
			_currentContainer.rootContainer = null;
			#if starling
			_currentContainer.rootContainerStarling = null;
			#end
		}
		_currentContainer = value;
		containerController.container = value;
		if (_currentContainer != null)
		{
			if (Std.isOfType(_currentContainer, IValEditorTimeLineContainer))
			{
				_currentTimeLineContainer = cast _currentContainer;
				_currentTimeLineContainer.juggler = juggler;
			}
			_currentContainer.rootContainer = _rootScene;
			#if starling
			_currentContainer.rootContainerStarling = _rootSceneStarling;
			#end
			_currentContainer.x = viewPort.x;
			_currentContainer.y = viewPort.y;
			_currentContainer.viewWidth = viewPort.width;
			_currentContainer.viewHeight = viewPort.height;
			_currentContainer.adjustView();
		}
		EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_CURRENT, _currentContainer);
		return _currentContainer;
	}
	
	static private var _currentTimeLineContainer:IValEditorTimeLineContainer;
	static private function get_currentTimeLineContainer():IValEditorTimeLineContainer { return _currentTimeLineContainer; }
	
	static private var _eventDispatcher:EventDispatcher = new EventDispatcher();
	static private function get_eventDispatcher():EventDispatcher { return _eventDispatcher; }
	
	static private function get_isLoadingFile():Bool { return ValEdit.isLoadingFile; }
	static private function set_isLoadingFile(value:Bool):Bool
	{
		return ValEdit.isLoadingFile = value;
	}
	
	static private var _rootContainer:IValEditorContainer;
	static private function get_rootContainer():IValEditorContainer { return _rootContainer; }
	static private function set_rootContainer(value:IValEditorContainer):IValEditorContainer
	{
		if (value == _rootContainer) return value;
		if (_rootContainer != null)
		{
			viewPort.removeEventListener(Event.CHANGE, onViewPortChange);
		}
		_rootContainer = value;
		if (_rootContainer != null)
		{
			viewPort.addEventListener(Event.CHANGE, onViewPortChange);
		}
		return _rootContainer;
	}
	
	static public function openContainer(container:ValEditorObject):Void
	{
		openedContainers[openedContainers.length] = container;
		openedContainerCollection.add(container);
		container.addEventListener(ObjectEvent.RENAMED, onOpenContainerObjectRenamed);
		
		if (_rootContainer == null)
		{
			rootContainer = container.object;
		}
		
		currentContainer = container.object;
		currentContainer.open();
		edit(currentContainer);
		EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_OPEN, currentContainer);
	}
	
	static public function openContainerTemplate(container:ValEditorObject):Void
	{
		while (openedContainers.length != 1)
		{
			closeContainer();
		}
		
		openContainer(container);
	}
	
	static public function makeContainerCurrent(container:ValEditorObject):Void
	{
		while (currentContainer != container.object)
		{
			closeContainer();
		}
	}
	
	static public function closeContainer():Void
	{
		var object:ValEditorObject = openedContainers.pop();
		var container:IValEditorContainer = object.object;
		openedContainerCollection.remove(object);
		
		object.removeEventListener(ObjectEvent.RENAMED, onOpenContainerObjectRenamed);
		
		if (openedContainers.length != 0)
		{
			currentContainer = openedContainers[openedContainers.length - 1].object;
		}
		else
		{
			currentContainer = null;
			rootContainer = null;
		}
		
		container.close();
		EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_CLOSE, container);
		
		if (_rootContainer == null)
		{
			container.pool();
		}
	}
	
	static public function closeAllContainers():Void
	{
		while (openedContainers.length != 0)
		{
			closeContainer();
		}
	}
	
	static private var _rootScene:DisplayObjectContainer;
	static private function get_rootScene():DisplayObjectContainer { return _rootScene; }
	static private function set_rootScene(value:DisplayObjectContainer):DisplayObjectContainer
	{
		if (_currentContainer != null)
		{
			_currentContainer.rootContainer = value;
		}
		return _rootScene = value;
	}
	
	#if starling
	static private var _rootSceneStarling:starling.display.DisplayObjectContainer;
	static private function get_rootSceneStarling():starling.display.DisplayObjectContainer { return _rootSceneStarling; }
	static private function set_rootSceneStarling(value:starling.display.DisplayObjectContainer):starling.display.DisplayObjectContainer
	{
		if (_currentContainer != null)
		{
			_currentContainer.rootContainerStarling = value;
		}
		return _rootSceneStarling = value;
	}
	#end
	
	static private var _sceneContainer:IValEditorContainer;
	static private function get_sceneContainer():IValEditorContainer { return _sceneContainer; }
	static private function set_sceneContainer(value:IValEditorContainer):IValEditorContainer
	{
		return _sceneContainer = value;
	}
	
	static private function onViewPortChange(evt:Event):Void
	{
		_currentContainer.x = viewPort.x;
		_currentContainer.y = viewPort.y;
		_currentContainer.viewWidth = viewPort.width;
		_currentContainer.viewHeight = viewPort.height;
		_currentContainer.adjustView();
	}
	
	static private var _categoryToClassCollection:Map<String, ArrayCollection<ValEditorClass>> = new Map<String, ArrayCollection<ValEditorClass>>();
	static private var _categoryToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _categoryToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	static private var _classToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _classToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	
	static private var _categoryToStringData:Map<String, StringData> = new Map<String, StringData>();
	static private var _classNameToStringData:Map<String, StringData> = new Map<String, StringData>();
	
	static private var _classMap:Map<String, ValEditorClass> = new Map<String, ValEditorClass>();
	static private var _displayMap:Map<DisplayObjectContainer, ValEditorClass> = new Map<DisplayObjectContainer, ValEditorClass>();
	static private var _uiClassMap:Map<String, Void->IValueUI> = new Map<String, Void->IValueUI>();
	
	static private var _liveActionManager:LiveInputActionManager;
	static private var _changeUpdateQueue:ChangeUpdateQueue;
	static private var _valEditUpdater:ValEditUpdater;
	static private var _zipSaveLoader:ZipSaveLoader;
	
	static public function init(completeCallback:Void->Void):Void
	{
		actionStack = new ValEditorActionStack();
		if (assetFileLoader == null)
		{
			#if desktop
			assetFileLoader = new AssetFilesLoaderDesktop();
			#else
			assetFileLoader = new AssetFilesLoader();
			#end
		}
		clipboard.isRealClipboard = true;
		keyboardController = new KeyboardController(Lib.current.stage);
		input.addController(keyboardController);
		_liveActionManager = new LiveInputActionManager();
		_changeUpdateQueue = new ChangeUpdateQueue();
		_valEditUpdater = new ValEditUpdater();
		_zipSaveLoader = new ZipSaveLoader();
		juggler = new Juggler();
		Juggler.start();
		Juggler.root.add(juggler);
		juggler.add(_valEditUpdater);
		juggler.add(input);
		juggler.add(_liveActionManager);
		juggler.add(_changeUpdateQueue);
		libraryDragManager = new LibraryDragManager();
		
		categoryCollection.sortCompareFunction = ArraySort.stringData;
		classCollection.sortCompareFunction = ArraySort.clss;
		templateCollection.sortCompareFunction = ArraySort.template;
		
		if (ValEdit.assetLib == null)
		{
			ValEdit.assetLib = new AssetLib();
			ValEdit.assetLib.init(true);
		}
		
		ValEdit.init(completeCallback);
	}
	
	static public function newFile():Void
	{
		isNewFile = true;
		var rootObject:ValEditorObject = createObjectWithClass(ValEditorContainerRoot, "root");
		openContainer(rootObject);
	}
	
	static public function fileSaved():Void
	{
		isNewFile = false;
		actionStack.changesSaved();
	}
	
	/** Creates an empty "new file" but does not clear exposed data */
	static public function reset():Void
	{
		FeathersWindows.closeAll();
		actionStack.clearSessions();
		assetFileLoader.clear();
		selection.clear();
		
		closeAllContainers();
		
		for (clss in _classMap)
		{
			clss.prepareForReset();
		}
		
		for (clss in _classMap)
		{
			clss.reset();
		}
		
		ValEdit.assetLib.reset();
	}
	
	static public function getClassByName(className:String):ValEditorClass
	{
		return _classMap.get(className);
	}
	
	static public function getClassByType(type:Class<Dynamic>):ValEditorClass
	{
		return getClassByName(Type.getClassName(type));
	}
	
	static public function getClassSettings(type:Class<Dynamic>, settings:ValEditorClassSettings = null):ValEditorClassSettings
	{
		if (settings == null) settings = ValEditorClassSettings.fromPool();
		
		ValEdit.getClassSettings(type, settings);
		
		getClassInteractiveSettings(type, settings);
		
		#if starling
		if (settings.isDisplayObject && settings.displayObjectType == DisplayObjectType.STARLING)
		{
			settings.hasRadianRotation = true;
			settings.usePivotScaling = true;
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
				
				#if starling
				case DisplayObjectType.STARLING :
					settings.interactiveFactory = InteractiveFactories.starling_default;
				#end
				
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
		
		var v:ValEditorClass = ValEditorClass.fromPool(type, className, settings.collection, settings.constructorCollection);
		
		var result:ValEditClass = ValEdit.registerClass(type, settings, v);
		if (result == null)
		{
			v.pool();
			return null;
		}
		
		_classMap.set(className, v);
		
		var index:Int = className.lastIndexOf(".");
		v.classNameShort = className.substr(index+1);
		v.canBeCreated = settings.canBeCreated;
		for (category in settings.categories)
		{
			v.addCategory(category);
		}
		if (settings.visibilityCollection == null)
		{
			settings.visibilityCollection = ClassVisibilityCollection.fromPool();
			settings.visibilityCollection.populateFromExposedCollection(settings.collection);
		}
		v.visibilityCollectionDefault = settings.visibilityCollection;
		v.visibilityCollectionDefault.classID = className;
		
		classVisibilities.add(v.visibilityCollectionDefault);
		
		v.exportClassName = settings.exportClassName;
		v.iconBitmapData = settings.iconBitmapData;
		v.hasRadianRotation = settings.hasRadianRotation;
		v.interactiveFactory = settings.interactiveFactory;
		v.useBounds = settings.useBounds;
		v.usePivotScaling = settings.usePivotScaling;
		
		v.hasPivotProperties = checkForClassProperty(v, RegularPropertyName.PIVOT_X);
		v.hasScaleProperties = checkForClassProperty(v, RegularPropertyName.SCALE_X);
		v.hasTransformProperty = checkForClassProperty(v, RegularPropertyName.TRANSFORM);
		v.hasTransformationMatrixProperty = checkForClassProperty(v, RegularPropertyName.TRANSFORMATION_MATRIX);
		v.hasVisibleProperty = checkForClassProperty(v, RegularPropertyName.VISIBLE);
		
		var objCollection:ArrayCollection<ValEditorObject>;
		var clssCollection:ArrayCollection<ValEditorClass>;
		var templateCollection:ArrayCollection<ValEditorTemplate>;
		var stringData:StringData;
		
		for (category in settings.categories)
		{
			if (!_categoryToClassCollection.exists(category))
			{
				stringData = StringData.fromPool(category);
				_categoryToStringData.set(category, stringData);
				categoryCollection.add(stringData);
				
				clssCollection = new ArrayCollection<ValEditorClass>();
				clssCollection.sortCompareFunction = ArraySort.clss;
				_categoryToClassCollection.set(category, clssCollection);
				
				objCollection = new ArrayCollection<ValEditorObject>();
				objCollection.sortCompareFunction = ArraySort.object;
				_categoryToObjectCollection.set(category, objCollection);
				
				templateCollection = new ArrayCollection<ValEditorTemplate>();
				templateCollection.sortCompareFunction = ArraySort.template;
				_categoryToTemplateCollection.set(category, templateCollection);
			}
			clssCollection = _categoryToClassCollection.get(category);
			clssCollection.add(v);
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
			classCollection.add(v);
		}
		
		return v;
	}
	
	static public function registerClassSimple(type:Class<Dynamic>, canBeCreated:Bool = true, collection:ExposedCollection, constructorCollection:ExposedCollection = null, categories:Array<String> = null, iconBitmapData:BitmapData = null):ValEditorClass
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		settings.canBeCreated = canBeCreated;
		settings.collection = collection;
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
		var clssCollection:ArrayCollection<ValEditorClass>;
		for (category in valClass.categories)
		{
			clssCollection = _categoryToClassCollection.get(category);
			if (clssCollection.length == 0)
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
			
			classCollection.remove(valClass);
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
			trace("ValEditor.registerUIClass ::: Class " + className + " already registered");
			return;
		}
		
		_uiClassMap[className] = factory;
	}
	
	static public function unregisterUIClass(exposedValueClass:Class<Dynamic>):Void
	{
		var className:String = Type.getClassName(exposedValueClass);
		if (!_uiClassMap.exists(className))
		{
			trace("ValEditor.unregisterUIClass ::: Class " + className + " not registered");
		}
		
		_uiClassMap.remove(className);
	}
	
	/**
	   
	   @param	object	instance of a registered Class
	   @param	uiContainer	if left null uiContainerDefault is used
	**/
	static public function edit(object:Dynamic, collection:ExposedCollection = null, container:DisplayObjectContainer = null, parentValue:ExposedValueWithCollection = null):ExposedCollection
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEditor.edit ::: null container");
		}
		
		// DEBUG
		if (Std.isOfType(object, ValEditorKeyFrame))
		{
			trace("debug");
		}
		//\DEBUG
		
		clearUIContainer(container);
		
		if (object == null) return null;
		
		var clss:Class<Dynamic> = Type.getClass(object);
		var className:String = Type.getClassName(clss);
		var valClass:ValEditorClass = _classMap[className];
		
		if (Std.isOfType(object, ValEditorObject))
		{
			valClass = cast cast(object, ValEditorObject).clss;
			if (collection == null)
			{
				collection = cast(object, ValEditorObject).currentCollection;
			}
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
			throw new Error("ValEditor.edit ::: unknown Class " + Type.getClassName(Type.getClass(object)));
		}
	}
	
	static public function editClassVisibilitiesEditor():Void
	{
		FeathersWindows.showClassVisibilitiesWindow(editorSettings.customClassVisibilities, classVisibilities, "Editor classes visibilities");
	}
	
	static public function editClassVisibilitiesFile():Void
	{
		FeathersWindows.showClassVisibilitiesWindow(fileSettings.customClassVisibilities, editorSettings.customClassVisibilities, "File classes visibilities");
	}
	
	static public function editConstructor(className:String, ?container:DisplayObjectContainer):ExposedCollection
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEditor.editConstructor ::: null container");
		}
		
		clearUIContainer(container);
		
		if (className == null) return null;
		
		var valClass:ValEditorClass = _classMap[className];
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
			throw new Error("ValEditor.editConstructor ::: unknown Class " + className);
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
	
	
	static public function editTemplate(template:ValEditorTemplate, ?container:DisplayObjectContainer):Void
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEditor.editTemplate ::: null container");
		}
		
		clearUIContainer(container);
		
		if (template == null) return;
		
		var valClass:ValEditorClass = cast template.clss;
		_displayMap[container] = valClass;
		valClass.addTemplateContainer(container, template);
	}
	
	static public function editUITheme():Void
	{
		FeathersWindows.showThemeEditWindow(theme, editorSettings.themeCustomValues, themeDefaultValues, "UI Theme");
	}
	
	/**
	   
	   @param	container
	**/
	static public function clearUIContainer(?container:DisplayObjectContainer):Void
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEditor.clearContainer ::: null container");
		}
		
		var valClass:ValEditorClass = _displayMap[container];
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
		return control;
	}
	
	static public function createObjectWithClass(clss:Class<Dynamic>, id:String = null, params:Array<Dynamic> = null, collection:ExposedCollection = null, objectID:String = null, object:Dynamic = null):ValEditorObject
	{
		return createObjectWithClassName(Type.getClassName(clss), id, params, collection, objectID, object);
	}
	
	static public function createObjectWithClassName(className:String, id:String = null, params:Array<Dynamic> = null, collection:ExposedCollection = null, objectID:String = null, object:Dynamic = null):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var valObject:ValEditorObject = ValEditorObject.fromPool(valClass, id);
		
		ValEdit.createObjectWithClassName(className, id, params, valObject, collection, objectID, object);
		
		valObject.applyClassVisibility(valClass.visibilityCollectionCurrent);
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
			valObject.hasPivotProperties = valClass.hasPivotProperties;
			valObject.hasScaleProperties = valClass.hasScaleProperties;
			valObject.hasTransformProperty = valClass.hasTransformProperty;
			valObject.hasTransformationMatrixProperty = valClass.hasTransformationMatrixProperty;
			valObject.hasVisibleProperty = valClass.hasVisibleProperty;
			valObject.hasRadianRotation = valClass.hasRadianRotation;
			valObject.useBounds = valClass.useBounds;
			valObject.usePivotScaling = valClass.usePivotScaling;
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
		
		template.object = createObjectWithTemplate(template, id, template.collection, false);
		template.object.currentCollection.readValues();
		
		var visibility:TemplateVisibilityCollection = TemplateVisibilityCollection.fromPool();
		visibility.populateFromClassVisibilityCollection(valClass.visibilityCollectionCurrent);
		template.visibilityCollectionDefault = visibility;
		
		registerTemplateInternal(template);
		
		return template;
	}
	
	static public function createObjectWithTemplate(template:ValEditorTemplate, ?id:String, ?collection:ExposedCollection, ?objectID:String, registerToTemplate:Bool = true):ValEditorObject
	{
		var valClass:ValEditorClass = cast template.clss;
		
		if (id == null)
		{
			id = template.makeObjectID();
		}
		
		var valObject:ValEditorObject = ValEditorObject.fromPool(valClass, id);
		
		valObject.hasPivotProperties = valClass.hasPivotProperties;
		valObject.hasScaleProperties = valClass.hasScaleProperties;
		valObject.hasTransformProperty = valClass.hasTransformProperty;
		valObject.hasTransformationMatrixProperty = valClass.hasTransformationMatrixProperty;
		valObject.hasVisibleProperty = valClass.hasVisibleProperty;
		valObject.hasRadianRotation = valClass.hasRadianRotation;
		valObject.useBounds = valClass.useBounds;
		valObject.usePivotScaling = valClass.usePivotScaling;
		
		ValEdit.createObjectWithTemplate(template, id, valObject, collection, objectID, registerToTemplate);
		
		if (registerToTemplate)
		{
			valObject.applyTemplateVisibility(template.visibilityCollectionCurrent);
		}
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
		}
		
		if (registerToTemplate)
		{
			registerObjectInternal(valObject);
		}
		
		return valObject;
	}
	
	static public function cloneObject(object:ValEditorObject, ?id:String):ValEditorObject
	{
		var newObject:ValEditorObject;
		if (object.template != null)
		{
			newObject = createObjectWithTemplate(cast object.template, id, object.currentCollection.clone(true), object.objectID);
		}
		else
		{
			newObject = createObjectWithClassName(object.className, id, null, object.currentCollection.clone(true), object.objectID);
		}
		return newObject;
	}
	
	static public function registerObject(valObject:ValEditorObject):Void
	{
		registerObjectInternal(valObject);
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
	
	static public function registerTemplate(template:ValEditorTemplate):Void
	{
		registerTemplateInternal(template);
	}
	
	static private function registerTemplateInternal(template:ValEditorTemplate):Void
	{
		template.addEventListener(TemplateEvent.INSTANCE_ADDED, onTemplateInstanceAdded);
		template.addEventListener(TemplateEvent.INSTANCE_REMOVED, onTemplateInstanceRemoved);
		template.addEventListener(TemplateEvent.INSTANCE_SUSPENDED, onTemplateInstanceSuspended);
		template.addEventListener(TemplateEvent.INSTANCE_UNSUSPENDED, onTemplateInstanceUnsuspended);
		template.addEventListener(RenameEvent.RENAMED, onTemplateRenamed);
		templateCollection.add(template);
		
		if (template.isSuspended)
		{
			cast(template.clss, ValEditorClass).unsuspendTemplate(template);
		}
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.clss.className);
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
		
		template.isInLibrary = true;
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
	
	static public function unregisterObject(valObject:ValEditorObject):Void
	{
		unregisterObjectInternal(valObject);
	}
	
	static private function unregisterObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.unregisterObjectInternal(valObject);
		
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
		if (template.object != null)
		{
			destroyObject(cast template.object);
			template.object = null;
		}
		
		unregisterTemplateInternal(template);
		
		template.pool();
	}
	
	static public function unregisterTemplate(template:ValEditorTemplate):Void
	{
		unregisterTemplateInternal(template);
	}
	
	static private function unregisterTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.unregisterTemplateInternal(template);
		
		template.removeEventListener(TemplateEvent.INSTANCE_ADDED, onTemplateInstanceAdded);
		template.removeEventListener(TemplateEvent.INSTANCE_REMOVED, onTemplateInstanceRemoved);
		template.removeEventListener(TemplateEvent.INSTANCE_SUSPENDED, onTemplateInstanceSuspended);
		template.removeEventListener(TemplateEvent.INSTANCE_UNSUSPENDED, onTemplateInstanceUnsuspended);
		template.removeEventListener(RenameEvent.RENAMED, onTemplateRenamed);
		templateCollection.remove(template);
		
		cast(template.clss, ValEditorClass).suspendTemplate(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.clss.className);
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
		
		template.isInLibrary = false;
	}
	
	static public function checkForClassProperty(clss:ValEditorClass, propertyName:String):Bool
	{
		if (clss.collection.hasValue(propertyName))
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
	
	static public function getClassUICollectionForCategory(category:String):ArrayCollection<ValEditorClass>
	{
		return _categoryToClassCollection.get(category);
	}
	
	static public function getClassStringData(className:String):StringData
	{
		return _classNameToStringData.get(className);
	}
	
	static public function getCollectionForObject(object:Dynamic):ExposedCollection
	{
		var valClass:ValEditorClass = getValEditorClassByClass(ValEdit.getObjectClass(object));
		if (valClass != null)
		{
			return valClass.getCollection();
		}
		return null;
	}
	
	static public function getValEditorClassByClass(clss:Class<Dynamic>):ValEditorClass
	{
		return _classMap.get(Type.getClassName(clss));
	}
	
	static public function getValEditorClassByClassName(className:String):ValEditorClass
	{
		return _classMap.get(className);
	}
	
	static public function getObjectUICollectionForClass(clss:Class<Dynamic>):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(Type.getClassName(clss));
	}
	
	static public function getObjectUICollectionForClassName(className:String):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(className);
	}
	
	static public function getTemplateUICollectionForClassName(className:String):ArrayCollection<ValEditorTemplate>
	{
		return _classToTemplateCollection.get(className);
	}
	
	static public function getTemplateUICollectionForCategory(category:String):ArrayCollection<ValEditorTemplate>
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
		container.autoIncreaseNumFrames = fileSettings.numFramesAutoIncrease;
		container.numFrames = fileSettings.numFramesDefault;
		container.frameIndex = 0;
		var layer:ValEditorLayer = createLayer();
		container.addLayer(layer);
		return container;
	}
	
	static public function createContainerRoot():ValEditorContainerRoot
	{
		var container:ValEditorContainerRoot = ValEditorContainerRoot.fromPool();
		container.autoIncreaseNumFrames = fileSettings.numFramesAutoIncrease;
		container.numFrames = fileSettings.numFramesDefault;
		container.frameIndex = 0;
		var layer:ValEditorLayer = createLayer();
		container.addLayer(layer);
		return container;
	}
	
	static public function createKeyFrame():ValEditorKeyFrame
	{
		var keyFrame:ValEditorKeyFrame = ValEditorKeyFrame.fromPool();
		keyFrame.transition = fileSettings.tweenTransitionDefault;
		return keyFrame;
	}
	
	static public function createLayer():ValEditorLayer
	{
		var layer:ValEditorLayer = ValEditorLayer.fromPool(createTimeLine());
		return layer;
	}
	
	static public function createTimeLine():ValEditorTimeLine
	{
		//var timeLine:ValEditorTimeLine = ValEditorTimeLine.fromPool(fileSettings.numFramesDefault);
		//timeLine.frameIndex = 0;
		//timeLine.autoIncreaseNumFrames = fileSettings.numFramesAutoIncrease;
		//timeLine.insertKeyFrame();
		var timeLine:ValEditorTimeLine = ValEditorTimeLine.fromPool(1);
		timeLine.frameIndex = 0;
		timeLine.insertKeyFrame();
		return timeLine;
	}
	
	static public function copy(?action:MultiAction):Void
	{
		if (action != null)
		{
			var clipboardClear:ClipboardClear = ClipboardClear.fromPool();
			clipboardClear.setup(clipboard);
			action.add(clipboardClear);
			
			selection.copyToClipboard(clipboard, action);
		}
		else
		{
			clipboard.clear();
			selection.copyToClipboard(clipboard);
		}
	}
	
	static public function cut(?action:MultiAction):Void
	{
		if (action != null)
		{
			if (selection.numObjects != 0)
			{
				var clipboardClear:ClipboardClear = ClipboardClear.fromPool();
				clipboardClear.setup(clipboard);
				action.add(clipboardClear);
				
				selection.cutToClipboard(clipboard, action);
				
				var selectionClear:SelectionClear = SelectionClear.fromPool();
				selectionClear.setup(selection);
				action.add(selectionClear);
			}
		}
		else
		{
			clipboard.clear();
			selection.cutToClipboard(clipboard);
			selection.clear();
		}
	}
	
	static public function delete(action:MultiAction):Void
	{
		var selectionClear:SelectionClear = SelectionClear.fromPool();
		selectionClear.setup(selection);
		
		selection.delete(action);
		
		action.addPost(selectionClear);
	}
	
	static public function paste(action:MultiAction):Void
	{
		clipboard.paste(action);
	}
	
	static public function selectAll(action:MultiAction):Void
	{
		containerController.selectAllVisible(action);
	}
	
	static public function unselectAll(action:MultiAction):Void
	{
		if (action != null)
		{
			if (selection.numObjects != 0)
			{
				var selectionClear:SelectionClear = SelectionClear.fromPool();
				selectionClear.setup(selection);
				action.add(selectionClear);
			}
		}
		else
		{
			selection.object = null;
		}
	}
	
	static public function insertFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		cast(currentTimeLineContainer.currentLayer.timeLine, ValEditorTimeLine).insertFrame(action);
	}
	
	static public function insertKeyFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		cast(currentTimeLineContainer.currentLayer.timeLine, ValEditorTimeLine).insertKeyFrame(action);
	}
	
	static public function removeFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		cast(currentTimeLineContainer.currentLayer.timeLine, ValEditorTimeLine).removeFrame(action);
	}
	
	static public function removeKeyFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		cast(currentTimeLineContainer.currentLayer.timeLine, ValEditorTimeLine).removeKeyFrame(action);
	}
	
	static public function firstFrame():Void
	{
		if (currentTimeLineContainer.isPlaying)
		{
			currentTimeLineContainer.stop();
		}
		currentTimeLineContainer.frameIndex = 0;
	}
	
	static public function lastFrame():Void
	{
		if (currentTimeLineContainer.isPlaying)
		{
			currentTimeLineContainer.stop();
		}
		currentTimeLineContainer.frameIndex = currentTimeLineContainer.lastFrameIndex;
	}
	
	static public function nextFrame():Void
	{
		if (currentTimeLineContainer.isPlaying)
		{
			currentTimeLineContainer.stop();
		}
		if (currentTimeLineContainer.frameIndex < currentTimeLineContainer.lastFrameIndex)
		{
			currentTimeLineContainer.frameIndex++;
		}
	}
	
	static public function previousFrame():Void
	{
		if (currentTimeLineContainer.isPlaying)
		{
			currentTimeLineContainer.stop();
		}
		if (currentTimeLineContainer.frameIndex != 0)
		{
			currentTimeLineContainer.frameIndex--;
		}
	}
	
	static public function playStop():Void
	{
		if (!currentTimeLineContainer.isPlaying)
		{
			//currentTimeLineContainer.timeLine.updateLastFrameIndex();
			if (currentTimeLineContainer.frameIndex >= currentTimeLineContainer.lastFrameIndex)
			{
				currentTimeLineContainer.frameIndex = 0;
			}
			currentTimeLineContainer.play();
		}
		else
		{
			currentTimeLineContainer.stop();
		}
	}
	
	static private function onOpenContainerObjectRenamed(evt:ObjectEvent):Void
	{
		openedContainerCollection.updateAt(openedContainerCollection.indexOf(cast evt.object));
	}
	
	static private function onTemplateInstanceAdded(evt:TemplateEvent):Void
	{
		var index:Int = templateCollection.indexOf(evt.template);
		if (index != -1) templateCollection.updateAt(index);
		
		var collection:ArrayCollection<ValEditorTemplate>;
		for (className in evt.template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
		
		for (category in cast(evt.template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
	}
	
	static private function onTemplateInstanceRemoved(evt:TemplateEvent):Void
	{
		var index:Int = templateCollection.indexOf(evt.template);
		if (index != -1) templateCollection.updateAt(index);
		
		var collection:ArrayCollection<ValEditorTemplate>;
		for (className in evt.template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
		
		for (category in cast(evt.template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
	}
	
	static private function onTemplateInstanceSuspended(evt:TemplateEvent):Void
	{
		var index:Int = templateCollection.indexOf(evt.template);
		if (index != -1) templateCollection.updateAt(index);
		
		var collection:ArrayCollection<ValEditorTemplate>;
		for (className in evt.template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
		
		for (category in cast(evt.template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
	}
	
	static private function onTemplateInstanceUnsuspended(evt:TemplateEvent):Void
	{
		var index:Int = templateCollection.indexOf(evt.template);
		if (index != -1) templateCollection.updateAt(index);
		
		var collection:ArrayCollection<ValEditorTemplate>;
		for (className in evt.template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
		
		for (category in cast(evt.template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
	}
	
	static private function onTemplateRenamed(evt:RenameEvent):Void
	{
		var template:ValEditorTemplate = evt.target;
		ValEdit.renameTemplate(template, evt.previousNameOrID);
		
		templateCollection.updateAt(templateCollection.indexOf(template));
		
		var collection:ArrayCollection<ValEditorTemplate>;
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.updateAt(collection.indexOf(template));
		}
		
		for (category in cast(template.clss, ValEditorClass).categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			collection.updateAt(collection.indexOf(template));
		}
	}
	
	static public function registerForChangeUpdate(object:IChangeUpdate):Void
	{
		_changeUpdateQueue.add(object);
	}
	
	static public function fromJSONSave(json:Dynamic):Void
	{
		isLoadingFile = true;
		var rootObject:ValEditorObject = createObjectWithClass(ValEditorContainerRoot, "root");
		var container:ValEditorContainerRoot = rootObject.object;
		
		var clss:ValEditorClass;
		var classList:Array<Dynamic> = json.classes;
		for (node in classList)
		{
			clss = _classMap.get(node.clss);
			if (clss == null)
			{
				throw new Error("missing Class ::: " + node.clss);
			}
			clss.fromJSONSave(node);
		}
		
		var clss:ValEditorClass;
		var constructorCollection:ExposedCollection;
		var template:ValEditorTemplate;
		var containerData:Array<Dynamic> = json.containerTemplates;
		if (containerData != null)
		{
			for (data in containerData)
			{
				clss = getClassByName(data.clss);
				if (clss.constructorCollection != null)
				{
					constructorCollection = clss.constructorCollection.clone(true);
					if (data.constructorCollection != null)
					{
						constructorCollection.fromJSONSave(data.constructorCollection);
					}
				}
				else
				{
					constructorCollection = null;
				}
				template = ValEditor.createTemplateWithClassName(clss.className, data.id, constructorCollection);
				//template.applyVisibility();
				template.fromJSONSave(data);
			}
		}
		
		container.fromJSONSave(json.root);
		isLoadingFile = false;
		
		openContainer(rootObject);
	}
	
	static public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.valeditVersion = ValEdit.VERSION;
		json.valeditorVersion = VERSION;
		
		#if flash
		json.flash = true;
		#end
		
		var containerTemplates:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
		var classList:Array<Dynamic> = [];
		for (clss in _classMap)
		{
			if (clss.numTemplates != 0)
			{
				if (!clss.isContainer)
				{
					classList.push(clss.toJSONSave());
				}
				else
				{
					for (template in clss.templates)
					{
						containerTemplates.push(template);
					}
				}
			}
		}
		json.classes = classList;
		
		var templateDependencies:Map<ValEditorTemplate, ContainerSaveData> = new Map<ValEditorTemplate, ContainerSaveData>();
		var templateSave:Map<ValEditorTemplate, Bool> = new Map<ValEditorTemplate, Bool>();
		var containerData:Array<Dynamic> = [];
		var saveData:ContainerSaveData;
		
		for (template in containerTemplates)
		{
			saveData = ContainerSaveData.fromPool(template);
			cast(template.object.object, IValEditorContainer).getContainerDependencies(saveData);
			templateDependencies.set(template, saveData);
			templateSave.set(template, false);
		}
		
		var template:ValEditorTemplate;
		var templateIndex:Int = -1;
		var templateCount:Int = containerTemplates.length;
		var ok:Bool;
		var data:Dynamic;
		while (true)
		{
			if (templateCount == 0) break;
			templateIndex ++;
			if (templateIndex == templateCount) templateIndex = 0;
			template = containerTemplates[templateIndex];
			saveData = templateDependencies.get(template);
			ok = true;
			for (tpl in saveData.dependencies)
			{
				if (!templateSave.get(tpl))
				{
					ok = false;
					break;
				}
			}
			
			if (ok)
			{
				data = template.toJSONContainerSave();
				containerData.push(data);
				templateSave.set(template, true);
				containerTemplates.remove(template);
				templateIndex--;
				templateCount--;
			}
		}
		
		json.containerTemplates = containerData;
		
		for (sData in templateDependencies)
		{
			sData.pool();
		}
		templateDependencies.clear();
		templateDependencies = null;
		templateSave.clear();
		templateSave = null;
		
		json.root = _rootContainer.toJSONSave();
		
		return json;
	}
	
	static public function fromZipSave(bytes:Bytes):Void
	{
		reset();
		
		_zipSaveLoader.addEventListener(Event.COMPLETE, fromZipSaveComplete);
		_zipSaveLoader.load(bytes);
	}
	
	static private function fromZipSaveComplete(evt:Event):Void
	{
		_zipSaveLoader.removeEventListener(Event.COMPLETE, fromZipSaveComplete);
		_zipSaveLoader.clear();
		fileSettings.apply();
	}
	
	static public function toZipSave():ByteArray
	{
		var bytes:Bytes;
		var entries:List<Entry> = new List<Entry>();
		var entry:Entry;
		var json:Dynamic = toJSONSave();
		
		bytes = Bytes.ofString(Json.stringify(json));
		entry = {
			fileName:"valedit_data.json",
			fileSize:bytes.length,
			fileTime:Date.now(),
			compressed:false,
			dataSize:bytes.length,
			data:bytes,
			crc32:Crc32.make(bytes)
		};
		if (fileSettings.compress)
		{
			ZipUtil.compressEntry(entry);
		}
		entries.push(entry);
		
		// ASSETS
		var assets:Dynamic = {};
		// binary
		var binaryList:Array<Dynamic> = [];
		for (asset in ValEdit.assetLib.binaryList)
		{
			if (asset.source == AssetSource.EXTERNAL)
			{
				binaryList.push(asset.toJSONSave());
				entry = asset.toZIPEntry();
				entries.push(entry);
			}
		}
		if (binaryList.length != 0)
		{
			assets.binary = binaryList;
		}
		
		// bitmap
		var bitmapList:Array<Dynamic> = [];
		for (asset in ValEdit.assetLib.bitmapList)
		{
			if (asset.source == AssetSource.EXTERNAL)
			{
				bitmapList.push(asset.toJSONSave());
				entry = asset.toZIPEntry();
				entries.push(entry);
			}
		}
		if (bitmapList.length != 0)
		{
			assets.bitmap = bitmapList;
		}
		
		// sound
		var soundList:Array<Dynamic> = [];
		for (asset in ValEdit.assetLib.soundList)
		{
			if (asset.source == AssetSource.EXTERNAL)
			{
				soundList.push(asset.toJSONSave());
				entry = asset.toZIPEntry();
				entries.push(entry);
			}
		}
		if (soundList.length != 0)
		{
			assets.sound = soundList;
		}
		
		// text
		var textList:Array<Dynamic> = [];
		for (asset in ValEdit.assetLib.textList)
		{
			if (asset.source == AssetSource.EXTERNAL)
			{
				textList.push(asset.toJSONSave());
				entry = asset.toZIPEntry();
				ZipUtil.compressEntry(entry);
				entries.push(entry);
			}
		}
		if (textList.length != 0)
		{
			assets.text = textList;
		}
		
		#if starling
		// starling_atlas
		var starlingAtlasList:Array<Dynamic> = [];
		for (asset in ValEdit.assetLib.starlingAtlasList)
		{
			starlingAtlasList.push(asset.toJSONSave());
		}
		if (starlingAtlasList.length != 0)
		{
			assets.starling_atlas = starlingAtlasList;
		}
		// starling_texture
		var starlingTextureList:Array<Dynamic> = [];
		for (asset in ValEdit.assetLib.starlingTextureList)
		{
			if (!asset.isFromAtlas)
			{
				starlingTextureList.push(asset.toJSONSave());
			}
		}
		if (starlingTextureList.length != 0)
		{
			assets.starling_texture = starlingTextureList;
		}
		#end
		
		bytes = Bytes.ofString(Json.stringify(assets));
		entry = {
			fileName:"valedit_assets.json",
			fileSize:bytes.length,
			fileTime:Date.now(),
			compressed:false,
			dataSize:bytes.length,
			data:bytes,
			crc32:Crc32.make(bytes)
		};
		if (fileSettings.compress)
		{
			ZipUtil.compressEntry(entry);
		}
		entries.push(entry);
		//\ASSETS
		
		// SETTINGS
		bytes = Bytes.ofString(Json.stringify(fileSettings.toJSON()));
		entry = {
			fileName:"valedit_fileSettings.json",
			fileSize:bytes.length,
			fileTime:Date.now(),
			compressed:false,
			dataSize:bytes.length,
			data:bytes,
			crc32:Crc32.make(bytes)
		};
		if (fileSettings.compress)
		{
			ZipUtil.compressEntry(entry);
		}
		entries.push(entry);
		
		bytes = Bytes.ofString(Json.stringify(exportSettings.toJSON()));
		entry = {
			fileName:"valedit_exportSettings.json",
			fileSize:bytes.length,
			fileTime:Date.now(),
			compressed:false,
			dataSize:bytes.length,
			data:bytes,
			crc32:Crc32.make(bytes)
		};
		if (fileSettings.compress)
		{
			ZipUtil.compressEntry(entry);
		}
		entries.push(entry);
		//\SETTINGS
		
		var output:BytesOutput = new BytesOutput();
		var zip:Writer = new Writer(output);
		zip.write(entries);
		output.close();
		
		var ba:ByteArray = ByteArray.fromBytes(output.getBytes());
		
		return ba;
	}
	
}
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
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.EventType;
import openfl.utils.ByteArray;
import valedit.ExposedCollection;
import valedit.ValEdit;
import valedit.animation.ValEditUpdater;
import valedit.asset.AssetLib;
import valedit.asset.AssetSource;
import valedit.ui.IValueUI;
import valedit.utils.PropertyMap;
import valedit.utils.RegularPropertyName;
import valedit.utils.ZipUtil;
import valedit.value.base.ExposedValue;
import valedit.value.base.ExposedValueWithCollection;
import valeditor.ValEditorContainerController;
import valeditor.container.IContainerEditable;
import valeditor.container.IContainerOpenFLEditable;
#if starling
import valeditor.container.IContainerStarlingEditable;
#end
import valeditor.container.ITimeLineContainerEditable;
import valeditor.container.ITimeLineLayerEditable;
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
import valeditor.events.RenameEvent;
import valeditor.events.TemplateEvent;
import valeditor.input.LiveInputActionManager;
import valeditor.ui.InteractiveFactories;
import valeditor.ui.InteractiveObjectController;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.data.StringData;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.utils.ArraySort;
#if starling
import starling.core.Starling;
#end
#if (desktop || air)
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
	static public var FEATHERS_VERSION:String = Compiler.getDefine("feathersui");
	static public var INPUT_ACTION_VERSION:String = Compiler.getDefine("inputAction");
	static public var VERSION:String = Compiler.getDefine("valeditor");
	
	static public var actionStack:ValEditorActionStack;
	#if (desktop || air)
	static public var assetFileLoader:AssetFilesLoaderDesktop;
	#else
	static public var assetFileLoader:AssetFilesLoader;
	#end
	static public var clipboard:ValEditorClipboard = new ValEditorClipboard();
	//static public var containerController(default, null):ValEditorContainerController = new ValEditorContainerController();
	static public var containerController:IContainerController;
	#if flash @:flash.property #end
	static public var currentContainer(get, never):IContainerEditable;
	#if flash @:flash.property #end
	static public var currentContainerObject(get, set):ValEditorObject;
	#if flash @:flash.property #end
	static public var currentTimeLineContainer(get, never):ITimeLineContainerEditable;
	static public var editorSettings(default, null):EditorSettings = new EditorSettings();
	static public var eventDispatcher(get, never):EventDispatcher;
	static public var exportSettings(default, null):ExportSettings = new ExportSettings();
	static public var fileDescription:String = "ValEditor Source file (*.ves)";
	static public var fileExtension:String = "ves";
	static public var fileSettings(default, null):FileSettings = new FileSettings();
	static public var input(default, null):Input = new Input();
	static public var interactiveObjectController(default, null):InteractiveObjectController = new InteractiveObjectController();
	static public var isLoadingFile(get, set):Bool;
	static public var isNewFile(default, null):Bool = false;
	static public var keyboardController(default, null):KeyboardController;
	static public var libraryDragManager(default, null):LibraryDragManager;
	static public var openedContainers(default, null):Array<ValEditorObject> = new Array<ValEditorObject>();
	#if flash @:flash.property #end
	static public var rootContainer(get, never):IContainerEditable;
	#if flash @:flash.property #end
	static public var rootContainerObject(get, set):ValEditorObject;
	static public var rootScene(get, set):DisplayObjectContainer;
	#if starling
	static public var rootSceneStarling(get, set):starling.display.DisplayObjectContainer;
	#end
	/** can be either the root container or an open container template */
	#if flash @:flash.property #end
	static public var sceneContainer(get, set):IContainerEditable;
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
	
	static private var _currentContainer:IContainerEditable;
	static private function get_currentContainer():IContainerEditable
	{
		return _currentContainer;
	}
	
	static private var _currentContainerObject:ValEditorObject;
	static private function get_currentContainerObject():ValEditorObject { return _currentContainerObject; }
	static private function set_currentContainerObject(value:ValEditorObject):ValEditorObject
	{
		if (value == _currentContainerObject) return value;
		
		if (_currentContainerObject != null)
		{
			if (_currentTimeLineContainer != null)
			{
				_currentTimeLineContainer.juggler = null;
				_currentTimeLineContainer = null;
			}
			
			if (_currentContainerObject.isContainerOpenFL)
			{
				cast(_currentContainer, IContainerOpenFLEditable).rootContainer = null;
			}
			#if starling
			if (_currentContainerObject.isContainerStarling)
			{
				cast(_currentContainer, IContainerStarlingEditable).rootContainer = null;
				cast(_currentContainer, IContainerStarlingEditable).rootContainerStarling = null;
			}
			#end
			
			_currentContainer = null;
			containerController.containerObject = null;
		}
		_currentContainerObject = value;
		if (_currentContainerObject != null)
		{
			_currentContainer = _currentContainerObject.object;
			if (_currentContainerObject.isTimeLineContainer)
			{
				_currentTimeLineContainer = cast _currentContainer;
				_currentTimeLineContainer.juggler = juggler;
			}
			
			if (_currentContainerObject.isContainerOpenFL)
			{
				cast(_currentContainer, IContainerOpenFLEditable).rootContainer = _rootScene;
			}
			#if starling
			if (_currentContainerObject.isContainerStarling)
			{
				cast(_currentContainer, IContainerStarlingEditable).rootContainer = _rootScene;
				cast(_currentContainer, IContainerStarlingEditable).rootContainerStarling = _rootSceneStarling;
			}
			#end
			
			if (_currentContainerObject.hasProperty(RegularPropertyName.X))
			{
				_currentContainerObject.setProperty(RegularPropertyName.X, viewPort.x);
				_currentContainerObject.setProperty(RegularPropertyName.Y, viewPort.y);
			}
			_currentContainer.viewWidth = viewPort.width;
			_currentContainer.viewHeight = viewPort.height;
			_currentContainer.adjustView();
			
			containerController.containerObject = _currentContainerObject;
		}
		EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_CURRENT, _currentContainer);
		return _currentContainerObject;
	}
	
	static private var _currentTimeLineContainer:ITimeLineContainerEditable;
	static private function get_currentTimeLineContainer():ITimeLineContainerEditable { return _currentTimeLineContainer; }
	
	static private var _eventDispatcher:EventDispatcher = new EventDispatcher();
	static private function get_eventDispatcher():EventDispatcher { return _eventDispatcher; }
	
	static private function get_isLoadingFile():Bool { return ValEdit.isLoadingFile; }
	static private function set_isLoadingFile(value:Bool):Bool
	{
		return ValEdit.isLoadingFile = value;
	}
	
	static private var _rootContainer:IContainerEditable;
	static private function get_rootContainer():IContainerEditable { return _rootContainer; }
	
	static private var _rootContainerObject:ValEditorObject;
	static private function get_rootContainerObject():ValEditorObject { return _rootContainerObject; }
	static private function set_rootContainerObject(value:ValEditorObject):ValEditorObject
	{
		if (value == _rootContainerObject) return value;
		
		if (_rootContainerObject != null)
		{
			_rootContainer = null;
			viewPort.removeEventListener(Event.CHANGE, onViewPortChange);
		}
		_rootContainerObject = value;
		if (_rootContainerObject != null)
		{
			_rootContainer = _rootContainerObject.object;
			viewPort.addEventListener(Event.CHANGE, onViewPortChange);
		}
		return _rootContainerObject;
	}
	
	static public function openContainer(container:ValEditorObject):Void
	{
		openedContainers[openedContainers.length] = container;
		openedContainerCollection.add(container);
		container.addEventListener(RenameEvent.RENAMED, onOpenContainerObjectRenamed);
		
		if (_rootContainerObject == null)
		{
			rootContainerObject = container;
		}
		
		currentContainerObject = container;
		_currentContainer.open();
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
		while (_currentContainerObject != container)
		{
			closeContainer();
		}
	}
	
	static public function closeContainer():Void
	{
		var object:ValEditorObject = openedContainers.pop();
		var container:IContainerEditable = object.object;
		openedContainerCollection.remove(object);
		
		object.removeEventListener(RenameEvent.RENAMED, onOpenContainerObjectRenamed);
		
		if (openedContainers.length != 0)
		{
			currentContainerObject = openedContainers[openedContainers.length - 1];
		}
		else
		{
			currentContainerObject = null;
			rootContainerObject = null;
		}
		
		container.close();
		EditorEvent.dispatch(_eventDispatcher, EditorEvent.CONTAINER_CLOSE, container);
		
		if (_rootContainerObject == null)
		{
			destroyObject(object);
			//container.pool();
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
		if (_currentContainerObject != null)
		{
			if (_currentContainerObject.isContainerOpenFL)
			{
				cast(_currentContainer, IContainerOpenFLEditable).rootContainer = value;
			}
		}
		return _rootScene = value;
	}
	
	#if starling
	static private var _rootSceneStarling:starling.display.DisplayObjectContainer;
	static private function get_rootSceneStarling():starling.display.DisplayObjectContainer { return _rootSceneStarling; }
	static private function set_rootSceneStarling(value:starling.display.DisplayObjectContainer):starling.display.DisplayObjectContainer
	{
		if (_currentContainerObject != null)
		{
			if (_currentContainerObject.isContainerStarling)
			{
				cast(_currentContainer, IContainerStarlingEditable).rootContainerStarling = value;
			}
		}
		return _rootSceneStarling = value;
	}
	#end
	
	static private var _sceneContainer:IContainerEditable;
	static private function get_sceneContainer():IContainerEditable { return _sceneContainer; }
	static private function set_sceneContainer(value:IContainerEditable):IContainerEditable
	{
		return _sceneContainer = value;
	}
	
	static private function onViewPortChange(evt:Event):Void
	{
		#if starling
		var centerX:Float = viewPort.x + (viewPort.width / 2.0);
		var centerY:Float = viewPort.y + (viewPort.height / 2.0);
		Starling.current.stage.projectionOffset.x = centerX - Starling.current.stage.stageWidth / 2.0;
		Starling.current.stage.projectionOffset.y = centerY - Starling.current.stage.stageHeight / 2.0;
		Starling.current.stage.projectionOffset = Starling.current.stage.projectionOffset;
		#end
		if (_currentContainerObject != null)
		{
			if (_currentContainerObject.hasProperty(RegularPropertyName.X))
			{
				_currentContainerObject.setProperty(RegularPropertyName.X, viewPort.x);
				_currentContainerObject.setProperty(RegularPropertyName.Y, viewPort.y);
			}
			_currentContainer.viewWidth = viewPort.width;
			_currentContainer.viewHeight = viewPort.height;
			_currentContainer.adjustView();
		}
	}
	
	static private var _categoryToClassCollection:Map<String, ArrayCollection<ValEditorClass>> = new Map<String, ArrayCollection<ValEditorClass>>();
	static private var _categoryToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _categoryToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	static private var _classToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _classToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	
	static private var _categoryToStringData:Map<String, StringData> = new Map<String, StringData>();
	static private var _classNameToStringData:Map<String, StringData> = new Map<String, StringData>();
	
	static private var _baseClassToClassList:Map<String, Array<String>> = new Map<String, Array<String>>();
	static private var _classMap:Map<String, ValEditorClass> = new Map<String, ValEditorClass>();
	static private var _displayMap:Map<DisplayObjectContainer, ValEditorClass> = new Map<DisplayObjectContainer, ValEditorClass>();
	static private var _templateMap:Map<String, ValEditorTemplate> = new Map<String, ValEditorTemplate>();
	static private var _uiClassMap:Map<String, Void->IValueUI> = new Map<String, Void->IValueUI>();
	
	static private var _liveActionManager:LiveInputActionManager;
	static private var _changeUpdateQueue:ChangeUpdateQueue;
	static private var _valEditUpdater:ValEditUpdater;
	static private var _zipSaveLoader:ZipSaveLoader;
	
	#if SWC
	// force some imports
	static private var __forceImport1:IContainerOpenFLEditable;
	#end
	
	static public function init(completeCallback:Void->Void):Void
	{
		actionStack = new ValEditorActionStack();
		if (assetFileLoader == null)
		{
			#if (desktop || air)
			assetFileLoader = new AssetFilesLoaderDesktop();
			#else
			assetFileLoader = new AssetFilesLoader();
			#end
		}
		if (containerController == null)
		{
			containerController = new ValEditorContainerController();
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
	
	static public function initSimple(completeCallback:Void->Void):Void
	{
		actionStack = new ValEditorActionStack();
		if (containerController == null)
		{
			containerController = new ValEditorContainerController();
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
		
		categoryCollection.sortCompareFunction = ArraySort.stringData;
		classCollection.sortCompareFunction = ArraySort.clss;
		templateCollection.sortCompareFunction = ArraySort.template;
		
		ValEdit.init(completeCallback);
	}
	
	static public function newFile():Void
	{
		isNewFile = true;
		#if !SWC
		var rootObject:ValEditorObject = createObjectWithClass(ValEditorContainerRoot, "root");
		openContainer(rootObject);
		#end
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
		if (assetFileLoader != null)
		{
			assetFileLoader.clear();
		}
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
		
		getClassDisplayObjectSettings(type, settings);
		getClassInteractiveSettings(type, settings);
		
		#if starling
		if (settings.isDisplayObject && settings.isDisplayObjectStarling)
		{
			settings.disposeFunctionName = "dispose";
			settings.hasRadianRotation = true;
			settings.usePivotScaling = true;
		}
		#end
		
		return settings;
	}
	
	static public function getClassDisplayObjectSettings(type:Class<Dynamic>, settings:ValEditorClassSettings):Void
	{
		var clss:Class<Dynamic> = type;
		if (clss == DisplayObject)
		{
			settings.isDisplayObject = true;
			settings.isDisplayObjectOpenFL = true;
		}
		#if starling
		else if (clss == starling.display.DisplayObject)
		{
			settings.isDisplayObject = true;
			settings.isDisplayObjectStarling = true;
		}
		#end
		else
		{
			while (true)
			{
				clss = Type.getSuperClass(clss);
				if (clss == null) break;
				if (clss == DisplayObject)
				{
					settings.isDisplayObject = true;
					settings.isDisplayObjectOpenFL = true;
					break;
				}
				#if starling
				else if (clss == starling.display.DisplayObject)
				{
					settings.isDisplayObject = true;
					settings.isDisplayObjectStarling = true;
					break;
				}
				#end
			}
		}
	}
	
	static public function getClassInteractiveSettings(type:Class<Dynamic>, settings:ValEditorClassSettings):Void
	{
		if (settings.isDisplayObject)
		{
			if (settings.isDisplayObjectOpenFL)
			{
				settings.interactiveFactory = InteractiveFactories.openFL_default;
			}
			#if starling
			else if (settings.isDisplayObjectStarling)
			{
				settings.interactiveFactory = InteractiveFactories.starling_default;
			}
			#end
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
		
		_classMap.set(className, v);
		
		var index:Int = className.lastIndexOf(".");
		v.classNameShort = className.substr(index + 1);
		v.classPackage = className.substr(0, index + 1);
		if (settings.exportClassName != null)
		{
			v.exportClassName = settings.exportClassName;
			index = settings.exportClassName.lastIndexOf(".");
			v.exportClassNameShort = settings.exportClassName.substr(index + 1);
			v.exportClassPackage = settings.exportClassName.substr(0, index + 1);
		}
		
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
		
		v.addToDisplayFunction = settings.addToDisplayFunction;
		v.addToDisplayFunctionName = settings.addToDisplayFunctionName;
		v.cloneFromFunctionName = settings.cloneFromFunctionName;
		v.cloneToFunctionName = settings.cloneToFunctionName;
		v.creationFunction = settings.creationFunction;
		v.creationFunctionForLoading = settings.creationFunctionForLoading;
		v.creationFunctionForTemplateInstance = settings.creationFunctionForTemplateInstance;
		v.creationInitFunction = settings.creationInitFunction;
		v.creationInitFunctionName = settings.creationInitFunctionName;
		v.disposeFunction = settings.disposeFunction;
		v.disposeFunctionName = settings.disposeFunctionName;
		v.exportClassName = settings.exportClassName;
		v.getBoundsFunctionName = settings.getBoundsFunctionName;
		v.hasRadianRotation = settings.hasRadianRotation;
		v.iconBitmapData = settings.iconBitmapData;
		v.interactiveFactory = settings.interactiveFactory;
		v.isContainer = settings.isContainer;
		v.isContainerOpenFL = settings.isContainerOpenFL;
		#if starling
		v.isContainerStarling = settings.isContainerStarling;
		#end
		v.isDisplayObject = settings.isDisplayObject;
		v.isDisplayObjectOpenFL = settings.isDisplayObjectOpenFL;
		#if starling
		v.isDisplayObjectStarling = settings.isDisplayObjectStarling;
		#end
		v.isTimeLineContainer = settings.isTimeLineContainer;
		v.propertyMap = settings.propertyMap != null ? settings.propertyMap : PropertyMap.fromPool();
		v.removeFromDisplayFunction = settings.removeFromDisplayFunction;
		v.removeFromDisplayFunctionName = settings.removeFromDisplayFunctionName;
		v.useBounds = settings.useBounds;
		v.usePivotScaling = settings.usePivotScaling;
		
		v.hasPivotProperties = checkForClassProperty(v, RegularPropertyName.PIVOT_X);
		v.hasScaleProperties = checkForClassProperty(v, RegularPropertyName.SCALE_X);
		v.hasVisibleProperty = checkForClassProperty(v, RegularPropertyName.VISIBLE);
		
		var clss:Class<Dynamic> = type;
		var superName:String;
		var nameList:Array<String>;
		
		nameList = _baseClassToClassList.get(className);
		if (nameList == null)
		{
			nameList = new Array<String>();
			_baseClassToClassList.set(className, nameList);
		}
		nameList.push(className);
		
		while (true)
		{
			clss = Type.getSuperClass(clss);
			if (clss == null) break;
			superName = Type.getClassName(clss);
			
			v.addSuperClassName(superName);
			
			nameList = _baseClassToClassList.get(superName);
			if (nameList == null)
			{
				nameList = new Array<String>();
				nameList.push(superName);
				_baseClassToClassList.set(superName, nameList);
			}
			nameList.push(className);
		}
		
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
		
		var objectList:Array<ValEditorObject> = valClass.getObjectList();
		
		if (valClass.canBeCreated)
		{
			for (obj in objectList)
			{
				destroyObjectInternal(obj);
			}
			
			classCollection.remove(valClass);
			_classToObjectCollection.remove(className);
		}
		else
		{
			for (obj in objectList)
			{
				unregisterObjectInternal(obj);
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
		
		clearUIContainer(container);
		
		if (object == null) return null;
		
		var clss:Class<Dynamic> = null;
		var className:String;
		var valClass:ValEditorClass;
		
		if (Std.isOfType(object, ValEditorObject))
		{
			valClass = cast(object, ValEditorObject).clss;
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
			return valClass.addUIContainer(container, object, collection, parentValue);
		}
		else
		{
			if (clss == null)
			{
				clss = Type.getClass(object);
			}
			while (true)
			{
				clss = Type.getSuperClass(clss);
				if (clss == null) break;
				className = Type.getClassName(clss);
				valClass = _classMap[className];
				if (valClass != null)
				{
					_displayMap[container] = valClass;
					return valClass.addUIContainer(container, object, collection, parentValue);
				}
			}
			throw new Error("ValEditor.edit ::: unknown Class " + Type.getClassName(Type.getClass(object)));
		}
	}
	
	static public function editValEditorObject(object:ValEditorObject, collection:ExposedCollection = null, container:DisplayObjectContainer = null):ExposedCollection
	{
		if (container == null) container = uiContainerDefault;
		if (container == null)
		{
			throw new Error("ValEditor.editValEditorObject ::: null container");
		}
		
		clearUIContainer(container);
		
		var valClass:ValEditorClass = getValEditorClassForClass(ValEditorObject);
		
		if (valClass == null)
		{
			throw new Error("ValEditor.editValEditorObject ::: ValEditorObject is not a registered class");
		}
		
		_displayMap[container] = valClass;
		return valClass.addUIContainer(container, object, collection, null, false);
	}
	
	static public function editClassVisibilitiesEditor():Void
	{
		FeathersWindows.showClassVisibilitiesWindow(editorSettings.customClassVisibilities, classVisibilities, "Editor classes visibilities");
	}
	
	static public function editClassVisibilitiesFile():Void
	{
		FeathersWindows.showClassVisibilitiesWindow(fileSettings.customClassVisibilities, editorSettings.customClassVisibilities, "File classes visibilities");
	}
	
	static public function editConstructor(className:String, ?uiContainer:DisplayObjectContainer):ExposedCollection
	{
		if (uiContainer == null) uiContainer = uiContainerDefault;
		if (uiContainer == null)
		{
			throw new Error("ValEditor.editConstructor ::: null container");
		}
		
		clearUIContainer(uiContainer);
		
		if (className == null) return null;
		
		var valClass:ValEditorClass = _classMap[className];
		if (valClass != null)
		{
			if (valClass.constructorCollection != null)
			{
				_displayMap[uiContainer] = valClass;
				return valClass.addConstructorUIContainer(uiContainer);
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
	   
	   @param	clss	a registered Class
	   @param	uiContainer	if left null uiContainerDefault is used
	**/
	static public function editConstructorWithClass<T>(clss:Class<T>, ?uiContainer:DisplayObjectContainer):ExposedCollection
	{
		return editConstructor(Type.getClassName(clss), uiContainer);
	}
	
	/**
	   
	   @param	template
	   @param	uiContainer
	**/
	static public function editTemplate(template:ValEditorTemplate, ?uiContainer:DisplayObjectContainer):Void
	{
		if (uiContainer == null) uiContainer = uiContainerDefault;
		if (uiContainer == null)
		{
			throw new Error("ValEditor.editTemplate ::: null container");
		}
		
		clearUIContainer(uiContainer);
		
		if (template == null) return;
		
		var valClass:ValEditorClass = template.clss;
		_displayMap[uiContainer] = valClass;
		valClass.addTemplateUIContainer(uiContainer, template);
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
			valClass.removeUIContainer(container);
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
		control.exposedValue = exposedValue;
		return control;
	}
	
	static public function createObjectWithClass(clss:Class<Dynamic>, id:String = null, params:Array<Dynamic> = null, collection:ExposedCollection = null, objectID:String = null, object:Dynamic = null, valObject:ValEditorObject = null):ValEditorObject
	{
		return createObjectWithClassName(Type.getClassName(clss), id, params, collection, objectID, object);
	}
	
	static public function createObjectWithClassName(className:String, id:String = null, params:Array<Dynamic> = null, collection:ExposedCollection = null, objectID:String = null, object:Dynamic = null, valObject:ValEditorObject = null):ValEditorObject
	{
		if (params == null) params = [];
		var valClass:ValEditorClass = _classMap.get(className);
		if (id == null)
		{
			id = valClass.makeObjectID();
		}
		if (valObject == null)
		{
			valObject = ValEditorObject.fromPool(valClass, id);
		}
		
		createObject(valObject, valClass, params, false, object);
		valObject.objectID = objectID;
		
		var collectionProvided:Bool = collection != null;
		if (collection == null)
		{
			collection = valClass.getCollection();
		}
		valObject.defaultCollection = collection;
		if (collectionProvided)
		{
			collection.applyAndSetObject(valObject.object);
		}
		else
		{
			collection.readAndSetObject(valObject.object);
		}
		
		valObject.applyClassVisibility(valClass.visibilityCollectionCurrent);
		
		valObject.getBoundsFunctionName = valClass.getBoundsFunctionName;
		valObject.hasPivotProperties = valClass.hasPivotProperties;
		valObject.hasScaleProperties = valClass.hasScaleProperties;
		valObject.hasVisibleProperty = valClass.hasVisibleProperty;
		valObject.hasRadianRotation = valClass.hasRadianRotation;
		valObject.propertyMap = valClass.propertyMap;
		valObject.useBounds = valClass.useBounds;
		valObject.usePivotScaling = valClass.usePivotScaling;
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
			interactiveObjectController.register(valObject.interactiveObject);
		}
		
		if (valObject.isCreationAsync)
		{
			valObject.loadSetup();
		}
		else
		{
			valObject.ready();
		}
		
		registerObjectInternal(valObject);
		
		return valObject;
	}
	
	static public function createObjectFromObject(object:Dynamic, id:String = null, objectID:String = null, collection:ExposedCollection = null):ValEditorObject
	{
		var valClass:ValEditorClass = getValEditorClassForObject(object);
		if (valClass == null)
		{
			throw new Error("ValEditor.createObjectFromObject ::: no ValEditorClass found for object");
		}
		return createObjectWithClassName(valClass.className, id, null, collection, objectID, object);
	}
	
	static private function createObject(valObject:ValEditorObject, valClass:ValEditorClass, params:Array<Dynamic>, isTemplateInstance:Bool, object:Dynamic = null):Void
	{
		if (object == null)
		{
			if (isLoadingFile && valClass.creationFunctionForLoading != null)
			{
				valObject.object = Reflect.callMethod(null, valClass.creationFunctionForLoading, params);
			}
			else if (isTemplateInstance && valClass.creationFunctionForTemplateInstance != null)
			{
				valObject.object = Reflect.callMethod(null, valClass.creationFunctionForTemplateInstance, params);
			}
			else if (valClass.creationFunction != null)
			{
				valObject.object = Reflect.callMethod(null, valClass.creationFunction, params);
			}
			else
			{
				valObject.object = Type.createInstance(valClass.classReference, params);
			}
			valObject.isExternal = false;
			if (!isLoadingFile) 
			{
				valObject.destroyOnCompletion = true;
			}
		}
		else
		{
			valObject.object = object;
			valObject.isExternal = true;
			valObject.destroyOnCompletion = false;
		}
		
		valObject.creationReadyEventName = valClass.creationReadyEventName;
		valObject.creationReadyRegisterFunctionName = valClass.creationReadyRegisterFunctionName;
		valObject.isContainer = valClass.isContainer;
		valObject.isContainerOpenFL = valClass.isContainerOpenFL;
		#if starling
		valObject.isContainerStarling = valClass.isContainerStarling;
		#end
		valObject.isTimeLineContainer = valClass.isTimeLineContainer;
		if (valClass.addToDisplayFunctionName != null)
		{
			valObject.addToDisplayFunction = Reflect.getProperty(valObject.object, valClass.addToDisplayFunctionName);
		}
		if (valClass.removeFromDisplayFunctionName != null)
		{
			valObject.removeFromDisplayFunction = Reflect.getProperty(valObject.object, valClass.removeFromDisplayFunctionName);
		}
		
		if (valClass.creationInitFunction != null)
		{
			Reflect.callMethod(null, valClass.creationInitFunction, [valObject.object]);
		}
		else if (valClass.creationInitFunctionName != null)
		{
			Reflect.callMethod(valObject.object, Reflect.getProperty(valObject.object, valClass.creationInitFunctionName), []);
		}
	}
	
	static public function createTemplateWithClass(clss:Class<Dynamic>, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		return createTemplateWithClassName(Type.getClassName(clss), id, constructorCollection);
	}
	
	static public function createTemplateWithClassName(className:String, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		var params:Array<Dynamic>;
		if (constructorCollection != null)
		{
			params = constructorCollection.toValueArray();
		}
		else
		{
			params = [];
		}
		
		var valClass:ValEditorClass = _classMap.get(className);
		
		var collection:ExposedCollection = valClass.getCollection();
		if (constructorCollection != null)
		{
			constructorCollection.copyValuesTo(collection);
		}
		
		var template:ValEditorTemplate = ValEditorTemplate.fromPool(valClass, id, collection, constructorCollection);
		template.object = createObjectWithTemplate(template, id, template.collection, false);
		template.object.currentCollection.read();
		
		var visibility:TemplateVisibilityCollection = TemplateVisibilityCollection.fromPool();
		visibility.populateFromClassVisibilityCollection(valClass.visibilityCollectionCurrent);
		template.visibilityCollectionDefault = visibility;
		
		registerTemplateInternal(template);
		
		return template;
	}
	
	/**
	   Creates a ValEditorObject from the specified template.
	   @param	template
	   @param	id
	   @param	collection
	   @param	objectID
	   @param	registerToTemplate	set to false only for the default template's object
	   @return
	**/
	static public function createObjectWithTemplate(template:ValEditorTemplate, ?id:String, ?collection:ExposedCollection, ?objectID:String, registerToTemplate:Bool = true):ValEditorObject
	{
		var valClass:ValEditorClass = template.clss;
		
		if (id == null)
		{
			id = template.makeObjectID();
		}
		
		var valObject:ValEditorObject = ValEditorObject.fromPool(valClass, id);
		
		var params:Array<Dynamic> = [];
		if (template.constructorCollection != null)
		{
			template.constructorCollection.toValueArray(params);
		}
		
		createObject(valObject, valClass, params, registerToTemplate);
		valObject.objectID = objectID;
		valObject.template = template;
		
		valObject.getBoundsFunctionName = valClass.getBoundsFunctionName;
		valObject.hasPivotProperties = valClass.hasPivotProperties;
		valObject.hasScaleProperties = valClass.hasScaleProperties;
		valObject.hasVisibleProperty = valClass.hasVisibleProperty;
		valObject.hasRadianRotation = valClass.hasRadianRotation;
		valObject.propertyMap = valClass.propertyMap;
		valObject.useBounds = valClass.useBounds;
		valObject.usePivotScaling = valClass.usePivotScaling;
		
		if (registerToTemplate)
		{
			if (valClass.cloneFromFunctionName != null)
			{
				Reflect.callMethod(valObject.object, Reflect.getProperty(valObject.object, valClass.cloneFromFunctionName), [template.object.object]);
			}
			else if (valClass.cloneToFunctionName != null)
			{
				Reflect.callMethod(template.object.object, Reflect.getProperty(template.object.object, valClass.cloneToFunctionName), [valObject.object]);
			}
			template.addInstance(valObject);
			
			// apply template values
			// this is only for template instances
			template.collection.applyToObject(valObject.object);
		}
		
		//template.collection.applyToObject(valObject.object);
		
		if (collection == null)
		{
			collection = valClass.getCollection();
			collection.readAndSetObject(valObject.object);
		}
		else
		{
			if (registerToTemplate)
			{
				collection.applyAndSetObject(valObject.object);
			}
			else
			{
				collection.readAndSetObject(valObject.object);
			}
		}
		valObject.defaultCollection = collection;
		
		valObject.ready();
		
		if (valClass.interactiveFactory != null)
		{
			valObject.interactiveObject = valClass.interactiveFactory(valObject);
			interactiveObjectController.register(valObject.interactiveObject);
		}
		
		if (registerToTemplate)
		{
			valObject.applyTemplateVisibility(template.visibilityCollectionCurrent);
			registerObjectInternal(valObject);
		}
		
		return valObject;
	}
	
	static public function cloneObject(object:ValEditorObject, ?id:String):ValEditorObject
	{
		var newObject:ValEditorObject;
		if (object.template != null)
		{
			newObject = createObjectWithTemplate(object.template, id, object.currentCollection.clone(true), object.objectID);
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
		// DEBUG : all objects should have an id when registered
		if (valObject.id == null)
		{
			throw new Error("ValEditor.registerObjectInternal ::: null object id");
		}
		//\DEBUG
		valObject.clss.addObject(valObject);
		
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
	}
	
	static public function registerTemplate(template:ValEditorTemplate):Void
	{
		registerTemplateInternal(template);
	}
	
	static private function registerTemplateInternal(template:ValEditorTemplate):Void
	{
		template.clss.addTemplate(template);
		_templateMap.set(template.id, template);
		
		template.addEventListener(TemplateEvent.INSTANCE_ADDED, onTemplateInstanceAdded);
		template.addEventListener(TemplateEvent.INSTANCE_REMOVED, onTemplateInstanceRemoved);
		template.addEventListener(TemplateEvent.INSTANCE_SUSPENDED, onTemplateInstanceSuspended);
		template.addEventListener(TemplateEvent.INSTANCE_UNSUSPENDED, onTemplateInstanceUnsuspended);
		template.addEventListener(RenameEvent.RENAMED, onTemplateRenamed);
		templateCollection.add(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.clss.className);
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
		
		template.isInLibrary = true;
	}
	
	static public function destroyObject(valObject:ValEditorObject):Void
	{
		destroyObjectInternal(valObject);
	}
	
	static private function destroyObjectInternal(valObject:ValEditorObject):Void
	{
		if (!valObject.isExternal)
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
		valObject.clss.removeObject(valObject);
		
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
		if (template.object != null)
		{
			destroyObject(template.object);
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
		template.clss.removeTemplate(template);
		_templateMap.remove(template.id);
		
		template.removeEventListener(TemplateEvent.INSTANCE_ADDED, onTemplateInstanceAdded);
		template.removeEventListener(TemplateEvent.INSTANCE_REMOVED, onTemplateInstanceRemoved);
		template.removeEventListener(TemplateEvent.INSTANCE_SUSPENDED, onTemplateInstanceSuspended);
		template.removeEventListener(TemplateEvent.INSTANCE_UNSUSPENDED, onTemplateInstanceUnsuspended);
		template.removeEventListener(RenameEvent.RENAMED, onTemplateRenamed);
		templateCollection.remove(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.clss.className);
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
	
	static public function getClassListForBaseClass(baseClassName:String):Array<String>
	{
		return _baseClassToClassList.get(baseClassName);
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
		var valClass:ValEditorClass = getValEditorClassForClass(ValEdit.getObjectClass(object));
		if (valClass != null)
		{
			return valClass.getCollection();
		}
		return null;
	}
	
	static public function getValEditorClassForClass(clss:Class<Dynamic>, strict:Bool = false):ValEditorClass
	{
		var className:String = Type.getClassName(clss);
		if (_classMap.exists(className))
		{
			return _classMap.get(className);
		}
		else if (!strict)
		{
			var valClass:ValEditorClass;
			while (true)
			{
				clss = Type.getSuperClass(clss);
				if (clss == null) break;
				className = Type.getClassName(clss);
				valClass = _classMap.get(className);
				if (valClass != null) return valClass;
			}
		}
		return null;
	}
	
	static public function getValEditorClassForClassName(className:String):ValEditorClass
	{
		return _classMap.get(className);
	}
	
	static public function getValEditorClassForObject(object:Dynamic, strict:Bool = false):ValEditorClass
	{
		return getValEditorClassForClass(Type.getClass(object));
	}
	
	static public function getObjectUICollectionForClass(clss:Class<Dynamic>):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(Type.getClassName(clss));
	}
	
	static public function getObjectUICollectionForClassName(className:String):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(className);
	}
	
	static public function getTemplate(id:String):ValEditorTemplate
	{
		return _templateMap.get(id);
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
	
	static public function setupTimeLineContainer(container:ITimeLineContainerEditable):Void
	{
		container.autoIncreaseNumFrames = fileSettings.numFramesAutoIncrease;
		container.frameRate = fileSettings.frameRateDefault;
		container.numFrames = fileSettings.numFramesDefault;
		container.frameIndex = 0;
		var layer:ITimeLineLayerEditable = container.createLayer();
		container.addLayer(layer);
		layer.timeLine.insertKeyFrame();
	}
	
	#if starling
	static public function createContainerRoot():ValEditorContainerRoot
	{
		var container:ValEditorContainerRoot = ValEditorContainerRoot.fromPool();
		container.autoIncreaseNumFrames = fileSettings.numFramesAutoIncrease;
		container.numFrames = fileSettings.numFramesDefault;
		container.frameIndex = 0;
		var layer:ITimeLineLayerEditable = container.createLayer();
		container.addLayer(layer);
		return container;
	}
	#end
	
	static public function createKeyFrame():ValEditorKeyFrame
	{
		var keyFrame:ValEditorKeyFrame = ValEditorKeyFrame.fromPool();
		keyFrame.transition = fileSettings.tweenTransitionDefault;
		return keyFrame;
	}
	
	//static public function createLayer():LayerOpenFLStarlingEditable
	//{
		//var layer:LayerOpenFLStarlingEditable = LayerOpenFLStarlingEditable.fromPool();
		//layer.timeLine.numFrames = fileSettings.numFramesDefault;
		//layer.timeLine.frameIndex = 0;
		//layer.timeLine.insertKeyFrame();
		//return layer;
	//}
	
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
	
	static public function erase(action:MultiAction):Void
	{
		var selectionClear:SelectionClear = SelectionClear.fromPool();
		selectionClear.setup(selection);
		
		selection.erase(action);
		
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
		
		currentTimeLineContainer.currentLayer.timeLine.insertFrame(action);
	}
	
	static public function insertKeyFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		currentTimeLineContainer.currentLayer.timeLine.insertKeyFrame(action);
	}
	
	static public function removeFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		currentTimeLineContainer.currentLayer.timeLine.removeFrame(action);
	}
	
	static public function removeKeyFrame(?action:MultiAction):Void
	{
		if (currentTimeLineContainer == null) return;
		if (currentTimeLineContainer.isPlaying) return;
		if (currentTimeLineContainer.currentLayer == null) return;
		
		currentTimeLineContainer.currentLayer.timeLine.removeKeyFrame(action);
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
	
	static private function onOpenContainerObjectRenamed(evt:RenameEvent):Void
	{
		openedContainerCollection.updateAt(openedContainerCollection.indexOf(cast evt.target));
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
		
		for (category in evt.template.clss.categories)
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
		
		for (category in evt.template.clss.categories)
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
		
		for (category in evt.template.clss.categories)
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
		
		for (category in evt.template.clss.categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			index = collection.indexOf(evt.template);
			if (index != -1) collection.updateAt(index);
		}
	}
	
	static private function onTemplateRenamed(evt:RenameEvent):Void
	{
		var template:ValEditorTemplate = evt.target;
		
		_templateMap.remove(evt.previousNameOrID);
		_templateMap.set(template.id, template);
		
		templateCollection.updateAt(templateCollection.indexOf(template));
		
		var collection:ArrayCollection<ValEditorTemplate>;
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.updateAt(collection.indexOf(template));
		}
		
		for (category in template.clss.categories)
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
		#if !SWC
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
				template.fromJSONSave(data);
			}
		}
		
		container.fromJSONSave(json.root);
		isLoadingFile = false;
		
		openContainer(rootObject);
		#end
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
			cast(template.object.object, IContainerEditable).getContainerDependencies(saveData);
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
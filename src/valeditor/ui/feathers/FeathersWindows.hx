package valeditor.ui.feathers;
import feathers.core.PopUpManager;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.events.MouseEvent;
import valedit.ExposedCollection;
import valedit.ValEditObject;
import valeditor.ValEditorLayer;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.editor.settings.EditorSettings;
import valeditor.editor.settings.ExportSettings;
import valeditor.editor.settings.FileSettings;
import valeditor.editor.visibility.ClassVisibilitiesCollection;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.ui.InteractiveObjectController;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.window.ClassVisibilitiesWindow;
import valeditor.ui.feathers.window.ClassVisibilityWindow;
import valeditor.ui.feathers.window.CreditsWindow;
import valeditor.ui.feathers.window.EditorSettingsWindow;
import valeditor.ui.feathers.window.ExportSettingsWindow;
import valeditor.ui.feathers.window.FileSettingsWindow;
import valeditor.ui.feathers.window.InteractiveObjectDebugWindow;
import valeditor.ui.feathers.window.LayerRenameWindow;
import valeditor.ui.feathers.window.MessageConfirmWindow;
import valeditor.ui.feathers.window.MessageWindow;
import valeditor.ui.feathers.window.ObjectAddWindow;
import valeditor.ui.feathers.window.ObjectCreationWindow;
import valeditor.ui.feathers.window.ObjectRenameWindow;
import valeditor.ui.feathers.window.ObjectSelectWindow;
import valeditor.ui.feathers.window.StartMenuWindow;
import valeditor.ui.feathers.window.TemplateCreationWindow;
import valeditor.ui.feathers.window.TemplateRenameWindow;
import valeditor.ui.feathers.window.TemplateVisibilityWindow;
import valeditor.ui.feathers.window.ThemeEditWindow;
import valeditor.ui.feathers.window.VersionsWindow;
import valeditor.ui.feathers.window.asset.AssetBrowser;
import valeditor.ui.feathers.window.asset.BinaryAssetsWindow;
import valeditor.ui.feathers.window.asset.BitmapAssetsWindow;
import valeditor.ui.feathers.window.ObjectEditWindow;
import valeditor.ui.feathers.window.asset.SoundAssetsWindow;
import valeditor.ui.feathers.window.asset.TextAssetsWindow;
import valedit.asset.BinaryAsset;
import valedit.asset.BitmapAsset;
import valedit.asset.SoundAsset;
import valedit.asset.TextAsset;
#if starling
import valedit.asset.starling.StarlingAtlasAsset;
import valeditor.ui.feathers.window.asset.starling.StarlingAtlasAssetsWindow;
import valedit.asset.starling.StarlingTextureAsset;
import valeditor.ui.feathers.window.asset.starling.StarlingTextureAssetsWindow;
#end
import valeditor.ui.UIConfig;

/**
 * ...
 * @author Matse
 */
class FeathersWindows 
{
	static public var isWindowOpen(get, never):Bool;
	
	static private function get_isWindowOpen():Bool { return _windowList.length != 0; }
	
	// Assets
	static private var _assetBrowser:AssetBrowser;
	
	static private var _binaryAssets:BinaryAssetsWindow;
	static private var _bitmapAssets:BitmapAssetsWindow;
	static private var _soundAssets:SoundAssetsWindow;
	static private var _textAssets:TextAssetsWindow;
	#if starling
	static private var _starlingAtlasAssets:StarlingAtlasAssetsWindow;
	static private var _starlingTextureAssets:StarlingTextureAssetsWindow;
	#end
	
	static private var _credits:CreditsWindow;
	static private var _versions:VersionsWindow;
	
	static private var _editorSettings:EditorSettingsWindow;
	static private var _themeEdit:ThemeEditWindow;
	static private var _exportSettings:ExportSettingsWindow;
	static private var _fileSettings:FileSettingsWindow;
	
	static private var _layerRename:LayerRenameWindow;
	
	static private var _messageWindow:MessageWindow;
	static private var _messageConfirmWindow:MessageConfirmWindow;
	
	static private var _objectAdd:ObjectAddWindow;
	static private var _objectCreate:ObjectCreationWindow;
	static private var _objectEdit:ObjectEditWindow;
	static private var _objectRename:ObjectRenameWindow;
	static private var _objectSelect:ObjectSelectWindow;
	
	static private var _startMenu:StartMenuWindow;
	
	static private var _templateCreate:TemplateCreationWindow;
	static private var _templateRename:TemplateRenameWindow;
	
	static private var _classVisibilities:ClassVisibilitiesWindow;
	static private var _classVisibility:ClassVisibilityWindow;
	static private var _templateVisibility:TemplateVisibilityWindow;
	
	static private var _interactiveObjectsDebug:InteractiveObjectDebugWindow;
	
	static private var _windowList:Array<DisplayObject> = new Array<DisplayObject>();
	
	static public function closeAll():Void
	{
		var windows:Array<DisplayObject> = _windowList.copy();
		for (window in windows)
		{
			closeWindow(window);
		}
	}
	
	static private function openWindow(window:DisplayObject):Void
	{
		//window.addEventListener(MouseEvent.CLICK, onMouseClick);
		//window.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		//window.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		//window.addEventListener(MouseEvent.RIGHT_CLICK, onRightMouseClick);
		//window.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		//window.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
		
		_windowList.push(window);
		PopUpManager.addPopUp(window, Lib.current.stage);
	}
	
	static public function closeWindow(window:DisplayObject):Void
	{
		//window.removeEventListener(MouseEvent.CLICK, onMouseClick);
		//window.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		//window.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		//window.removeEventListener(MouseEvent.RIGHT_CLICK, onRightMouseClick);
		//window.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		//window.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
		
		_windowList.remove(window);
		PopUpManager.removePopUp(window);
	}
	
	static private function getLargeWindowWidth():Float
	{
		// was Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2.0;
		return Lib.current.stage.stageWidth * 0.8;
	}
	
	static private function getLargeWindowHeight():Float
	{
		// was Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2.0;
		return Lib.current.stage.stageHeight * 0.8;
	}
	
	static private function getMediumWindowWidth():Float
	{
		// was Lib.current.stage.stageWidth / 2.0;
		return Lib.current.stage.stageWidth * 0.5;
	}
	
	static private function getMediumWindowHeight():Float
	{
		// was Lib.current.stage.stageHeight / 2.0;
		return Lib.current.stage.stageHeight * 0.5;
	}
	
	static private function getSmallWindowWidth():Float
	{
		return Lib.current.stage.stageWidth * 0.33;
	}
	
	static private function getSmallWindowHeight():Float
	{
		return Lib.current.stage.stageHeight * 0.33;
	}
	
	static public function showAssetBrowser():Void
	{
		if (_assetBrowser == null)
		{
			_assetBrowser = new AssetBrowser();
		}
		
		_assetBrowser.width = getLargeWindowWidth();
		_assetBrowser.height = getLargeWindowHeight();
		
		openWindow(_assetBrowser);
	}
	
	static public function toggleAssetBrowser():Void
	{
		if (_assetBrowser == null)
		{
			showAssetBrowser();
		}
		else
		{
			if (_assetBrowser.stage == null)
			{
				showAssetBrowser();
			}
			else
			{
				closeWindow(_assetBrowser);
			}
		}
	}
	
	static public function showBinaryAssets(?selectionCallback:BinaryAsset->Void, ?cancelCallback:Void->Void, title:String = "Binary assets"):Void
	{
		if (_binaryAssets == null)
		{
			_binaryAssets = new BinaryAssetsWindow();
			_binaryAssets.closeOnSelection = true;
			_binaryAssets.cancelEnabled = true;
		}
		
		_binaryAssets.reset();
		_binaryAssets.title = title;
		_binaryAssets.cancelCallback = cancelCallback;
		_binaryAssets.selectionCallback = selectionCallback;
		
		_binaryAssets.width = getLargeWindowWidth();
		_binaryAssets.height = getLargeWindowHeight();
		
		openWindow(_binaryAssets);
	}
	
	static public function showBitmapAssets(?selectionCallback:BitmapAsset->Void, ?cancelCallback:Void->Void, title:String = "Bitmap assets"):Void
	{
		if (_bitmapAssets == null)
		{
			_bitmapAssets = new BitmapAssetsWindow();
			_bitmapAssets.closeOnSelection = true;
			_bitmapAssets.cancelEnabled = true;
		}
		
		_bitmapAssets.reset();
		_bitmapAssets.title = title;
		_bitmapAssets.cancelCallback = cancelCallback;
		_bitmapAssets.selectionCallback = selectionCallback;
		
		_bitmapAssets.width = getLargeWindowWidth();
		_bitmapAssets.height = getLargeWindowHeight();
		
		openWindow(_bitmapAssets);
	}
	
	static public function showSoundAssets(?selectionCallback:SoundAsset->Void, ?cancelCallback:Void->Void, title:String = "Sound assets"):Void
	{
		if (_soundAssets == null)
		{
			_soundAssets = new SoundAssetsWindow();
			_soundAssets.closeOnSelection = true;
			_soundAssets.cancelEnabled = true;
		}
		
		_soundAssets.reset();
		_soundAssets.title = title;
		_soundAssets.cancelCallback = cancelCallback;
		_soundAssets.selectionCallback = selectionCallback;
		
		_soundAssets.width = getLargeWindowWidth();
		_soundAssets.height = getLargeWindowHeight();
		
		openWindow(_soundAssets);
	}
	
	static public function showTextAssets(?selectionCallback:TextAsset->Void, ?cancelCallback:Void->Void, title:String = "Text assets"):Void
	{
		if (_textAssets == null)
		{
			_textAssets = new TextAssetsWindow();
			_textAssets.closeOnSelection = true;
			_textAssets.cancelEnabled = true;
		}
		
		_textAssets.reset();
		_textAssets.title = title;
		_textAssets.cancelCallback = cancelCallback;
		_textAssets.selectionCallback = selectionCallback;
		
		_textAssets.width = getLargeWindowWidth();
		_textAssets.height = getLargeWindowHeight();
		
		openWindow(_textAssets);
	}
	
	#if starling
	static public function showStarlingAtlasAssetsWindow(?selectionCallback:StarlingAtlasAsset->Void, ?cancelCallback:Void->Void, title:String = "Starling Atlas assets"):Void
	{
		if (_starlingAtlasAssets == null)
		{
			_starlingAtlasAssets = new StarlingAtlasAssetsWindow();
			_starlingAtlasAssets.closeOnSelection = true;
			_starlingAtlasAssets.cancelEnabled = true;
		}
		
		_starlingAtlasAssets.reset();
		_starlingAtlasAssets.title = title;
		_starlingAtlasAssets.cancelCallback = cancelCallback;
		_starlingAtlasAssets.selectionCallback = selectionCallback;
		
		_starlingAtlasAssets.width = getLargeWindowWidth();
		_starlingAtlasAssets.height = getLargeWindowHeight();
		
		openWindow(_starlingAtlasAssets);
	}
	
	static public function showStarlingTextureAssetsWindow(?selectionCallback:StarlingTextureAsset->Void, ?cancelCallback:Void->Void, title:String = "Starling Texture assets"):Void
	{
		if (_starlingTextureAssets == null)
		{
			_starlingTextureAssets = new StarlingTextureAssetsWindow();
			_starlingTextureAssets.closeOnSelection = true;
			_starlingTextureAssets.cancelEnabled = true;
		}
		
		_starlingTextureAssets.reset();
		_starlingTextureAssets.title = title;
		_starlingTextureAssets.cancelCallback = cancelCallback;
		_starlingTextureAssets.selectionCallback = selectionCallback;
		
		_starlingTextureAssets.width = getLargeWindowWidth();
		_starlingTextureAssets.height = getLargeWindowHeight();
		
		openWindow(_starlingTextureAssets);
	}
	#end
	
	static public function showCreditsWindow():Void
	{
		if (_credits == null)
		{
			_credits = new CreditsWindow();
		}
		
		_credits.width = getMediumWindowWidth();
		_credits.height = getMediumWindowHeight();
		
		openWindow(_credits);
	}
	
	static public function showVersionsWindow():Void
	{
		if (_versions == null)
		{
			_versions = new VersionsWindow();
		}
		
		openWindow(_versions);
	}
	
	static public function showEditorSettingsWindow(settings:EditorSettings, title:String, confirmCallback:Void->Void = null, cancelCallback:Void->Void = null):Void
	{
		if (_editorSettings == null)
		{
			_editorSettings = new EditorSettingsWindow();
		}
		
		_editorSettings.settings = settings;
		_editorSettings.title = title;
		_editorSettings.cancelCallback = cancelCallback;
		_editorSettings.confirmCallback = confirmCallback;
		
		_editorSettings.width = getMediumWindowWidth();
		_editorSettings.height = getMediumWindowHeight();
		
		openWindow(_editorSettings);
	}
	
	static public function showThemeEditWindow(theme:ValEditorTheme, customCollection:ExposedCollection, defaultCollection:ExposedCollection, title:String, confirmCallback:Void->Void = null, cancelCallback:Void->Void = null):Void
	{
		if (_themeEdit == null)
		{
			_themeEdit = new ThemeEditWindow();
		}
		
		_themeEdit.setTheme(theme, customCollection, defaultCollection);
		_themeEdit.title = title;
		_themeEdit.confirmCallback = confirmCallback;
		_themeEdit.cancelCallback = cancelCallback;
		
		_themeEdit.width = getMediumWindowWidth();
		_themeEdit.height = getLargeWindowHeight();
		
		openWindow(_themeEdit);
	}
	
	static public function showExportSettingsWindow(settings:ExportSettings, confirmCallback:Void->Void = null, cancelCallback:Void->Void = null):Void
	{
		if (_exportSettings == null)
		{
			_exportSettings = new ExportSettingsWindow();
		}
		
		_exportSettings.settings = settings;
		_exportSettings.cancelCallback = cancelCallback;
		_exportSettings.confirmCallback = confirmCallback;
		
		_exportSettings.width = getMediumWindowWidth();
		_exportSettings.height = getMediumWindowHeight();
		
		openWindow(_exportSettings);
	}
	
	static public function showFileSettingsWindow(settings:FileSettings, title:String, confirmCallback:Void->Void = null, cancelCallback:Void->Void = null):Void
	{
		if (_fileSettings == null)
		{
			_fileSettings = new FileSettingsWindow();
		}
		
		_fileSettings.settings = settings;
		_fileSettings.title = title;
		_fileSettings.cancelCallback = cancelCallback;
		_fileSettings.confirmCallback = confirmCallback;
		
		_fileSettings.width = getMediumWindowWidth();
		_fileSettings.height = getMediumWindowHeight();
		
		openWindow(_fileSettings);
	}
	
	static public function showLayerRenameWindow(layer:ValEditorLayer, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void):Void
	{
		if (_layerRename == null)
		{
			_layerRename = new LayerRenameWindow();
		}
		
		_layerRename.layer = layer;
		_layerRename.confirmCallback = confirmCallback;
		_layerRename.cancelCallback = cancelCallback;
		
		_layerRename.width = getMediumWindowWidth();
		
		openWindow(_layerRename);
	}
	
	static public function showMessageWindow(title:String, message:String):Void
	{
		if (_messageWindow == null)
		{
			_messageWindow = new MessageWindow();
		}
		
		_messageWindow.title = title;
		_messageWindow.message = message;
		
		_messageWindow.width = getSmallWindowWidth();
		_messageWindow.validateNow();
		
		openWindow(_messageWindow);
	}
	
	static public function hideMessageWindow():Void
	{
		if (_messageWindow == null) return;
		
		closeWindow(_messageWindow);
	}
	
	static public function showMessageConfirmWindow(title:String, message:String, confirmCallback:Void->Void):Void
	{
		if (_messageConfirmWindow == null)
		{
			_messageConfirmWindow = new MessageConfirmWindow();
		}
		
		_messageConfirmWindow.title = title;
		_messageConfirmWindow.message = message;
		_messageConfirmWindow.confirmCallback = confirmCallback;
		
		_messageConfirmWindow.width = getSmallWindowWidth();
		_messageConfirmWindow.validateNow();
		
		openWindow(_messageConfirmWindow);
	}
	
	static public function showObjectAddWindow(reusableObjects:Array<ValEditObject>, newObjectCallback:Void->Void, reuseObjectCallback:Dynamic->Void, cancelCallback:Void->Void, title:String = "Add Object"):Void
	{
		if (_objectAdd == null)
		{
			_objectAdd = new ObjectAddWindow();
		}
		
		_objectAdd.title = title;
		_objectAdd.newObjectCallback = newObjectCallback;
		_objectAdd.reuseObjectCallback = reuseObjectCallback;
		_objectAdd.reusableObjects = reusableObjects;
		_objectAdd.cancelCallback = cancelCallback;
		_objectAdd.reset();
		
		_objectAdd.width = getMediumWindowWidth();
		_objectAdd.height = getMediumWindowHeight();
		
		openWindow(_objectAdd);
	}
	
	static public function showObjectCreationWindow(?confirmCallback:Dynamic->Void, ?cancelCallback:Void->Void, title:String = "Create Object"):Void
	{
		if (_objectCreate == null)
		{
			_objectCreate = new ObjectCreationWindow();
		}
		
		_objectCreate.title = title;
		_objectCreate.confirmCallback = confirmCallback;
		_objectCreate.cancelCallback = cancelCallback;
		_objectCreate.reset();
		
		_objectCreate.width = getMediumWindowWidth();
		_objectCreate.height = getLargeWindowHeight();
		
		openWindow(_objectCreate);
	}
	
	static public function showObjectEditWindow(object:Dynamic, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void, ?title:String):Void
	{
		if (_objectEdit == null)
		{
			_objectEdit = new ObjectEditWindow();
		}
		
		_objectEdit.title = title;
		_objectEdit.editObject = object;
		_objectEdit.cancelCallback = cancelCallback;
		_objectEdit.confirmCallback = confirmCallback;
		
		_objectEdit.width = getMediumWindowWidth();
		_objectEdit.height = getLargeWindowHeight();
		
		openWindow(_objectEdit);
	}
	
	static public function showObjectRenameWindow(object:ValEditorObject, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void):Void
	{
		if (_objectRename == null)
		{
			_objectRename = new ObjectRenameWindow();
		}
		
		_objectRename.object = object;
		_objectRename.confirmCallback = confirmCallback;
		_objectRename.cancelCallback = cancelCallback;
		
		_objectRename.width = getMediumWindowWidth();
		
		openWindow(_objectRename);
	}
	
	static public function showObjectSelectWindow(confirmCallback:Dynamic->Void, ?cancelCallback:Void->Void, ?allowedClassNames:Array<String>, ?allowedCategories:Array<String>, ?excludeObjects:Array<Dynamic>, title:String = "Select Object"):Void
	{
		if (_objectSelect == null)
		{
			_objectSelect = new ObjectSelectWindow();
		}
		
		_objectSelect.title = title;
		_objectSelect.cancelCallback = cancelCallback;
		_objectSelect.confirmCallback = confirmCallback;
		_objectSelect.reset(allowedClassNames, excludeObjects);
		
		_objectSelect.width = getMediumWindowWidth();
		_objectSelect.height = getLargeWindowHeight();
		
		openWindow(_objectSelect);
	}
	
	static public function showStartMenuWindow(newFileCallback:Void->Void, loadFileCallback:Void->Void):Void
	{
		if (_startMenu == null)
		{
			_startMenu = new StartMenuWindow();
		}
		
		_startMenu.newFileCallback = newFileCallback;
		_startMenu.loadFileCallback = loadFileCallback;
		
		_startMenu.width = getMediumWindowWidth();
		
		openWindow(_startMenu);
	}
	
	static public function closeStartMenuWindow():Void
	{
		if (_startMenu == null)
		{
			return;
		}
		
		if (_startMenu.stage != null)
		{
			closeWindow(_startMenu);
		}
	}
	
	static public function showTemplateCreationWindow(?confirmCallback:ValEditorTemplate->Void, ?cancelCallback:Void->Void, title:String = "Create Template"):Void
	{
		if (_templateCreate == null)
		{
			_templateCreate = new TemplateCreationWindow();
		}
		
		_templateCreate.title = title;
		_templateCreate.confirmCallback = confirmCallback;
		_templateCreate.cancelCallback = cancelCallback;
		_templateCreate.reset();
		
		_templateCreate.width = getMediumWindowWidth();
		_templateCreate.height = getLargeWindowHeight();
		
		openWindow(_templateCreate);
	}
	
	static public function showTemplateRenameWindow(template:ValEditorTemplate, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void):Void
	{
		if (_templateRename == null)
		{
			_templateRename = new TemplateRenameWindow();
		}
		
		_templateRename.template = template;
		_templateRename.confirmCallback = confirmCallback;
		_templateRename.cancelCallback = cancelCallback;
		
		_templateRename.width = getMediumWindowWidth();
		
		openWindow(_templateRename);
	}
	
	static public function showClassVisibilitiesWindow(collection:ClassVisibilitiesCollection, defaultCollection:ClassVisibilitiesCollection, title:String, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void):Void
	{
		if (_classVisibilities == null)
		{
			_classVisibilities = new ClassVisibilitiesWindow();
		}
		
		_classVisibilities.title = title;
		_classVisibilities.visibilitiesCollection = collection;
		_classVisibilities.visibilitiesCollectionDefault = defaultCollection;
		_classVisibilities.confirmCallback = confirmCallback;
		_classVisibilities.cancelCallback = cancelCallback;
		
		_classVisibilities.width = getMediumWindowWidth();
		_classVisibilities.height = getLargeWindowHeight();
		
		openWindow(_classVisibilities);
	}
	
	static public function showClassVisibilityWindow(collection:ClassVisibilityCollection, defaultCollection:ClassVisibilityCollection, title:String, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void):Void
	{
		if (_classVisibility == null)
		{
			_classVisibility = new ClassVisibilityWindow();
		}
		
		_classVisibility.title = title;
		_classVisibility.visibilityCollection = collection;
		_classVisibility.visibilityCollectionDefault = defaultCollection;
		_classVisibility.confirmCallback = confirmCallback;
		_classVisibility.cancelCallback = cancelCallback;
		
		_classVisibility.width = getMediumWindowWidth();
		_classVisibility.height = getLargeWindowHeight();
		
		openWindow(_classVisibility);
	}
	
	static public function showTemplateVisibilityWindow(collection:TemplateVisibilityCollection, defaultCollection:TemplateVisibilityCollection, title:String, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void):Void
	{
		if (_templateVisibility == null)
		{
			_templateVisibility = new TemplateVisibilityWindow();
		}
		
		_templateVisibility.title = title;
		_templateVisibility.visibilityCollection = collection;
		_templateVisibility.visibilityCollectionDefault = defaultCollection;
		_templateVisibility.confirmCallback = confirmCallback;
		_templateVisibility.cancelCallback = cancelCallback;
		
		_templateVisibility.width = getMediumWindowWidth();
		_templateVisibility.height = getLargeWindowHeight();
		
		openWindow(_templateVisibility);
	}
	
	static public function showInteractiveObjectDebugWindow(controller:InteractiveObjectController):Void
	{
		if (_interactiveObjectsDebug == null)
		{
			_interactiveObjectsDebug = new InteractiveObjectDebugWindow();
		}
		
		_interactiveObjectsDebug.controller = controller;
		
		_interactiveObjectsDebug.width = getMediumWindowWidth();
		
		openWindow(_interactiveObjectsDebug);
	}
	
	static private function onMouseClick(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	static private function onMouseDown(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	static private function onMouseUp(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	static private function onRightMouseClick(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	static private function onRightMouseDown(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	static private function onRightMouseUp(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	
	
}
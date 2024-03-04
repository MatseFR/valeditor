package valeditor.editor.base;
import feathers.controls.navigators.StackItem;
import feathers.data.ArrayCollection;
import haxe.io.Path;
import inputAction.InputAction;
import inputAction.controllers.KeyAction;
import inputAction.events.InputActionEvent;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.filters.BlurFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
import openfl.utils.Assets;
import valedit.DisplayObjectType;
import valedit.ValEdit;
import valedit.asset.AssetLib;
import valedit.asset.AssetType;
import valedit.data.feathers.themes.SimpleThemeData;
import valedit.data.openfl.display.DisplayData;
import valedit.data.openfl.filters.FiltersData;
import valedit.data.openfl.geom.GeomData;
import valedit.data.openfl.text.TextData;
import valedit.data.starling.text.StarlingTextData;
import valedit.data.valedit.ShapeData;
import valedit.data.valeditor.ContainerData;
import valedit.data.valeditor.SettingsData;
import valedit.object.openfl.display.ArcShape;
import valedit.object.openfl.display.BurstShape;
import valedit.object.openfl.display.CircleShape;
import valedit.object.openfl.display.EllipseShape;
import valedit.object.openfl.display.FlowerShape;
import valedit.object.openfl.display.GearShape;
import valedit.object.openfl.display.PolygonShape;
import valedit.object.openfl.display.RectangleShape;
import valedit.object.openfl.display.RoundRectangleShape;
import valedit.object.openfl.display.StarShape;
import valedit.object.openfl.display.WedgeShape;
import valeditor.ValEditorContainer;
import valeditor.ValEditorKeyFrame;
import valeditor.editor.UIAssets;
import valeditor.editor.action.MultiAction;
import valeditor.editor.file.FileController;
import valeditor.editor.settings.ExportSettings;
import valeditor.editor.settings.FileSettings;
import valeditor.events.SelectionEvent;
import valeditor.input.InputActionID;
import valeditor.ui.InteractiveFactories;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.view.EditorView;

#if air
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import flash.events.NativeDragEvent;
import flash.filesystem.File;
#elseif desktop
import openfl.filesystem.File;
#else
import js.html.FileList;
import openfl.net.FileReference;
import valeditor.utils.file.FileReaderLoader;
#end

#if starling
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import valedit.data.starling.display.StarlingDisplayData;
import valedit.data.starling.texture.StarlingTextureData;
import valeditor.utils.starling.TextureCreationParameters;
#end

/**
 * ...
 * @author Matse
 */
class ValEditorFull extends ValEditorBaseFeathers
{
	public var editView(default, null):EditorView;
	
	private var _fileSettings:FileSettings = new FileSettings();
	private var _isStartUp:Bool = true;
	
	#if html5
	private var _fileReaderLoader:FileReaderLoader = new FileReaderLoader();
	#end
	
	// file menu
	private var _fileMenuCollection:ArrayCollection<MenuItem>;
	private var _newFileItem:MenuItem;
	private var _openFileItem:MenuItem;
	private var _saveFileItem:MenuItem;
	private var _saveFileAsItem:MenuItem;
	private var _fileSettingsItem:MenuItem;
	private var _exportSettingsItem:MenuItem;
	
	// edit menu
	private var _editMenuCollection:ArrayCollection<MenuItem>;
	private var _undoItem:MenuItem;
	private var _redoItem:MenuItem;
	
	// asset menu
	private var _assetMenuCollection:ArrayCollection<MenuItem>;
	private var _assetBrowserItem:MenuItem;
	
	// theme menu
	private var _themeMenuCollection:ArrayCollection<MenuItem>;
	private var _lightModeItem:MenuItem;
	private var _darkModeItem:MenuItem;
	private var _editThemeItem:MenuItem;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		ValEdit.assetLib = new AssetLib();
		ValEdit.assetLib.excludePath("icon");
		ValEdit.assetLib.excludePath("ui/dark");
		ValEdit.assetLib.excludePath("ui/light");
		ValEdit.assetLib.init(true);
		
		super.initialize();
	}
	
	override function editorSetup():Void 
	{
		super.editorSetup();
		
		UIAssets.lightMode.lockIcon = Assets.getBitmapData("ui/light/lock.png");
		UIAssets.darkMode.lockIcon = Assets.getBitmapData("ui/dark/lock.png");
		UIAssets.lightMode.visibleIcon = Assets.getBitmapData("ui/light/eye.png");
		UIAssets.darkMode.visibleIcon = Assets.getBitmapData("ui/dark/eye.png");
		
		// register assets file extensions
		ValEdit.assetLib.registerExtension("bmp", AssetType.BITMAP);
		ValEdit.assetLib.registerExtension("jpg", AssetType.BITMAP);
		ValEdit.assetLib.registerExtension("jpeg", AssetType.BITMAP);
		ValEdit.assetLib.registerExtension("png", AssetType.BITMAP);
		
		ValEdit.assetLib.registerExtension("wav", AssetType.SOUND);
		#if air
		ValEdit.assetLib.registerExtension("mp3", AssetType.SOUND);
		#else
		ValEdit.assetLib.registerExtension("ogg", AssetType.SOUND);
		#end
		
		ValEdit.assetLib.registerExtension("txt", AssetType.TEXT);
		ValEdit.assetLib.registerExtension("xml", AssetType.TEXT);
		ValEdit.assetLib.registerExtension("json", AssetType.TEXT);
		
		var sprite:Sprite = new Sprite();
		addChild(sprite);
		ValEditor.rootScene = sprite;
		
		#if starling
		var starlingSprite = new starling.display.Sprite();
		Starling.current.stage.addChild(starlingSprite);
		ValEditor.rootSceneStarling = starlingSprite;
		#end
		
		initInputActions();
		ValEditor.input.addEventListener(InputActionEvent.ACTION_BEGIN, onInputActionBegin);
	}
	
	override function initUI():Void 
	{
		super.initUI();
		
		var item:StackItem;
		
		this.editView = new EditorView();
		this.editView.initializeNow();
		ValEditor.uiContainerDefault = this.editView.editContainer;
		
		item = StackItem.withDisplayObject(EditorView.ID, this.editView);
		this.screenNavigator.addItem(item);
		
		// File menu
		this._newFileItem = new MenuItem("new", "New", true, "Ctrl+N");
		this._openFileItem = new MenuItem("open", "Open", true, "Ctrl+O");
		this._saveFileItem = new MenuItem("save", "Save", true, "Ctrl+S");
		this._saveFileAsItem = new MenuItem("save as", "Save As", true, "Ctrl+Shift+S");
		this._fileSettingsItem = new MenuItem("file settings", "File Settings");
		this._exportSettingsItem = new MenuItem("export settings", "Export Settings");
		
		this._fileMenuCollection = new ArrayCollection<MenuItem>([
			this._newFileItem,
			this._openFileItem,
			this._saveFileItem,
			this._saveFileAsItem,
			this._fileSettingsItem,
			this._exportSettingsItem
		]);
		this.editView.addMenu("file", "File", onFileMenuCallback, onFileMenuOpen, this._fileMenuCollection);
		
		// Edit menu
		this._undoItem = new MenuItem("undo", "Undo", true, "Ctrl+Z");
		this._redoItem = new MenuItem("redo", "Redo", true, "Ctrl+Y");
		
		this._editMenuCollection = new ArrayCollection<MenuItem>([
			this._undoItem,
			this._redoItem
		]);
		this.editView.addMenu("edit", "Edit", onEditMenuCallback, onEditMenuOpen, this._editMenuCollection);
		
		// Asset menu
		this._assetBrowserItem = new MenuItem("browser", "Browser", true, "Ctrl+B");
		
		this._assetMenuCollection = new ArrayCollection<MenuItem>([
			this._assetBrowserItem
		]);
		this.editView.addMenu("asset", "Asset", onAssetMenuCallback, onAssetMenuOpen, this._assetMenuCollection);
		
		// Theme menu
		this._lightModeItem = new MenuItem("light mode", "Light mode");
		this._darkModeItem = new MenuItem("dark mode", "Dark mode");
		this._editThemeItem = new MenuItem("edit", "Edit");
		
		this._themeMenuCollection = new ArrayCollection<MenuItem>([
			this._lightModeItem,
			this._darkModeItem,
			this._editThemeItem
		]);
		this.editView.addMenu("theme", "Theme", onThemeMenuCallback, onThemeMenuOpen, this._themeMenuCollection);
	}
	
	override function exposeData():Void 
	{
		super.exposeData();
		
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// UI Theme
		ValEditor.registerClassSimple(ValEditorTheme, false, SimpleThemeData.exposeSimpleTheme());
		
		// OpenFL Display
		settings.canBeCreated = false;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = DisplayData.exposeSprite();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(Sprite, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = DisplayData.exposeBitmapInstance();
		settings.templateCollection = DisplayData.exposeBitmapTemplate();
		settings.constructorCollection = DisplayData.exposeBitmapConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(Bitmap, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeArcShapeInstance();
		settings.templateCollection = ShapeData.exposeArcShapeTemplate();
		settings.constructorCollection = ShapeData.exposeArcShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(ArcShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeBurstShapeInstance();
		settings.templateCollection = ShapeData.exposeBurstShapeTemplate();
		settings.constructorCollection = ShapeData.exposeBurstShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(BurstShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeCircleShapeInstance();
		settings.templateCollection = ShapeData.exposeCircleShapeTemplate();
		settings.constructorCollection = ShapeData.exposeCircleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(CircleShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeEllipseShapeInstance();
		settings.templateCollection = ShapeData.exposeEllipseShapeTemplate();
		settings.constructorCollection = ShapeData.exposeEllipseShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(EllipseShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeFlowerShapeInstance();
		settings.templateCollection = ShapeData.exposeFlowerShapeTemplate();
		settings.constructorCollection = ShapeData.exposeFlowerShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(FlowerShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeGearShapeInstance();
		settings.templateCollection = ShapeData.exposeGearShapeTemplate();
		settings.constructorCollection = ShapeData.exposeGearShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(GearShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposePolygonShapeInstance();
		settings.templateCollection = ShapeData.exposePolygonShapeTemplate();
		settings.constructorCollection = ShapeData.exposePolygonShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(PolygonShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeRectangleShapeInstance();
		settings.templateCollection = ShapeData.exposeRectangleShapeTemplate();
		settings.constructorCollection = ShapeData.exposeRectangleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(RectangleShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeRoundRectangleShapeInstance();
		settings.templateCollection = ShapeData.exposeRoundRectangleShapeTemplate();
		settings.constructorCollection = ShapeData.exposeRoundRectangleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(RoundRectangleShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeStarShapeInstance();
		settings.templateCollection = ShapeData.exposeStarShapeTemplate();
		settings.constructorCollection = ShapeData.exposeStarShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(StarShape, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = ShapeData.exposeWedgeShapeInstance();
		settings.templateCollection = ShapeData.exposeWedgeShapeTemplate();
		settings.constructorCollection = ShapeData.exposeWedgeShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(WedgeShape, settings);
		settings.clear();
		
		// OpenFL Filters
		ValEditor.registerClassSimple(BlurFilter, false, FiltersData.exposeBlurFilter(), null, FiltersData.exposeBlurFilterConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_FILTER]);
		ValEditor.registerClassSimple(DropShadowFilter, false, FiltersData.exposeDropShadowFilter(), null, FiltersData.exposeDropShadowFilterConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_FILTER]);
		ValEditor.registerClassSimple(GlowFilter, false, FiltersData.exposeGlowFilter(), null, FiltersData.exposeGlowFilterConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_FILTER]);
		
		// OpenFL Geom
		ValEditor.registerClassSimple(ColorTransform, false, GeomData.exposeColorTransform());
		ValEditor.registerClassSimple(Matrix, false, GeomData.exposeMatrix());
		ValEditor.registerClassSimple(Transform, false, GeomData.exposeTransform());
		ValEditor.registerClassSimple(Point, false, GeomData.exposePoint(), null, GeomData.exposePointConstructor());
		ValEditor.registerClassSimple(Rectangle, false, GeomData.exposeRectangle(), null, GeomData.exposeRectangleConstructor());
		
		// OpenFL Text
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_TEXT);
		settings.iconBitmapData = Assets.getBitmapData("icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.objectCollection = TextData.exposeTextFieldInstance();
		settings.templateCollection = TextData.exposeTextFieldTemplate();
		settings.interactiveFactory = InteractiveFactories.openFL_visible;
		ValEditor.registerClass(TextField, settings);
		settings.clear();
		
		ValEditor.registerClassSimple(Font, false, TextData.exposeFont());
		ValEditor.registerClassSimple(TextFormat, false, TextData.exposeTextFormat(), null, TextData.exposeTextFormatConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_TEXT]);
		
		#if starling
		// Starling Texture Creation
		ValEditor.registerClassSimple(TextureCreationParameters, false, StarlingTextureData.exposeTextureCreationParameters());
		
		// Starling Display
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/starling.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.STARLING;
		settings.objectCollection = StarlingDisplayData.exposeQuadInstance();
		settings.templateCollection = StarlingDisplayData.exposeQuadTemplate();
		settings.constructorCollection = StarlingDisplayData.exposeQuadConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(Quad, settings);
		settings.clear();
		
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("icon/starling.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.STARLING;
		settings.objectCollection = StarlingDisplayData.exposeImageInstance();
		settings.templateCollection = StarlingDisplayData.exposeImageTemplate();
		settings.constructorCollection = StarlingDisplayData.exposeImageConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(Image, settings);
		settings.clear();
		
		// Starling Filters
		
		// Starling Text
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_TEXT);
		settings.iconBitmapData = Assets.getBitmapData("icon/starling.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.STARLING;
		settings.objectCollection = StarlingTextData.exposeTextFieldInstance();
		settings.templateCollection = StarlingTextData.exposeTextFieldTemplate();
		settings.constructorCollection = StarlingTextData.exposeTextFieldConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_visible;
		settings.hasRadianRotation = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.text.TextField, settings);
		settings.clear();
		#end
		
		#if massive_starling
		//ValEditor.registerClass(FrameProxy, MassiveData.exposeFrameProxy());
		//ValEditor.registerClass(ImageDataProxy, MassiveData.exposeImageDataProxy(), true, true, DisplayObjectType.STARLING);
		//ValEditor.registerClass(QuadDataProxy, MassiveData.exposeQuadDataProxy(), true, true, DisplayObjectType.STARLING);
		#end
		
		settings.pool();
		
		ValEditor.registerClassSimple(ValEditorContainer, false, ContainerData.exposeValEditorContainer());
		ValEditor.registerClassSimple(ValEditorKeyFrame, false, ContainerData.exposeValEditKeyFrame());
		ValEditor.registerClassSimple(ExportSettings, false, SettingsData.exposeExportSettings());
		ValEditor.registerClassSimple(FileSettings, false, SettingsData.exposeFileSettings());
	}
	
	override function ready():Void 
	{
		super.ready();
		
		this.screenNavigator.rootItemID = EditorView.ID;
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
		
		FeathersWindows.showStartMenuWindow(onNewFile, onLoadFile);
		
		#if air
		Lib.current.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onFileDragIn);
		Lib.current.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onFileDrop);
		#else
		Lib.current.stage.window.onDropFile.add(onFileDrop);
		#end
	}
	
	private function onNewFile():Void
	{
		if (this._isStartUp)
		{
			FeathersWindows.closeStartMenuWindow();
		}
		FeathersWindows.showFileSettingsWindow(this._fileSettings, "New File", onNewFileSettingsConfirm, onNewFileSettingsCancel);
	}
	
	private function onNewFileSettingsConfirm():Void
	{
		ValEditor.reset();
		this._fileSettings.clone(ValEditor.fileSettings);
		ValEditor.newFile();
		this._isStartUp = false;
	}
	
	private function onNewFileSettingsCancel():Void
	{
		if (this._isStartUp)
		{
			FeathersWindows.showStartMenuWindow(onNewFile, onLoadFile);
		}
	}
	
	private function onLoadFile():Void
	{
		FileController.open(onLoadFileConfirm, onLoadFileCancel);
	}
	
	private function onLoadFileConfirm(filePath:String):Void
	{
		if (this._isStartUp)
		{
			FeathersWindows.closeStartMenuWindow();
		}
		this._isStartUp = false;
		
		ValEditor.fileSettings.fileName = Path.withoutDirectory(filePath);
		ValEditor.fileSettings.filePath = Path.directory(filePath);
	}
	
	private function onLoadFileCancel():Void
	{
		
	}
	
	private function onSelectionChange(evt:SelectionEvent):Void
	{
		if (evt == null || evt.object == null)
		{
			ValEditor.edit(ValEditor.currentContainer);
		}
		else
		{
			if (Std.isOfType(evt.object, ValEditorObject))
			{
				ValEditor.edit(evt.object);
			}
			else if (Std.isOfType(evt.object, ValEditorTemplate))
			{
				ValEditor.editTemplate(evt.object);
			}
			else if (Std.isOfType(evt.object, ValEditorKeyFrame))
			{
				ValEditor.edit(evt.object);
			}
			else
			{
				ValEditor.edit(null);
			}
		}
	}
	
	private function onFileMenuOpen(evt:Event):Void
	{
		this._saveFileItem.enabled = ValEditor.actionStack.hasChanges;
		this._fileMenuCollection.updateAt(this._fileMenuCollection.indexOf(this._saveFileItem));
	}
	
	private function onFileMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "new" :
				onNewFile();
			
			case "open" :
				onLoadFile();
			
			case "save" :
				FileController.save();
			
			case "save as" :
				FileController.save(true);
			
			case "file settings" :
				FeathersWindows.showFileSettingsWindow(ValEditor.fileSettings, "File Settings");
			
			case "export settings" :
				FeathersWindows.showExportSettingsWindow(ValEditor.exportSettings);
		}
		
		Lib.current.stage.focus = null;
	}
	
	private function onEditMenuOpen(evt:Event):Void
	{
		this._undoItem.enabled = ValEditor.actionStack.canUndo;
		this._redoItem.enabled = ValEditor.actionStack.canRedo;
		this._editMenuCollection.updateAll();
	}
	
	private function onEditMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "undo" :
				ValEditor.actionStack.undo();
			
			case "redo" :
				ValEditor.actionStack.redo();
		}
		
		Lib.current.stage.focus = null;
	}
	
	private function onAssetMenuOpen(evt:Event):Void
	{
		
	}
	
	private function onAssetMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "browser" :
				FeathersWindows.showAssetBrowser();
		}
		
		Lib.current.stage.focus = null;
	}
	
	private function onThemeMenuOpen(evt:Event):Void
	{
		this._lightModeItem.enabled = this.theme.darkMode;
		this._darkModeItem.enabled = !this.theme.darkMode;
		this._themeMenuCollection.updateAll();
	}
	
	private function onThemeMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "light mode" :
				this.theme.darkMode = false;
			
			case "dark mode" :
				this.theme.darkMode = true;
			
			case "edit" :
				ValEditor.edit(this.theme);
		}
		
		Lib.current.stage.focus = null;
	}
	
	private function onInputActionBegin(evt:InputActionEvent):Void
	{
		if (this._isStartUp) return;
		
		var action:MultiAction;
		var inputAction:InputAction = evt.action;
		
		switch (inputAction.actionID)
		{
			case InputActionID.ASSET_BROWSER :
				FeathersWindows.toggleAssetBrowser();
			
			case InputActionID.COPY :
				action = MultiAction.fromPool();
				action.isStepAction = false;
				ValEditor.copy(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case InputActionID.CUT :
				action = MultiAction.fromPool();
				ValEditor.cut(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case InputActionID.PASTE :
				action = MultiAction.fromPool();
				ValEditor.paste(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case InputActionID.DELETE :
				action = MultiAction.fromPool();
				ValEditor.delete(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case InputActionID.SELECT_ALL :
				action = MultiAction.fromPool();
				ValEditor.selectAll(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case InputActionID.UNSELECT_ALL :
				action = MultiAction.fromPool();
				ValEditor.unselectAll(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case InputActionID.PLAY_STOP :
				ValEditor.playStop();
			
			case InputActionID.UNDO :
				ValEditor.actionStack.undo();
			
			case InputActionID.REDO :
				ValEditor.actionStack.redo();
			
			// file
			case InputActionID.NEW_FILE :
				onNewFile();
			
			case InputActionID.OPEN :
				onLoadFile();
			
			case InputActionID.EXPORT :
				trace("export");
			
			case InputActionID.EXPORT_AS :
				trace("export as");
			
			case InputActionID.SAVE :
				FileController.save();
			
			case InputActionID.SAVE_AS :
				FileController.save(true);
		}
		
	}
	
	private function initInputActions():Void
	{
		// Keyboard
		var keyAction:KeyAction;
		
		var firstRepeatDelay:Float = 0.5;
		var repeatDelay:Float = 0.05;
		
		// play/stop
		keyAction = new KeyAction(InputActionID.PLAY_STOP);
		ValEditor.keyboardController.addKeyAction(Keyboard.ENTER, keyAction);
		
		// insert frame
		keyAction = new KeyAction(InputActionID.INSERT_FRAME, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.F5, keyAction);
		
		// insert keyframe
		keyAction = new KeyAction(InputActionID.INSERT_KEYFRAME, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.F6, keyAction);
		
		// remove frame
		keyAction = new KeyAction(InputActionID.REMOVE_FRAME, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.F5, keyAction);
		
		// remove keyframe
		keyAction = new KeyAction(InputActionID.REMOVE_KEYFRAME, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.F6, keyAction);
		
		// move selection
		keyAction = new KeyAction(InputActionID.MOVE_DOWN_1, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.DOWN, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_DOWN_10, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.DOWN, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_LEFT_1, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.LEFT, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_LEFT_10, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.LEFT, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_RIGHT_1, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.RIGHT, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_RIGHT_10, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.RIGHT, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_UP_1, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.UP, keyAction);
		keyAction = new KeyAction(InputActionID.MOVE_UP_10, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		ValEditor.keyboardController.addKeyAction(Keyboard.UP, keyAction);
		
		// select all
		keyAction = new KeyAction(InputActionID.SELECT_ALL, false, true, false);
		ValEditor.keyboardController.addKeyAction(Keyboard.A, keyAction);
		
		// unselect all
		keyAction = new KeyAction(InputActionID.UNSELECT_ALL, false, true, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.A, keyAction);
		
		// copy
		keyAction = new KeyAction(InputActionID.COPY, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.C, keyAction);
		
		// cut
		keyAction = new KeyAction(InputActionID.CUT, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.X, keyAction);
		
		// paste
		keyAction = new KeyAction(InputActionID.PASTE, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.V, keyAction);
		
		// delete
		keyAction = new KeyAction(InputActionID.DELETE);
		ValEditor.keyboardController.addKeyAction(Keyboard.DELETE, keyAction);
		ValEditor.keyboardController.addKeyAction(Keyboard.BACKSPACE, keyAction);
		
		// undo
		keyAction = new KeyAction(InputActionID.UNDO, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.Z, keyAction);
		
		// redo
		keyAction = new KeyAction(InputActionID.REDO, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.Y, keyAction);
		
		// save
		keyAction = new KeyAction(InputActionID.SAVE, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.S, keyAction);
		keyAction = new KeyAction(InputActionID.SAVE_AS, false, true, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.S, keyAction);
		
		// new file
		keyAction = new KeyAction(InputActionID.NEW_FILE, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.N, keyAction);
		
		// open
		keyAction = new KeyAction(InputActionID.OPEN, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.O, keyAction);
		
		// export
		keyAction = new KeyAction(InputActionID.EXPORT, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.E, keyAction);
		keyAction = new KeyAction(InputActionID.EXPORT_AS, false, true, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.E, keyAction);
		
		// asset browser
		keyAction = new KeyAction(InputActionID.ASSET_BROWSER, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.B, keyAction);
	}
	
	#if air
	private function onFileDragIn(evt:NativeDragEvent):Void
	{
		var fileList:Array<File> = evt.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT);
		for (file in fileList)
		{
			if (file.extension == ValEditor.fileExtension)
			{
				NativeDragManager.acceptDragDrop(Lib.current.stage);
				break;
			}
			else if (!this._isStartUp && ValEdit.assetLib.isValidExtension(file.extension))
			{
				NativeDragManager.acceptDragDrop(Lib.current.stage);
				break;
			}
		}
	}
	
	private function onFileDrop(evt:NativeDragEvent):Void
	{
		var fileList:Array<File> = evt.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT);
		// look for source file
		for (file in fileList)
		{
			if (file.extension == ValEditor.fileExtension)
			{
				FileController.openFile(file, onLoadFileConfirm);
				return;
			}
		}
		
		// look for asset file
		for (file in fileList)
		{
			if (!this._isStartUp && ValEdit.assetLib.isValidExtension(file.extension))
			{
				ValEditor.assetFileLoader.addFile(file, ValEdit.assetLib.getAssetTypeForExtension(file.extension));
			}
		}
		FeathersWindows.showMessageWindow("Assets", "importing assets");
		ValEditor.assetFileLoader.load(onAssetFilesLoadComplete);
	}
	#elseif desktop
	private function onFileDrop(filePath:String):Void
	{
		var file:File;
		if (Path.extension(filePath) == ValEditor.fileExtension)
		{
			file = new File(filePath);
			FileController.openFile(file, onLoadFileConfirm);
		}
		else if (!this._isStartUp && ValEdit.assetLib.isValidExtension(Path.extension(filePath)))
		{
			file = new File(filePath);
			ValEditor.assetFileLoader.addFile(file, ValEdit.assetLib.getAssetTypeForExtension(file.extension));
			if (!ValEditor.assetFileLoader.isRunning)
			{
				FeathersWindows.showMessageWindow("Assets", "importing assets");
				ValEditor.assetFileLoader.load(onAssetFilesLoadComplete);
			}
		}
	}
	#else
	private function onFileDrop(filePath:String):Void
	{
		var fileList:FileList = cast filePath;
		
		// look for source file
		for (file in fileList)
		{
			if (Path.extension(file.name) == ValEditor.fileExtension)
			{
				this._fileReaderLoader.addFile(file);
				this._fileReaderLoader.start(onSourceFileReady);
				return;
			}
		}
		
		if (!this._isStartUp)
		{
			// look for asset file
			for (file in fileList)
			{
				if (ValEdit.assetLib.isValidExtension(Path.extension(file.name)))
				{
					this._fileReaderLoader.addFile(file);
				}
			}
			
			if (!ValEditor.assetFileLoader.isRunning)
			{
				FeathersWindows.showMessageWindow("Assets", "importing assets");
				this._fileReaderLoader.start(onAssetFilesReady);
			}
		}
	}
	
	private function onSourceFileReady(files:Array<FileReference>):Void
	{
		FileController.openFile(files[0], onLoadFileConfirm);
	}
	
	private function onAssetFilesReady(files:Array<FileReference>):Void
	{
		for (file in files)
		{
			ValEditor.assetFileLoader.addFile(file, ValEdit.assetLib.getAssetTypeForExtension(file.extension));
		}
		
		if (!ValEditor.assetFileLoader.isRunning)
		{
			FeathersWindows.showMessageWindow("Assets", "importing assets");
			ValEditor.assetFileLoader.load(onAssetFilesLoadComplete);
		}
	}
	#end
	
	private function onAssetFilesLoadComplete():Void
	{
		FeathersWindows.hideMessageWindow();
	}
	
	public function exposeAll():Void
	{
		exposeOpenFL();
		#if starling
		exposeStarling();
		#end
	}
	
	public function exposeOpenFL():Void
	{
		
	}
	
	#if starling
	public function exposeStarling():Void
	{
		
	}
	#end
	
}
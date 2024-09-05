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
import valedit.SpriteContainerOpenFL;
import valedit.SpriteContainerOpenFLStarling;
import valedit.SpriteContainerStarling;
import valedit.SpriteContainerStarling3D;
import valedit.TimeLineContainerOpenFL;
import valedit.TimeLineContainerOpenFLStarling;
import valedit.TimeLineContainerStarling;
import valedit.TimeLineContainerStarling3D;
import valedit.ValEdit;
import valedit.asset.AssetLib;
import valedit.asset.AssetType;
import valedit.data.openfl.display.DisplayData;
import valedit.data.openfl.filters.FiltersData;
import valedit.data.openfl.geom.GeomData;
import valedit.data.openfl.text.TextData;
import valedit.data.starling.text.StarlingTextData;
import valedit.data.valedit.ShapeData;
import valedit.data.valeditor.ContainerData;
import valedit.data.valeditor.SettingsData;
import valedit.object.openfl.display.ArcShape;
import valedit.object.openfl.display.ArrowShape;
import valedit.object.openfl.display.BurstShape;
import valedit.object.openfl.display.CircleShape;
import valedit.object.openfl.display.DonutShape;
import valedit.object.openfl.display.EllipseShape;
import valedit.object.openfl.display.FlowerShape;
import valedit.object.openfl.display.GearShape;
import valedit.object.openfl.display.PolygonShape;
import valedit.object.openfl.display.RectangleShape;
import valedit.object.openfl.display.RoundRectangleShape;
import valedit.object.openfl.display.StarShape;
import valedit.object.openfl.display.WedgeShape;
import valeditor.ValEditorClassSettings;
import valeditor.ValEditorKeyFrame;
import valeditor.container.SpriteContainerOpenFLEditable;
import valeditor.container.SpriteContainerOpenFLStarlingEditable;
import valeditor.container.SpriteContainerStarling3DEditable;
import valeditor.container.SpriteContainerStarlingEditable;
import valeditor.container.TimeLineContainerOpenFLEditable;
import valeditor.container.TimeLineContainerOpenFLStarlingEditable;
import valeditor.container.TimeLineContainerStarling3DEditable;
import valeditor.container.TimeLineContainerStarlingEditable;
import valeditor.editor.UIAssets;
import valeditor.editor.action.MultiAction;
import valeditor.editor.file.FileController;
import valeditor.editor.settings.ExportSettings;
import valeditor.editor.settings.FileSettings;
import valeditor.editor.settings.StarlingSettings;
import valeditor.events.SelectionEvent;
import valeditor.input.InputActionID;
import valeditor.ui.InteractiveFactories;
import valeditor.ui.InteractiveObjectController;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.data.MenuItem;
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
	private var _preferencesItem:MenuItem;
	
	// asset menu
	private var _assetMenuCollection:ArrayCollection<MenuItem>;
	private var _assetBrowserItem:MenuItem;
	
	// help menu
	private var _helpMenuCollection:ArrayCollection<MenuItem>;
	private var _creditsItem:MenuItem;
	private var _versionsItem:MenuItem;
	
	// debug menu
	private var _debugMenuCollection:ArrayCollection<MenuItem>;
	private var _interactiveObjectsItem:MenuItem;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		ValEdit.assetLib = new AssetLib();
		ValEdit.assetLib.excludePath("valeditor/credits");
		ValEdit.assetLib.excludePath("valeditor/icon");
		ValEdit.assetLib.excludePath("valeditor/ui");
		ValEdit.assetLib.excludePath("valeditor/ui/dark");
		ValEdit.assetLib.excludePath("valeditor/ui/light");
		ValEdit.assetLib.init(true);
		
		super.initialize();
	}
	
	override function editorSetup():Void 
	{
		super.editorSetup();
		
		UIAssets.lightMode.lockIcon = Assets.getBitmapData("valeditor/ui/light/lock.png");
		UIAssets.darkMode.lockIcon = Assets.getBitmapData("valeditor/ui/dark/lock.png");
		UIAssets.lightMode.visibleIcon = Assets.getBitmapData("valeditor/ui/light/eye.png");
		UIAssets.darkMode.visibleIcon = Assets.getBitmapData("valeditor/ui/dark/eye.png");
		
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
		this._preferencesItem = new MenuItem("preferences", "Preferences", true);
		
		this._editMenuCollection = new ArrayCollection<MenuItem>([
			this._undoItem,
			this._redoItem,
			this._preferencesItem
		]);
		this.editView.addMenu("edit", "Edit", onEditMenuCallback, onEditMenuOpen, this._editMenuCollection);
		
		// Asset menu
		this._assetBrowserItem = new MenuItem("browser", "Browser", true, "Ctrl+B");
		
		this._assetMenuCollection = new ArrayCollection<MenuItem>([
			this._assetBrowserItem
		]);
		this.editView.addMenu("asset", "Asset", onAssetMenuCallback, onAssetMenuOpen, this._assetMenuCollection);
		
		// Help menu
		this._creditsItem = new MenuItem("credits", "Credits", true);
		this._versionsItem = new MenuItem("versions", "Versions", true);
		
		this._helpMenuCollection = new ArrayCollection<MenuItem>([
			this._creditsItem,
			this._versionsItem
		]);
		this.editView.addMenu("help", "Help", onHelpMenuCallback, null, this._helpMenuCollection);
		
		// Debug menu
		this._interactiveObjectsItem = new MenuItem("debug-interactiveObjects", "Interactive Objects");
		
		this._debugMenuCollection = new ArrayCollection<MenuItem>([
			this._interactiveObjectsItem
		]);
		this.editView.addMenu("debug", "Debug", onDebugMenuCallback, null, this._debugMenuCollection);
	}
	
	override function exposeData():Void 
	{
		super.exposeData();
		
		exposeOpenFL();
		#if starling
		exposeStarling();
		#end
		exposeValEditor();
	}
	
	override function ready():Void 
	{
		super.ready();
		
		//Reflect.callMethod(FeathersWindows, FeathersWindows.showAssetBrowser, []);
		//Reflect.callMethod(null, FeathersWindows.showAssetBrowser, []);
		//Reflect.callMethod(null, Reflect.getProperty(FeathersWindows, "showAssetBrowser"), []);
		
		//trace("openfl-juggler v" + ValEdit.OPENFL_JUGGLER_VERSION);
		
		//var sprite:Sprite = new Sprite();
		//var matrix:Matrix = new Matrix();
		//matrix.createGradientBox(this.stage.stageWidth, this.stage.stageHeight);// , Math.PI / 2); // make vertical
		//sprite.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0.0, 0.0], [127, 255], matrix);
		//sprite.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
		//sprite.graphics.endFill();
		//addChild(sprite);
		
		//var sprite:Sprite = new Sprite();
		//var matrix:Matrix = new Matrix();
		//matrix.createGradientBox(this.stage.stageWidth, this.stage.stageHeight, -Math.PI / 2); // make vertical
		//sprite.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000, 0x000000, 0x000000], [0.0, 1.0, 1.0, 0.0], [127, 157, 225, 255], matrix);
		//sprite.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
		//sprite.graphics.endFill();
		//addChild(sprite);
		
		//var tf:TextField = new TextField();
		//tf.y = 100;
		//var format:TextFormat = tf.defaultTextFormat;
		//format.size = 20;
		////tf.defaultTextFormat = format;
		//tf.text = "yop yop yop";
		//tf.defaultTextFormat = format;
		//tf.text = tf.text;
		//addChild(tf);
		
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
		this._fileSettings.clear();
		ValEditor.fileSettings.clone(this._fileSettings);
		ValEditor.fileSettings.reset();
		FeathersWindows.showFileSettingsWindow(ValEditor.fileSettings, "New File", onNewFileSettingsConfirm, onNewFileSettingsCancel);
	}
	
	private function onNewFileSettingsConfirm():Void
	{
		ValEditor.reset();
		ValEditor.newFile();
		ValEditor.fileSettings.apply();
		this._isStartUp = false;
	}
	
	private function onNewFileSettingsCancel():Void
	{
		ValEditor.fileSettings.clear();
		this._fileSettings.clone(ValEditor.fileSettings);
		ValEditor.fileSettings.apply();
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
		this._saveFileItem.enabled = ValEditor.isNewFile || ValEditor.actionStack.hasChanges;
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
			
			case "preferences" :
				FeathersWindows.showEditorSettingsWindow(ValEditor.editorSettings, "ValEditor settings");
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
	
	private function onHelpMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "credits" :
				FeathersWindows.showCreditsWindow();
			
			case "versions" :
				FeathersWindows.showVersionsWindow();
		}
	}
	
	private function onDebugMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "debug-interactiveObjects" :
				FeathersWindows.showInteractiveObjectDebugWindow(ValEditor.interactiveObjectController);
		}
	}
	
	private function onInputActionBegin(evt:InputActionEvent):Void
	{
		var action:MultiAction;
		var inputAction:InputAction = evt.action;
		
		switch (inputAction.actionID)
		{
			case InputActionID.ASSET_BROWSER :
				if (this._isStartUp) return;
				FeathersWindows.toggleAssetBrowser();
			
			case InputActionID.COPY :
				if (this._isStartUp) return;
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
				if (this._isStartUp) return;
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
			
			case InputActionID.DELETE :
				if (this._isStartUp) return;
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
			
			case InputActionID.EXPORT :
				if (this._isStartUp) return;
				trace("export");
			
			case InputActionID.EXPORT_AS :
				if (this._isStartUp) return;
				trace("export as");
			
			case InputActionID.NEW_FILE :
				if (this._isStartUp) return;
				onNewFile();
			
			case InputActionID.OPEN :
				if (this._isStartUp) return;
				onLoadFile();
			
			case InputActionID.PASTE :
				if (this._isStartUp) return;
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
			
			case InputActionID.PLAY_STOP :
				if (this._isStartUp) return;
				ValEditor.playStop();
			
			case InputActionID.REDO :
				ValEditor.actionStack.redo();
			
			case InputActionID.SAVE :
				if (this._isStartUp) return;
				if (ValEditor.isNewFile || ValEditor.actionStack.hasChanges)
				{
					FileController.save();
				}
			
			case InputActionID.SAVE_AS :
				if (this._isStartUp) return;
				FileController.save(true);
			
			case InputActionID.SELECT_ALL :
				if (this._isStartUp) return;
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
			
			case InputActionID.UNDO :
				ValEditor.actionStack.undo();
			
			case InputActionID.UNSELECT_ALL :
				if (this._isStartUp) return;
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
		exposeValEditor();
	}
	
	public function exposeOpenFL():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// OpenFL Display
		// Sprite
		settings.canBeCreated = false;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = DisplayData.exposeSprite();
		settings.visibilityCollection = DisplayData.getSpriteVisibility();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(Sprite, settings);
		settings.clear();
		
		// Bitmap
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = DisplayData.exposeBitmap();
		settings.visibilityCollection = DisplayData.getBitmapVisibility();
		settings.constructorCollection = DisplayData.exposeBitmapConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(Bitmap, settings);
		settings.clear();
		
		// ArcShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeArcShape();
		settings.visibilityCollection = ShapeData.getArcShapeVisibility();
		settings.constructorCollection = ShapeData.exposeArcShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(ArcShape, settings);
		settings.clear();
		
		// ArrowShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeArrowShape();
		settings.visibilityCollection = ShapeData.getArrowShapeVisibility();
		settings.constructorCollection = ShapeData.exposeArrowShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(ArrowShape, settings);
		settings.clear();
		
		// BurstShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeBurstShape();
		settings.visibilityCollection = ShapeData.getBurstShapeVisibility();
		settings.constructorCollection = ShapeData.exposeBurstShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(BurstShape, settings);
		settings.clear();
		
		// CircleShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeCircleShape();
		settings.visibilityCollection = ShapeData.getCircleShapeVisibility();
		settings.constructorCollection = ShapeData.exposeCircleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(CircleShape, settings);
		settings.clear();
		
		// DonutShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeDonutShape();
		settings.visibilityCollection = ShapeData.getDonutShapeVisibility();
		settings.constructorCollection = ShapeData.exposeDonutShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(DonutShape, settings);
		settings.clear();
		
		// EllipseShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeEllipseShape();
		settings.visibilityCollection = ShapeData.getEllipseShapeVisibility();
		settings.constructorCollection = ShapeData.exposeEllipseShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(EllipseShape, settings);
		settings.clear();
		
		// FlowerShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeFlowerShape();
		settings.visibilityCollection = ShapeData.getFlowerShapeVisibility();
		settings.constructorCollection = ShapeData.exposeFlowerShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(FlowerShape, settings);
		settings.clear();
		
		// GearShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeGearShape();
		settings.visibilityCollection = ShapeData.getGearShapeVisibility();
		settings.constructorCollection = ShapeData.exposeGearShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(GearShape, settings);
		settings.clear();
		
		// PolygonShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposePolygonShape();
		settings.visibilityCollection = ShapeData.getPolygonShapeVisibility();
		settings.constructorCollection = ShapeData.exposePolygonShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(PolygonShape, settings);
		settings.clear();
		
		// RectangleShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeRectangleShape();
		settings.visibilityCollection = ShapeData.getRectangleShapeVisibility();
		settings.constructorCollection = ShapeData.exposeRectangleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(RectangleShape, settings);
		settings.clear();
		
		// RoundRectangleShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeRoundRectangleShape();
		settings.visibilityCollection = ShapeData.getRoundRectangleShapeVisibility();
		settings.constructorCollection = ShapeData.exposeRoundRectangleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(RoundRectangleShape, settings);
		settings.clear();
		
		// StarShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeStarShape();
		settings.visibilityCollection = ShapeData.getStarShapeVisibility();
		settings.constructorCollection = ShapeData.exposeStarShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(StarShape, settings);
		settings.clear();
		
		// WedgeShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = ShapeData.exposeWedgeShape();
		settings.visibilityCollection = ShapeData.getWedgeShapeVisibility();
		settings.constructorCollection = ShapeData.exposeWedgeShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(WedgeShape, settings);
		settings.clear();
		
		// OpenFL Filters
		ValEditor.registerClassSimple(BlurFilter, false, FiltersData.exposeBlurFilter(), FiltersData.exposeBlurFilterConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_FILTER]);
		ValEditor.registerClassSimple(DropShadowFilter, false, FiltersData.exposeDropShadowFilter(), FiltersData.exposeDropShadowFilterConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_FILTER]);
		ValEditor.registerClassSimple(GlowFilter, false, FiltersData.exposeGlowFilter(), FiltersData.exposeGlowFilterConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_FILTER]);
		
		// OpenFL Geom
		ValEditor.registerClassSimple(ColorTransform, false, GeomData.exposeColorTransform());
		ValEditor.registerClassSimple(Matrix, false, GeomData.exposeMatrix());
		ValEditor.registerClassSimple(Transform, false, GeomData.exposeTransform());
		ValEditor.registerClassSimple(Point, false, GeomData.exposePoint(), GeomData.exposePointConstructor());
		ValEditor.registerClassSimple(Rectangle, false, GeomData.exposeRectangle(), GeomData.exposeRectangleConstructor());
		
		// OpenFL Text
		// TextField
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_TEXT);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.OPENFL;
		settings.collection = TextData.exposeTextField();
		settings.visibilityCollection = TextData.getTextFieldVisibility();
		settings.interactiveFactory = InteractiveFactories.openFL_visible;
		settings.useBounds = true;
		ValEditor.registerClass(TextField, settings);
		settings.clear();
		
		ValEditor.registerClassSimple(Font, false, TextData.exposeFont());
		ValEditor.registerClassSimple(TextFormat, false, TextData.exposeTextFormat(), TextData.exposeTextFormatConstructor(), [CategoryID.OPENFL, CategoryID.OPENFL_TEXT]);
		
		settings.pool();
	}
	
	#if starling
	public function exposeStarling():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Starling Texture Creation
		ValEditor.registerClassSimple(TextureCreationParameters, false, StarlingTextureData.exposeTextureCreationParameters());
		
		// Starling Display
		// Quad
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.STARLING;
		settings.collection = StarlingDisplayData.exposeQuad();
		settings.visibilityCollection = StarlingDisplayData.getQuadVisibility();
		settings.constructorCollection = StarlingDisplayData.exposeQuadConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(Quad, settings);
		settings.clear();
		
		// Image
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.STARLING;
		settings.collection = StarlingDisplayData.exposeImage();
		settings.visibilityCollection = StarlingDisplayData.getImageVisibility();
		settings.constructorCollection = StarlingDisplayData.exposeImageConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(Image, settings);
		settings.clear();
		
		// Starling Filters
		
		// Starling Text
		// TextField
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_TEXT);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.isDisplayObject = true;
		settings.displayObjectType = DisplayObjectType.STARLING;
		settings.collection = StarlingTextData.exposeTextField();
		settings.visibilityCollection = StarlingTextData.getTextFieldVisibility();
		settings.constructorCollection = StarlingTextData.exposeTextFieldConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_visible;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.text.TextField, settings);
		settings.clear();
		
		// TextFormat
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_TEXT);
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.collection = StarlingTextData.exposeTextFormat();
		//settings.visibilityCollection = StarlingTextData
		settings.constructorCollection = StarlingTextData.exposeTextFormatConstructor();
		ValEditor.registerClass(starling.text.TextFormat, settings);
		settings.clear();
		
		// StarlingSettings
		ValEditor.registerClassSimple(StarlingSettings, false, SettingsData.exposeStarlingSettings());
		
		settings.pool();
	}
	#end
	
	public function exposeValEditor():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// SpriteContainerOpenFL
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = SpriteContainerOpenFLEditable.fromPool;
		settings.creationFunctionForLoading = SpriteContainerOpenFLEditable.fromPool;
		settings.creationFunctionForTemplateInstance = SpriteContainerOpenFLEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.exportClassName = Type.getClassName(SpriteContainerOpenFL);
		settings.isContainer = true;
		settings.isContainerOpenFL = true;
		settings.collection = ContainerData.exposeSpriteContainerOpenFLEditable();
		settings.visibilityCollection = ContainerData.getSpriteContainerOpenFLEditableVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(SpriteContainerOpenFLEditable, settings);
		settings.clear();
		
		// SpriteContainerOpenFLStarling
		#if starling
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = SpriteContainerOpenFLStarlingEditable.fromPool;
		settings.creationFunctionForLoading = SpriteContainerOpenFLStarlingEditable.fromPool;
		settings.creationFunctionForTemplateInstance = SpriteContainerOpenFLStarlingEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl_starling.png");
		settings.exportClassName = Type.getClassName(SpriteContainerOpenFLStarling);
		settings.isContainer = true;
		settings.isContainerOpenFL = true;
		settings.isContainerStarling = true;
		settings.collection = ContainerData.exposeSpriteContainerOpenFLEditable();
		settings.visibilityCollection = ContainerData.getSpriteContainerOpenFLEditableVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(SpriteContainerOpenFLStarlingEditable, settings);
		settings.clear();
		#end
		
		#if starling
		// SpriteContainerStarling
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = SpriteContainerStarlingEditable.fromPool;
		settings.creationFunctionForLoading = SpriteContainerStarlingEditable.fromPool;
		settings.creationFunctionForTemplateInstance = SpriteContainerStarlingEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.exportClassName = Type.getClassName(SpriteContainerStarling);
		settings.isContainer = true;
		settings.isContainerStarling = true;
		settings.collection = ContainerData.exposeSpriteContainerStarlingEditable();
		settings.visibilityCollection = ContainerData.getSpriteContainerStarlingEditableVisibility();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		ValEditor.registerClass(SpriteContainerStarlingEditable, settings);
		settings.clear();
		#end
		
		#if starling
		// SpriteContainerStarling3D
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = SpriteContainerStarling3DEditable.fromPool;
		settings.creationFunctionForLoading = SpriteContainerStarling3DEditable.fromPool;
		settings.creationFunctionForTemplateInstance = SpriteContainerStarling3DEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.exportClassName = Type.getClassName(SpriteContainerStarling3D);
		settings.isContainer = true;
		settings.isContainerStarling = true;
		settings.collection = ContainerData.exposeSpriteContainerStarling3DEditable();
		settings.visibilityCollection = ContainerData.getSpriteContainerStarling3DEditableVisibility();
		settings.useBounds = true;
		settings.hasRadianRotation = true;
		ValEditor.registerClass(SpriteContainerStarling3DEditable, settings);
		settings.clear();
		#end
		
		// TimeLineContainerOpenFL
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = TimeLineContainerOpenFLEditable.create;
		settings.creationFunctionForLoading = TimeLineContainerOpenFLEditable.fromPool;
		settings.creationFunctionForTemplateInstance = TimeLineContainerOpenFLEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		settings.exportClassName = Type.getClassName(TimeLineContainerOpenFL);
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.isContainer = true;
		settings.isContainerOpenFL = true;
		settings.isTimeLineContainer = true;
		settings.collection = ContainerData.exposeTimeLineContainerOpenFLEditable();
		settings.visibilityCollection = ContainerData.getTimeLineContainerOpenFLEditableVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(TimeLineContainerOpenFLEditable, settings);
		settings.clear();
		
		// TimeLineContainerStarling
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = TimeLineContainerStarlingEditable.create;
		settings.creationFunctionForLoading = TimeLineContainerStarlingEditable.fromPool;
		settings.creationFunctionForTemplateInstance = TimeLineContainerStarlingEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.exportClassName = Type.getClassName(TimeLineContainerStarling);
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.isContainer = true;
		settings.isContainerStarling = true;
		settings.isTimeLineContainer = true;
		settings.collection = ContainerData.exposeTimeLineContainerStarlingEditable();
		settings.visibilityCollection = ContainerData.getTimeLineContainerStarlingEditableVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(TimeLineContainerStarlingEditable, settings);
		settings.clear();
		
		// TimeLineContainerStarling3D
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = TimeLineContainerStarling3DEditable.create;
		settings.creationFunctionForLoading = TimeLineContainerStarling3DEditable.fromPool;
		settings.creationFunctionForTemplateInstance = TimeLineContainerStarling3DEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		settings.exportClassName = Type.getClassName(TimeLineContainerStarling3D);
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.isContainer = true;
		settings.isContainerStarling = true;
		settings.isTimeLineContainer = true;
		settings.collection = ContainerData.exposeTimeLineContainerStarling3DEditable();
		settings.visibilityCollection = ContainerData.getTimeLineContainerStarling3DEditableVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(TimeLineContainerStarling3DEditable, settings);
		settings.clear();
		
		// TimeLineContainerOpenFLStarling
		settings.canBeCreated = true;
		settings.cloneToFunctionName = "cloneTo";
		settings.creationFunction = TimeLineContainerOpenFLStarlingEditable.create;
		settings.creationFunctionForLoading = TimeLineContainerOpenFLStarlingEditable.fromPool;
		settings.creationFunctionForTemplateInstance = TimeLineContainerOpenFLStarlingEditable.fromPool;
		settings.disposeFunctionName = "pool";
		settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl_starling.png");
		settings.exportClassName = Type.getClassName(TimeLineContainerOpenFLStarling);
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		settings.isContainer = true;
		settings.isContainerOpenFL = true;
		settings.isContainerStarling = true;
		settings.isTimeLineContainer = true;
		settings.collection = ContainerData.exposeTimeLineContainerOpenFLStarlingEditable();
		settings.visibilityCollection = ContainerData.getTimeLineContainerOpenFLStarlingEditableVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(TimeLineContainerOpenFLStarlingEditable, settings);
		settings.clear();
		
		// ValEditorContainerRoot
		settings.canBeCreated = false;
		settings.creationFunction = ValEditor.createContainerRoot;
		settings.creationFunctionForLoading = ValEditorContainerRoot.fromPool;
		settings.disposeFunctionName = "pool";
		settings.exportClassName = Type.getClassName(TimeLineContainerOpenFLStarling);
		settings.isContainer = true;
		settings.isContainerOpenFL = true;
		settings.isContainerStarling = true;
		settings.isTimeLineContainer = true;
		settings.collection = ContainerData.exposeValEditorContainerRoot();
		settings.visibilityCollection = ContainerData.getValEditorContainerRootVisibility();
		settings.useBounds = true;
		ValEditor.registerClass(ValEditorContainerRoot, settings);
		settings.clear();
		
		// ValEditorKeyFrame
		ValEditor.registerClassSimple(ValEditorKeyFrame, false, ContainerData.exposeValEditorKeyFrame());
		// ExportSettings
		ValEditor.registerClassSimple(ExportSettings, false, SettingsData.exposeExportSettings());
		// FileSettings
		ValEditor.registerClassSimple(FileSettings, false, SettingsData.exposeFileSettings());
		// InteractiveObjectController
		ValEditor.registerClassSimple(InteractiveObjectController, false, SettingsData.exposeInteractiveObjectController());
		
		settings.pool();
	}
	
}
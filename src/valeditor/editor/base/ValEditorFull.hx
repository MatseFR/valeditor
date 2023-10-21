package valeditor.editor.base;
import feathers.controls.navigators.StackItem;
import inputAction.InputAction;
import inputAction.controllers.KeyAction;
import inputAction.events.InputActionEvent;
import openfl.display.Sprite;
import openfl.ui.Keyboard;
import valedit.data.valeditor.ContainerData;
import valedit.data.valeditor.SettingsData;
import valeditor.ValEditorContainer;
import valeditor.ValEditorKeyFrame;
import valeditor.editor.file.FileController;
import valeditor.editor.settings.ExportSettings;
import valeditor.input.InputActionID;
import valeditor.ui.feathers.view.EditorView;

#if starling
import starling.core.Starling;
#end

/**
 * ...
 * @author Matse
 */
class ValEditorFull extends ValEditorBaseFeathers
{
	public var editView(default, null):EditorView;

	public function new() 
	{
		super();
	}
	
	override function editorSetup():Void 
	{
		super.editorSetup();
		
		ValEditor.init();
		
		var sprite:Sprite = new Sprite();
		addChild(sprite);
		ValEditor.rootScene = sprite;
		
		#if starling
		var starlingSprite = new starling.display.Sprite();
		Starling.current.stage.addChild(starlingSprite);
		ValEditor.rootSceneStarling = starlingSprite;
		#end
		
		var container:ValEditorContainer = ValEditor.createContainer();
		ValEditor.rootContainer = container;
		
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
	}
	
	override function exposeData():Void 
	{
		super.exposeData();
		
		ValEditor.registerClassSimple(ValEditorContainer, false, ContainerData.exposeValEditorContainer());
		ValEditor.registerClassSimple(ValEditorKeyFrame, false, ContainerData.exposeValEditKeyFrame());
		ValEditor.registerClassSimple(ExportSettings, false, SettingsData.exposeExportSettings());
	}
	
	override function ready():Void 
	{
		super.ready();
		
		this.screenNavigator.rootItemID = EditorView.ID;
		
		ValEditor.currentContainer = ValEditor.rootContainer;
	}
	
	private function onInputActionBegin(evt:InputActionEvent):Void
	{
		var action:InputAction = evt.action;
		
		switch (action.actionID)
		{
			case InputActionID.COPY :
				ValEditor.clipboard.clear();
				ValEditor.selection.copyToClipboard(ValEditor.clipboard);
			
			case InputActionID.CUT :
				ValEditor.clipboard.clear();
				ValEditor.selection.cutToClipboard(ValEditor.clipboard);
				ValEditor.selection.clear();
			
			case InputActionID.PASTE :
				ValEditor.clipboard.paste();
			
			case InputActionID.DELETE :
				ValEditor.selection.delete();
			
			case InputActionID.SELECT_ALL :
				ValEditor.currentContainer.selectAllVisible();
			
			case InputActionID.UNSELECT_ALL :
				ValEditor.selection.object = null;
			
			case InputActionID.PLAY_STOP :
				ValEditor.playStop();
			
			// file
			case InputActionID.NEW_FILE :
				trace("new file");
			
			case InputActionID.OPEN :
				FileController.open();
			
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
		#if html5
		ValEditor.keyboardController.addKeyAction(Keyboard.NUMBER_5, keyAction);
		#else
		ValEditor.keyboardController.addKeyAction(Keyboard.F5, keyAction);
		#end
		
		// insert keyframe
		keyAction = new KeyAction(InputActionID.INSERT_KEYFRAME, false, false, false, 0, 0, firstRepeatDelay, repeatDelay);
		#if html5
		ValEditor.keyboardController.addKeyAction(Keyboard.NUMBER_6, keyAction);
		#else
		ValEditor.keyboardController.addKeyAction(Keyboard.F6, keyAction);
		#end
		
		// remove frame
		keyAction = new KeyAction(InputActionID.REMOVE_FRAME, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		#if html5
		ValEditor.keyboardController.addKeyAction(Keyboard.NUMBER_5, keyAction);
		#else
		ValEditor.keyboardController.addKeyAction(Keyboard.F5, keyAction);
		#end
		
		// remove keyframe
		keyAction = new KeyAction(InputActionID.REMOVE_KEYFRAME, false, false, true, 0, 0, firstRepeatDelay, repeatDelay);
		#if html5
		ValEditor.keyboardController.addKeyAction(Keyboard.NUMBER_6, keyAction);
		#else
		ValEditor.keyboardController.addKeyAction(Keyboard.F6, keyAction);
		#end
		
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
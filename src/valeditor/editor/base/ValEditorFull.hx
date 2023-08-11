package valeditor.editor.base;
import feathers.controls.navigators.StackItem;
import inputAction.InputAction;
import inputAction.controllers.KeyAction;
import inputAction.events.InputActionEvent;
import openfl.display.Sprite;
import openfl.ui.Keyboard;
import valedit.ValEdit;
import valedit.data.valeditor.ContainerData;
import valedit.data.valeditor.SettingsData;
import valeditor.ValEditorContainer;
import valeditor.ValEditorKeyFrame;
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
		
		var sprite:Sprite = new Sprite();
		addChild(sprite);
		ValEditor.rootScene = sprite;
		
		#if starling
		var starlingSprite = new starling.display.Sprite();
		Starling.current.stage.addChild(starlingSprite);
		ValEditor.rootSceneStarling = starlingSprite;
		#end
		
		var container:ValEditorContainer = new ValEditorContainer();
		ValEditor.rootContainer = container;
		
		ValEditor.init();
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
		
		ValEditor.registerClass(ValEditorContainer, ContainerData.exposeValEditorContainer(), false, false);
		ValEditor.registerClass(ValEditorKeyFrame, ContainerData.exposeValEditKeyFrame(), false, false);
		ValEditor.registerClass(ExportSettings, SettingsData.exposeExportSettings(), false, false);
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
			case InputActionID.DELETE :
				ValEditor.selection.delete();
			
			case InputActionID.SELECT_ALL :
				ValEditor.currentContainer.selectAllVisible();
			
			case InputActionID.UNSELECT_ALL :
				ValEditor.selection.object = null;
			
			case InputActionID.NEW_FILE :
				trace("new file");
			
			case InputActionID.OPEN :
				trace("open");
			
			case InputActionID.EXPORT :
				trace("export");
			
			case InputActionID.EXPORT_AS :
				trace("export as");
			
			case InputActionID.SAVE :
				trace("save");
			
			case InputActionID.SAVE_AS :
				trace("save as");
		}
		
	}
	
	private function initInputActions():Void
	{
		// Keyboard
		var keyAction:KeyAction;
		
		var firstRepeatDelay:Float = 0.5;
		var repeatDelay:Float = 0.05;
		
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
package valeditor.editor.base;
import feathers.controls.navigators.StackItem;
import inputAction.controllers.KeyAction;
import openfl.ui.Keyboard;
import valeditor.input.InputActionID;
import valeditor.ui.feathers.view.EditorView;
import valedit.ValEdit;

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
	
	override function ready():Void 
	{
		var item:StackItem;
		
		super.ready();
		
		ValEditor.init();
		initInputActions();
		
		this.editView = new EditorView();
		this.editView.initializeNow();
		ValEdit.uiContainerDefault = this.editView.editContainer;
		
		item = StackItem.withDisplayObject(EditorView.ID, this.editView);
		this.screenNavigator.addItem(item);
		
		this.screenNavigator.rootItemID = EditorView.ID;
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
		
		keyAction = new KeyAction(InputActionID.DELETE);
		ValEditor.keyboardController.addKeyAction(Keyboard.DELETE, keyAction);
		ValEditor.keyboardController.addKeyAction(Keyboard.BACKSPACE, keyAction);
	}
	
}
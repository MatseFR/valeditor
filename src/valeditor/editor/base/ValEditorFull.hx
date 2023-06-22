package valeditor.editor.base;
import feathers.controls.navigators.StackItem;
import inputAction.InputAction;
import inputAction.controllers.KeyAction;
import inputAction.events.InputActionEvent;
import openfl.ui.Keyboard;
import valedit.ValEdit;
import valeditor.input.InputActionID;
import valeditor.ui.feathers.view.EditorView;

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
		ValEditor.input.addEventListener(InputActionEvent.ACTION_BEGIN, onInputActionBegin);
		
		this.editView = new EditorView();
		this.editView.initializeNow();
		ValEdit.uiContainerDefault = this.editView.editContainer;
		
		item = StackItem.withDisplayObject(EditorView.ID, this.editView);
		this.screenNavigator.addItem(item);
		
		this.screenNavigator.rootItemID = EditorView.ID;
	}
	
	private function onInputActionBegin(evt:InputActionEvent):Void
	{
		var action:InputAction = evt.action;
		
		switch (action.actionID)
		{
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
	
}
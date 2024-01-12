package valeditor.input;

import inputAction.Input;
import inputAction.InputAction;
import juggler.animation.IAnimatable;
import valedit.utils.RegularPropertyName;
import valeditor.editor.action.MultiAction;

/**
 * ...
 * @author Matse
 */
class LiveInputActionManager implements IAnimatable 
{
	
	public function new() 
	{
		
	}
	
	public function advanceTime(time:Float):Void 
	{
		var action:MultiAction;
		var inputAction:InputAction;
		var input:Input = ValEditor.input;
		
		if (ValEditor.currentContainer != null)
		{
			// insert frame
			if (input.justDid(InputActionID.INSERT_FRAME) != null)
			{
				action = MultiAction.fromPool();
				ValEditor.insertFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			}
			else
			{
				inputAction = input.isDoing(InputActionID.INSERT_FRAME);
				if (inputAction != null && inputAction.canRepeat())
				{
					action = MultiAction.fromPool();
					ValEditor.insertFrame(action);
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
			
			// insert keyframe
			if (input.justDid(InputActionID.INSERT_KEYFRAME) != null)
			{
				action = MultiAction.fromPool();
				ValEditor.insertKeyFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			}
			else
			{
				inputAction = input.isDoing(InputActionID.INSERT_KEYFRAME);
				if (inputAction != null && inputAction.canRepeat())
				{
					action = MultiAction.fromPool();
					ValEditor.insertKeyFrame(action);
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
			
			// remove frame
			if (input.justDid(InputActionID.REMOVE_FRAME) != null)
			{
				action = MultiAction.fromPool();
				ValEditor.removeFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			}
			else
			{
				inputAction = input.isDoing(InputActionID.REMOVE_FRAME);
				if (inputAction != null && inputAction.canRepeat())
				{
					action = MultiAction.fromPool();
					ValEditor.removeFrame(action);
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
			
			// remove keyframe
			if (input.justDid(InputActionID.REMOVE_KEYFRAME) != null)
			{
				action = MultiAction.fromPool();
				ValEditor.removeKeyFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			}
			else
			{
				inputAction = input.isDoing(InputActionID.REMOVE_KEYFRAME);
				if (inputAction != null && inputAction.canRepeat())
				{
					action = MultiAction.fromPool();
					ValEditor.removeKeyFrame(action);
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
			
			// Move down
			if (input.justDid(InputActionID.MOVE_DOWN_1) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, 1.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_DOWN_1);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, 1.0);
				}
			}
			
			if (input.justDid(InputActionID.MOVE_DOWN_10) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, 10.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_DOWN_10);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, 10.0);
				}
			}
			
			// Move left
			if (input.justDid(InputActionID.MOVE_LEFT_1) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, -1.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_LEFT_1);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, -1.0);
				}
			}
			
			if (input.justDid(InputActionID.MOVE_LEFT_10) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, -10.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_LEFT_10);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, -10.0);
				}
			}
			
			// Move right
			if (input.justDid(InputActionID.MOVE_RIGHT_1) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, 1.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_RIGHT_1);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, 1.0);
				}
			}
			
			if (input.justDid(InputActionID.MOVE_RIGHT_10) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, 10.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_RIGHT_10);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.X, 10.0);
				}
			}
			
			// Move up
			if (input.justDid(InputActionID.MOVE_UP_1) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, -1.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_UP_1);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, -1.0);
				}
			}
			
			if (input.justDid(InputActionID.MOVE_UP_10) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, -10.0);
			}
			else
			{
				inputAction = input.isDoing(InputActionID.MOVE_UP_10);
				if (inputAction != null && inputAction.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, -10.0);
				}
			}
		}
	}
	
}
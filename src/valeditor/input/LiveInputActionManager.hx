package valeditor.input;

import inputAction.Input;
import inputAction.InputAction;
import juggler.animation.IAnimatable;
import valedit.utils.RegularPropertyName;

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
		var action:InputAction;
		var input:Input = ValEditor.input;
		
		if (ValEditor.currentContainer != null)
		{
			// insert frame
			if (input.justDid(InputActionID.INSERT_FRAME) != null)
			{
				ValEditor.insertFrame();
			}
			else
			{
				action = input.isDoing(InputActionID.INSERT_FRAME);
				if (action != null && action.canRepeat())
				{
					ValEditor.insertFrame();
				}
			}
			
			// insert keyframe
			if (input.justDid(InputActionID.INSERT_KEYFRAME) != null)
			{
				ValEditor.insertKeyFrame();
			}
			else
			{
				action = input.isDoing(InputActionID.INSERT_KEYFRAME);
				if (action != null && action.canRepeat())
				{
					ValEditor.insertKeyFrame();
				}
			}
			
			// remove frame
			if (input.justDid(InputActionID.REMOVE_FRAME) != null)
			{
				ValEditor.removeFrame();
			}
			else
			{
				action = input.isDoing(InputActionID.REMOVE_FRAME);
				if (action != null && action.canRepeat())
				{
					ValEditor.removeFrame();
				}
			}
			
			// remove keyframe
			if (input.justDid(InputActionID.REMOVE_KEYFRAME) != null)
			{
				ValEditor.removeKeyFrame();
			}
			else
			{
				action = input.isDoing(InputActionID.REMOVE_KEYFRAME);
				if (action != null && action.canRepeat())
				{
					ValEditor.removeKeyFrame();
				}
			}
			
			// Move down
			if (input.justDid(InputActionID.MOVE_DOWN_1) != null)
			{
				ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, 1.0);
			}
			else
			{
				action = input.isDoing(InputActionID.MOVE_DOWN_1);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_DOWN_10);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_LEFT_1);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_LEFT_10);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_RIGHT_1);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_RIGHT_10);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_UP_1);
				if (action != null && action.canRepeat())
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
				action = input.isDoing(InputActionID.MOVE_UP_10);
				if (action != null && action.canRepeat())
				{
					ValEditor.currentContainer.selection.modifyDisplayProperty(RegularPropertyName.Y, -10.0);
				}
			}
		}
	}
	
}
package valeditor;

import valedit.ValEditClassSettings;
import valeditor.ui.IInteractiveObject;

/**
 * ...
 * @author Matse
 */
class ValEditorClassSettings extends ValEditClassSettings 
{
	public var interactiveFactory:ValEditorObject->IInteractiveObject;

	public function new() 
	{
		super();
	}
	
}
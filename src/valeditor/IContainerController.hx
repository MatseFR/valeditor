package valeditor;
import juggler.animation.IAnimatable;
import valeditor.container.IContainerEditable;
import valeditor.editor.action.MultiAction;

/**
 * @author Matse
 */
interface IContainerController extends IAnimatable
{
	public var container(get, never):IContainerEditable;
	public var containerObject(get, set):ValEditorObject;
	public var ignoreRightClick(default, null):Bool;
	public var selection(default, null):ValEditorObjectGroup;
	public var ignoreSelectionEvents(get, set):Bool;
	
	function clear():Void;
	function selectAllVisible(?action:MultiAction):Void;
}
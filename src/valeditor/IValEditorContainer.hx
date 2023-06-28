package valeditor;
import valedit.IValEditContainer;

/**
 * @author Matse
 */
interface IValEditorContainer extends IValEditContainer
{
	function open():Void;
	function close():Void;
}
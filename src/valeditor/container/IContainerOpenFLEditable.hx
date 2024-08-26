package valeditor.container;
import openfl.display.DisplayObjectContainer;

/**
 * @author Matse
 */
interface IContainerOpenFLEditable 
{
	public var container(get, never):DisplayObjectContainer;
	public var rootContainer(get, set):DisplayObjectContainer;
}
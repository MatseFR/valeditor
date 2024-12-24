package valeditor.container;
#if starling
import starling.display.DisplayObjectContainer;

/**
 * @author Matse
 */
interface IContainerStarlingEditable 
{
	public var containerStarling(get, never):DisplayObjectContainer;
	public var rootContainer(get, set):openfl.display.DisplayObjectContainer;
	public var rootContainerStarling(get, set):DisplayObjectContainer;
}
#end
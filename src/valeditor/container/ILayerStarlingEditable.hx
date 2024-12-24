package valeditor.container;
#if starling
import starling.display.DisplayObjectContainer;

/**
 * @author Matse
 */
interface ILayerStarlingEditable 
{
	public var rootContainerStarling(get, set):DisplayObjectContainer;
}
#end
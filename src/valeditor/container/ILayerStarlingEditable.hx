#if starling
package valeditor.container;
import starling.display.DisplayObjectContainer;

/**
 * @author Matse
 */
interface ILayerStarlingEditable 
{
	public var rootContainerStarling(get, set):DisplayObjectContainer;
}
#end
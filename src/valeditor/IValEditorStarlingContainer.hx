package valeditor;
import starling.display.DisplayObjectContainer;

/**
 * @author Matse
 */
interface IValEditorStarlingContainer 
{
	public var containerStarling(get, never):DisplayObjectContainer;
	public var rootContainer(get, set):openfl.display.DisplayObjectContainer;
	public var rootContainerStarling(get, set):DisplayObjectContainer;
}
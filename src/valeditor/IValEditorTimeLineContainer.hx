package valeditor;
import juggler.animation.Juggler;
import valedit.ValEditLayer;
import valedit.ValEditTimeLine;

/**
 * @author Matse
 */
interface IValEditorTimeLineContainer 
{
	public var currentLayer(get, set):ValEditLayer;
	public var frameIndex(get, set):Int;
	public var frameRate(get, set):Float;
	public var isPlaying(get, never):Bool;
	public var juggler(get, set):Juggler;
	public var lastFrameIndex(get, never):Int;
	public var timeLine(default, null):ValEditTimeLine;
	
	function play():Void;
	function stop():Void;
}
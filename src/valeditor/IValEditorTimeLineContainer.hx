package valeditor;
import feathers.data.ArrayCollection;
import juggler.animation.Juggler;
import valedit.ValEditLayer;
import valedit.ValEditTimeLine;

/**
 * @author Matse
 */
interface IValEditorTimeLineContainer extends IValEditorContainer
{
	public var currentLayer(get, set):ValEditLayer;
	public var frameIndex(get, set):Int;
	public var frameRate(get, set):Float;
	public var hasInvisibleLayer(get, never):Bool;
	public var hasLockedLayer(get, never):Bool;
	public var isPlaying(get, never):Bool;
	public var juggler(get, set):Juggler;
	public var lastFrameIndex(get, never):Int;
	public var layerCollection(default, null):ArrayCollection<ValEditorLayer>;
	public var numLayers(get, never):Int;
	public var timeLine(default, null):ValEditTimeLine;
	
	function addLayer(layer:ValEditLayer):Void;
	function addLayerAt(layer:ValEditLayer, index:Int):Void;
	function getLayer(name:String):ValEditLayer;
	function getLayerAt(index:Int):ValEditLayer;
	function getLayerIndex(layer:ValEditLayer):Int;
	function getOtherLayers(layersToIgnore:Array<ValEditorLayer>, ?otherLayers:Array<ValEditorLayer>):Array<ValEditorLayer>;
	function layerIndexDown(layer:ValEditLayer):Void;
	function layerIndexUp(layer:ValEditLayer):Void;
	function layerNameExists(name:String):Bool;
	function removeLayer(layer:ValEditLayer):Void;
	function removeLayerAt(index:Int):Void;
	function removeLayerWithName(name:String):Void;
	function play():Void;
	function stop():Void;
}
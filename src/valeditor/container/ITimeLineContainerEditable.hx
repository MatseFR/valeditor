package valeditor.container;
import feathers.data.ArrayCollection;
import juggler.animation.Juggler;
import valeditor.ValEditorTimeLine;
import valeditor.container.IContainerEditable;

/**
 * @author Matse
 */
interface ITimeLineContainerEditable extends IContainerEditable
{
	public var autoIncreaseNumFrames(get, set):Bool;
	public var currentLayer(get, set):ITimeLineLayerEditable;
	public var frameIndex(get, set):Int;
	public var frameRate(get, set):Float;
	public var hasInvisibleLayer(get, never):Bool;
	public var hasLockedLayer(get, never):Bool;
	public var isPlaying(get, never):Bool;
	public var juggler(get, set):Juggler;
	public var lastFrameIndex(get, never):Int;
	public var layerCollection(default, null):ArrayCollection<ITimeLineLayerEditable>;
	public var numFrames(get, set):Int;
	public var numLayers(get, never):Int;
	public var timeLine(default, null):ValEditorTimeLine;
	
	function createLayer():ITimeLineLayerEditable;
	function addLayer(layer:ITimeLineLayerEditable):Void;
	function addLayerAt(layer:ITimeLineLayerEditable, index:Int):Void;
	function getLayer(name:String):ITimeLineLayerEditable;
	function getLayerAt(index:Int):ITimeLineLayerEditable;
	function getLayerIndex(layer:ITimeLineLayerEditable):Int;
	function getOtherLayers(layersToIgnore:Array<ITimeLineLayerEditable>, ?otherLayers:Array<ITimeLineLayerEditable>):Array<ITimeLineLayerEditable>;
	function layerIndexDown(layer:ITimeLineLayerEditable):Void;
	function layerIndexUp(layer:ITimeLineLayerEditable):Void;
	function layerNameExists(name:String):Bool;
	function removeLayer(layer:ITimeLineLayerEditable):Void;
	function removeLayerAt(index:Int):Void;
	function removeLayerWithName(name:String):Void;
	function play():Void;
	function stop():Void;
}
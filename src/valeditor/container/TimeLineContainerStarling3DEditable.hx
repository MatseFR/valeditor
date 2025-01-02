package valeditor.container;
import valeditor.ValEditorObjectLibrary;
#if starling
import feathers.data.ArrayCollection;
import haxe.ds.ObjectMap;
import juggler.animation.Juggler;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;
import starling.display.BlendMode;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite3D;
import valedit.events.PlayEvent;
import valeditor.editor.data.ContainerSaveData;
import valeditor.events.ContainerEvent;
import valeditor.events.KeyFrameEvent;
import valeditor.events.LayerEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
import valeditor.events.TimeLineActionEvent;
import valeditor.ui.UIConfig;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class TimeLineContainerStarling3DEditable extends EventDispatcher implements IContainerEditable implements ITimeLineContainerEditable implements IContainerStarlingEditable
{
	static private var _POOL:Array<TimeLineContainerStarling3DEditable> = new Array<TimeLineContainerStarling3DEditable>();
	
	static public function create():TimeLineContainerStarling3DEditable
	{
		var container:TimeLineContainerStarling3DEditable = fromPool();
		ValEditor.setupTimeLineContainer(container);
		return container;
	}
	
	static public function fromPool():TimeLineContainerStarling3DEditable
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TimeLineContainerStarling3DEditable();
	}
	
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var alpha(get, set):Float;
	public var autoPlay:Bool = true;
	public var autoIncreaseNumFrames(get, set):Bool;
	public var blendMode(get, set):String;
	public var cameraX(get, set):Float;
	public var cameraY(get, set):Float;
	public var containerStarling(get, never):DisplayObjectContainer;
	public var containerUI(default, null):openfl.display.DisplayObjectContainer = new openfl.display.Sprite();
	public var currentLayer(get, set):ITimeLineLayerEditable;
	public var frameIndex(get, set):Int;
	public var frameRate(get, set):Float;
	public var hasInvisibleLayer(get, never):Bool;
	public var hasLockedLayer(get, never):Bool;
	public var height(get, set):Float;
	public var isLoaded(get, never):Bool;
	public var isOpen(get, never):Bool;
	public var isPlaying(get, never):Bool;
	public var isReverse(get, never):Bool;
	public var juggler(get, set):Juggler;
	public var lastFrameIndex(get, never):Int;
	public var layerCollection(default, null):ArrayCollection<ITimeLineLayerEditable> = new ArrayCollection<ITimeLineLayerEditable>();
	public var loop(get, set):Bool;
	public var numFrames(get, set):Int;
	public var numLayers(get, never):Int;
	public var numLoops(get, set):Int;
	public var objectLibrary(default, null):ValEditorObjectLibrary = new ValEditorObjectLibrary();
	public var parent(get, never):DisplayObjectContainer;
	/** reverse animation on every odd loop */
	public var reverse(get, set):Bool;
	public var rootContainer(get, set):openfl.display.DisplayObjectContainer;
	public var rootContainerStarling(get, set):DisplayObjectContainer;
	public var rotationX(get, set):Float;
	public var rotationY(get, set):Float;
	public var rotationZ(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var scaleZ(get, set):Float;
	public var selectedLayers(default, null):Array<ITimeLineLayerEditable> = new Array<ITimeLineLayerEditable>();
	public var timeLine(default, null):ValEditorTimeLine;
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	public var visible(get, set):Bool;
	public var width(get, set):Float;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	
	private function get_alpha():Float { return this._containerStarling.alpha; }
	private function set_alpha(value:Float):Float
	{
		return this._containerStarling.alpha = value;
	}
	
	private function get_autoIncreaseNumFrames():Bool { return this.timeLine.autoIncreaseNumFrames; }
	private function set_autoIncreaseNumFrames(value:Bool):Bool
	{
		return this.timeLine.autoIncreaseNumFrames = value;
	}
	
	private var _blendMode:String = BlendMode.AUTO;
	private function get_blendMode():String { return this._blendMode; }
	private function set_blendMode(value:String):String
	{
		this._containerStarling.blendMode = value;
		return this._blendMode = value;
	}
	
	private var _cameraX:Float = 0;
	private function get_cameraX():Float { return this._cameraX; }
	private function set_cameraX(value:Float):Float
	{
		this._containerStarling.x = this.containerUI.x = this._x - value;
		return this._cameraX = value;
	}
	
	private var _cameraY:Float = 0;
	private function get_cameraY():Float { return this._cameraY; }
	private function set_cameraY(value:Float):Float
	{
		this._containerStarling.y = this.containerUI.y = this._y - value;
		return this._cameraY = value;
	}
	
	private var _containerStarling:Sprite3D = new Sprite3D();
	private function get_containerStarling():DisplayObjectContainer { return this._containerStarling; }
	
	private var _currentLayer:ITimeLineLayerEditable;
	private function get_currentLayer():ITimeLineLayerEditable { return this._currentLayer; }
	private function set_currentLayer(value:ITimeLineLayerEditable):ITimeLineLayerEditable
	{
		if (this._currentLayer == value) return value;
		this._currentLayer = value;
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
		return this._currentLayer;
	}
	
	private function get_frameIndex():Int { return this.timeLine.frameIndex; }
	private function set_frameIndex(value:Int):Int
	{
		return this.timeLine.frameIndex = value;
	}
	
	private function get_frameRate():Float { return this.timeLine.frameRate; }
	private function set_frameRate(value:Float):Float
	{
		return this.timeLine.frameRate = value;
	}
	
	private function get_hasInvisibleLayer():Bool
	{
		for (layer in this._layers)
		{
			if (!layer.visible) return true;
		}
		return false;
	}
	
	private function get_hasLockedLayer():Bool
	{
		for (layer in this._layers)
		{
			if (layer.locked) return true;
		}
		return false;
	}
	
	private function get_isLoaded():Bool { return this.objectLibrary.isLoaded; }
	
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	
	private function get_isPlaying():Bool { return this.timeLine.isPlaying; }
	
	private function get_isReverse():Bool { return this.timeLine.isReverse; }
	
	private function get_juggler():Juggler { return this.timeLine.juggler; }
	private function set_juggler(value:Juggler):Juggler
	{
		return this.timeLine.juggler = value;
	}
	
	private function get_height():Float { return this._containerStarling.height; }
	private function set_height(value:Float):Float
	{
		return this._containerStarling.height = value;
	}
	
	private function get_lastFrameIndex():Int { return this.timeLine.lastFrameIndex; }
	
	private function get_loop():Bool { return this.timeLine.loop; }
	private function set_loop(value:Bool):Bool
	{
		return this.timeLine.loop = value;
	}
	
	private function get_numFrames():Int { return this.timeLine.numFrames; }
	private function set_numFrames(value:Int):Int
	{
		return this.timeLine.numFrames = value;
	}
	
	private function get_numLayers():Int { return this._layers.length; }
	
	private function get_numLoops():Int { return this.timeLine.numLoops; }
	private function set_numLoops(value:Int):Int
	{
		return this.timeLine.numLoops = value;
	}
	
	private function get_parent():DisplayObjectContainer { return this._rootContainerStarling; }
	
	private function get_reverse():Bool { return this.timeLine.reverse; }
	private function set_reverse(value:Bool):Bool
	{
		return this.timeLine.reverse = value;
	}
	
	private var _rootContainer:openfl.display.DisplayObjectContainer;
	private function get_rootContainer():openfl.display.DisplayObjectContainer { return this._rootContainer; }
	private function set_rootContainer(value:openfl.display.DisplayObjectContainer):openfl.display.DisplayObjectContainer
	{
		if (this._rootContainer == value) return value;
		
		if (this._rootContainer != null)
		{
			this._rootContainer.removeChild(this.containerUI);
		}
		
		if (value != null)
		{
			value.addChild(this.containerUI);
		}
		
		return this._rootContainer = value;
	}
	
	private var _rootContainerStarling:DisplayObjectContainer;
	private function get_rootContainerStarling():DisplayObjectContainer { return this._rootContainerStarling; }
	private function set_rootContainerStarling(value:DisplayObjectContainer):DisplayObjectContainer
	{
		if (this._rootContainerStarling == value) return value;
		
		if (this._rootContainerStarling != null)
		{
			this._rootContainerStarling.removeChild(this._containerStarling);
		}
		
		if (value != null)
		{
			value.addChild(this._containerStarling);
		}
		
		return this._rootContainerStarling = value;
	}
	
	private function get_rotationX():Float { return this._containerStarling.rotationX; }
	private function set_rotationX(value:Float):Float
	{
		return this._containerStarling.rotationX = value;
	}
	
	private function get_rotationY():Float { return this._containerStarling.rotationY; }
	private function set_rotationY(value:Float):Float
	{
		return this._containerStarling.rotationY = value;
	}
	
	private function get_rotationZ():Float { return this._containerStarling.rotationZ; }
	private function set_rotationZ(value:Float):Float
	{
		return this._containerStarling.rotationZ = value;
	}
	
	private function get_scaleX():Float { return this._containerStarling.scaleX; }
	private function set_scaleX(value:Float):Float 
	{
		return this._containerStarling.scaleX = this.containerUI.scaleX = value;
	}
	
	private function get_scaleY():Float { return this._containerStarling.scaleY; }
	private function set_scaleY(value:Float):Float 
	{
		return this._containerStarling.scaleY = this.containerUI.scaleY = value;
	}
	
	private function get_scaleZ():Float { return this._containerStarling.scaleZ; }
	private function set_scaleZ(value:Float):Float
	{
		return this._containerStarling.scaleZ = value;
	}
	
	private var _viewCenterX:Float = 0;
	private function get_viewCenterX():Float { return this._viewCenterX; }
	private function set_viewCenterX(value:Float):Float
	{
		this.cameraX = Math.fround(value - this._viewWidth / 2);
		return this._viewCenterX = value;
	}
	
	private var _viewCenterY:Float = 0;
	private function get_viewCenterY():Float { return this._viewCenterY; }
	private function set_viewCenterY(value:Float):Float
	{
		this.cameraY = Math.fround(value - this._viewHeight / 2);
		return this._viewCenterY = value;
	}
	
	private var _viewHeight:Float = 0;
	private function get_viewHeight():Float { return this._viewHeight; }
	private function set_viewHeight(value:Float):Float
	{
		return this._viewHeight = value;
	}
	
	private var _viewWidth:Float = 0;
	private function get_viewWidth():Float { return this._viewWidth; }
	private function set_viewWidth(value:Float):Float
	{
		return this._viewWidth = value;
	}
	
	private function get_visible():Bool { return this._containerStarling.visible; }
	private function set_visible(value:Bool):Bool
	{
		return this._containerStarling.visible = this.containerUI.visible = value;
	}
	
	private function get_width():Float { return this._containerStarling.width; }
	private function set_width(value:Float):Float
	{
		return this._containerStarling.width = value;
	}
	
	private var _x:Float = 0;
	private function get_x():Float { return this._x; }
	private function set_x(value:Float):Float
	{
		this._containerStarling.x = this.containerUI.x = value - this._cameraX;
		return this._x = value;
	}
	
	private var _y:Float = 0;
	private function get_y():Float { return this._y; }
	private function set_y(value:Float):Float
	{
		this._containerStarling.y = this.containerUI.y = value - this._cameraY;
		return this._y = value;
	}
	
	private var _z:Float = 0;
	private function get_z():Float { return this._z; }
	private function set_z(value:Float):Float
	{
		return this._containerStarling.z = value;
	}
	
	private var _pivotIndicator:PivotIndicator = new PivotIndicator(UIConfig.CONTAINER_PIVOT_SIZE, UIConfig.CONTAINER_PIVOT_COLOR,
		UIConfig.CONTAINER_PIVOT_ALPHA, UIConfig.CONTAINER_PIVOT_OUTLINE_COLOR, UIConfig.CONTAINER_PIVOT_OUTLINE_ALPHA);
	
	private var _layerNameIndex:Int = 0;
	private var _layers:Array<ITimeLineLayerEditable> = new Array<ITimeLineLayerEditable>();
	private var _layerMap:Map<String, ITimeLineLayerEditable> = new Map<String, ITimeLineLayerEditable>();
	
	private var _allObjects:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
	private var _activeObjects:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
	private var _objectToLayer:ObjectMap<ValEditorObject, ITimeLineLayerEditable> = new ObjectMap<ValEditorObject, ITimeLineLayerEditable>();
	
	public function new() 
	{
		super();
		this.timeLine = new ValEditorTimeLine(0);
		this.timeLine.addEventListener(PlayEvent.PLAY, onPlay);
		this.timeLine.addEventListener(PlayEvent.STOP, onStop);
	}
	
	public function clear():Void
	{
		this.objectLibrary.clear();
		this.timeLine.clear();
		
		for (layer in this._layers)
		{
			layerUnregister(layer);
			layer.pool();
		}
		this._layers.resize(0);
		this._layerMap.clear();
		this._currentLayer = null;
		
		this.rootContainer = null;
		this.rootContainerStarling = null;
		
		this.layerCollection.removeAll();
		this.activeObjectsCollection.removeAll();
		this.allObjectsCollection.removeAll();
		
		this.viewCenterX = 0;
		this.viewCenterY = 0;
		this.viewWidth = 0;
		this.viewHeight = 0;
		
		this.selectedLayers.resize(0);
		
		this._layerNameIndex = 0;
		
		this.alpha = 1.0;
		this.autoPlay = true;
		this.blendMode = BlendMode.AUTO;
		this.cameraX = 0;
		this.cameraY = 0;
		this.rotationX = 0;
		this.rotationY = 0;
		this.rotationZ = 0;
		this.scaleX = 1.0;
		this.scaleY = 1.0;
		this.scaleZ = 1.0;
		this.visible = true;
		this.x = 0;
		this.y = 0;
		this.z = 0;
		
		this._allObjects.clear();
		this._activeObjects.clear();
		this._objectToLayer.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function adjustView():Void
	{
		this.viewCenterX = this._viewCenterX;
		this.viewCenterY = this._viewCenterY;
	}
	
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		if (targetSpace == this)
		{
			targetSpace = this._containerStarling;
		}
		return this._containerStarling.getBounds(targetSpace);
	}
	
	public function createLayer():ITimeLineLayerEditable
	{
		return LayerStarlingEditable.fromPool();
	}
	
	public function layerNameExists(name:String):Bool
	{
		return this._layerMap.exists(name);
	}
	
	public function makeLayerName():String
	{
		var name:String = null;
		while (true)
		{
			this._layerNameIndex++;
			name = "layer " + this._layerNameIndex;
			if (!this._layerMap.exists(name)) break;
		}
		return name;
	}
	
	public function play():Void
	{
		this.timeLine.play();
	}
	
	public function stop():Void
	{
		this.timeLine.stop();
	}
	
	public function canAddObject(object:ValEditorObject):Bool
	{
		return this._currentLayer.canAddObject(object);
	}
	
	public function hasActiveObject(objectID:String):Bool
	{
		return this._activeObjects.exists(objectID);
	}
	
	public function hasObject(objectID:String):Bool
	{
		return this._allObjects.exists(objectID);
	}
	
	public function hasVisibleObject():Bool
	{
		for (layer in this.layerCollection)
		{
			if (layer.visible && layer.hasVisibleObject())
			{
				return true;
			}
		}
		return false;
	}
	
	public function addLayer(layer:ITimeLineLayerEditable):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.add(layer);
		this._layers[this._layers.length] = layer;
		this._layerMap.set(layer.name, layer);
		layerRegister(layer, this._layers.length - 1);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_ADDED, layer);
		this.currentLayer = layer;
	}
	
	public function addLayerAt(layer:ITimeLineLayerEditable, index:Int):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.addAt(layer, index);
		this._layers.insert(index, layer);
		this._layerMap.set(layer.name, layer);
		layerRegister(layer, index);
		
		// update layer indexes
		var count:Int = this._layers.length;
		for (i in index+1...count)
		{
			this._layers[i].indexUpdate(count - 1 - i);
		}
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_ADDED, layer);
		this.currentLayer = layer;
	}
	
	public function getLayer(name:String):ITimeLineLayerEditable
	{
		return this._layerMap.get(name);
	}
	
	public function getLayerAt(index:Int):ITimeLineLayerEditable
	{
		return this._layers[index];
	}
	
	public function getLayerIndex(layer:ITimeLineLayerEditable):Int
	{
		return this._layers.indexOf(layer);
	}
	
	public function getOtherLayers(layersToIgnore:Array<ITimeLineLayerEditable>, ?otherLayers:Array<ITimeLineLayerEditable>):Array<ITimeLineLayerEditable>
	{
		if (otherLayers == null) otherLayers = new Array<ITimeLineLayerEditable>();
		
		for (layer in this._layers)
		{
			if (layersToIgnore.indexOf(layer) == -1)
			{
				otherLayers.push(layer);
			}
		}
		
		return otherLayers;
	}
	
	public function layerIndexDown(layer:ITimeLineLayerEditable):Void
	{
		var index:Int = this._layers.indexOf(layer);
		var count:Int = this._layers.length;
		
		this._layers.splice(index, 1);
		this._layers.insert(index + 1, layer);
		
		this.layerCollection.removeAt(index);
		this.layerCollection.addAt(layer, index + 1);
		
		this._layers[index].indexUpdate(count - 1 - index);
		this._layers[index + 1].indexUpdate(count - 1 - (index + 1));
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_INDEX_DOWN, layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
	}
	
	public function layerIndexUp(layer:ITimeLineLayerEditable):Void
	{
		var index:Int = this._layers.indexOf(layer);
		var count:Int = this._layers.length;
		
		this._layers.splice(index, 1);
		this._layers.insert(index - 1, layer);
		
		this.layerCollection.removeAt(index);
		this.layerCollection.addAt(layer, index - 1);
		
		this._layers[index].indexUpdate(count - 1 - index);
		this._layers[index - 1].indexUpdate(count - 1 - (index - 1));
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_INDEX_UP, layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
	}
	
	public function removeLayer(layer:ITimeLineLayerEditable):Void
	{
		var index:Int = this._layers.indexOf(layer);
		removeLayerAt(index);
	}
	
	public function removeLayerAt(index:Int):Void
	{
		var layer:ITimeLineLayerEditable = this._layers.splice(index, 1)[0];
		this._layerMap.remove(layer.name);
		this.layerCollection.removeAt(index);
		layerUnregister(layer);
		
		var count:Int = this._layers.length;
		for (i in index...count)
		{
			this._layers[i].indexUpdate(count - 1 - i);
		}
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_REMOVED, layer);
		if (this._currentLayer == layer)
		{
			if (index != 0)
			{
				index --;
			}
			this.currentLayer = this._layers[index];
		}
	}
	
	public function removeLayerWithName(name:String):Void
	{
		var layer:ITimeLineLayerEditable = this._layerMap.get(name);
		removeLayer(layer);
	}
	
	public function setLayerIndex(layer:ITimeLineLayerEditable, index:Int):Void
	{
		var prevIndex:Int = this._layers.indexOf(layer);
		this._layers.splice(prevIndex, 1);
		this._layers.insert(index, layer);
		var layerCount:Int = this._layers.length - 1;
		layer.index = layerCount - index;
		
		if (index > prevIndex)
		{
			for (i in prevIndex...index)
			{
				this._layers[i].indexUpdate(layerCount - i);
			}
		}
		else
		{
			for (i in index + 1...prevIndex + 1)
			{
				this._layers[i].indexUpdate(layerCount - i);
			}
		}
	}
	
	private function layerRegister(layer:ITimeLineLayerEditable, index:Int):Void 
	{
		layer.index = this._layers.length - 1 - index;
		layer.timeLine.autoIncreaseNumFrames = this.autoIncreaseNumFrames;
		layer.timeLine.numFrames = this.numFrames;
		layer.timeLine.frameIndex = this.frameIndex;
		
		layer.container = this;
		this.timeLine.addSlaveAt(layer.timeLine, index);
		
		cast(layer, ILayerStarlingEditable).rootContainerStarling = this._containerStarling;
		
		for (object in layer.allObjects)
		{
			objectRegister(object, layer);
		}
		
		layer.addEventListener(LayerEvent.OBJECT_ACTIVATED, layer_objectActivated);
		layer.addEventListener(LayerEvent.OBJECT_DEACTIVATED, layer_objectDeactivated);
		layer.addEventListener(LayerEvent.OBJECT_ADDED, layer_objectAdded);
		layer.addEventListener(LayerEvent.OBJECT_REMOVED, layer_objectRemoved);
		layer.addEventListener(LayerEvent.LOCK_CHANGE, onLayerLockChange);
		layer.addEventListener(LayerEvent.VISIBLE_CHANGE, onLayerVisibilityChange);
		layer.addEventListener(RenameEvent.RENAMED, layer_renamed);
		
		layer.timeLine.addEventListener(TimeLineActionEvent.INSERT_FRAME, timeLine_insertFrame);
		layer.timeLine.addEventListener(TimeLineActionEvent.INSERT_KEYFRAME, timeLine_insertKeyFrame);
		layer.timeLine.addEventListener(TimeLineActionEvent.REMOVE_FRAME, timeLine_removeFrame);
		layer.timeLine.addEventListener(TimeLineActionEvent.REMOVE_KEYFRAME, timeLine_removeKeyFrame);
		layer.timeLine.addEventListener(KeyFrameEvent.TRANSITION_CHANGE, keyFrame_transitionChange);
		layer.timeLine.addEventListener(KeyFrameEvent.TWEEN_CHANGE, keyFrame_tweenChange);
	}
	
	private function layerUnregister(layer:ITimeLineLayerEditable):Void 
	{
		layer.container = null;
		this.timeLine.removeSlave(layer.timeLine);
		
		cast(layer, ILayerStarlingEditable).rootContainerStarling = null;
		
		for (object in layer.allObjects)
		{
			objectUnregister(object);
		}
		
		layer.removeEventListener(LayerEvent.OBJECT_ACTIVATED, layer_objectActivated);
		layer.removeEventListener(LayerEvent.OBJECT_DEACTIVATED, layer_objectDeactivated);
		layer.removeEventListener(LayerEvent.OBJECT_ADDED, layer_objectAdded);
		layer.removeEventListener(LayerEvent.OBJECT_REMOVED, layer_objectRemoved);
		layer.removeEventListener(LayerEvent.LOCK_CHANGE, onLayerLockChange);
		layer.removeEventListener(LayerEvent.VISIBLE_CHANGE, onLayerVisibilityChange);
		layer.removeEventListener(RenameEvent.RENAMED, layer_renamed);
		
		layer.timeLine.removeEventListener(TimeLineActionEvent.INSERT_FRAME, timeLine_insertFrame);
		layer.timeLine.removeEventListener(TimeLineActionEvent.INSERT_KEYFRAME, timeLine_insertKeyFrame);
		layer.timeLine.removeEventListener(TimeLineActionEvent.REMOVE_FRAME, timeLine_removeFrame);
		layer.timeLine.removeEventListener(TimeLineActionEvent.REMOVE_KEYFRAME, timeLine_removeKeyFrame);
		layer.timeLine.removeEventListener(KeyFrameEvent.TRANSITION_CHANGE, keyFrame_transitionChange);
		layer.timeLine.removeEventListener(KeyFrameEvent.TWEEN_CHANGE, keyFrame_tweenChange);
	}
	
	public function addObject(object:ValEditorObject):Void
	{
		this._currentLayer.addObject(object);
	}
	
	public function getActiveObject(objectID:String):ValEditorObject
	{
		return this._activeObjects.get(objectID);
	}
	
	public function getObject(objectID:String):ValEditorObject
	{
		return this._allObjects.get(objectID);
	}
	
	public function removeObject(object:ValEditorObject):Void
	{
		var layer:ITimeLineLayerEditable = this._objectToLayer.get(object);
		layer.removeObject(object);
	}
	
	public function removeObjectCompletely(object:ValEditorObject):Void
	{
		object.removeAllKeyFrames();
	}
	
	private function objectRegister(object:ValEditorObject, layer:ITimeLineLayerEditable):Void 
	{
		this._allObjects.set(object.objectID, object);
		this._objectToLayer.set(object, layer);
		this.allObjectsCollection.add(object);
		
		object.addEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.addEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.addEventListener(RenameEvent.RENAMED, object_renamed);
		
		object.container = this;
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED_TO_CONTAINER, object);
	}
	
	private function objectUnregister(object:ValEditorObject):Void 
	{
		this._allObjects.remove(object.objectID);
		this._objectToLayer.remove(object);
		this.allObjectsCollection.remove(object);
		
		object.removeEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.removeEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.removeEventListener(RenameEvent.RENAMED, object_renamed);
		
		object.container = null;
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED_FROM_CONTAINER, object);
	}
	
	private function onPlay(evt:PlayEvent):Void
	{
		PlayEvent.dispatch(this, PlayEvent.PLAY);
	}
	
	private function onStop(evt:PlayEvent):Void
	{
		PlayEvent.dispatch(this, PlayEvent.STOP);
	}
	
	public function getContainerDependencies(data:ContainerSaveData):Void
	{
		for (object in this.allObjectsCollection)
		{
			if (object.template != null && object.clss.isContainer && !data.hasDependency(object.template))
			{
				data.addDependency(object.template);
			}
		}
	}
	
	private function keyFrame_transitionChange(evt:KeyFrameEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function keyFrame_tweenChange(evt:KeyFrameEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function layer_objectAdded(evt:LayerEvent):Void
	{
		if (evt.object.numKeyFrames == 1)
		{
			objectRegister(evt.object, evt.layer);
		}
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED, evt.object);
	}
	
	private function layer_objectRemoved(evt:LayerEvent):Void
	{
		if (evt.object.numKeyFrames == 0)
		{
			objectUnregister(evt.object);
		}
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED, evt.object);
	}
	
	private function layer_objectActivated(evt:LayerEvent):Void 
	{
		this._activeObjects.set(evt.object.objectID, evt.object);
		this.activeObjectsCollection.add(evt.object);
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ACTIVATED, evt.object);
	}
	
	private function layer_objectDeactivated(evt:LayerEvent):Void 
	{
		this._activeObjects.remove(evt.object.objectID);
		this.activeObjectsCollection.remove(evt.object);
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_DEACTIVATED, evt.object);
	}
	
	private function layer_renamed(evt:RenameEvent):Void 
	{
		var layer:ITimeLineLayerEditable = evt.target;
		this._layerMap.remove(evt.previousNameOrID);
		this._layerMap.set(layer.name, layer);
		
		this.layerCollection.updateAt(this.layerCollection.indexOf(layer));
	}
	
	private function object_functionCalled(evt:ObjectFunctionEvent):Void
	{
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_FUNCTION_CALLED, evt.object, evt);
	}
	
	private function object_propertyChange(evt:ObjectPropertyEvent):Void
	{
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_PROPERTY_CHANGE, evt.object, evt);
	}
	
	private function object_renamed(evt:RenameEvent):Void
	{
		var object:ValEditorObject = cast evt.target;
		
		if (this._allObjects.exists(evt.previousNameOrID))
		{
			this._allObjects.remove(evt.previousNameOrID);
			this._allObjects.set(object.objectID, object);
			this.allObjectsCollection.updateAt(this.allObjectsCollection.indexOf(object));
		}
		
		if (this._activeObjects.exists(evt.previousNameOrID))
		{
			this._activeObjects.remove(evt.previousNameOrID);
			this._activeObjects.set(object.objectID, object);
			this.activeObjectsCollection.updateAt(this.activeObjectsCollection.indexOf(object));
		}
	}
	
	private function timeLine_insertFrame(evt:TimeLineActionEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function timeLine_insertKeyFrame(evt:TimeLineActionEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function timeLine_removeFrame(evt:TimeLineActionEvent):Void
	{
		dispatchEvent(evt);
	}
	
	private function timeLine_removeKeyFrame(evt:TimeLineActionEvent):Void
	{
		dispatchEvent(evt);
	}
	
	public function open():Void
	{
		if (this._isOpen) return;
		
		this._isOpen = true;
		this.containerUI.addChild(this._pivotIndicator);
		ContainerEvent.dispatch(this, ContainerEvent.OPEN);
	}
	
	public function close():Void
	{
		if (!this._isOpen) return;
		
		this._isOpen = false;
		this.containerUI.removeChild(this._pivotIndicator);
		ContainerEvent.dispatch(this, ContainerEvent.CLOSE);
	}
	
	public function getAllObjects(?objects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (objects == null) objects = new Array<ValEditorObject>();
		
		for (layer in this._layers)
		{
			layer.getAllObjects(objects);
		}
		
		return objects;
	}
	
	public function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (visibleObjects == null) visibleObjects = new Array<ValEditorObject>();
		
		for (layer in this._layers)
		{
			if (layer.visible)
			{
				layer.getAllVisibleObjects(visibleObjects);
			}
		}
		
		return visibleObjects;
	}
	
	private function onLayerLockChange(evt:LayerEvent):Void
	{
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_LOCK_CHANGE, evt.layer);
	}
	
	private function onLayerVisibilityChange(evt:LayerEvent):Void
	{
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_VISIBILITY_CHANGE, evt.layer);
	}
	
	public function cloneTo(container:TimeLineContainerStarling3DEditable):Void
	{
		container.alpha = this.alpha;
		container.autoPlay = this.autoPlay;
		container.visible = this.visible;
		container.x = this.x;
		container.y = this.y;
		
		this.timeLine.cloneTo(container.timeLine);
		var layerCount:Int = this.numLayers;
		var layer:ITimeLineLayerEditable;
		var cloneLayer:ITimeLineLayerEditable;
		for (i in 0...layerCount)
		{
			layer = this.getLayerAt(i);
			cloneLayer = createLayer();
			layer.cloneTo(cloneLayer);
			container.addLayer(cloneLayer);
		}
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.autoPlay = json.autoPlay;
		this.visible = json.visible;
		this.x = json.x;
		this.y = json.y;
		this.viewCenterX = json.viewCenterX;
		this.viewCenterY = json.viewCenterY;
		
		this.timeLine.fromJSONSave(json.timeLine);
		
		var layer:ITimeLineLayerEditable;
		var layers:Array<Dynamic> = json.layers;
		for (node in layers)
		{
			layer = createLayer();
			layer.fromJSONSave(node);
			addLayerAt(layer, 0);
		}
		
		this.frameIndex = json.frameIndex;
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.autoPlay = this.autoPlay;
		json.frameIndex = this.frameIndex;
		json.visible = this.visible;
		json.x = this.x;
		json.y = this.y;
		json.viewCenterX = this.viewCenterX;
		json.viewCenterY = this.viewCenterY;
		
		json.timeLine = this.timeLine.toJSONSave();
		
		var layers:Array<Dynamic> = [];
		for (layer in this._layers)
		{
			layers.push(layer.toJSONSave());
		}
		json.layers = layers;
		
		return json;
	}
	
}
#end
package valeditor;

import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.Rectangle;
import valedit.IValEditOpenFLContainer;
import valedit.IValEditStarlingContainer;
import valedit.ValEditContainer;
import valedit.ValEditLayer;
import valedit.ValEditObject;
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
class ValEditorContainer extends ValEditContainer implements IValEditorContainer implements IValEditorStarlingContainer implements IValEditorTimeLineContainer
{
	static private var _POOL:Array<ValEditorContainer> = new Array<ValEditorContainer>();
	
	static public function fromPool():ValEditorContainer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorContainer();
	}
	
	public var activeObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var allObjectsCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var autoIncreaseNumFrames(get, set):Bool;
	public var containerUI(default, null):DisplayObjectContainer = new Sprite();
	public var hasInvisibleLayer(get, never):Bool;
	public var hasLockedLayer(get, never):Bool;
	public var isOpen(get, never):Bool;
	public var layerCollection(default, null):ArrayCollection<ValEditorLayer> = new ArrayCollection<ValEditorLayer>();
	public var parent(get, never):DisplayObjectContainer;
	public var selectedLayers(default, null):Array<ValEditorLayer> = new Array<ValEditorLayer>();
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	
	private function get_autoIncreaseNumFrames():Bool { return cast(this.timeLine, ValEditorTimeLine).autoIncreaseNumFrames; }
	private function set_autoIncreaseNumFrames(value:Bool):Bool
	{
		return cast(this.timeLine, ValEditorTimeLine).autoIncreaseNumFrames = value;
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
	
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	
	private function get_parent():Dynamic
	{
		return this._rootContainer;
	}
	
	override function set_rotation(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.rotation = value;
		}
		return super.set_rotation(value);
	}
	
	override function set_scaleX(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.scaleX = value;
		}
		return super.set_scaleX(value);
	}
	
	override function set_scaleY(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.scaleY = value;
		}
		return super.set_scaleY(value);
	}
	
	override function set_x(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.x = value - this._cameraX;
		}
		return super.set_x(value);
	}
	
	override function set_y(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.y = value - this._cameraY;
		}
		return super.set_y(value);
	}
	
	override function set_cameraX(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.x = this._x - value;
		}
		return super.set_cameraX(value);
	}
	
	override function set_cameraY(value:Float):Float 
	{
		if (this.containerUI != null)
		{
			this.containerUI.y = this._y - value;
		}
		return super.set_cameraY(value);
	}
	
	override function set_currentLayer(value:ValEditLayer):ValEditLayer 
	{
		if (this._currentLayer == value) return value;
		super.set_currentLayer(value);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
		return this._currentLayer;
	}
	
	override function set_rootContainer(value:DisplayObjectContainer):DisplayObjectContainer 
	{
		var oldContainer:DisplayObjectContainer = this._rootContainer;
		super.set_rootContainer(value);
		if (value != null)
		{
			value.addChild(this.containerUI);
		}
		else if (oldContainer != null)
		{
			oldContainer.removeChild(this.containerUI);
		}
		return value;
	}
	
	private var _viewCenterX:Float = 0;
	private function get_viewCenterX():Float { return this._viewCenterX; }//this.cameraX + this._viewWidth / 2; }
	private function set_viewCenterX(value:Float):Float
	{
		this.cameraX = Math.fround(value - this._viewWidth / 2);
		return this._viewCenterX = value;
	}
	
	private var _viewCenterY:Float = 0;
	private function get_viewCenterY():Float { return this._viewCenterY; }//this.cameraY + this._viewHeight / 2; }
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
	
	private var _pivotIndicator:PivotIndicator = new PivotIndicator(UIConfig.CONTAINER_PIVOT_SIZE, UIConfig.CONTAINER_PIVOT_COLOR,
		UIConfig.CONTAINER_PIVOT_ALPHA, UIConfig.CONTAINER_PIVOT_OUTLINE_COLOR, UIConfig.CONTAINER_PIVOT_OUTLINE_ALPHA);
	
	private var _layerNameIndex:Int = 0;
	
	public function new() 
	{
		this.timeLine = new ValEditorTimeLine(0);
		super();
	}
	
	override public function clear():Void
	{
		for (layer in this._layers)
		{
			layerUnregister(layer);
		}
		
		this.layerCollection.removeAll();
		this.activeObjectsCollection.removeAll();
		this.allObjectsCollection.removeAll();
		this.viewCenterX = 0;
		this.viewCenterY = 0;
		this.viewWidth = 0;
		this.viewHeight = 0;
		
		this._currentLayer = null;
		
		this.selectedLayers.resize(0);
		
		this._layerNameIndex = 0;
		
		super.clear();
	}
	
	override public function pool():Void 
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
		var rect:Rectangle = null;
		#if starling
		var rectStarling:Rectangle = null;
		var targetSpaceStarling:Dynamic = null;
		#end
		
		if (targetSpace == this #if starling || targetSpace == this._container #end)
		{
			targetSpace = this._container;
			#if starling
			targetSpaceStarling = this._containerStarling;
			#end
		}
		#if starling
		else if (targetSpace == this._rootContainer)
		{
			targetSpaceStarling = this._rootContainerStarling;
		}
		#end
		
		if (this._container != null)
		{
			rect = this._container.getBounds(targetSpace);
		}
		#if starling
		if (this._containerStarling != null)
		{
			rectStarling = this._containerStarling.getBounds(targetSpaceStarling);
		}
		
		if (rect != null && rectStarling != null)
		{
			return rect.union(rectStarling);
		}
		else if (rectStarling != null)
		{
			return rectStarling;
		}
		#end
		
		if (rect != null)
		{
			return rect;
		}
		
		return new Rectangle();
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
	
	public function canAddObject(object:ValEditorObject):Bool
	{
		return cast(this._currentLayer, ValEditorLayer).canAddObject();
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
	
	//override public function addObject(object:ValEditObject):Void 
	//{
		//super.addObject(object);
		//
		//ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED, cast object);
	//}
	
	//override public function removeObject(object:ValEditObject):Void 
	//{
		//super.removeObject(object);
		//
		//ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED, cast object);
	//}
	
	override public function addLayer(layer:ValEditLayer):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.add(cast layer);
		super.addLayer(layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_ADDED, layer);
		this.currentLayer = layer;
	}
	
	override public function addLayerAt(layer:ValEditLayer, index:Int):Void 
	{
		if (layer.name == null || layer.name == "")
		{
			layer.name = makeLayerName();
		}
		this.layerCollection.addAt(cast layer, index);
		super.addLayerAt(layer, index);
		
		// update layer indexes
		var count:Int = this._layers.length;
		for (i in index+1...count)
		{
			cast(this._layers[i], ValEditorLayer).indexUpdate(count - 1 - i);
		}
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_ADDED, layer);
		this.currentLayer = layer;
	}
	
	public function getLayerIndex(layer:ValEditLayer):Int
	{
		return this._layers.indexOf(layer);
	}
	
	public function getOtherLayers(layersToIgnore:Array<ValEditorLayer>, ?otherLayers:Array<ValEditorLayer>):Array<ValEditorLayer>
	{
		if (otherLayers == null) otherLayers = new Array<ValEditorLayer>();
		
		for (layer in this._layers)
		{
			if (layersToIgnore.indexOf(cast layer) == -1)
			{
				otherLayers.push(cast layer);
			}
		}
		
		return otherLayers;
	}
	
	public function layerIndexDown(layer:ValEditLayer):Void
	{
		var index:Int = this._layers.indexOf(layer);
		var count:Int = this._layers.length;
		
		this._layers.splice(index, 1);
		this._layers.insert(index + 1, layer);
		
		this.layerCollection.removeAt(index);
		this.layerCollection.addAt(cast layer, index + 1);
		
		cast(this._layers[index], ValEditorLayer).indexUpdate(count - 1 - index);
		cast(this._layers[index + 1], ValEditorLayer).indexUpdate(count - 1 - (index + 1));
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_INDEX_DOWN, layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
	}
	
	public function layerIndexUp(layer:ValEditLayer):Void
	{
		var index:Int = this._layers.indexOf(layer);
		var count:Int = this._layers.length;
		
		this._layers.splice(index, 1);
		this._layers.insert(index - 1, layer);
		
		this.layerCollection.removeAt(index);
		this.layerCollection.addAt(cast layer, index - 1);
		
		cast(this._layers[index], ValEditorLayer).indexUpdate(count - 1 - index);
		cast(this._layers[index - 1], ValEditorLayer).indexUpdate(count - 1 - (index - 1));
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_INDEX_UP, layer);
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_SELECTED, this._currentLayer);
	}
	
	override public function removeLayer(layer:ValEditLayer):Void
	{
		var index:Int = this.layerCollection.indexOf(cast layer);
		removeLayerAt(index);
	}
	
	override public function removeLayerAt(index:Int):Void
	{
		var layer:ValEditLayer = this._layers[index];
		this.layerCollection.removeAt(index);
		super.removeLayerAt(index);
		
		var count:Int = this._layers.length;
		for (i in index...count)
		{
			cast(this._layers[i], ValEditorLayer).indexUpdate(count - 1 - i);
		}
		
		ContainerEvent.dispatch(this, ContainerEvent.LAYER_REMOVED, layer);
		if (this._currentLayer == layer)
		{
			if (index != 0)
			{
				index --;
			}
			this.currentLayer = this.layerCollection.get(index);
		}
	}
	
	public function setLayerIndex(layer:ValEditLayer, index:Int):Void
	{
		var prevIndex:Int = this._layers.indexOf(layer);
		this._layers.splice(prevIndex, 1);
		this._layers.insert(index, layer);
		var layerCount:Int = this._layers.length - 1;
		cast(layer, ValEditorLayer).index = layerCount - index;
		
		if (index > prevIndex)
		{
			for (i in prevIndex...index)
			{
				cast(this._layers[i], ValEditorLayer).indexUpdate(layerCount - i);
			}
		}
		else
		{
			for (i in index + 1...prevIndex + 1)
			{
				cast(this._layers[i], ValEditorLayer).indexUpdate(layerCount - i);
			}
		}
	}
	
	override function layerRegister(layer:ValEditLayer, index:Int):Void 
	{
		cast(layer, ValEditorLayer).index = this._layers.length - 1 - index;
		cast(layer.timeLine, ValEditorTimeLine).autoIncreaseNumFrames = this.autoIncreaseNumFrames;
		layer.timeLine.numFrames = this.numFrames;
		layer.timeLine.frameIndex = this.frameIndex;
		
		super.layerRegister(layer, index);
		
		for (object in layer.allObjects)
		{
			objectRegister(object, layer);
		}
		
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
	
	override function layerUnregister(layer:ValEditLayer):Void 
	{
		super.layerUnregister(layer);
		
		for (object in layer.allObjects)
		{
			objectUnregister(object);
		}
		
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
	
	private function objectRegister(object:ValEditObject, layer:ValEditLayer):Void 
	{
		trace("ValEditorContainer.objectRegister");
		
		this._allObjects.set(object.objectID, object);
		this._objectToLayer.set(object, layer);
		this.allObjectsCollection.add(cast object);
		
		object.addEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.addEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.addEventListener(RenameEvent.RENAMED, object_renamed);
		
		object.container = this;
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED_TO_CONTAINER, object);
	}
	
	private function objectUnregister(object:ValEditObject):Void 
	{
		trace("ValEditorContainer.objectUnregister");
		
		this._allObjects.remove(object.objectID);
		this._objectToLayer.remove(object);
		this.allObjectsCollection.remove(cast object);
		
		object.removeEventListener(ObjectFunctionEvent.CALLED, object_functionCalled);
		object.removeEventListener(ObjectPropertyEvent.CHANGE, object_propertyChange);
		object.removeEventListener(RenameEvent.RENAMED, object_renamed);
		
		object.container = null;
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED_FROM_CONTAINER, object);
	}
	
	public function getContainerDependencies(data:ContainerSaveData):Void
	{
		for (object in this.allObjectsCollection)
		{
			if (object.template != null && object.clss.isContainer && !data.hasDependency(cast object.template))
			{
				data.addDependency(cast object.template);
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
	
	override function layer_objectActivated(evt:LayerEvent):Void 
	{
		super.layer_objectActivated(evt);
		
		var editorObject:ValEditorObject = cast evt.object;
		
		this.activeObjectsCollection.add(editorObject);
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ACTIVATED, editorObject);
	}
	
	override function layer_objectDeactivated(evt:LayerEvent):Void 
	{
		super.layer_objectDeactivated(evt);
		
		var editorObject:ValEditorObject = cast evt.object;
		
		this.activeObjectsCollection.remove(editorObject);
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_DEACTIVATED, editorObject);
	}
	
	private function layer_renamed(evt:RenameEvent):Void 
	{
		var layer:ValEditLayer = cast evt.target;
		this._layerMap.remove(evt.previousNameOrID);
		this._layerMap.set(layer.name, layer);
		
		this.layerCollection.updateAt(this.layerCollection.indexOf(cast evt.target));
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
			cast(layer, ValEditorLayer).getAllObjects(objects);
		}
		
		return objects;
	}
	
	public function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (visibleObjects == null) visibleObjects = new Array<ValEditorObject>();
		
		for (layer in this.layerCollection)
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
	
	public function cloneTo(container:ValEditorContainer):Void
	{
		container.alpha = this.alpha;
		container.autoPlay = this.autoPlay;
		container.visible = this.visible;
		container.x = this.x;
		container.y = this.y;
		container.viewCenterX = this.viewCenterX;
		container.viewCenterY = this.viewCenterY;
		
		cast(this.timeLine, ValEditorTimeLine).cloneTo(cast container.timeLine);
		
		var layerCount:Int = this.numLayers;
		var layer:ValEditorLayer;
		var cloneLayer:ValEditorLayer;
		for (i in 0...layerCount)
		{
			layer = cast this.getLayerAt(i);
			cloneLayer = ValEditorLayer.fromPool();
			layer.cloneTo(cloneLayer);
			container.addLayer(cloneLayer);
		}
		
		container.frameIndex = this.frameIndex;
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.autoPlay = json.autoPlay;
		this.visible = json.visible;
		this.x = json.x;
		this.y = json.y;
		this.viewCenterX = json.viewCenterX;
		this.viewCenterY = json.viewCenterY;
		
		cast(this.timeLine, ValEditorTimeLine).fromJSONSave(json.timeLine);
		
		var layer:ValEditorLayer;
		var layers:Array<Dynamic> = json.layers;
		for (node in layers)
		{
			layer = ValEditorLayer.fromPool(ValEditorTimeLine.fromPool(0));
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
		
		json.timeLine = cast(this.timeLine, ValEditorTimeLine).toJSONSave();
		
		var layers:Array<Dynamic> = [];
		for (layer in this._layers)
		{
			layers.push(cast(layer, ValEditorLayer).toJSONSave());
		}
		json.layers = layers;
		
		return json;
	}
	
}
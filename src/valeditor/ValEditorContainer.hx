package valeditor;

import feathers.data.ArrayCollection;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import valedit.ValEditContainer;
import valedit.ValEditLayer;
import valeditor.events.ContainerEvent;
import valeditor.events.LayerEvent;
import valeditor.events.RenameEvent;
import valeditor.ui.UIConfig;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class ValEditorContainer extends ValEditContainer implements IValEditorContainer
{
	static private var _POOL:Array<ValEditorContainer> = new Array<ValEditorContainer>();
	
	static public function fromPool():ValEditorContainer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorContainer();
	}
	
	public var containerUI(default, null):DisplayObjectContainer = new Sprite();
	public var hasInvisibleLayer(get, never):Bool;
	public var hasLockedLayer(get, never):Bool;
	public var isOpen(get, never):Bool;
	public var layerCollection(default, null):ArrayCollection<ValEditorLayer> = new ArrayCollection<ValEditorLayer>();
	public var objectCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	public var selectedLayers(default, null):Array<ValEditorLayer> = new Array<ValEditorLayer>();
	public var viewCenterX(get, set):Float;
	public var viewCenterY(get, set):Float;
	public var viewHeight(get, set):Float;
	public var viewWidth(get, set):Float;
	
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
		this.cameraX = value - this._viewWidth / 2;
		return this._viewCenterX = value;
	}
	
	private var _viewCenterY:Float = 0;
	private function get_viewCenterY():Float { return this._viewCenterY; }//this.cameraY + this._viewHeight / 2; }
	private function set_viewCenterY(value:Float):Float
	{
		this.cameraY = value - this._viewHeight / 2;
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
		this.containerUI.addChild(this._pivotIndicator);
	}
	
	override public function clear():Void
	{
		for (layer in this._layers)
		{
			layerUnregister(layer);
		}
		
		this.layerCollection.removeAll();
		this.objectCollection.removeAll();
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
	
	public function canAddObject():Bool
	{
		return cast(this._currentLayer, ValEditorLayer).canAddObject();
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
			cast(this._layers[i], ValEditorLayer).indexUpdate(count - 1 - i);// this._layers[i].index++);
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
	
	override public function removeLayer(layer:ValEditLayer):Void 
	{
		var index:Int = this.layerCollection.indexOf(cast layer);
		this.layerCollection.remove(cast layer);
		super.removeLayer(layer);
		
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
				cast(this._layers[i], ValEditorLayer).indexUpdate(layerCount - i);// this._layers[i].index--);
			}
		}
		else
		{
			for (i in index + 1...prevIndex + 1)
			{
				cast(this._layers[i], ValEditorLayer).indexUpdate(layerCount - i);// this._layers[i].index++);
			}
		}
	}
	
	override function layerRegister(layer:ValEditLayer, index:Int):Void 
	{
		cast(layer, ValEditorLayer).index = this._layers.length - 1 - index;
		
		super.layerRegister(layer, index);
		
		layer.addEventListener(LayerEvent.OBJECT_ADDED, layer_objectAdded);
		layer.addEventListener(LayerEvent.OBJECT_REMOVED, layer_objectRemoved);
		layer.addEventListener(RenameEvent.RENAMED, layer_renamed);
	}
	
	override function layerUnregister(layer:ValEditLayer):Void 
	{
		super.layerUnregister(layer);
		
		layer.removeEventListener(LayerEvent.OBJECT_ADDED, layer_objectAdded);
		layer.removeEventListener(LayerEvent.OBJECT_REMOVED, layer_objectRemoved);
		layer.removeEventListener(RenameEvent.RENAMED, layer_renamed);
	}
	
	private function layer_objectAdded(evt:LayerEvent):Void 
	{
		this._objects.set(evt.object.id, evt.object);
		this._objectToLayer.set(evt.object, evt.layer);
		
		var editorObject:ValEditorObject = cast evt.object;
		
		editorObject.container = this;
		
		this.objectCollection.add(editorObject);
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_ADDED, editorObject);
	}
	
	private function layer_objectRemoved(evt:LayerEvent):Void 
	{
		this._objects.remove(evt.object.id);
		this._objectToLayer.remove(evt.object);
		
		var editorObject:ValEditorObject = cast evt.object;
		
		editorObject.container = null;
		
		this.objectCollection.remove(editorObject);
		
		ContainerEvent.dispatch(this, ContainerEvent.OBJECT_REMOVED, editorObject);
	}
	
	private function layer_renamed(evt:RenameEvent):Void 
	{
		var layer:ValEditLayer = cast evt.target;
		this._layerMap.remove(evt.previousNameOrID);
		this._layerMap.set(layer.name, layer);
		
		this.layerCollection.updateAt(this.layerCollection.indexOf(cast evt.target));
	}
	
	public function open():Void
	{
		if (this._isOpen) return;
		
		this._isOpen = true;
		ContainerEvent.dispatch(this, ContainerEvent.OPEN);
	}
	
	public function close():Void
	{
		if (!this._isOpen) return;
		
		this._isOpen = false;
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
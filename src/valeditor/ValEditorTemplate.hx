package valeditor;

import valedit.ExposedCollection;
import valedit.ValEditClass;
import valedit.ValEditLayer;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
import valedit.utils.ReverseIterator;
import valedit.value.base.ExposedValue;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.events.ContainerEvent;
import valeditor.events.KeyFrameEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
import valeditor.events.TemplateEvent;
import valeditor.events.TimeLineActionEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorTemplate extends ValEditTemplate implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	static public function fromPool(clss:ValEditClass, ?id:String, ?collection:ExposedCollection,
									?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(clss, id, collection, constructorCollection);
		return new ValEditorTemplate(clss, id, collection, constructorCollection);
	}
	
	public var isInClipboard:Bool = false;
	public var isInLibrary:Bool = false;
	public var isSuspended:Bool = false;
	public var lockInstanceUpdates:Bool = false;
	public var visibilityCollectionCurrent(default, null):TemplateVisibilityCollection;
	public var visibilityCollectionDefault(get, set):TemplateVisibilityCollection;
	public var visibilityCollectionFile(get, set):TemplateVisibilityCollection;
	
	override function set_id(value:String):String 
	{
		if (this._id == value) return value;
		var oldID:String = this._id;
		super.set_id(value);
		
		if (oldID != null)
		{
			this.object.id = this._id;
			
			this._instanceMap.clear();
			var objID:String = oldID + "-";
			for (instance in this._instances)
			{
				if (instance.id.indexOf(objID) == 0)
				{
					instance.id = this._id + "-" + instance.id.substr(objID.length);
				}
				this._instanceMap.set(instance.id, instance);
			}
		}
		
		RenameEvent.dispatch(this, RenameEvent.RENAMED, oldID);
		return this._id;
	}
	
	override function get_numInstances():Int { return this._instances.length - this._suspendedInstances.length; }
	
	override function set_object(value:ValEditObject):ValEditObject 
	{
		if (this._object == value) return value;
		
		if (this._object != null)
		{
			this._object.removeEventListener(ObjectPropertyEvent.CHANGE, onTemplateObjectPropertyChange);
			this._object.removeEventListener(ObjectFunctionEvent.CALLED, onTemplateObjectFunctionCalled);
			if (Std.isOfType(this._object.object, IValEditorContainer))
			{
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_ADDED, onTemplateContainerLayerAdded);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_INDEX_DOWN, onTemplateContainerLayerIndexDown);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_INDEX_UP, onTemplateContainerLayerIndexUp);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_REMOVED, onTemplateContainerLayerRemoved);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_RENAMED, onTemplateContainerLayerRenamed);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_SELECTED, onTemplateContainerLayerSelected);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.LAYER_VISIBILITY_CHANGE, onTemplateContainerLayerVisibilityChange);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.OBJECT_ADDED, onTemplateContainerObjectAdded);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.OBJECT_REMOVED, onTemplateContainerObjectRemoved);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.OBJECT_FUNCTION_CALLED, onTemplateContainerObjectFunctionCalled);
				cast(this._object.object, IValEditorContainer).removeEventListener(ContainerEvent.OBJECT_PROPERTY_CHANGE, onTemplateContainerObjectPropertyChange);
				
				cast(this._object.object, IValEditorContainer).removeEventListener(TimeLineActionEvent.INSERT_FRAME, onTemplateContainerInsertFrame);
				cast(this._object.object, IValEditorContainer).removeEventListener(TimeLineActionEvent.INSERT_KEYFRAME, onTemplateContainerInsertKeyFrame);
				cast(this._object.object, IValEditorContainer).removeEventListener(TimeLineActionEvent.REMOVE_FRAME, onTemplateContainerRemoveFrame);
				cast(this._object.object, IValEditorContainer).removeEventListener(TimeLineActionEvent.REMOVE_KEYFRAME, onTemplateContainerRemoveKeyFrame);
				cast(this._object.object, IValEditorContainer).removeEventListener(KeyFrameEvent.TRANSITION_CHANGE, onTemplateContainerKeyFrameTransitionChange);
				cast(this._object.object, IValEditorContainer).removeEventListener(KeyFrameEvent.TWEEN_CHANGE, onTemplateContainerKeyFrameTweenChange);
			}
		}
		
		if (value != null)
		{
			value.addEventListener(ObjectPropertyEvent.CHANGE, onTemplateObjectPropertyChange);
			value.addEventListener(ObjectFunctionEvent.CALLED, onTemplateObjectFunctionCalled);
			if (Std.isOfType(value.object, IValEditorContainer))
			{
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_ADDED, onTemplateContainerLayerAdded);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_INDEX_DOWN, onTemplateContainerLayerIndexDown);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_INDEX_UP, onTemplateContainerLayerIndexUp);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_REMOVED, onTemplateContainerLayerRemoved);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_RENAMED, onTemplateContainerLayerRenamed);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_SELECTED, onTemplateContainerLayerSelected);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.LAYER_VISIBILITY_CHANGE, onTemplateContainerLayerVisibilityChange);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.OBJECT_ADDED, onTemplateContainerObjectAdded);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.OBJECT_REMOVED, onTemplateContainerObjectRemoved);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.OBJECT_FUNCTION_CALLED, onTemplateContainerObjectFunctionCalled);
				cast(value.object, IValEditorContainer).addEventListener(ContainerEvent.OBJECT_PROPERTY_CHANGE, onTemplateContainerObjectPropertyChange);
				
				cast(value.object, IValEditorContainer).addEventListener(TimeLineActionEvent.INSERT_FRAME, onTemplateContainerInsertFrame);
				cast(value.object, IValEditorContainer).addEventListener(TimeLineActionEvent.INSERT_KEYFRAME, onTemplateContainerInsertKeyFrame);
				cast(value.object, IValEditorContainer).addEventListener(TimeLineActionEvent.REMOVE_FRAME, onTemplateContainerRemoveFrame);
				cast(value.object, IValEditorContainer).addEventListener(TimeLineActionEvent.REMOVE_KEYFRAME, onTemplateContainerRemoveKeyFrame);
				cast(value.object, IValEditorContainer).addEventListener(KeyFrameEvent.TRANSITION_CHANGE, onTemplateContainerKeyFrameTransitionChange);
				cast(value.object, IValEditorContainer).addEventListener(KeyFrameEvent.TWEEN_CHANGE, onTemplateContainerKeyFrameTweenChange);
			}
		}
		
		return super.set_object(value);
	}
	
	private var _visibilityCollectionDefault:TemplateVisibilityCollection;
	private function get_visibilityCollectionDefault():TemplateVisibilityCollection { return this._visibilityCollectionDefault; }
	private function set_visibilityCollectionDefault(value:TemplateVisibilityCollection):TemplateVisibilityCollection
	{
		this._visibilityCollectionDefault = value;
		updateVisibilityCollection();
		return this._visibilityCollectionDefault;
	}
	
	private var _visibilityCollectionFile:TemplateVisibilityCollection;
	private function get_visibilityCollectionFile():TemplateVisibilityCollection { return this._visibilityCollectionFile; }
	private function set_visibilityCollectionFile(value:TemplateVisibilityCollection):TemplateVisibilityCollection
	{
		this._visibilityCollectionFile = value;
		updateVisibilityCollection();
		return this._visibilityCollectionFile;
	}
	
	private var _objectIDIndex:Int = -1;
	private var _suspendedInstances:Array<ValEditorObject> = new Array<ValEditorObject>();

	public function new(clss:ValEditClass, ?id:String, ?collection:ExposedCollection, ?constructorCollection:ExposedCollection) 
	{
		super(clss, id, collection, constructorCollection);
	}
	
	override public function clear():Void 
	{
		this.isInClipboard = false;
		this.isInLibrary = false;
		this.isSuspended = false;
		this.lockInstanceUpdates = false;
		this._objectIDIndex = -1;
		
		if (this.object != null)
		{
			ValEditor.destroyObject(cast this.object);
			this.object = null;
		}
		
		for (i in new ReverseIterator(this._instances.length - 1, 0))
		{
			ValEditor.destroyObject(cast this._instances[i]);
		}
		
		this._suspendedInstances.resize(0);
		
		this.visibilityCollectionCurrent = null;
		
		if (this._visibilityCollectionDefault != null)
		{
			this._visibilityCollectionDefault = null;
		}
		
		if (this._visibilityCollectionFile != null)
		{
			this._visibilityCollectionFile.pool();
			this._visibilityCollectionFile = null;
		}
		
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function updateVisibilityCollection():Void
	{
		var newVisibility:TemplateVisibilityCollection;
		if (this._visibilityCollectionFile != null)
		{
			newVisibility = this._visibilityCollectionFile;
		}
		else
		{
			newVisibility = this._visibilityCollectionDefault;
		}
		
		this.visibilityCollectionCurrent = newVisibility;
		// register for change update to avoid applying visibility multiple times
		//ValEditor.registerForChangeUpdate(this);
		applyVisibility();
	}
	
	public function changeUpdate():Void
	{
		applyVisibility();
	}
	
	public function applyVisibility():Void
	{
		this.visibilityCollectionCurrent.applyToTemplateCollection(cast(this.object, ValEditorObject).defaultCollection);
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).applyTemplateVisibility(this.visibilityCollectionCurrent);
		}
	}
	
	override public function canBeDestroyed():Bool 
	{
		return super.canBeDestroyed() && !this.isInLibrary && !this.isInClipboard && !this.isSuspended;
	}
	
	override public function addInstance(instance:ValEditObject):Void 
	{
		super.addInstance(instance);
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_ADDED, this);
	}
	
	override public function removeInstance(instance:ValEditObject):Void 
	{
		super.removeInstance(instance);
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_REMOVED, this);
	}
	
	public function registerInstances():Void
	{
		for (instance in this._instances)
		{
			ValEditor.registerObject(cast instance);
			cast(instance, ValEditorObject).restoreKeyFrames();
		}
	}
	
	public function unregisterInstances():Void
	{
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).backupKeyFrames();
			ValEditor.unregisterObject(cast instance);
		}
	}
	
	public function suspendInstance(instance:ValEditorObject):Void
	{
		this._suspendedInstances.push(instance);
		instance.isSuspended = true;
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_SUSPENDED, this);
	}
	
	public function unsuspendInstance(instance:ValEditorObject):Void
	{
		this._suspendedInstances.remove(instance);
		instance.isSuspended = false;
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_UNSUSPENDED, this);
	}
	
	public function makeObjectID():String
	{
		var objID:String = null;
		while (true)
		{
			this._objectIDIndex++;
			objID = this.id + "-" + this._objectIDIndex;
			if (!this._instanceMap.exists(objID)) break;
		}
		return objID;
	}
	
	public function objectIDExists(id:String):Bool
	{
		return this._instanceMap.exists(id);
	}
	
	private function onTemplateContainerKeyFrameTransitionChange(evt:KeyFrameEvent):Void
	{
		//trace("onTemplateContainerKeyFrameTransitionChange");
		
		var currentFrame:ValEditorKeyFrame = cast cast(this.object.object, IValEditorTimeLineContainer).currentLayer.timeLine.frameCurrent;
		var instanceContainer:IValEditorTimeLineContainer;
		var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
		var prevFrameIndex:Int;
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.frameCurrent.transition = currentFrame.transition;
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	private function onTemplateContainerKeyFrameTweenChange(evt:KeyFrameEvent):Void
	{
		//trace("onTemplateContainerKeyFrameTweenChange");
		
		var currentFrame:ValEditorKeyFrame = cast cast(this.object.object, IValEditorTimeLineContainer).currentLayer.timeLine.frameCurrent;
		var instanceContainer:IValEditorTimeLineContainer;
		var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
		var prevFrameIndex:Int;
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.frameCurrent.tween = currentFrame.tween;
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	private function onTemplateContainerLayerAdded(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerAdded");
		
		var layer:ValEditorLayer = evt.object;
		var index:Int = cast(this.object.object, IValEditorTimeLineContainer).getLayerIndex(layer);
		var objectLayer:ValEditorLayer;
		for (instance in this._instances)
		{
			objectLayer = ValEditorLayer.fromPool();
			layer.cloneTo(objectLayer);
			cast(instance.object, IValEditorTimeLineContainer).addLayerAt(objectLayer, index);
		}
	}
	
	private function onTemplateContainerLayerIndexDown(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerIndexDown");
		
		var layer:ValEditorLayer = evt.object;
		var objectLayer:ValEditLayer;
		for (instance in this._instances)
		{
			objectLayer = cast(instance.object, IValEditorTimeLineContainer).getLayer(layer.name);
			cast(instance.object, IValEditorTimeLineContainer).layerIndexDown(objectLayer);
		}
	}
	
	private function onTemplateContainerLayerIndexUp(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerIndexUp");
		
		var layer:ValEditorLayer = evt.object;
		var objectLayer:ValEditLayer;
		for (instance in this._instances)
		{
			objectLayer = cast(instance.object, IValEditorTimeLineContainer).getLayer(layer.name);
			cast(instance.object, IValEditorTimeLineContainer).layerIndexUp(objectLayer);
		}
	}
	
	private function onTemplateContainerLayerRemoved(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerRemoved");
		
		var layer:ValEditorLayer = evt.object;
		var objectLayer:ValEditLayer;
		for (instance in this._instances)
		{
			objectLayer = cast(instance.object, IValEditorTimeLineContainer).getLayer(layer.name);
			cast(instance.object, IValEditorTimeLineContainer).removeLayer(objectLayer);
			objectLayer.pool();
		}
	}
	
	private function onTemplateContainerLayerRenamed(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerRenamed");
		
		var layer:ValEditorLayer = evt.object;
		var index:Int = cast(this.object.object, IValEditorTimeLineContainer).getLayerIndex(layer);
		var objectLayer:ValEditLayer;
		for (instance in this._instances)
		{
			objectLayer = cast(instance.object, IValEditorTimeLineContainer).getLayerAt(index);
			objectLayer.name = layer.name;
		}
	}
	
	private function onTemplateContainerLayerSelected(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerSelected");
		
		var layer:ValEditorLayer = evt.object;
		var index:Int = cast(this.object.object, IValEditorTimeLineContainer).getLayerIndex(layer);
		var objectLayer:ValEditLayer;
		for (instance in this._instances)
		{
			objectLayer = cast(instance.object, IValEditorTimeLineContainer).getLayerAt(index);
			cast(instance.object, IValEditorTimeLineContainer).currentLayer = objectLayer;
		}
	}
	
	private function onTemplateContainerLayerVisibilityChange(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerVisibilityChange");
		
		var layer:ValEditorLayer = evt.object;
		var index:Int = cast(this.object.object, IValEditorTimeLineContainer).getLayerIndex(layer);
		var objectLayer:ValEditLayer;
		for (instance in this._instances)
		{
			objectLayer = cast(instance.object, IValEditorTimeLineContainer).getLayerAt(index);
			objectLayer.visible = layer.visible;
		}
	}
	
	private function onTemplateContainerObjectAdded(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectAdded");
		
		var object:ValEditorObject = evt.object;
		var instanceObject:ValEditorObject;
		
		if (Std.isOfType(this.object.object, IValEditorTimeLineContainer))
		{
			var instanceContainer:IValEditorTimeLineContainer;
			var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
			var prevFrameIndex:Int;
			
			for (instance in this._instances)
			{
				instanceContainer = cast instance.object;
				prevFrameIndex = instanceContainer.frameIndex;
				instanceContainer.frameIndex = frameIndex;
				if (instanceContainer.hasActiveObject(object.objectID)) continue;
				instanceObject = cast instanceContainer.getObject(object.objectID);
				if (instanceObject == null)
				{
					instanceObject = ValEditor.cloneObject(object);
				}
				instanceContainer.addObject(instanceObject);
				instanceContainer.frameIndex = prevFrameIndex;
			}
		}
		else
		{
			for (instance in this._instances)
			{
				instanceObject = ValEditor.cloneObject(object);
				cast(instance.object, IValEditorContainer).addObject(instanceObject);
			}
		}
	}
	
	private function onTemplateContainerObjectRemoved(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectRemoved");
		
		var object:ValEditorObject = evt.object;
		var instanceObject:ValEditObject;
		
		if (Std.isOfType(this.object.object, IValEditorTimeLineContainer))
		{
			var timeLineContainer:IValEditorTimeLineContainer;
			var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
			var prevFrameIndex:Int;
			
			for (instance in this._instances)
			{
				timeLineContainer = cast instance.object;
				prevFrameIndex = timeLineContainer.frameIndex;
				timeLineContainer.frameIndex = frameIndex;
				if (!timeLineContainer.hasActiveObject(object.objectID)) continue;
				instanceObject = timeLineContainer.getActiveObject(object.objectID);
				timeLineContainer.removeObject(instanceObject);
				if (instanceObject.canBeDestroyed())
				{
					ValEditor.destroyObject(cast instanceObject);
				}
				timeLineContainer.frameIndex = prevFrameIndex;
			}
		}
		else
		{
			var instanceContainer:IValEditorContainer;
			
			for (instance in this._instances)
			{
				instanceContainer = cast instance.object;
				if (!instanceContainer.hasActiveObject(object.objectID)) continue;
				instanceObject = instanceContainer.getActiveObject(object.objectID);
				instanceContainer.removeObject(instanceObject);
				if (instanceObject.canBeDestroyed())
				{
					ValEditor.destroyObject(cast instanceObject);
				}
			}
		}
	}
	
	private function onTemplateContainerObjectFunctionCalled(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectFunctionCalled");
		
		var functionEvent:ObjectFunctionEvent = cast evt.subEvent;
		var object:ValEditorObject = functionEvent.object;
		var instanceContainer:IValEditorContainer;
		var instanceObject:ValEditorObject;
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			instanceObject = cast instanceContainer.getActiveObject(object.objectID);
			instanceObject.templateFunctionCall(functionEvent.functionName, functionEvent.parameters);
		}
	}
	
	private function onTemplateContainerObjectPropertyChange(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectPropertyChange");
		
		var propertyEvent:ObjectPropertyEvent = cast evt.subEvent;
		var object:ValEditorObject = propertyEvent.object;
		var templateValue:ExposedValue = object.currentCollection.getValueDeep(propertyEvent.propertyNames);
		var instanceContainer:IValEditorContainer;
		var instanceObject:ValEditorObject;
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			instanceObject = cast instanceContainer.getActiveObject(object.objectID);
			instanceObject.templateChildPropertyChange(templateValue, propertyEvent.propertyNames);
		}
	}
	
	private function onTemplateContainerSelectedFrameIndexChange(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerSelectedFrameIndexChange");
		
		var index:Int = cast(cast(cast(this.object.object, IValEditorTimeLineContainer).currentLayer, ValEditorLayer).timeLine, ValEditorTimeLine).selectedFrameIndex;
		for (instance in this._instances)
		{
			cast(cast(cast(instance.object, IValEditorTimeLineContainer).currentLayer, ValEditorLayer).timeLine, ValEditorTimeLine).selectedFrameIndex = index;
		}
	}
	
	private function onTemplateContainerInsertFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerInsertFrame");
		
		var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:IValEditorTimeLineContainer;
		
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			cast(instanceContainer.currentLayer.timeLine, ValEditorTimeLine).insertFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	private function onTemplateContainerInsertKeyFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerInsertKeyFrame");
		
		var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:IValEditorTimeLineContainer;
		
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			cast(instanceContainer.currentLayer.timeLine, ValEditorTimeLine).insertKeyFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	private function onTemplateContainerRemoveFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerRemoveFrame");
		
		var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:IValEditorTimeLineContainer;
		
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			cast(instanceContainer.currentLayer.timeLine, ValEditorTimeLine).removeFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	private function onTemplateContainerRemoveKeyFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerRemoveKeyFrame");
		
		var frameIndex:Int = cast(this.object.object, IValEditorTimeLineContainer).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:IValEditorTimeLineContainer;
		
		for (instance in this._instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			cast(instanceContainer.currentLayer.timeLine, ValEditorTimeLine).removeKeyFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	@:access(valedit.value.base.ExposedValue)
	private function onTemplateObjectPropertyChange(evt:ObjectPropertyEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		var templateValue:ExposedValue = evt.object.currentCollection.getValueDeep(evt.propertyNames);
		if (!templateValue.visible) return;
		
		// check for corresponding constructor value
		if (this.constructorCollection != null)
		{
			var value:ExposedValue = this.constructorCollection.getValueDeep(evt.propertyNames);
			if (value != null)
			{
				templateValue.cloneValue(value);
			}
		}
		
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).templatePropertyChange(templateValue, evt.propertyNames);
		}
	}
	
	private function onTemplateObjectFunctionCalled(evt:ObjectFunctionEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		for (instance in this._instances)
		{
			cast(instance, ValEditorObject).templateFunctionCall(evt.functionName, evt.parameters);
		}
	}
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.id = json.id;
		this.collection.fromJSONSave(json.collection);
		this.collection.apply();
		if (this.constructorCollection != null && json.constructorCollection != null)
		{
			this.constructorCollection.fromJSONSave(json.constructorCollection);
		}
		if (json.visibilityCollection != null)
		{
			if (this._visibilityCollectionFile == null)
			{
				this._visibilityCollectionFile = TemplateVisibilityCollection.fromPool();
			}
			this._visibilityCollectionFile.fromJSON(json.visibilityCollection);
			updateVisibilityCollection();
		}
		
		if (this.clss.isContainer)
		{
			cast(this.object.object, IValEditorContainer).fromJSONSave(json.containerData);
		}
		
		var instance:ValEditorObject;
		var instances:Array<Dynamic> = json.instances;
		for (node in instances)
		{
			instance = ValEditor.createObjectWithTemplate(this, node.id);
		}
	}
	
	public function toJSONContainerSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		json.clss = this.clss.className;
		return toJSONSave(json);
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		json.id = this.id;
		json.collection = this.collection.toJSONSave();
		if (this.constructorCollection != null)
		{
			json.constructorCollection = this.constructorCollection.toJSONSave();
		}
		
		if (this._visibilityCollectionFile != null)
		{
			json.visibilityCollection = this._visibilityCollectionFile.toJSON();
		}
		
		if (this.clss.isContainer)
		{
			json.containerData = cast(this.object.object, IValEditorContainer).toJSONSave();
		}
		
		var instances:Array<Dynamic> = [];
		for (instance in this._instances)
		{
			instances.push(cast(instance, ValEditorObject).toJSONSave());
		}
		json.instances = instances;
		
		return json;
	}
	
}
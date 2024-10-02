package valeditor;

import openfl.errors.Error;
import openfl.events.EventDispatcher;
import valedit.ExposedCollection;
import valedit.utils.ReverseIterator;
import valedit.value.base.ExposedValue;
import valeditor.container.IContainerEditable;
import valeditor.container.ITimeLineContainerEditable;
import valeditor.container.ITimeLineLayerEditable;
import valeditor.editor.action.ValEditorAction;
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
class ValEditorTemplate extends EventDispatcher implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	static public function fromPool(clss:ValEditorClass, id:String, collection:ExposedCollection,
									?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(clss, id, collection, constructorCollection);
		return new ValEditorTemplate(clss, id, collection, constructorCollection);
	}
	
	/** Reference to the ValEditorClass from which the template was created. */
	public var clss:ValEditorClass;
	/** The default and current collection of the template's object. It is applied to instances created from the template and later changes are applied to instances as well. */
	public var collection(default, null):ExposedCollection;
	/** The constructor collection that the template's object was created with, if any. Template's instances are created using those values for constructor parameters. */
	public var constructorCollection(default, null):ExposedCollection;
	/** Unique identifier, set by user or generated. */
	public var id(get, set):String;
	/** Contains all ValEditorObject instances for the template. */
	public var instances(default, null):Array<ValEditorObject> = new Array<ValEditorObject>();
	/** Tells whether the template is in clipboard or not. */
	public var isInClipboard:Bool = false;
	/** Tells whether the template is in library or not. This is set by 'ValEditor.registerTemplateInternal' and 'ValEditor.unregisterTemplateInternal' functions. */
	public var isInLibrary:Bool = false;
	/** If true, prevents property changes and function calls propagation to instances. This is used by LibraryDragManager and Asset's update function. */
	public var lockInstanceUpdates:Bool = false;
	/** Tells how many instances this template has. Suspended instances are substracted from the total. */
	public var numInstances(get, never):Int;
	/** The template's object. */
	public var object(get, set):ValEditorObject;
	/** The current visibility collection. */
	public var visibilityCollectionCurrent(default, null):TemplateVisibilityCollection;
	/** The default visibility collection. */
	public var visibilityCollectionDefault(get, set):TemplateVisibilityCollection;
	/** The visibility collection from the current opened file (if any) */
	public var visibilityCollectionFile(get, set):TemplateVisibilityCollection;
	
	private var _id:String;
	private function get_id():String { return this._id; }
	private function set_id(value:String):String 
	{
		if (this._id == value) return value;
		var oldID:String = this._id;
		this._id = value;
		
		if (oldID != null)
		{
			this.object.id = this._id;
			
			this._instanceMap.clear();
			var objID:String = oldID + "-";
			for (instance in this.instances)
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
	
	private function get_numInstances():Int { return this.instances.length - this._suspendedInstances.length; }
	
	private var _object:ValEditorObject;
	private function get_object():ValEditorObject { return this._object; }
	private function set_object(value:ValEditorObject):ValEditorObject 
	{
		if (this._object == value) return value;
		
		if (this._object != null)
		{
			this._object.removeEventListener(ObjectPropertyEvent.CHANGE, onTemplateObjectPropertyChange);
			this._object.removeEventListener(ObjectFunctionEvent.CALLED, onTemplateObjectFunctionCalled);
			if (this._object.isContainer)
			{
				var container:IContainerEditable = cast this._object.object;
				container.removeEventListener(ContainerEvent.LAYER_ADDED, onTemplateContainerLayerAdded);
				container.removeEventListener(ContainerEvent.LAYER_INDEX_DOWN, onTemplateContainerLayerIndexDown);
				container.removeEventListener(ContainerEvent.LAYER_INDEX_UP, onTemplateContainerLayerIndexUp);
				container.removeEventListener(ContainerEvent.LAYER_REMOVED, onTemplateContainerLayerRemoved);
				container.removeEventListener(ContainerEvent.LAYER_RENAMED, onTemplateContainerLayerRenamed);
				container.removeEventListener(ContainerEvent.LAYER_SELECTED, onTemplateContainerLayerSelected);
				container.removeEventListener(ContainerEvent.LAYER_VISIBILITY_CHANGE, onTemplateContainerLayerVisibilityChange);
				container.removeEventListener(ContainerEvent.OBJECT_ADDED, onTemplateContainerObjectAdded);
				container.removeEventListener(ContainerEvent.OBJECT_REMOVED, onTemplateContainerObjectRemoved);
				container.removeEventListener(ContainerEvent.OBJECT_FUNCTION_CALLED, onTemplateContainerObjectFunctionCalled);
				container.removeEventListener(ContainerEvent.OBJECT_PROPERTY_CHANGE, onTemplateContainerObjectPropertyChange);
				
				container.removeEventListener(TimeLineActionEvent.INSERT_FRAME, onTemplateContainerInsertFrame);
				container.removeEventListener(TimeLineActionEvent.INSERT_KEYFRAME, onTemplateContainerInsertKeyFrame);
				container.removeEventListener(TimeLineActionEvent.REMOVE_FRAME, onTemplateContainerRemoveFrame);
				container.removeEventListener(TimeLineActionEvent.REMOVE_KEYFRAME, onTemplateContainerRemoveKeyFrame);
				container.removeEventListener(KeyFrameEvent.TRANSITION_CHANGE, onTemplateContainerKeyFrameTransitionChange);
				container.removeEventListener(KeyFrameEvent.TWEEN_CHANGE, onTemplateContainerKeyFrameTweenChange);
			}
		}
		
		if (value != null)
		{
			value.addEventListener(ObjectPropertyEvent.CHANGE, onTemplateObjectPropertyChange);
			value.addEventListener(ObjectFunctionEvent.CALLED, onTemplateObjectFunctionCalled);
			if (value.isContainer)
			{
				var container:IContainerEditable = cast value.object;
				container.addEventListener(ContainerEvent.LAYER_ADDED, onTemplateContainerLayerAdded);
				container.addEventListener(ContainerEvent.LAYER_INDEX_DOWN, onTemplateContainerLayerIndexDown);
				container.addEventListener(ContainerEvent.LAYER_INDEX_UP, onTemplateContainerLayerIndexUp);
				container.addEventListener(ContainerEvent.LAYER_REMOVED, onTemplateContainerLayerRemoved);
				container.addEventListener(ContainerEvent.LAYER_RENAMED, onTemplateContainerLayerRenamed);
				container.addEventListener(ContainerEvent.LAYER_SELECTED, onTemplateContainerLayerSelected);
				container.addEventListener(ContainerEvent.LAYER_VISIBILITY_CHANGE, onTemplateContainerLayerVisibilityChange);
				container.addEventListener(ContainerEvent.OBJECT_ADDED, onTemplateContainerObjectAdded);
				container.addEventListener(ContainerEvent.OBJECT_REMOVED, onTemplateContainerObjectRemoved);
				container.addEventListener(ContainerEvent.OBJECT_FUNCTION_CALLED, onTemplateContainerObjectFunctionCalled);
				container.addEventListener(ContainerEvent.OBJECT_PROPERTY_CHANGE, onTemplateContainerObjectPropertyChange);
				
				container.addEventListener(TimeLineActionEvent.INSERT_FRAME, onTemplateContainerInsertFrame);
				container.addEventListener(TimeLineActionEvent.INSERT_KEYFRAME, onTemplateContainerInsertKeyFrame);
				container.addEventListener(TimeLineActionEvent.REMOVE_FRAME, onTemplateContainerRemoveFrame);
				container.addEventListener(TimeLineActionEvent.REMOVE_KEYFRAME, onTemplateContainerRemoveKeyFrame);
				container.addEventListener(KeyFrameEvent.TRANSITION_CHANGE, onTemplateContainerKeyFrameTransitionChange);
				container.addEventListener(KeyFrameEvent.TWEEN_CHANGE, onTemplateContainerKeyFrameTweenChange);
			}
		}
		
		return this._object = value;
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
	
	private var _instanceMap:Map<String, ValEditorObject> = new Map<String, ValEditorObject>();
	private var _objectIDIndex:Int = -1;
	private var _registeredActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	private var _suspendedInstances:Array<ValEditorObject> = new Array<ValEditorObject>();

	public function new(clss:ValEditorClass, ?id:String, ?collection:ExposedCollection, ?constructorCollection:ExposedCollection) 
	{
		super();
		setTo(clss, id, collection, constructorCollection);
	}
	
	/**
	   Resets the template entirely, destroying objects and pooling visibilities if needed.
	**/
	public function clear():Void 
	{
		this.clss = null;
		this.collection = null;
		this.constructorCollection = null;
		this._id = null;
		this.isInClipboard = false;
		this.isInLibrary = false;
		this.lockInstanceUpdates = false;
		this._objectIDIndex = -1;
		
		if (this.object != null)
		{
			ValEditor.destroyObject(this.object);
			this.object = null;
		}
		
		for (i in new ReverseIterator(this.instances.length - 1, 0))
		{
			ValEditor.destroyObject(this.instances[i]);
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
		
		// DEBUG
		if (this.numInstances != 0)
		{
			throw new Error("ValEditorTemplate ::: non-zero numInstances after clear");
		}
		//\DEBUG
	}
	
	/**
	   Clears template and sends it to pool.
	**/
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	/**
	   Template related actions will call this so that the template doesn't get destroyed as long as it has registered actions.
	   @param	action
	**/
	public function registerAction(action:ValEditorAction):Void
	{
		this._registeredActions[this._registeredActions.length] = action;
	}
	
	/**
	   Template related action will call this when they are removed from stack, so that the template can be destroyed once it no longer has registered actions.
	   @param	action
	**/
	public function unregisterAction(action:ValEditorAction):Void
	{
		this._registeredActions.remove(action);
	}
	
	/**
	   Returns true if the template can be destroyed, false otherwise.
	   @return
	**/
	public function canBeDestroyed():Bool 
	{
		return this.numInstances == 0 && !this.isInLibrary && !this.isInClipboard && this._registeredActions.length == 0;
	}
	
	/**
	   Equivalent to the constructor when calling 'fromPool'.
	   @param	clss
	   @param	id
	   @param	collection
	   @param	constructorCollection
	   @return
	**/
	private function setTo(clss:ValEditorClass, id:String, collection:ExposedCollection,
						   constructorCollection:ExposedCollection):ValEditorTemplate
	{
		this.clss = clss;
		this.id = id;
		this.collection = collection;
		this.constructorCollection = constructorCollection;
		return this;
	}
	
	/**
	   Determines which TemplateVisibilityCollection to use as current.
	**/
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
	
	/**
	   Called by ChangeUpdateQueue, applies visibility
	**/
	public function changeUpdate():Void
	{
		applyVisibility();
	}
	
	/**
	   Applies the current TemplateVisibilityCollection to the template's object's default collection and to the template instances collections.
	**/
	public function applyVisibility():Void
	{
		this.visibilityCollectionCurrent.applyToTemplateCollection(this.object.defaultCollection);
		for (instance in this.instances)
		{
			instance.applyTemplateVisibility(this.visibilityCollectionCurrent);
		}
	}
	
	/**
	   Adds the specified object to the template's instances. If the template is from a container class, child objects are flagged to not be saved.
	   @param	instance
	**/
	public function addInstance(instance:ValEditorObject):Void 
	{
		instance.template = this;
		this.instances[this.instances.length] = instance;
		this._instanceMap.set(instance.id, instance);
		if (this.clss.isContainer)
		{
			for (object in cast(instance.object, IContainerEditable).allObjectsCollection)
			{
				object.save = false;
			}
		}
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_ADDED, this);
	}
	
	/**
	   Returns the ValeditorObject corresponding to the specified id.
	   @param	id
	   @return
	**/
	public function getInstance(id:String):ValEditorObject
	{
		return this._instanceMap.get(id);
	}
	
	/**
	   Removes the specified object from the template's instances, and unsuspends it if needed.
	   @param	instance
	**/
	public function removeInstance(instance:ValEditorObject):Void 
	{
		if (instance.isSuspended)
		{
			unsuspendInstance(instance, false);
		}
		instance.template = null;
		this.instances.remove(instance);
		this._instanceMap.remove(instance.id);
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_REMOVED, this);
	}
	
	/**
	   Returns the constructor values used when creating the template, so that instances can use the same values.
	   @param	values
	   @return
	**/
	public function getConstructorValues(?values:Array<Dynamic>):Array<Dynamic>
	{
		if (values == null) values = [];
		if (this.constructorCollection != null)
		{
			this.constructorCollection.toValueArray(values);
		}
		return values;
	}
	
	/**
	   TODO : use ValEditorTemplate.loadComplete
	**/
	public function loadComplete():Void
	{
		for (instance in this.instances)
		{
			instance.loadComplete();
		}
	}
	
	/**
	   Makes the template register its instances to ValEditor and call restoreKeyFrames() on all of them.
	   This is used by TemplateAdd and TemplateRemove actions.
	**/
	public function registerInstances():Void
	{
		for (instance in this.instances)
		{
			ValEditor.registerObject(instance);
			instance.restoreKeyFrames();
		}
	}
	
	/**
	   Makes the template unregister its instances from ValEditor and call backupKeyFrames() on all of them.
	   This is used by TemplateAdd and TemplateRemove actions.
	**/
	public function unregisterInstances():Void
	{
		for (instance in this.instances)
		{
			instance.backupKeyFrames();
			ValEditor.unregisterObject(instance);
		}
	}
	
	/**
	   Suspends the specified instance, meaning it's not part of the template's instance count anymore.
	   This is called by ValEditorObject when its container property is set to null.
	   @param	instance
	**/
	public function suspendInstance(instance:ValEditorObject):Void
	{
		this._suspendedInstances.push(instance);
		instance.isSuspended = true;
		TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_SUSPENDED, this);
	}
	
	/**
	   Unsuspends the specified instance, restoring it as part of the template's instance count.
	   This is called by ValEditorObject when its container property is set to a non-null value, and by ValEditorTemplate's removeInstance function.
	   @param	instance
	   @param	dispatchEvent
	**/
	public function unsuspendInstance(instance:ValEditorObject, dispatchEvent:Bool = true):Void
	{
		this._suspendedInstances.remove(instance);
		instance.isSuspended = false;
		if (dispatchEvent) TemplateEvent.dispatch(this, TemplateEvent.INSTANCE_UNSUSPENDED, this);
	}
	
	/**
	   Creates and returns an instance identifier, used by ValEditor's createObjectWithTemplate function if the 'id' parameter is left null.
	   @return
	**/
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
	
	/**
	   Tells whether the specified instance identifier already exists for this template or not.
	   @param	id
	   @return
	**/
	public function objectIDExists(id:String):Bool
	{
		return this._instanceMap.exists(id);
	}
	
	/**
	   Triggered when the template's object is a timeline container and a keyframe's transition property changes.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerKeyFrameTransitionChange(evt:KeyFrameEvent):Void
	{
		//trace("onTemplateContainerKeyFrameTransitionChange");
		
		var currentFrame:ValEditorKeyFrame = cast(this._object.object, ITimeLineContainerEditable).currentLayer.timeLine.frameCurrent;
		var instanceContainer:ITimeLineContainerEditable;
		var frameIndex:Int = cast(this._object.object, ITimeLineContainerEditable).frameIndex;
		var prevFrameIndex:Int;
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.frameCurrent.transition = currentFrame.transition;
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	/**
	   Triggered when the template's object is a timeline container and a keyframe's tween property changes.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerKeyFrameTweenChange(evt:KeyFrameEvent):Void
	{
		//trace("onTemplateContainerKeyFrameTweenChange");
		
		var currentFrame:ValEditorKeyFrame = cast(this._object.object, ITimeLineContainerEditable).currentLayer.timeLine.frameCurrent;
		var instanceContainer:ITimeLineContainerEditable;
		var frameIndex:Int = cast(this._object.object, ITimeLineContainerEditable).frameIndex;
		var prevFrameIndex:Int;
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.frameCurrent.tween = currentFrame.tween;
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer is added.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerAdded(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerAdded");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var index:Int = cast(this._object.object, ITimeLineContainerEditable).getLayerIndex(layer);
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).createLayer();
			layer.cloneTo(objectLayer);
			for (object in objectLayer.allObjects)
			{
				object.save = false;
			}
			cast(instance.object, ITimeLineContainerEditable).addLayerAt(objectLayer, index);
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer is moved down.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerIndexDown(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerIndexDown");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).getLayer(layer.name);
			cast(instance.object, ITimeLineContainerEditable).layerIndexDown(objectLayer);
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer is moved up.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerIndexUp(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerIndexUp");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).getLayer(layer.name);
			cast(instance.object, ITimeLineContainerEditable).layerIndexUp(objectLayer);
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer is removed.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerRemoved(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerRemoved");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).getLayer(layer.name);
			cast(instance.object, ITimeLineContainerEditable).removeLayer(objectLayer);
			objectLayer.pool();
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer is renamed.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerRenamed(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerRenamed");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var index:Int = cast(this._object.object, ITimeLineContainerEditable).getLayerIndex(layer);
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).getLayerAt(index);
			objectLayer.name = layer.name;
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer is selected.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerSelected(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerSelected");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var index:Int = cast(this._object.object, ITimeLineContainerEditable).getLayerIndex(layer);
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).getLayerAt(index);
			cast(instance.object, ITimeLineContainerEditable).currentLayer = objectLayer;
		}
	}
	
	/**
	   Triggered when the template's object is a container and a layer visibility changes.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerLayerVisibilityChange(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerLayerVisibilityChange");
		
		var layer:ITimeLineLayerEditable = evt.object;
		var index:Int = cast(this._object.object, ITimeLineContainerEditable).getLayerIndex(layer);
		var objectLayer:ITimeLineLayerEditable;
		for (instance in this.instances)
		{
			objectLayer = cast(instance.object, ITimeLineContainerEditable).getLayerAt(index);
			objectLayer.visible = layer.visible;
		}
	}
	
	/**
	   Triggered when the template's object is a container and an object is added to it.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerObjectAdded(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectAdded");
		
		var object:ValEditorObject = evt.object;
		var instanceObject:ValEditorObject;
		
		if (this._object.isTimeLineContainer)
		{
			var instanceContainer:ITimeLineContainerEditable;
			var frameIndex:Int = cast(this._object.object, ITimeLineContainerEditable).frameIndex;
			var prevFrameIndex:Int;
			
			for (instance in this.instances)
			{
				instanceContainer = cast instance.object;
				prevFrameIndex = instanceContainer.frameIndex;
				instanceContainer.frameIndex = frameIndex;
				if (instanceContainer.hasActiveObject(object.objectID)) continue;
				instanceObject = instanceContainer.getObject(object.objectID);
				if (instanceObject == null)
				{
					instanceObject = ValEditor.cloneObject(object);
					instanceObject.save = false;
				}
				instanceContainer.addObject(instanceObject);
				instanceContainer.frameIndex = prevFrameIndex;
			}
		}
		else
		{
			for (instance in this.instances)
			{
				instanceObject = ValEditor.cloneObject(object);
				cast(instance.object, IContainerEditable).addObject(instanceObject);
			}
		}
	}
	
	/**
	   Triggered when the template's object is a container and an object is removed from it.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerObjectRemoved(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectRemoved");
		
		var object:ValEditorObject = evt.object;
		var instanceObject:ValEditorObject;
		
		if (this._object.isTimeLineContainer)
		{
			var timeLineContainer:ITimeLineContainerEditable;
			var frameIndex:Int = cast(this._object.object, ITimeLineContainerEditable).frameIndex;
			var prevFrameIndex:Int;
			
			for (instance in this.instances)
			{
				timeLineContainer = cast instance.object;
				prevFrameIndex = timeLineContainer.frameIndex;
				timeLineContainer.frameIndex = frameIndex;
				if (!timeLineContainer.hasActiveObject(object.objectID)) continue;
				instanceObject = timeLineContainer.getActiveObject(object.objectID);
				timeLineContainer.removeObject(instanceObject);
				if (instanceObject.canBeDestroyed())
				{
					ValEditor.destroyObject(instanceObject);
				}
				timeLineContainer.frameIndex = prevFrameIndex;
			}
		}
		else
		{
			var instanceContainer:IContainerEditable;
			
			for (instance in this.instances)
			{
				instanceContainer = cast instance.object;
				if (!instanceContainer.hasActiveObject(object.objectID)) continue;
				instanceObject = instanceContainer.getActiveObject(object.objectID);
				instanceContainer.removeObject(instanceObject);
				if (instanceObject.canBeDestroyed())
				{
					ValEditor.destroyObject(instanceObject);
				}
			}
		}
	}
	
	/**
	   Triggered when the template's object is a container and a function is called on an child object.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerObjectFunctionCalled(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectFunctionCalled");
		
		var functionEvent:ObjectFunctionEvent = cast evt.subEvent;
		var object:ValEditorObject = functionEvent.object;
		var instanceContainer:IContainerEditable;
		var instanceObject:ValEditorObject;
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			instanceObject = instanceContainer.getActiveObject(object.objectID);
			instanceObject.templateFunctionCall(functionEvent.functionName, functionEvent.parameters);
		}
	}
	
	/**
	   Triggered when the template's object is a container and a property changes on a child object.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerObjectPropertyChange(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerObjectPropertyChange");
		
		var propertyEvent:ObjectPropertyEvent = cast evt.subEvent;
		var object:ValEditorObject = propertyEvent.object;
		var templateValue:ExposedValue = object.currentCollection.getValueDeep(propertyEvent.propertyNames);
		var instanceContainer:IContainerEditable;
		var instanceObject:ValEditorObject;
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			instanceObject = instanceContainer.getActiveObject(object.objectID);
			instanceObject.templateChildPropertyChange(templateValue, propertyEvent.propertyNames);
		}
	}
	
	/**
	   Triggered when the template's object is a timeline container and its selectedFrameIndex property changes.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerSelectedFrameIndexChange(evt:ContainerEvent):Void
	{
		//trace("onTemplateContainerSelectedFrameIndexChange");
		
		var index:Int = cast(this.object.object, ITimeLineContainerEditable).currentLayer.timeLine.selectedFrameIndex;
		for (instance in this.instances)
		{
			cast(instance.object, ITimeLineContainerEditable).currentLayer.timeLine.selectedFrameIndex = index;
		}
	}
	
	/**
	   Triggered when the template's object is a timeline container and a frame is inserted.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerInsertFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerInsertFrame");
		
		var frameIndex:Int = cast(this.object.object, ITimeLineContainerEditable).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:ITimeLineContainerEditable;
		
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.insertFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	/**
	   Triggered when the template's object is a timeline container and a keyframe is inserted.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerInsertKeyFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerInsertKeyFrame");
		
		var frameIndex:Int = cast(this.object.object, ITimeLineContainerEditable).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:ITimeLineContainerEditable;
		
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.insertKeyFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	/**
	   Triggered when the template's object is a timeline container and a frame is removed.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerRemoveFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerRemoveFrame");
		
		var frameIndex:Int = cast(this.object.object, ITimeLineContainerEditable).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:ITimeLineContainerEditable;
		
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.removeFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	/**
	   Triggered when the template's object is a timeline container and a keyframe is removed.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateContainerRemoveKeyFrame(evt:TimeLineActionEvent):Void
	{
		//trace("onTemplateContainerRemoveKeyFrame");
		
		var frameIndex:Int = cast(this.object.object, ITimeLineContainerEditable).frameIndex;
		var prevFrameIndex:Int;
		var instanceContainer:ITimeLineContainerEditable;
		
		for (instance in this.instances)
		{
			instanceContainer = cast instance.object;
			prevFrameIndex = instanceContainer.frameIndex;
			instanceContainer.frameIndex = frameIndex;
			instanceContainer.currentLayer.timeLine.removeKeyFrame(evt.action);
			instanceContainer.frameIndex = prevFrameIndex;
		}
	}
	
	/**
	   Triggered when a property changes on the template's object.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
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
		
		for (instance in this.instances)
		{
			instance.templatePropertyChange(templateValue, evt.propertyNames);
		}
	}
	
	/**
	   Triggered when a function is called on the template's object.
	   This is used by the template to replicate the change on all instances.
	   @param	evt
	**/
	private function onTemplateObjectFunctionCalled(evt:ObjectFunctionEvent):Void
	{
		if (this.lockInstanceUpdates)
		{
			return;
		}
		
		for (instance in this.instances)
		{
			instance.templateFunctionCall(evt.functionName, evt.parameters);
		}
	}
	
	/**
	   Loads the template from json save data.
	   @param	json
	**/
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
			cast(this.object.object, IContainerEditable).fromJSONSave(json.containerData);
		}
		
		var instance:ValEditorObject;
		var instances:Array<Dynamic> = json.instances;
		for (node in instances)
		{
			instance = ValEditor.createObjectWithTemplate(this, node.id);
			instance.fromJSONSave(node);
		}
	}
	
	/**
	   Saves a container template's data to json.
	   @param	json
	   @return
	**/
	public function toJSONContainerSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		json.clss = this.clss.className;
		return toJSONSave(json);
	}
	
	/**
	   Saves a template's data to json.
	   @param	json
	   @return
	**/
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
			json.containerData = cast(this.object.object, IContainerEditable).toJSONSave();
		}
		
		var instances:Array<Dynamic> = [];
		for (instance in this.instances)
		{
			if (instance.save)
			{
				instances.push(instance.toJSONSave());
			}
		}
		json.instances = instances;
		
		return json;
	}
	
}
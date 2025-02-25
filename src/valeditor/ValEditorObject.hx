package valeditor;

import haxe.Constraints.Function;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;
import valedit.ExposedCollection;
import valedit.events.ValueEvent;
import valedit.utils.PropertyMap;
import valedit.utils.ReverseIterator;
import valedit.value.ExposedFunction;
import valedit.value.base.ExposedValue;
import valeditor.container.IContainerEditable;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.events.LoadEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * A ValEditorObject holds the reference to a "real" object and stores the necessary data for it.
 * @author Matse
 */
class ValEditorObject extends EventDispatcher implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	static public function fromPool(clss:ValEditorClass, ?id:String):ValEditorObject
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(clss, id);
		return new ValEditorObject(clss, id);
	}
	
	/** if not null this function is called when the object is added to display */
	public var addToDisplayFunction:Function;
	/** The object's full class name (ie: openfl.display.Bitmap) */ 
	public var className:String;
	/** The ValEditorClass that this object was created from. */
	public var clss:ValEditorClass;
	/** The constructor collection for this object, if any. Objects created from a template don't have a constructor collection. */
	public var constructorCollection(get, set):ExposedCollection;
	/** The container for this object, if any */
	public var container(get, set):IContainerEditable;
	/** Name of the event to listen for after creating the object to know when it's ready to use, if any */
	public var creationReadyEventName:String;
	/** Name of the object's function to call with a callback after creating the object to know when it's ready to use, if any */
	public var creationReadyRegisterFunctionName:String;
	/** The current collection for this object, it can either be on related to a keyframe or the default one. */
	public var currentCollection(default, null):ExposedCollection;
	/** The current keyframe for this object, if any */
	public var currentKeyFrame(default, null):ValEditorKeyFrame;
	/** The collection used as 'currentCollection' when the object is not associated with any keyframe or when 'currentKeyFrame' is null */
	public var defaultCollection(get, set):ExposedCollection;
	/** */
	public var destroyOnCompletion:Bool = true;
	/** Name of the 'getBounds' function for this object, if any */
	public var getBoundsFunctionName(get, set):String;
	/** returns true if this object has a 'getBounds' function, false otherwise.
	 * Note that this only applies to display objects and containers. */
	public var hasBoundsFunction(get, never):Bool;
	/** Tells whether this object has pivot properties or not (typically pivotX, pivotY). This is used by IInteractiveObject and SelectionBox. */
	public var hasPivotProperties:Bool;
	/** Tells whether this object has scale properties or not (typically scaleX, scaleY). This is used by IInteractiveObject and SelectionBox. */
	public var hasScaleProperties:Bool;
	/** Tells whether this object has a 'visible' property or not. This is used by IInteractiveObject.
	 * Note that this only applies to display objects. */
	public var hasVisibleProperty:Bool;
	/** Tells whether this object uses radians for rotation (Starling display objects, typically). */
	public var hasRadianRotation:Bool;
	/** the unique identifier for this object */
	public var id(get, set):String;
	/** the 'IInteractiveObject instance associated with this object, use by ValEditorContainerController to handle mouse/touch events.
	 * This only applies to display objects (not containers). */
	public var interactiveObject(get, set):IInteractiveObject;
	/** Tells whether this object is a container (OpenFL, Starling or both) or not. */
	public var isContainer:Bool;
	/** Tells whether this object is an OpenFL container or not.
	 * Note that 'isContainerOpenFL' and 'isContainerStarling' can be both true in the case of a mixed container. */
	public var isContainerOpenFL:Bool;
	#if starling
	/** Tells wheter this object is a Starling container or not.
	 * Note that 'isContainerOpenFL' and 'isContainerStarling' can be both true in the case of a mixed container. */
	public var isContainerStarling:Bool;
	#end
	/** Tells wether this objet is created asynchronously (or requires some loading) */
	public var isCreationAsync(get, never):Bool;
	/** Tells whether this object is a display object (OpenFL or Starling) or not. */
	public var isDisplayObject:Bool;
	/** Tells whether this object is an OpenFL display object or not. */
	public var isDisplayObjectOpenFL:Bool;
	#if starling
	/** Tells whether this object is a Starling display object or not. */
	public var isDisplayObjectStarling:Bool;
	#end
	/** Tells whether this object was created by ValEditor (false) or provided from another source (true) */
	public var isExternal:Bool;
	/** Tells whether this object is in clipboard or not. */
	public var isInClipboard:Bool;
	/** Tells whether this object is in a library (which will prevent it from being destroyed) or not. */
	public var isInLibrary:Bool;
	/** Tells whether this object is in pool or not. */
	public var isInPool(get, never):Bool;
	public var isLoaded(default, null):Bool = true;
	/** Tells whether this object received a mouse down (openfl) or begin touch (starling) event. This is used by ValEditorContainerController when moving objects around.
	 * Note that this only applies to display objects and containers. */
	public var isMouseDown:Bool;
	/** Tells whether this object is selectable or not.
	 * Note that this only applies to display objects and containers. */
	public var isSelectable(get, set):Bool;
	/** Tells whether this object is suspended or not. An object becomes suspended when it's a template instance and it doesn't have a container anymore but is still in the undo stack */
	public var isSuspended:Bool;
	/** Tells if this object is a timeline container */
	public var isTimeLineContainer:Bool;
	/** References to keyframes this object is associated with */
	public var keyFrames(get, never):Array<ValEditorKeyFrame>;
	/** Initial 'x' value before moving, this is used by ValEditorContainerController to restore an object's position when a move is cancelled.
	 * Note that this only applies to display objects and containers */
	public var mouseRestoreX:Float;
	/** Initial 'y' value before moving, this is used by ValEditorContainerController to restore an object's position when a move is cancelled.
	 * Note that this only applies to display objects and containers */
	public var mouseRestoreY:Float;
	/** Tells how many keyframes this object is associated with. */
	public var numKeyFrames(default, null):Int = 0;
	/** the real object, which can be anything */
	public var object:Dynamic;
	/** Not the real ID, returns the value of 'id' if null. This is used to have the same ids in container instances */
	public var objectID(get, set):String;
	/** Reference to the PivotIndicator instance set by ValEditorContainerController when this object is selected (null otherwise).
	 * Note that this only applies to display objects and containers */
	public var pivotIndicator(get, set):PivotIndicator;
	/** PropertyMap stores associations between an object's property name and the "regular" property name.
	 * For example an object could have a property named 'xLoc' that would need to be associated with "x". */
	public var propertyMap:PropertyMap;
	/** if not null this function is called when the object is removed from display */
	public var removeFromDisplayFunction:Function;
	/** */
	public var restoreValuesOnCompletion:Bool = false;
	/** Tells whether this object should be in saved file or not. */
	public var save:Bool = true;
	/** Reference to the SelectionBox instance set by ValEditorContainerController when this object is selected (null otherwise).
	 * Note that this only applies to display objects and containers. */
	public var selectionBox(get, set):SelectionBox;
	/** Reference to this object's template, if it has one (null otherwise). */
	public var template:ValEditorTemplate;
	/** if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height. */
	public var useBounds:Bool;
	/** Tells whether pivot values should be multiplied with the corresponding scale value (true) or not (false).
	 * Starling display objects need to have their pivotX property multiplied by their scaleX property to get the "real" value, for example. */
	public var usePivotScaling:Bool;
	
	private var _constructorCollection:ExposedCollection;
	private function get_constructorCollection():ExposedCollection { return this._constructorCollection; }
	private function set_constructorCollection(value:ExposedCollection):ExposedCollection
	{
		if (this._constructorCollection == value) return value;
		
		if (this._constructorCollection != null)
		{
			this._constructorCollection.valEditorObject = null;
		}
		if (value != null)
		{
			value.valEditorObject = this;
		}
		return this._constructorCollection = value;
	}
	
	private var _container:IContainerEditable;
	private function get_container():IContainerEditable { return this._container; }
	private function set_container(value:IContainerEditable):IContainerEditable
	{
		if (this._container == value) return value;
		
		if (this.template != null)
		{
			if (value == null)
			{
				this.template.suspendInstance(this);
			}
			else if (this.isSuspended)
			{
				this.template.unsuspendInstance(this);
			}
		}
		
		return this._container = value;
	}
	
	private var _defaultCollection:ExposedCollection;
	private function get_defaultCollection():ExposedCollection { return this._defaultCollection; }
	private function set_defaultCollection(value:ExposedCollection):ExposedCollection 
	{
		if (this._defaultCollection == value) return value;
		
		if (this._defaultCollection != null)
		{
			this._defaultCollection.valEditorObject = null;
		}
		if (value != null)
		{
			value.valEditorObject = this;
			value.readFromObject(this.object);
		}
		if (this.currentCollection == null && this.isLoaded)
		{
			setCurrentCollection(value);
		}
		return this._defaultCollection = value;
	}
	
	private var _getBoundsFunctionName:String;
	private function get_getBoundsFunctionName():String { return this._getBoundsFunctionName; }
	private function set_getBoundsFunctionName(value:String):String
	{
		if (value == this._getBoundsFunctionName) return value;
		if (this.object != null && value != null)
		{
			this._boundsFunction = Reflect.field(this.object, value);
		}
		else
		{
			this._boundsFunction = null;
		}
		return this._getBoundsFunctionName = value;
	}
	
	private function get_hasBoundsFunction():Bool { return this._boundsFunction != null; }
	
	private var _id:String;
	private function get_id():String { return this._id; }
	private function set_id(value:String):String 
	{
		if (this._id == value) return value;
		var oldID:String = this._id;
		this._id = value;
		RenameEvent.dispatch(this, RenameEvent.RENAMED, oldID);
		return this._id;
	}
	
	private var _interactiveObject:IInteractiveObject;
	private function get_interactiveObject():IInteractiveObject { return this._interactiveObject; }
	private function set_interactiveObject(value:IInteractiveObject):IInteractiveObject
	{
		if (value == this._interactiveObject) return value;
		if (value != null)
		{
			value.objectUpdate(this);
			if (!this._isSelectable) Reflect.setProperty(value, "visible", this._isSelectable);
			value.visibilityLocked = !this._isSelectable;
		}
		return this._interactiveObject = value;
	}
	
	private function get_isCreationAsync():Bool { return !this.isExternal && (this.creationReadyEventName != null || this.creationReadyRegisterFunctionName != null); }
	
	private var _isInPool:Bool = false;
	private function get_isInPool():Bool { return this._isInPool; }
	
	private var _isSelectable:Bool = true;
	private function get_isSelectable():Bool { return this._isSelectable; }
	private function set_isSelectable(value:Bool):Bool
	{
		if (this._isSelectable == value) return value;
		if (this._interactiveObject != null)
		{
			this._interactiveObject.visibilityLocked = !value;
			if (value)
			{
				this._interactiveObject.objectUpdate(this);
			}
			else
			{
				Reflect.setProperty(this._interactiveObject, "visible", value);
			}
			
		}
		return this._isSelectable = value;
	}
	
	private function get_keyFrames():Array<ValEditorKeyFrame> { return this._keyFrames.copy(); }
	
	private var _objectID:String;
	private function get_objectID():String { return this._objectID != null ? this._objectID : this._id; }
	private function set_objectID(value:String):String 
	{
		if (this._objectID == value) return value;
		var oldObjectID:String = this.objectID;
		this._objectID = value;
		RenameEvent.dispatch(this, RenameEvent.RENAMED, oldObjectID);
		return this._objectID;
	}
	
	private var _pivotIndicator:PivotIndicator;
	private function get_pivotIndicator():PivotIndicator { return this._pivotIndicator; }
	private function set_pivotIndicator(value:PivotIndicator):PivotIndicator
	{
		if (value == this._pivotIndicator) return value;
		if (value != null)
		{
			value.objectUpdate(this);
		}
		return this._pivotIndicator = value;
	}
	
	private var _selectionBox:SelectionBox;
	private function get_selectionBox():SelectionBox { return this._selectionBox; }
	private function set_selectionBox(value:SelectionBox):SelectionBox
	{
		if (value == this._selectionBox) return value;
		if (value != null)
		{
			value.objectUpdate(this);
		}
		return this._selectionBox = value;
	}
	
	private var _boundsFunction:Function;
	private var _keyFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	private var _keyFrameToCollection:Map<ValEditorKeyFrame, ExposedCollection> = new Map<ValEditorKeyFrame, ExposedCollection>();
	private var _restoreKeyFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	private var _restoreKeyFramesCollections:Array<ExposedCollection> = new Array<ExposedCollection>();
	
	private var _registeredActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	
	private var _realPropertyName:String;
	private var _regularPropertyName:String;
	
	public function new(clss:ValEditorClass, ?id:String) 
	{
		super();
		
		setTo(clss, id);
	}
	
	/**
	   resets this object entirely, removing it from container and clearing keyframes if needed
	**/
	public function clear():Void 
	{
		if (this.container != null)
		{
			this.container.removeObjectCompletely(this);
		}
		
		if (this._interactiveObject != null)
		{
			this._interactiveObject.pool();
			this._interactiveObject = null;
		}
		if (this._pivotIndicator != null)
		{
			this._pivotIndicator.pool();
			this._pivotIndicator = null;
		}
		if (this._selectionBox != null)
		{
			this._selectionBox.pool();
			this._selectionBox = null;
		}
		
		this.clss = null;
		this.currentCollection = null;
		if (this._constructorCollection != null)
		{
			this._constructorCollection.pool();
			this._constructorCollection = null;
		}
		if (this._defaultCollection != null)
		{
			this._defaultCollection.pool();
			this._defaultCollection = null;
		}
		
		this.addToDisplayFunction = null;
		this._boundsFunction = null;
		this.container = null;
		this.creationReadyEventName = null;
		this.creationReadyRegisterFunctionName = null;
		this.getBoundsFunctionName = "getBounds";
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.isContainer = false;
		this.isContainerOpenFL = false;
		#if starling
		this.isContainerStarling = false;
		#end
		this.isDisplayObject = false;
		this.isDisplayObjectOpenFL = false;
		#if starling
		this.isDisplayObjectStarling = false;
		#end
		this.isExternal = false;
		this.isInClipboard = false;
		this.isInLibrary = false;
		this.isLoaded = true;
		this.isMouseDown = false;
		this.isSelectable = true;
		this.isSuspended = false;
		this.isTimeLineContainer = false;
		this.numKeyFrames = 0;
		this.object = null;
		this.objectID = null;
		this.propertyMap = null;
		this.removeFromDisplayFunction = null;
		this.save = true;
		this.template = null;
		this.useBounds = false;
		this.usePivotScaling = false;
		
		this._restoreKeyFrames.resize(0);
		for (collection in this._restoreKeyFramesCollections)
		{
			collection.pool();
		}
		this._restoreKeyFramesCollections.resize(0);
	}
	
	/**
	   Clears the object and sends it to pool
	**/
	public function pool():Void 
	{
		clear();
		// DEBUG
		// TODO : remove when no longer useful
		if (this._isInPool)
		{
			throw new Error("ValEditorObject.pool ::: object already in pool");
		}
		//\DEBUG
		_POOL[_POOL.length] = this;
		this._isInPool = true;
	}
	
	/**
	   Object related actions will call this so that the object doesn't get destroyed as long as it has registered actions.
	   @param	action
	**/
	public function registerAction(action:ValEditorAction):Void
	{
		this._registeredActions[this._registeredActions.length] = action;
	}
	
	/**
	   Object related actions that registered to this object will call this when they get cleared.
	   @param	action
	**/
	public function unregisterAction(action:ValEditorAction):Void
	{
		this._registeredActions.remove(action);
	}
	
	/**
	   Returns true if this object can be destroyed, false otherwise.
	   @return
	**/
	public function canBeDestroyed():Bool 
	{
		return !this._isInPool && !this.isInLibrary && this.container == null && this.numKeyFrames == 0 && !this.isInClipboard && this._registeredActions.length == 0;
		//return !this._isInPool && this.container == null && this.numKeyFrames == 0 && !this.isInClipboard && !this.isSuspended && this._registeredActions.length == 0;
	}
	
	/**
	   Equivalent to the constructor when calling 'fromPool'.
	   @param	clss
	   @param	id
	   @return
	**/
	private function setTo(clss:ValEditorClass, id:String):ValEditorObject
	{
		this._id = id;
		this.clss = clss;
		this.className = clss.className;
		this.isDisplayObject = clss.isDisplayObject;
		if (this.isDisplayObject)
		{
			this.isDisplayObjectOpenFL = clss.isDisplayObjectOpenFL;
			#if starling
			this.isDisplayObjectStarling = clss.isDisplayObjectStarling;
			#end
		}
		
		this._isInPool = false;
		
		return this;
	}
	
	/**
	   Called by ValEditor on object creation once everything has been set.
	**/
	public function ready():Void 
	{
		if (this.getBoundsFunctionName != null)
		{
			this._boundsFunction = Reflect.field(this.object, this.getBoundsFunctionName);
		}
	}
	
	/**
	   Applies provided ClassVisibilityCollection to 'defaultCollection' and all keyframe related collections.
	   @param	visibility
	**/
	public function applyClassVisibility(visibility:ClassVisibilityCollection):Void
	{
		if (this.template == null)
		{
			visibility.applyToObjectCollection(this._defaultCollection);
			for (collection in this._keyFrameToCollection)
			{
				visibility.applyToObjectCollection(collection);
			}
		}
		else
		{
			visibility.applyToTemplateObjectCollection(this._defaultCollection);
			for (collection in this._keyFrameToCollection)
			{
				visibility.applyToTemplateObjectCollection(collection);
			}
		}
	}
	
	/**
	   Applies provided TemplateVisibilityCollection to 'defaultCollection' and all keyframe related collections.
	   @param	visibility
	**/
	public function applyTemplateVisibility(visibility:TemplateVisibilityCollection):Void
	{
		visibility.applyToTemplateObjectCollection(this._defaultCollection);
		for (collection in this._keyFrameToCollection)
		{
			visibility.applyToTemplateObjectCollection(collection);
		}
	}
	
	/**
	   Creates and returns a collection for the specified keyframe. If this object has a keyframe that is located before the specified one in the timeline it will clone that one.
	   @param	keyFrame
	   @return
	**/
	public function createCollectionForKeyFrame(keyFrame:ValEditorKeyFrame):ExposedCollection 
	{
		var collection:ExposedCollection = null;
		var previousFrame:ValEditorKeyFrame = keyFrame.timeLine.getPreviousKeyFrame(keyFrame);
		if (previousFrame != null && this._keyFrameToCollection.exists(previousFrame))
		{
			collection = this._keyFrameToCollection.get(previousFrame).clone(true);
		}
		
		if (collection == null)
		{
			collection = this.clss.getCollection();
			collection.readFromObject(this.object);
		}
		
		if (this.template != null)
		{
			this.template.visibilityCollectionCurrent.applyToTemplateObjectCollection(collection);
		}
		else
		{
			this.clss.visibilityCollectionCurrent.applyToObjectCollection(collection);
		}
		
		return collection;
	}
	
	/**
	   Called by ValEditorTemplate through TemplateAdd (cancel) and TemplateRemove (apply) actions.
	**/
	public function backupKeyFrames():Void
	{
		for (keyFrame in this._keyFrames)
		{
			this._restoreKeyFrames.push(keyFrame);
		}
		
		for (keyFrame in this._restoreKeyFrames)
		{
			this._restoreKeyFramesCollections.push(this._keyFrameToCollection.get(keyFrame));
			keyFrame.remove(this, false);
		}
	}
	
	/**
	   Called by ValEditorTemplate through TemplateAdd (apply) and TemplateRemove (cancel) actions.
	**/
	public function restoreKeyFrames():Void
	{
		var count:Int = this._restoreKeyFrames.length;
		for (i in 0...count)
		{
			this._restoreKeyFrames[i].add(this, this._restoreKeyFramesCollections[i]);
		}
		this._restoreKeyFrames.resize(0);
		this._restoreKeyFramesCollections.resize(0);
	}
	
	/**
	   Associates this object to the specified keyframe, if 'collection' is null a collection is created using 'createCollectionForKeyFrame'.
	   @param	keyFrame
	   @param	collection
	**/
	public function addKeyFrame(keyFrame:ValEditorKeyFrame, collection:ExposedCollection = null):Void 
	{
		if (collection == null)
		{
			collection = createCollectionForKeyFrame(keyFrame);
		}
		collection.valEditorObject = this;
		this._keyFrames[this._keyFrames.length] = keyFrame;
		this._keyFrameToCollection.set(keyFrame, collection);
		this.numKeyFrames++;
	}
	
	/**
	   Returns the collection associated to specified keyframe, if any.
	   @param	keyFrame
	   @return
	**/
	public function getCollectionForKeyFrame(keyFrame:ValEditorKeyFrame):ExposedCollection
	{
		return this._keyFrameToCollection.get(keyFrame);
	}
	
	/**
	   Returns keyframe with startIndex >= frameIndex and endIndex >= frameIndex if available, null otherwise
	   @param	frameIndex
	   @return
	**/
	public function getKeyFrameForFrameIndex(frameIndex:Int):ValEditorKeyFrame
	{
		for (keyFrame in this._keyFrames)
		{
			if (keyFrame.indexStart >= frameIndex && keyFrame.indexEnd >= frameIndex)
			{
				return keyFrame;
			}
		}
		return null;
	}
	
	/**
	   Returns true if this object is associated with specified keyframe, false otherwise.
	   @param	keyFrame
	   @return
	**/
	public function hasKeyFrame(keyFrame:ValEditorKeyFrame):Bool
	{
		return this._keyFrameToCollection.exists(keyFrame);
	}
	
	/**
	   Returns true if this object is associated with a keyframe with startIndex >= frameIndex and endIndex >= frameIndex
	   @param	frameIndex
	   @return
	**/
	public function hasKeyFrameForFrameIndex(frameIndex:Int):Bool
	{
		for (keyFrame in this._keyFrames)
		{
			if (keyFrame.indexStart >= frameIndex && keyFrame.indexEnd >= frameIndex)
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	   Removes all keyframe associations for this object and optionnally pools related collections.
	   @param	poolCollections
	**/
	public function removeAllKeyFrames(poolCollections:Bool = true):Void
	{
		for (i in new ReverseIterator(this._keyFrames.length - 1, 0))
		{
			this._keyFrames[i].remove(this, poolCollections);
		}
	}
	
	/**
	   Removes association with specified keyframe and optionnally pools related collection.
	   @param	keyFrame
	   @param	poolCollection
	**/
	public function removeKeyFrame(keyFrame:ValEditorKeyFrame, poolCollection:Bool = true):Void 
	{
		if (poolCollection)
		{
			this._keyFrameToCollection.get(keyFrame).pool();
		}
		else
		{
			this._keyFrameToCollection.get(keyFrame).valEditorObject = null;
		}
		
		this._keyFrames.remove(keyFrame);
		this._keyFrameToCollection.remove(keyFrame);
		this.numKeyFrames--;
		
		if (this.currentKeyFrame == keyFrame)
		{
			setKeyFrame(null);
		}
	}
	
	/**
	   Sets the current keyframe for this object, updating 'currentKeyFrame' and 'currentCollection' values. The new 'currentCollection' is applied (if not null).
	   @param	keyFrame
	**/
	public function setKeyFrame(keyFrame:ValEditorKeyFrame):Void 
	{
		if (this.currentKeyFrame == keyFrame) return;
		
		this.currentKeyFrame = keyFrame;
		if (this.currentKeyFrame == null)
		{
			setCurrentCollection(null);
		}
		else
		{
			setCurrentCollection(this._keyFrameToCollection.get(keyFrame));
		}
	}
	
	/**
	   Sets the 'currentCollection' value, removes object and listener on the previous one if needed then sets and applies to object, adds listener for changes and calls 'changeUpdate'.
	   @param	collection
	**/
	private function setCurrentCollection(collection:ExposedCollection):Void
	{
		if (this.currentCollection == collection) return;
		
		if (this.currentCollection != null)
		{
			this.currentCollection.object = null;
			this.currentCollection.removeEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		}
		
		if (collection == null)
		{
			this.currentCollection = this._defaultCollection;
		}
		else
		{
			this.currentCollection = collection;
		}
		
		if (this.currentCollection != null)
		{
			this.currentCollection.applyAndSetObject(this.object);
			this.currentCollection.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
			
			changeUpdate();
		}
	}
	
	/**
	   This is called by template when a function is called on it, or when the template is a container and a function is called on one of its child objects.
	   @param	propertyName
	   @param	parameters
	**/
	public function templateFunctionCall(propertyName:String, parameters:Array<Dynamic>):Void
	{
		this._defaultCollection.applyAndSetObject(this.object);
		var func:ExposedFunction = cast this._defaultCollection.getValue(propertyName);
		func.executeWithParameters(parameters);
		this._defaultCollection.object = null;
		
		if (this.currentCollection != null)
		{
			this.currentCollection.object = null;
		}
		
		for (collection in this._keyFrameToCollection)
		{
			collection.applyAndSetObject(this.object);
			func = cast collection.getValue(propertyName);
			func.executeWithParameters(parameters);
			collection.object = null;
		}
		
		if (this.currentCollection != null)
		{
			this.currentCollection.applyAndSetObject(this.object);
		}
	}
	
	/**
	   This is called by template when an exposed property changes on the template's object.
	   @param	templateValue
	   @param	propertyNames
	**/
	public function templatePropertyChange(templateValue:ExposedValue, propertyNames:Array<String>):Void
	{
		templateValue.cloneValue(this._defaultCollection.getValueDeep(propertyNames));
		
		for (collection in this._keyFrameToCollection)
		{
			templateValue.cloneValue(collection.getValueDeep(propertyNames));
		}
	}
	
	/**
	   This is called by container template when a container's child property change on the template's object.
	   @param	templateValue
	   @param	propertyNames
	**/
	public function templateChildPropertyChange(templateValue:ExposedValue, propertyNames:Array<String>):Void
	{
		templateValue.cloneValue(this.currentCollection.getValueDeep(propertyNames));
	}
	
	/**
	   Triggered by a value change in the current collection.
	   @param	evt
	**/
	private function onValueChange(evt:ValueEvent):Void
	{
		//trace("ValEditorObject.onValueChange");
		
		registerForChangeUpdate();
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, evt.value.getPropertyNames());
	}
	
	/**
	   Returns the value for the specified regular property name (keep in mind 'propertyMap' will replace it if needed), directly from the object itself.
	   @param	regularPropertyName
	   @return
	**/
	public function getProperty(regularPropertyName:String):Dynamic
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		return Reflect.getProperty(this.object, this._realPropertyName);
	}
	
	/**
	   Tells whether 'currentCollection' has a value for the specified regular property name or not.
	   @param	regularPropertyName
	   @return
	**/
	public function hasProperty(regularPropertyName:String):Bool
	{
		if (this.currentCollection == null) return false;
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		return this.currentCollection.hasValue(this._realPropertyName);
	}
	
	/**
	   Modifies specified property by the specified amount directly on the object, then updates the related value in the current collection if there is one.
	   This is used by ValEditorContainerController, either directly or through ValEditorObjectGroup.
	   @param	regularPropertyName
	   @param	value
	   @param	objectOnly
	   @param	dispatchValueChange
	**/
	public function modifyProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		Reflect.setProperty(this.object, this._realPropertyName, Reflect.getProperty(this.object, this._realPropertyName) + value);
		
		if (dispatchValueChange && this.currentCollection != null)
		{
			var value:ExposedValue = this.currentCollection.getValue(this._realPropertyName);
			value.valueChanged();
			this.currentCollection.read();
		}
		
		if (!objectOnly)
		{
			registerForChangeUpdate();
		}
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, [this._realPropertyName]);
	}
	
	/**
	   Sets specified property to the specified value directly on the object, then updates the related value in the current collection if there is one.
	   @param	regularPropertyName
	   @param	value
	   @param	objectOnly
	   @param	dispatchValueChange
	**/
	public function setProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		Reflect.setProperty(this.object, this._realPropertyName, value);
		
		if (dispatchValueChange && this.currentCollection != null)
		{
			var value:ExposedValue = this.currentCollection.getValue(this._realPropertyName);
			value.valueChanged();
			this.currentCollection.read();
		}
		
		if (!objectOnly)
		{
			registerForChangeUpdate();
		}
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, [this._realPropertyName]);
	}
	
	/**
	   Returns the exposed value in the current collection for the specified property name.
	   @param	regularPropertyName
	   @return
	**/
	public function getValue(regularPropertyName:String):ExposedValue
	{
		if (this.currentCollection == null) return null;
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		return this.currentCollection.getValue(this._realPropertyName);
	}
	
	/**
	   Adds this to the ChangeUpdateQueue for a single changeUpdate call.
	   This prevents updating interactive object, selection box and pivot indicator for every change in a single frame.
	**/
	public function registerForChangeUpdate():Void
	{
		ValEditor.registerForChangeUpdate(this);
	}
	
	/**
	   Called by ChangeUpdateQueue, updates interactive object, selection box and pivot indicator if applicable.
	**/
	public function changeUpdate():Void
	{
		if (this._interactiveObject != null)
		{
			this._interactiveObject.objectUpdate(this);
		}
		
		if (!this.isMouseDown)
		{
			if (this._selectionBox != null)
			{
				this._selectionBox.objectUpdate(this);
			}
		}
		
		if (this._pivotIndicator != null)
		{
			this._pivotIndicator.objectUpdate(this);
		}
	}
	
	/**
	   This is used by ExposedFunction and ExposedFunctionExternal when they are executed. If the object comes from a template it will reflect that call on template instances.
	   @param	propertyName
	   @param	parameters
	**/
	public function functionCalled(propertyName:String, parameters:Array<Dynamic>):Void
	{
		ObjectFunctionEvent.dispatch(this, ObjectFunctionEvent.CALLED, this, propertyName, parameters);
	}
	
	/**
	   Calls the getBounds function on the real object.
	   @param	targetSpace
	   @return
	**/
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		return Reflect.callMethod(this.object, this._boundsFunction, [targetSpace]);
	}
	
	public function loadSetup():Void
	{
		this.isLoaded = false;
		if (this.creationReadyEventName != null)
		{
			this.object.addEventListener(this.creationReadyEventName, onObjectLoadedEvent);
		}
		else if (this.creationReadyRegisterFunctionName != null)
		{
			Reflect.callMethod(this.object, Reflect.getProperty(this.object, this.creationReadyRegisterFunctionName), [onObjectLoadedCallback]);
		}
	}
	
	private function onObjectLoadedCallback(obj:Dynamic = null):Void
	{
		objectLoaded();
	}
	
	private function onObjectLoadedEvent(evt:Dynamic):Void
	{
		this.object.removeEventListener(this.creationReadyEventName, onObjectLoadedEvent);
		objectLoaded();
	}
	
	private function objectLoaded():Void
	{
		this.isLoaded = true;
		if (this.currentCollection == null)
		{
			setCurrentCollection(this._defaultCollection);
		}
		ready();
		LoadEvent.dispatch(this, LoadEvent.COMPLETE);
	}
	
	/**
	   Called after loading a saved file is complete. This is meant to handle reference values.
	**/
	public function loadComplete():Void
	{
		if (this.defaultCollection != null)
		{
			this.defaultCollection.loadComplete();
		}
		
		for (collection in this._keyFrameToCollection)
		{
			collection.loadComplete();
		}
	}
	
	/**
	   Loads object's default collection and objectID (if not null).
	   @param	json
	**/
	public function fromJSONSave(json:Dynamic):Void
	{
		this.id = json.id;
		if (json.objectID != null)
		{
			this.objectID = json.objectID;
		}
		
		if (json.destroyOnCompletion != null)
		{
			this.destroyOnCompletion = json.destroyOnCompletion;
		}
		if (json.restoreValuesOnCompletion != null)
		{
			this.restoreValuesOnCompletion = json.restoreValuesOnCompletion;
		}
		
		if (json.constructorCollection != null)
		{
			//if (this.className == "tLotDClassic.gameObjects.platforms.FallingPlatform")
			//{
				//trace("debug");
			//}
			if (this._constructorCollection == null)
			{
				this.constructorCollection = this.clss.getConstructorCollection();
			}
			this._constructorCollection.fromJSONSave(json.constructorCollection);
		}
		if (json.defaultCollection != null)
		{
			if (this._defaultCollection == null)
			{
				this.defaultCollection = this.clss.getCollection();
			}
			this._defaultCollection.fromJSONSave(json.defaultCollection);
		}
	}
	
	/**
	   Saves object's default collection and objectID (if not null).
	   @param	json
	   @return
	**/
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.id = this.id;
		if (this._objectID != null)
		{
			json.objectID = this._objectID;
		}
		json.destroyOnCompletion = this.destroyOnCompletion;
		json.restoreValuesOnCompletion = this.restoreValuesOnCompletion;
		
		if (this.template != null)
		{
			json.templateID = this.template.id;
			if (this._defaultCollection != null)
			{
				json.defaultCollection = this._defaultCollection.toJSONSave(null, false, this.template.collection);
			}
		}
		else
		{
			json.clss = this.clss.className;
			if (this._constructorCollection != null)
			{
				json.constructorCollection = this._constructorCollection.toJSONSave();
			}
			if (this._defaultCollection != null)
			{
				json.defaultCollection = this._defaultCollection.toJSONSave();
			}
		}
		
		return json;
	}
	
	/**
	   Saves the collection related to specified keyframe.
	   @param	keyFrame
	   @param	json
	   @return
	**/
	public function toJSONSaveKeyFrame(keyFrame:ValEditorKeyFrame, json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.id = this.id;
		if (this._objectID != null)
		{
			json.objectID = this._objectID;
		}
		var collection:ExposedCollection = this._keyFrameToCollection.get(keyFrame);
		
		if (this.template != null)
		{
			json.templateID = this.template.id;
			json.collection = collection.toJSONSave(null, false, this.template.collection);
		}
		else
		{
			json.collection = collection.toJSONSave();
		}
		
		return json;
	}
	
}
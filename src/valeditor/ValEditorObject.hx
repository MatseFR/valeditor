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
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.events.RenameEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
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
	
	public var className:String;
	public var clss:ValEditorClass;
	public var container(get, set):IContainerEditable;
	public var currentCollection(default, null):ExposedCollection;
	public var currentKeyFrame(default, null):ValEditorKeyFrame;
	public var defaultCollection(get, set):ExposedCollection;
	public var displayObjectType:Int;
	public var getBoundsFunctionName(get, set):String;
	public var hasBoundsFunction(get, never):Bool;
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformProperty:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasVisibleProperty:Bool;
	public var hasRadianRotation:Bool;
	public var id(get, set):String;
	public var interactiveObject(get, set):IInteractiveObject;
	public var isContainer:Bool;
	public var isContainerOpenFL:Bool;
	#if starling
	public var isContainerStarling:Bool;
	#end
	public var isDisplayObject:Bool;
	public var isInClipboard:Bool;
	public var isInPool(get, never):Bool;
	public var isMouseDown:Bool;
	public var isSelectable(get, set):Bool;
	public var isSuspended:Bool;
	public var isTimeLineContainer:Bool;
	public var keyFrames(get, never):Array<ValEditorKeyFrame>;
	public var mouseRestoreX:Float;
	public var mouseRestoreY:Float;
	public var numKeyFrames(default, null):Int = 0;
	public var object:Dynamic;
	public var objectID(get, set):String;
	public var pivotIndicator(get, set):PivotIndicator;
	public var propertyMap:PropertyMap;
	public var save:Bool = true;
	public var selectionBox(get, set):SelectionBox;
	public var template:ValEditorTemplate;
	/* if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height */
	public var useBounds:Bool;
	public var usePivotScaling:Bool;
	
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
		}
		if (this.currentCollection == null)
		{
			this.currentCollection = value;
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
		if (this._defaultCollection != null)
		{
			this._defaultCollection.pool();
			this._defaultCollection = null;
		}
		
		this._boundsFunction = null;
		this.container = null;
		this.getBoundsFunctionName = "getBounds";
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasTransformProperty = false;
		this.hasTransformationMatrixProperty = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.isContainer = false;
		this.isContainerOpenFL = false;
		#if starling
		this.isContainerStarling = false;
		#end
		this.isDisplayObject = false;
		this.isInClipboard = false;
		this.isMouseDown = false;
		this.isSelectable = true;
		this.isSuspended = false;
		this.isTimeLineContainer = false;
		this.numKeyFrames = 0;
		this.object = null;
		this.objectID = null;
		this.propertyMap = null;
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
	
	public function pool():Void 
	{
		clear();
		// DEBUG
		// TODO : remove when no longer useful
		if (_POOL.indexOf(this) != -1)
		{
			throw new Error("ValEditorObject.pool ::: object already in pool");
		}
		//\DEBUG
		_POOL[_POOL.length] = this;
		this._isInPool = true;
	}
	
	public function registerAction(action:ValEditorAction):Void
	{
		this._registeredActions[this._registeredActions.length] = action;
	}
	
	public function unregisterAction(action:ValEditorAction):Void
	{
		this._registeredActions.remove(action);
	}
	
	public function canBeDestroyed():Bool 
	{
		return !this._isInPool && this.container == null && this.numKeyFrames == 0 && !this.isInClipboard && !this.isSuspended && this._registeredActions.length == 0;
	}
	
	public function ready():Void 
	{
		if (this.getBoundsFunctionName != null)
		{
			this._boundsFunction = Reflect.field(this.object, this.getBoundsFunctionName);
		}
	}
	
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
	
	public function applyTemplateVisibility(visibility:TemplateVisibilityCollection):Void
	{
		visibility.applyToTemplateObjectCollection(this._defaultCollection);
		for (collection in this._keyFrameToCollection)
		{
			visibility.applyToTemplateObjectCollection(collection);
		}
	}
	
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
			collection.readValuesFromObject(this.object);
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
	
	public function getCollectionForKeyFrame(keyFrame:ValEditorKeyFrame):ExposedCollection
	{
		return this._keyFrameToCollection.get(keyFrame);
	}
	
	public function hasKeyFrame(keyFrame:ValEditorKeyFrame):Bool
	{
		return this._keyFrameToCollection.exists(keyFrame);
	}
	
	public function removeAllKeyFrames(poolCollections:Bool = true):Void
	{
		for (i in new ReverseIterator(this._keyFrames.length - 1, 0))
		{
			this._keyFrames[i].remove(this, poolCollections);
		}
	}
	
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
	
	public function setKeyFrame(keyFrame:ValEditorKeyFrame):Void 
	{
		if (this.currentKeyFrame == keyFrame) return;
		if (this.currentCollection != null)
		{
			this.currentCollection.object = null;
			this.currentCollection.removeEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		}
		
		if (keyFrame == null)
		{
			this.currentCollection = null;
		}
		else
		{
			this.currentCollection = this._keyFrameToCollection.get(keyFrame);
		}
		this.currentKeyFrame = keyFrame;
		
		if (this.currentCollection != null)
		{
			this.currentCollection.applyAndSetObject(this.object);
			this.currentCollection.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
			
			if (this._interactiveObject != null)
			{
				this._interactiveObject.objectUpdate(this);
			}
			if (this._selectionBox != null)
			{
				this._selectionBox.objectUpdate(this);
			}
		}
	}
	
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
	
	//@:access(valedit.value.base.ExposedValue)
	public function templatePropertyChange(templateValue:ExposedValue, propertyNames:Array<String>):Void
	{
		templateValue.cloneValue(this._defaultCollection.getValueDeep(propertyNames));
		
		for (collection in this._keyFrameToCollection)
		{
			templateValue.cloneValue(collection.getValueDeep(propertyNames));
		}
	}
	
	public function templateChildPropertyChange(templateValue:ExposedValue, propertyNames:Array<String>):Void
	{
		templateValue.cloneValue(this.currentCollection.getValueDeep(propertyNames));
	}
	
	public function valueChange(value:ExposedValue):Void
	{
		// this value changed on object, reflect changes on interactiveObject & realObject if needed
		registerForChangeUpdate();
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, value.getPropertyNames());
	}
	
	private function onValueChange(evt:ValueEvent):Void
	{
		//this._regularPropertyName = this.propertyMap.getRegularPropertyName(evt.value.propertyName);
		//if (this._regularPropertyName == null) this._regularPropertyName = evt.value.propertyName;
		
		registerForChangeUpdate();
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, evt.value.getPropertyNames());
	}
	
	public function getProperty(regularPropertyName:String):Dynamic
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		return Reflect.getProperty(this.object, this._realPropertyName);
	}
	
	public function hasProperty(regularPropertyName:String):Bool
	{
		if (this.currentCollection == null) return false;
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		return this.currentCollection.hasValue(this._realPropertyName);
	}
	
	public function modifyProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		Reflect.setProperty(this.object, this._realPropertyName, Reflect.getProperty(this.object, this._realPropertyName) + value);
		
		if (dispatchValueChange && this.currentCollection != null)
		{
			var value:ExposedValue = this.currentCollection.getValue(this._realPropertyName);
			value.valueChanged();
			this.currentCollection.readValues();
		}
		
		if (!objectOnly)
		{
			registerForChangeUpdate();
		}
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, [this._realPropertyName]);
	}
	
	public function setProperty(regularPropertyName:String, value:Dynamic, objectOnly:Bool = false, dispatchValueChange:Bool = true):Void
	{
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		Reflect.setProperty(this.object, this._realPropertyName, value);
		
		if (dispatchValueChange && this.currentCollection != null)
		{
			var value:ExposedValue = this.currentCollection.getValue(this._realPropertyName);
			value.valueChanged();
			this.currentCollection.readValues();
		}
		
		if (!objectOnly)
		{
			registerForChangeUpdate();
		}
		
		ObjectPropertyEvent.dispatch(this, ObjectPropertyEvent.CHANGE, this, [this._realPropertyName]);
	}
	
	public function getValue(regularPropertyName:String):ExposedValue
	{
		if (this.currentCollection == null) return null;
		this._realPropertyName = this.propertyMap.getObjectPropertyName(regularPropertyName);
		if (this._realPropertyName == null) this._realPropertyName = regularPropertyName;
		return this.currentCollection.getValue(this._realPropertyName);
	}
	
	public function registerForChangeUpdate():Void
	{
		ValEditor.registerForChangeUpdate(this);
	}
	
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
	
	public function functionCalled(propertyName:String, parameters:Array<Dynamic>):Void
	{
		ObjectFunctionEvent.dispatch(this, ObjectFunctionEvent.CALLED, this, propertyName, parameters);
	}
	
	public function getBounds(targetSpace:Dynamic):Rectangle
	{
		return Reflect.callMethod(this.object, this._boundsFunction, [targetSpace]);
	}
	
	private function setTo(clss:ValEditorClass, id:String):ValEditorObject
	{
		this._id = id;
		this.clss = clss;
		this.className = clss.className;
		this.isDisplayObject = clss.isDisplayObject;
		this.displayObjectType = clss.displayObjectType;
		
		this._isInPool = false;
		
		return this;
	}
	
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
	
	public function fromJSONSave(json:Dynamic):Void
	{
		this.id = json.id;
		if (json.objectID != null)
		{
			this.objectID = json.objectID;
		}
		if (json.defaultCollection != null)
		{
			if (this.defaultCollection == null)
			{
				this.defaultCollection = ExposedCollection.fromPool();
			}
			this.defaultCollection.fromJSONSave(json.defaultCollection);
		}
	}
	
	public function toJSONSave(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.id = this.id;
		if (this._objectID != null)
		{
			json.objectID = this._objectID;
		}
		if (this._defaultCollection != null && this.numKeyFrames == 0)
		{
			if (this.template != null)
			{
				json.templateID = this.template.id;
				json.defaultCollection = this._defaultCollection.toJSONSave(null, false, this.template.collection);
			}
			else
			{
				json.defaultCollection = this._defaultCollection.toJSONSave();
			}
		}
		
		return json;
	}
	
	public function toJSONSaveKeyFrame(keyFrame:ValEditorKeyFrame, json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.id = this.id;
		//if (this._objectID != null)
		//{
			//json.objectID = this._objectID;
		//}
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
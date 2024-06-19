package valeditor;

import haxe.Constraints.Function;
import openfl.geom.Rectangle;
import valedit.ExposedCollection;
import valedit.IValEditContainer;
import valedit.ValEditClass;
import valedit.ValEditKeyFrame;
import valedit.ValEditObject;
import valedit.events.ValueEvent;
import valedit.value.ExposedFunction;
import valedit.value.base.ExposedValue;
import valeditor.editor.change.IChangeUpdate;
import valeditor.editor.visibility.ClassVisibilityCollection;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.events.ObjectEvent;
import valeditor.events.ObjectFunctionEvent;
import valeditor.events.ObjectPropertyEvent;
import valeditor.ui.IInteractiveObject;
import valeditor.ui.feathers.controls.SelectionBox;
import valeditor.ui.shape.PivotIndicator;

/**
 * ...
 * @author Matse
 */
class ValEditorObject extends ValEditObject implements IChangeUpdate
{
	static private var _POOL:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	static public function fromPool(clss:ValEditClass, ?id:String):ValEditorObject
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(clss, id);
		return new ValEditorObject(clss, id);
	}
	
	public var container(get, set):IValEditContainer;
	public var getBoundsFunctionName(get, set):String;
	public var hasBoundsFunction(get, never):Bool;
	public var hasPivotProperties:Bool;
	public var hasScaleProperties:Bool;
	public var hasTransformProperty:Bool;
	public var hasTransformationMatrixProperty:Bool;
	public var hasVisibleProperty:Bool;
	public var hasRadianRotation:Bool;
	public var interactiveObject(get, set):IInteractiveObject;
	public var isInClipboard:Bool;
	public var isMouseDown:Bool;
	public var isSelectable(get, set):Bool;
	public var isSuspended:Bool;
	public var mouseRestoreX:Float;
	public var mouseRestoreY:Float;
	public var pivotIndicator(get, set):PivotIndicator;
	public var selectionBox(get, set):SelectionBox;
	/* if set to true, ValEditor will use the getBounds function in order to retrieve object's position/width/height */
	public var useBounds:Bool;
	public var usePivotScaling:Bool;
	
	private var _container:IValEditContainer;
	private function get_container():IValEditContainer { return this._container; }
	private function set_container(value:IValEditContainer):IValEditContainer
	{
		if (value == this._container) return value;
		
		return this._container = value;
	}
	
	override function set_defaultCollection(value:ExposedCollection):ExposedCollection 
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
		return super.set_defaultCollection(value);
	}
	
	private var _getBoundsFunctionName:String = "getBounds";
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
	
	override function set_id(value:String):String 
	{
		super.set_id(value);
		ObjectEvent.dispatch(this, ObjectEvent.RENAMED, this);
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
	
	override function set_objectID(value:String):String 
	{
		if (this._objectID == value) return value;
		super.set_objectID(value);
		ObjectEvent.dispatch(this, ObjectEvent.RENAMED, this);
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
	private var _restoreKeyFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	private var _restoreKeyFramesCollections:Array<ExposedCollection> = new Array<ExposedCollection>();
	
	public function new(clss:ValEditClass, ?id:String) 
	{
		super(clss, id);
	}
	
	override public function clear():Void 
	{
		super.clear();
		
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
		
		this.container = null;
		this.getBoundsFunctionName = null;
		this.hasPivotProperties = false;
		this.hasScaleProperties = false;
		this.hasTransformProperty = false;
		this.hasTransformationMatrixProperty = false;
		this.hasVisibleProperty = false;
		this.hasRadianRotation = false;
		this.isInClipboard = false;
		this.isMouseDown = false;
		this.isSelectable = true;
		this.isSuspended = false;
		this.usePivotScaling = false;
		
		this._restoreKeyFrames.resize(0);
		for (collection in this._restoreKeyFramesCollections)
		{
			collection.pool();
		}
		this._restoreKeyFramesCollections.resize(0);
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function canBeDestroyed():Bool 
	{
		return this.numKeyFrames == 0 && !this.isInClipboard && !this.isSuspended;
	}
	
	override public function ready():Void 
	{
		super.ready();
		this._boundsFunction = Reflect.field(this.object, this.getBoundsFunctionName);
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
	
	override public function createCollectionForKeyFrame(keyFrame:ValEditKeyFrame):ExposedCollection 
	{
		var collection:ExposedCollection = null;
		var previousFrame:ValEditKeyFrame = keyFrame.timeLine.getPreviousKeyFrame(keyFrame);
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
			cast(this.template, ValEditorTemplate).visibilityCollectionCurrent.applyToTemplateObjectCollection(collection);
		}
		else
		{
			cast(this.clss, ValEditorClass).visibilityCollectionCurrent.applyToObjectCollection(collection);
		}
		
		return collection;
	}
	
	public function backupKeyFrames():Void
	{
		for (keyFrame in this._keyFrames)
		{
			this._restoreKeyFrames.push(cast keyFrame);
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
	
	override public function addKeyFrame(keyFrame:ValEditKeyFrame, collection:ExposedCollection = null):Void 
	{
		super.addKeyFrame(keyFrame, collection);
		this._keyFrameToCollection.get(keyFrame).valEditorObject = this;
		if (this.isSuspended && this.template != null)
		{
			cast(this.template, ValEditorTemplate).unsuspendInstance(this);
		}
	}
	
	override public function removeKeyFrame(keyFrame:ValEditKeyFrame, poolCollection:Bool = true):Void 
	{
		if (!poolCollection)
		{
			this._keyFrameToCollection.get(keyFrame).valEditorObject = null;
		}
		super.removeKeyFrame(keyFrame, poolCollection);
		if (this.numKeyFrames == 0 && this.template != null)
		{
			cast(this.template, ValEditorTemplate).suspendInstance(this);
		}
	}
	
	override public function setKeyFrame(keyFrame:ValEditKeyFrame):Void 
	{
		if (this.currentKeyFrame == keyFrame) return;
		if (this.currentCollection != null)
		{
			this.currentCollection.removeEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		}
		super.setKeyFrame(keyFrame);
		if (this.currentCollection != null)
		{
			this.currentCollection.addEventListener(ValueEvent.VALUE_CHANGE, onValueChange);
		}
		if (this._interactiveObject != null)
		{
			this._interactiveObject.objectUpdate(this);
		}
		if (this._selectionBox != null)
		{
			this._selectionBox.objectUpdate(this);
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
		if (this._objectID != null)
		{
			json.objectID = this._objectID;
		}
		json.templateID = this.template.id;
		var collection:ExposedCollection = this._keyFrameToCollection.get(keyFrame);
		
		if (this.template != null)
		{
			json.collection = collection.toJSONSave(null, false, this.template.collection);
		}
		else
		{
			json.collection = collection.toJSONSave();
		}
		
		return json;
	}
	
}
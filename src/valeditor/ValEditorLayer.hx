package valeditor;

import feathers.data.ArrayCollection;
import openfl.errors.Error;
import valedit.DisplayObjectType;
import valedit.ValEditLayer;
import valedit.ValEditObject;
import valedit.utils.RegularPropertyName;
import valedit.utils.StringIndexedMap;
import valeditor.events.LayerEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorLayer extends ValEditLayer 
{
	static private var _POOL:Array<ValEditorLayer> = new Array<ValEditorLayer>();
	
	static public function fromPool(?timeLine:ValEditorTimeLine):ValEditorLayer
	{
		if (_POOL.length != 0) return cast _POOL.pop().setTo(timeLine);
		return new ValEditorLayer(timeLine);
	}
	
	public var objectCollection(default, null):ArrayCollection<ValEditObject> = new ArrayCollection<ValEditObject>();
	
	override function set_name(value:String):String 
	{
		if (value == this._name) return value;
		super.set_name(value);
		LayerEvent.dispatch(this, LayerEvent.RENAMED, this);
		return this._name;
	}
	
	private var _displayObjects:StringIndexedMap<ValEditorObject> = new StringIndexedMap<ValEditorObject>();
	
	public function new(?timeLine:ValEditorTimeLine) 
	{
		if (timeLine == null) timeLine = ValEditorTimeLine.fromPool(0);
		super(timeLine);
	}
	
	override public function clear():Void 
	{
		this.objectCollection.removeAll();
		this._displayObjects.clear();
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function getAllVisibleObjects(?visibleObjects:Array<ValEditorObject>):Array<ValEditorObject>
	{
		if (visibleObjects == null) visibleObjects = new Array<ValEditorObject>();
		
		for (object in this._displayObjects)
		{
			if (object.getProperty(RegularPropertyName.VISIBLE) == true)
			{
				visibleObjects.push(object);
			}
		}
		
		return visibleObjects;
	}
	
	public function canAddObject():Bool
	{
		return this.timeLine.frameCurrent != null && (!this.timeLine.frameCurrent.tween || this.timeLine.frameCurrent.indexCurrent == this.timeLine.frameCurrent.indexStart);
	}
	
	override public function activate(object:ValEditObject):Void 
	{
		super.activate(object);
		
		var editorObject:ValEditorObject = cast object;
		
		if (object.isDisplayObject)
		{
			this._displayObjects.set(editorObject.id, editorObject);
			
			switch (object.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					this._container.addChild(cast editorObject.interactiveObject);
				
				#if starling
				case DisplayObjectType.STARLING :
					this._containerStarling.addChild(cast editorObject.interactiveObject);
				#end
				
				default :
					throw new Error("ValEditorLayer.add ::: unknown display object type " + object.displayObjectType);
			}
		}
		
		this.objectCollection.add(editorObject);
	}
	
	override public function deactivate(object:ValEditObject):Void 
	{
		super.deactivate(object);
		
		var editorObject:ValEditorObject = cast object;
		
		if (object.isDisplayObject)
		{
			this._displayObjects.remove(editorObject.id);
			
			switch (object.displayObjectType)
			{
				case DisplayObjectType.OPENFL :
					this._container.removeChild(cast editorObject.interactiveObject);
				
				#if starling
				case DisplayObjectType.STARLING :
					this._containerStarling.removeChild(cast editorObject.interactiveObject);
				#end
				
				default :
					throw new Error("ValEditorContainer.remove ::: unknown display object type " + object.displayObjectType);
			}
		}
		
		this.objectCollection.remove(editorObject);
	}
	
}
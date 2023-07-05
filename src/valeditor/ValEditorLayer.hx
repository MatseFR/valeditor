package valeditor;

import feathers.data.ArrayCollection;
import openfl.errors.Error;
import valedit.ObjectType;
import valedit.ValEditLayer;
import valedit.ValEditObject;
import valeditor.events.LayerEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorLayer extends ValEditLayer 
{
	public var objectCollection(default, null):ArrayCollection<ValEditObject> = new ArrayCollection<ValEditObject>();
	
	override function set_name(value:String):String 
	{
		if (value == this._name) return value;
		super.set_name(value);
		LayerEvent.dispatch(this, LayerEvent.RENAMED, this);
		return this._name;
	}
	
	public function new() 
	{
		super();
	}
	
	override public function add(object:ValEditObject):Void 
	{
		super.add(object);
		
		var editorObject:ValEditorObject = cast object;
		
		switch (object.objectType)
		{
			case ObjectType.DISPLAY_OPENFL :
				this._container.addChild(cast editorObject.interactiveObject);
			
			#if starling
			case ObjectType.DISPLAY_STARLING :
				this._containerStarling.addChild(cast editorObject.interactiveObject);
			#end
			
			case ObjectType.OTHER :
				// nothing here
			
			default :
				throw new Error("ValEditorLayer.add ::: unknown object type " + object.objectType);
		}
		
		this.objectCollection.add(editorObject);
	}
	
	override public function remove(object:ValEditObject):Void 
	{
		super.remove(object);
		
		var editorObject:ValEditorObject = cast object;
		
		switch (object.objectType)
		{
			case ObjectType.DISPLAY_OPENFL :
				this._container.removeChild(cast editorObject.interactiveObject);
			
			#if starling
			case ObjectType.DISPLAY_STARLING :
				this._containerStarling.removeChild(cast editorObject.interactiveObject);
			#end
			
			case ObjectType.OTHER :
				// nothing here
			
			default :
				throw new Error("ValEditorContainer.remove ::: unknown object type " + object.objectType);
		}
		
		this.objectCollection.remove(editorObject);
	}
	
}
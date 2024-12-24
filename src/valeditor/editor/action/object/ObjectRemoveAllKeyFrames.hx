package valeditor.editor.action.object;

import openfl.errors.Error;
import valedit.ExposedCollection;
import valeditor.ValEditorKeyFrame;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ObjectRemoveAllKeyFrames extends ValEditorAction 
{
	static private var _POOL:Array<ObjectRemoveAllKeyFrames> = new Array<ObjectRemoveAllKeyFrames>();
	
	static public function fromPool():ObjectRemoveAllKeyFrames
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectRemoveAllKeyFrames();
	}
	
	public var object:ValEditorObject;
	public var keyFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	public var collections:Array<ExposedCollection> = new Array<ExposedCollection>();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.object.unregisterAction(this);
		if (this.status == ValEditorActionStatus.DONE)
		{
			if (this.object.canBeDestroyed())
			{
				ValEditor.destroyObject(this.object);
			}
			for (collection in this.collections)
			{
				collection.pool();
			}
		}
		this.object = null;
		this.keyFrames.resize(0);
		this.collections.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(object:ValEditorObject):Void
	{
		this.object = object;
		
		this.object.registerAction(this);
		
		for (keyFrame in this.object.keyFrames)
		{
			this.keyFrames[this.keyFrames.length] = keyFrame;
			this.collections[this.collections.length] = this.object.getCollectionForKeyFrame(keyFrame);
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectRemoveAllKeyFrames already applied");
		}
		
		this.object.removeAllKeyFrames(false);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectRemoveAllKeyFrames already cancelled");
		}
		
		var count:Int = this.keyFrames.length;
		for (i in 0...count)
		{
			this.keyFrames[i].add(this.object, this.collections[i]);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
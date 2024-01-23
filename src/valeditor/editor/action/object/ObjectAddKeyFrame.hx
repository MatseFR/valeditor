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
class ObjectAddKeyFrame extends ValEditorAction 
{
	static private var _POOL:Array<ObjectAddKeyFrame> = new Array<ObjectAddKeyFrame>();
	
	static public function fromPool():ObjectAddKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectAddKeyFrame();
	}
	
	public var object:ValEditorObject;
	public var keyFrame:ValEditorKeyFrame;
	public var collection:ExposedCollection;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			//if (this.object.canBeDestroyed())
			//{
				//ValEditor.destroyObject(this.object);
			//}
			if (this.collection != null)
			{
				this.collection.pool();
			}
		}
		this.object = null;
		this.keyFrame = null;
		this.collection = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(object:ValEditorObject, keyFrame:ValEditorKeyFrame, ?collection:ExposedCollection):Void
	{
		this.object = object;
		this.keyFrame = keyFrame;
		this.collection = collection;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectAddKeyFrame already applied");
		}
		
		this.keyFrame.add(this.object, this.collection);
		if (this.collection == null)
		{
			this.collection = this.object.getCollectionForKeyFrame(this.keyFrame);
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectAddKeyFrame already cancelled");
		}
		
		this.keyFrame.remove(this.object, false);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
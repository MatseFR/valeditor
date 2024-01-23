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
class ObjectRemoveKeyFrame extends ValEditorAction 
{
	static private var _POOL:Array<ObjectRemoveKeyFrame> = new Array<ObjectRemoveKeyFrame>();
	
	static public function fromPool():ObjectRemoveKeyFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ObjectRemoveKeyFrame();
	}
	
	public var object:ValEditorObject;
	public var keyFrame:ValEditorKeyFrame;
	public var collection:ExposedCollection;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.status == ValEditorActionStatus.DONE)
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
		if (collection == null)
		{
			this.collection = this.object.getCollectionForKeyFrame(this.keyFrame);
		}
		else
		{
			this.collection = collection;
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ObjectRemoveKeyFrame already applied");
		}
		
		this.keyFrame.remove(this.object, false);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ObjectRemoveKeyFrame already cancelled");
		}
		
		this.keyFrame.add(this.object, this.collection);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
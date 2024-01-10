package valeditor.editor.action.keyframe;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class KeyFrameCopyObjectsFrom extends ValEditorAction 
{
	static private var _POOL:Array<KeyFrameCopyObjectsFrom> = new Array<KeyFrameCopyObjectsFrom>();
	
	static public function fromPool():KeyFrameCopyObjectsFrom
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new KeyFrameCopyObjectsFrom();
	}
	
	public var keyFrame:ValEditorKeyFrame;
	public var fromKeyFrame:ValEditorKeyFrame;
	public var objects:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	private var _isFirstApply:Bool = true;

	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.keyFrame = null;
		this.fromKeyFrame = null;
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			for (object in objects)
			{
				if (object.canBeDestroyed())
				{
					ValEditor.destroyObject(object);
				}
			}
		}
		this.objects.resize(0);
		
		this._isFirstApply = true;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(keyFrame:ValEditorKeyFrame, fromKeyFrame:ValEditorKeyFrame):Void
	{
		this.keyFrame = keyFrame;
		this.fromKeyFrame = fromKeyFrame;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("KeyFrameCopyObjectsFrom already applied");
		}
		
		if (this._isFirstApply)
		{
			this._isFirstApply = false;
			var previousObjectCount:Int = this.keyFrame.objects.length;
			this.keyFrame.copyObjectsFrom(this.fromKeyFrame);
			var objectCount:Int = this.keyFrame.objects.length;
			for (i in previousObjectCount...objectCount)
			{
				this.objects.push(cast this.keyFrame.objects[i]);
			}
		}
		else
		{
			for (object in this.objects)
			{
				this.keyFrame.add(object);
			}
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("KeyFrameCopyObjectsFrom already cancelled");
		}
		
		for (object in this.objects)
		{
			this.keyFrame.remove(object);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
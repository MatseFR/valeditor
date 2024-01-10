package valeditor.editor.action.keyframe;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class KeyFrameCreate extends ValEditorAction 
{
	static private var _POOL:Array<KeyFrameCreate> = new Array<KeyFrameCreate>();
	
	static public function fromPool():KeyFrameCreate
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new KeyFrameCreate();
	}
	
	public var keyFrame:ValEditorKeyFrame;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			this.keyFrame.pool();
		}
		this.keyFrame = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(keyFrame:ValEditorKeyFrame):Void
	{
		this.keyFrame = keyFrame;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("KeyFrameCreate already applied");
		}
		
		// do nothing
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("KeyFrameCreate already applied");
		}
		
		// do nothing
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
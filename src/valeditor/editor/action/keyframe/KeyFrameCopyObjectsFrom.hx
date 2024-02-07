package valeditor.editor.action.keyframe;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class KeyFrameCopyObjectsFrom extends MultiAction 
{
	static private var _POOL:Array<KeyFrameCopyObjectsFrom> = new Array<KeyFrameCopyObjectsFrom>();
	
	static public function fromPool():KeyFrameCopyObjectsFrom
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new KeyFrameCopyObjectsFrom();
	}
	
	public var keyFrame:ValEditorKeyFrame;
	public var fromKeyFrame:ValEditorKeyFrame;
	
	override function get_numActions():Int  { return super.get_numActions() + 1; }
	
	private var _isFirstApply:Bool = true;

	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		this.keyFrame = null;
		this.fromKeyFrame = null;
		
		this._isFirstApply = true;
		
		super.clear();
	}
	
	override public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(keyFrame:ValEditorKeyFrame, fromKeyFrame:ValEditorKeyFrame):Void
	{
		this.keyFrame = keyFrame;
		this.fromKeyFrame = fromKeyFrame;
	}
	
	override public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("KeyFrameCopyObjectsFrom already applied");
		}
		
		if (this._isFirstApply)
		{
			this._isFirstApply = false;
			this.keyFrame.copyObjectsFrom(this.fromKeyFrame, this);
			
			this.status = ValEditorActionStatus.DONE;
		}
		else
		{
			super.apply();
		}
	}
	
	override public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("KeyFrameCopyObjectsFrom already cancelled");
		}
		
		super.cancel();
	}
	
}
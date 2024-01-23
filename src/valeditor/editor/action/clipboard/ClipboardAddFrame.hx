package valeditor.editor.action.clipboard;

import openfl.errors.Error;
import valeditor.ValEditorKeyFrame;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.clipboard.ValEditorClipboard;

/**
 * ...
 * @author Matse
 */
class ClipboardAddFrame extends ValEditorAction 
{
	static private var _POOL:Array<ClipboardAddFrame> = new Array<ClipboardAddFrame>();
	
	static public function fromPool():ClipboardAddFrame
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClipboardAddFrame();
	}
	
	public var clipboard:ValEditorClipboard;
	public var keyFrames:Array<ValEditorKeyFrame> = new Array<ValEditorKeyFrame>();
	public var numFrames(get, never):Int;
	
	private function get_numFrames():Int { return this.keyFrames.length; }
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.clipboard = null;
		this.keyFrames.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(clipboard:ValEditorClipboard, ?keyFrames:Array<ValEditorKeyFrame>):Void
	{
		this.clipboard = clipboard;
		if (keyFrames != null)
		{
			for (frame in keyFrames)
			{
				this.keyFrames.push(frame);
			}
		}
	}
	
	public function addFrame(keyFrame:ValEditorKeyFrame):Void
	{
		this.keyFrames.push(keyFrame);
	}
	
	public function addFrames(keyFrames:Array<ValEditorKeyFrame>):Void
	{
		for (frame in keyFrames)
		{
			this.keyFrames.push(frame);
		}
	}
	
	public function hasFrame(keyFrame:ValEditorKeyFrame):Bool
	{
		return this.keyFrames.indexOf(keyFrame) != -1;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ClipboardAddFrame already applied");
		}
		
		this.clipboard.addFrames(this.keyFrames);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ClipoardAddFrame already cancelled");
		}
		
		this.clipboard.removeFrames(this.keyFrames);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
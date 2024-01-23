package valeditor.editor.action.clipboard;

import openfl.errors.Error;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.clipboard.ValEditorClipboard;

/**
 * ...
 * @author Matse
 */
class ClipboardClear extends ValEditorAction 
{
	static private var _POOL:Array<ClipboardClear> = new Array<ClipboardClear>();
	
	static public function fromPool():ClipboardClear
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClipboardClear();
	}
	
	public var backupClipboard:ValEditorClipboard = new ValEditorClipboard();
	public var clipboard:ValEditorClipboard;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.backupClipboard.clear();
		this.clipboard = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(clipboard:ValEditorClipboard):Void
	{
		this.clipboard = clipboard;
		this.backupClipboard.copyFrom(this.clipboard);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ClipboardClear already applied");
		}
		
		this.clipboard.clear();
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ClipboardClear already cancelled");
		}
		
		this.clipboard.copyFrom(this.backupClipboard);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
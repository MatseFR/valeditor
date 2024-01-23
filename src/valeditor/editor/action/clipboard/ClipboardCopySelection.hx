package valeditor.editor.action.clipboard;

import openfl.errors.Error;
import valeditor.editor.Selection;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.clipboard.ValEditorClipboard;

/**
 * ...
 * @author Matse
 */
class ClipboardCopySelection extends ValEditorAction 
{
	static private var _POOL:Array<ClipboardCopySelection> = new Array<ClipboardCopySelection>();
	
	static public function fromPool():ClipboardCopySelection
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClipboardCopySelection();
	}
	
	public var clipboard:ValEditorClipboard;
	public var selection:Selection;
	public var backupClipboard:ValEditorClipboard = new ValEditorClipboard();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.clipboard = null;
		this.selection = null;
		this.backupClipboard.clear();
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(clipboard:ValEditorClipboard, selection:Selection):Void
	{
		this.clipboard = clipboard;
		this.selection = selection;
		this.backupClipboard.copyFrom(this.clipboard);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ClipboardCopySelection already applied");
		}
		
		this.selection.copyToClipboard(this.clipboard);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ClipboardCopySelection already cancelled");
		}
		
		this.clipboard.clear();
		this.clipboard.copyFrom(this.backupClipboard);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.clipboard;

import openfl.errors.Error;
import valeditor.ValEditorTemplate;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.clipboard.ValEditorClipboard;

/**
 * ...
 * @author Matse
 */
class ClipboardAddTemplate extends ValEditorAction 
{
	static private var _POOL:Array<ClipboardAddTemplate> = new Array<ClipboardAddTemplate>();
	
	static public function fromPool():ClipboardAddTemplate
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClipboardAddTemplate();
	}
	
	public var clipboard:ValEditorClipboard;
	public var numTemplates(get, never):Int;
	public var templates:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	
	private function get_numTemplates():Int { return this.templates.length; }
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.clipboard = null;
		this.templates.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(clipboard:ValEditorClipboard, ?templates:Array<ValEditorTemplate>):Void
	{
		this.clipboard = clipboard;
		if (templates != null)
		{
			for (template in templates)
			{
				this.templates.push(template);
			}
		}
	}
	
	public function addTemplate(template:ValEditorTemplate):Void
	{
		this.templates.push(template);
	}
	
	public function addTemplates(templates:Array<ValEditorTemplate>):Void
	{
		for (template in templates)
		{
			this.templates.push(template);
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ClipboardAddTemplate already applied");
		}
		
		this.clipboard.addTemplates(this.templates);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ClipboardAddTemplate already cancelled");
		}
		
		this.clipboard.removeTemplates(this.templates);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
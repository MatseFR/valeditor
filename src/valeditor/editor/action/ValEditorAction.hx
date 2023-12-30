package valeditor.editor.action;

/**
 * ...
 * @author Matse
 */
abstract class ValEditorAction
{
	public var name:String;
	public var status:ValEditorActionStatus = ValEditorActionStatus.UNDONE;
	
	public function clear():Void
	{
		this.status = ValEditorActionStatus.UNDONE;
	}
	
	abstract public function pool():Void;
	abstract public function apply():Void;
	abstract public function cancel():Void;
}
package valeditor.editor.action;
import openfl.errors.Error;

/**
 * ...
 * @author Matse
 */
class MultiAction extends ValEditorAction 
{
	static private var _POOL:Array<MultiAction> = new Array<MultiAction>();
	
	static public function fromPool():MultiAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new MultiAction();
	}
	
	public var actions:Array<ValEditorAction> = new Array<ValEditorAction>();

	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		for (action in this.actions)
		{
			action.pool();
		}
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function add(action:ValEditorAction):Void
	{
		this.actions.push(action);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("MultiAction already applied");
		}
		
		for (action in this.actions)
		{
			action.apply();
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("MultiAction already cancelled");
		}
		
		for (action in this.actions)
		{
			action.cancel();
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
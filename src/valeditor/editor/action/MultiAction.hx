package valeditor.editor.action;
import openfl.errors.Error;
import valedit.utils.ReverseIterator;

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
	public var postActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	public var reversePostActionsOnCancel:Bool = true;

	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		for (action in this.actions)
		{
			action.pool();
		}
		this.actions.resize(0);
		
		for (action in this.postActions)
		{
			action.pool();
		}
		this.postActions.resize(0);
		
		this.reversePostActionsOnCancel = true;
		
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
	
	public function addPost(action:ValEditorAction):Void
	{
		this.postActions.push(action);
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
		
		for (action in this.postActions)
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
		
		if (this.reversePostActionsOnCancel)
		{
			for (i in new ReverseIterator(this.postActions.length - 1, 0))
			{
				this.postActions[i].cancel();
			}
		}
		else
		{
			for (action in this.postActions)
			{
				action.cancel();
			}
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
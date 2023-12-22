package valeditor.editor.action.value;
import openfl.errors.Error;
import valedit.value.base.ExposedValue;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ValueChangeAction extends ValEditorAction
{
	static private var _POOL:Array<ValueChangeAction> = new Array<ValueChangeAction>();
	
	static public function fromPool():ValueChangeAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValueChangeAction();
	}
	
	public var exposedValue:ExposedValue;
	public var newValue:Dynamic;
	public var previousValue:Dynamic;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.exposedValue = null;
		this.newValue = null;
		this.previousValue = null;
		
		super.clear();
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(exposedValue:ExposedValue, newValue:Dynamic):Void
	{
		this.exposedValue = exposedValue;
		this.newValue = newValue;
		this.previousValue = this.exposedValue.value;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ValueChangeAction already applied");
		}
		this.exposedValue.value = this.newValue;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ValueChangeAction already cancelled");
		}
		this.exposedValue.value = this.previousValue;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.value;
import openfl.errors.Error;
import valedit.value.base.ExposedValue;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ValueChange extends ValEditorAction
{
	static private var _POOL:Array<ValueChange> = new Array<ValueChange>();
	
	static public function fromPool():ValueChange
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValueChange();
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
	
	public function setup(exposedValue:ExposedValue, newValue:Dynamic, ?previousValue:Dynamic):Void
	{
		this.exposedValue = exposedValue;
		this.newValue = newValue;
		if (previousValue == null)
		{
			this.previousValue = this.exposedValue.value;
		}
		else
		{
			this.previousValue = previousValue;
		}
		
		//// DEBUG
		//if (this.newValue == this.previousValue)
		//{
			//throw new Error("ValueChange ::: new value is the same as previous value");
		//}
		////\DEBUG
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ValueChange already applied");
		}
		
		this.exposedValue.value = this.newValue;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ValueChange already cancelled");
		}
		
		this.exposedValue.value = this.previousValue;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
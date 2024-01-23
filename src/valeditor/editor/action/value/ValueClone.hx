package valeditor.editor.action.value;

import openfl.errors.Error;
import valedit.value.base.ExposedValue;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ValueClone extends ValEditorAction 
{
	static private var _POOL:Array<ValueClone> = new Array<ValueClone>();
	
	static public function fromPool():ValueClone
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValueClone();
	}
	
	public var fromValue:ExposedValue;
	public var toValue:ExposedValue;
	public var backupValue:ExposedValue;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.fromValue = null;
		this.toValue = null;
		this.backupValue.pool();
		this.backupValue = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(fromValue:ExposedValue, toValue:ExposedValue):Void
	{
		this.fromValue = fromValue;
		this.toValue = toValue;
		this.backupValue = this.toValue.clone(true);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ValueClone already applied");
		}
		
		this.fromValue.cloneValue(this.toValue);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ValueClone already cancelled");
		}
		
		this.backupValue.cloneValue(this.toValue);
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
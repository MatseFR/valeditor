package valeditor.editor.action.value;

import openfl.errors.Error;
import valedit.value.base.ExposedValue;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ValueUIUpdate extends ValEditorAction 
{
	static private var _POOL:Array<ValueUIUpdate> = new Array<ValueUIUpdate>();
	
	static public function fromPool():ValueUIUpdate
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValueUIUpdate();
	}
	
	public var value:ExposedValue;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.value = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(value:ExposedValue):Void
	{
		this.value = value;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ValueUIUpdate already applied");
		}
		
		if (this.value.uiControl != null)
		{
			this.value.uiControl.updateExposedValue();
		}
		//else
		//{
			//throw new Error("uiControl is null");
		//}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ValueUIUpdate already cancelled");
		}
		
		if (this.value.uiControl != null)
		{
			this.value.uiControl.updateExposedValue();
		}
		//else
		//{
			//throw new Error("uiControl is null");
		//}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
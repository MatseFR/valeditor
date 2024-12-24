package valeditor.editor.action.value;

import openfl.errors.Error;
import valedit.value.ExposedObjectReference;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.action.ValEditorActionStatus;

/**
 * ...
 * @author Matse
 */
@:access(valedit.value.ExposedObjectReference)
class ReferenceRangeChange extends ValEditorAction 
{
	static private var _POOL:Array<ReferenceRangeChange> = new Array<ReferenceRangeChange>();
	
	static public function fromPool():ReferenceRangeChange
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ReferenceRangeChange();
	}
	
	public var exposedObjectReference:ExposedObjectReference;
	public var newRange:String;
	public var previousRange:Dynamic;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.exposedObjectReference = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(exposedObjectReference:ExposedObjectReference, newRange:String, ?previousRange:String):Void
	{
		this.exposedObjectReference = exposedObjectReference;
		this.newRange = newRange;
		if (previousRange == null)
		{
			this.previousRange = this.exposedObjectReference._referenceRange;
		}
		else
		{
			this.previousRange = previousRange;
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ReferenceRangeChange already applied");
		}
		
		this.exposedObjectReference._referenceRange = newRange;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ReferenceRangeChange already cancelled");
		}
		
		this.exposedObjectReference._referenceRange = previousRange;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
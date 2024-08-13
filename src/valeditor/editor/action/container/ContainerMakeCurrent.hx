package valeditor.editor.action.container;

import openfl.errors.Error;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;
import valeditor.editor.action.selection.SelectionClear;

/**
 * ...
 * @author Matse
 */
class ContainerMakeCurrent extends ValEditorAction 
{
	static private var _POOL:Array<ContainerMakeCurrent> = new Array<ContainerMakeCurrent>();
	
	static public function fromPool():ContainerMakeCurrent
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ContainerMakeCurrent();
	}
	
	public var container:ValEditorObject;
	
	private var _restoreContainers:Array<ValEditorObject> = new Array<ValEditorObject>();
	private var _selectionClear:SelectionClear = SelectionClear.fromPool();
	private var _isFirstApply:Bool = true;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.container = null;
		this._restoreContainers.resize(0);
		this._selectionClear.clear();
		this._isFirstApply = true;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(container:ValEditorObject):Void
	{
		this.container = container;
		this._selectionClear.setup(ValEditor.selection);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ContainerMakeCurrent already applied");
		}
		
		if (this._isFirstApply)
		{
			var index:Int = ValEditor.openedContainers.indexOf(this.container) + 1;
			var count:Int = ValEditor.openedContainers.length;
			for (i in index...count)
			{
				this._restoreContainers.push(ValEditor.openedContainers[i]);
			}
			this._isFirstApply = false;
		}
		
		this._selectionClear.apply();
		ValEditor.makeContainerCurrent(this.container);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ContainerMakeCurrent already cancelled");
		}
		
		for (container in this._restoreContainers)
		{
			ValEditor.openContainer(container);
		}
		this._selectionClear.cancel();
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
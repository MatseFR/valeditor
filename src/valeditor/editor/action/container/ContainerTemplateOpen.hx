package valeditor.editor.action.container;

import openfl.errors.Error;
import valeditor.IValEditorContainer;
import valeditor.ValEditorObject;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ContainerTemplateOpen extends ValEditorAction 
{
	static private var _POOL:Array<ContainerTemplateOpen> = new Array<ContainerTemplateOpen>();
	
	static public function fromPool():ContainerTemplateOpen
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ContainerTemplateOpen();
	}
	
	public var container:ValEditorObject;
	private var _restoreOpenContainers:Array<ValEditorObject> = new Array<ValEditorObject>();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.container = null;
		this._restoreOpenContainers.resize(0);
		
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
		var count:Int = ValEditor.openedContainers.length;
		for (i in 1...count)
		{
			this._restoreOpenContainers.push(ValEditor.openedContainers[i]);
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ContainerTemplateOpen already applied");
		}
		
		ValEditor.openContainerTemplate(this.container);
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ContainerTemplateOpen already cancelled");
		}
		
		ValEditor.closeContainer();
		for (container in this._restoreOpenContainers)
		{
			ValEditor.openContainer(container);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
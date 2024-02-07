package valeditor.editor.action.container;

import openfl.errors.Error;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ContainerSetCurrentLayer extends ValEditorAction 
{
	static private var _POOL:Array<ContainerSetCurrentLayer> = new Array<ContainerSetCurrentLayer>();
	
	static public function fromPool():ContainerSetCurrentLayer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ContainerSetCurrentLayer();
	}
	
	public var container:ValEditorContainer;
	public var layer:ValEditorLayer;
	public var previousLayer:ValEditorLayer;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.container = null;
		this.layer = null;
		this.previousLayer = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(container:ValEditorContainer, layer:ValEditorLayer):Void
	{
		this.container = container;
		this.layer = layer;
		this.previousLayer = cast this.container.currentLayer;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("ContainerSetCurrentLayer already applied");
		}
		
		this.container.currentLayer = this.layer;
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("ContainerSetCurrentLayer already cancelled");
		}
		
		this.container.currentLayer = this.previousLayer;
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.layer;

import openfl.errors.Error;
import valeditor.ValEditorLayer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class LayerIndexUp extends ValEditorAction 
{
	static private var _POOL:Array<LayerIndexUp> = new Array<LayerIndexUp>();
	
	static public function fromPool():LayerIndexUp
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerIndexUp();
	}
	
	public var container:IValEditorTimeLineContainer;
	public var layers:Array<ValEditorLayer>;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.container = null;
		this.layers = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(container:IValEditorTimeLineContainer, layers:Array<ValEditorLayer>):Void
	{
		this.container = container;
		this.layers = layers;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerIndexUp already applied");
		}
		
		for (layer in this.layers)
		{
			this.container.layerIndexUp(layer);
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerIndexUp already cancelled");
		}
		
		for (layer in this.layers)
		{
			this.container.layerIndexDown(layer);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
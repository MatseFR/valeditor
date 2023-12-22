package valeditor.editor.action.layer;

import openfl.errors.Error;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class LayerIndexUpAction extends ValEditorAction 
{
	static private var _POOL:Array<LayerIndexUpAction> = new Array<LayerIndexUpAction>();
	
	static public function fromPool():LayerIndexUpAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerIndexUpAction();
	}
	
	public var container:ValEditorContainer;
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
	
	public function setup(container:ValEditorContainer, layers:Array<ValEditorLayer>):Void
	{
		this.container = container;
		this.layers = layers;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerIndexUpAction already applied");
		}
		
		var index:Int;
		for (layer in this.layers)
		{
			index = this.container.getLayerIndex(layer);
			this.container.removeLayerAt(index);
			this.container.addLayerAt(layer, index - 1);
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerIndexUpAction already cancelled");
		}
		
		var index:Int;
		for (layer in this.layers)
		{
			index = this.container.getLayerIndex(layer);
			this.container.removeLayerAt(index);
			this.container.addLayerAt(layer, index + 1);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.layer;

import openfl.errors.Error;
import valeditor.ValEditorLayer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class LayerVisibleAction extends ValEditorAction 
{
	static private var _POOL:Array<LayerVisibleAction> = new Array<LayerVisibleAction>();
	
	static public function fromPool():LayerVisibleAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerVisibleAction();
	}
	
	public var layers:Array<ValEditorLayer>;
	public var visibilities:Array<Bool>;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.layers = null;
		this.visibilities = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(layers:Array<ValEditorLayer>, visibilities:Array<Bool>):Void
	{
		this.layers = layers;
		this.visibilities = visibilities;
	}
	
	public function addLayer(layer:ValEditorLayer, visible:Bool):Void
	{
		if (this.layers == null) this.layers = new Array<ValEditorLayer>();
		if (this.visibilities == null) this.visibilities = new Array<Bool>();
		
		this.layers.push(layer);
		this.visibilities.push(visible);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerVisibleAction already applied");
		}
		
		var count:Int = this.layers.length;
		for (i in 0...count)
		{
			this.layers[i].visible = this.visibilities[i];
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerVisibleAction already cancelled");
		}
		
		var count:Int = this.layers.length;
		for (i in 0...count)
		{
			this.layers[i].visible = !this.visibilities[i];
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
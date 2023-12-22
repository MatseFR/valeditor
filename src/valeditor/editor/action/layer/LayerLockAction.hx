package valeditor.editor.action.layer;

import openfl.errors.Error;
import valeditor.ValEditorLayer;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class LayerLockAction extends ValEditorAction 
{
	static private var _POOL:Array<LayerLockAction> = new Array<LayerLockAction>();
	
	static public function fromPool():LayerLockAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerLockAction();
	}
	
	public var layers:Array<ValEditorLayer>;
	public var lockValues:Array<Bool>;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		this.layers = null;
		this.lockValues = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(layers:Array<ValEditorLayer>, lockValues:Array<Bool>):Void
	{
		this.layers = layers;
		this.lockValues = lockValues;
	}
	
	public function addLayer(layer:ValEditorLayer, lock:Bool):Void
	{
		if (this.layers == null) this.layers = new Array<ValEditorLayer>();
		if (this.lockValues == null) this.lockValues = new Array<Bool>();
		
		this.layers.push(layer);
		this.lockValues.push(lock);
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerLockAction already applied");
		}
		
		var count:Int = this.layers.length;
		for (i in 0...count)
		{
			this.layers[i].locked = this.lockValues[i];
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerLockAction already cancelled");
		}
		
		var count:Int = this.layers.length;
		for (i in 0...count)
		{
			this.layers[i].locked = !this.lockValues[i];
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
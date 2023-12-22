package valeditor.editor.action.layer;
import openfl.errors.Error;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.utils.ArraySort;

/**
 * ...
 * @author Matse
 */
class LayerRemoveAction extends ValEditorAction 
{
	static private var _POOL:Array<LayerRemoveAction> = new Array<LayerRemoveAction>();
	
	static public function fromPool():LayerRemoveAction
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerRemoveAction();
	}
	
	public var container:ValEditorContainer;
	public var layers:Array<ValEditorLayer>;
	public var layerIndices:Array<Int> = new Array<Int>();
	
	public function new() 
	{
		
	}
	
	override public function clear():Void 
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			for (layer in this.layers)
			{
				layer.pool();
			}
		}
		this.container = null;
		this.layers = null;
		this.layerIndices.resize(0);
		
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
			throw new Error("LayerRemoveAction already applied");
		}
		
		if (this.layerIndices.length == 0)
		{
			for (layer in this.layers)
			{
				this.layerIndices.push(this.container.getLayerIndex(layer));
			}
			this.layerIndices.sort(ArraySort.int_reverse);
			this.layers.resize(0);
			for (index in this.layerIndices)
			{
				this.layers[this.layers.length] = cast this.container.getLayerAt(index);
			}
		}
		for (index in this.layerIndices)
		{
			this.container.removeLayerAt(index);
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerRemoveAction already cancelled");
		}
		var count:Int = this.layers.length;
		for (i in 0...count)
		{
			this.container.addLayerAt(this.layers[i], this.layerIndices[i]);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
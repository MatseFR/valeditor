package valeditor.editor.action.layer;
import openfl.errors.Error;
import valedit.utils.ReverseIterator;
import valeditor.container.ITimeLineContainerEditable;
import valeditor.container.ITimeLineLayerEditable;

/**
 * ...
 * @author Matse
 */
class LayerAdd extends ValEditorAction 
{
	static private var _POOL:Array<LayerAdd> = new Array<LayerAdd>();
	
	static public function fromPool():LayerAdd
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerAdd();
	}
	
	public var container:ITimeLineContainerEditable;
	public var layers:Array<ITimeLineLayerEditable>;
	public var layerIndex:Int = -1;
	
	public function new() 
	{
		
	}
	
	override public function clear():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			for (layer in this.layers)
			{
				layer.pool();
			}
		}
		this.container = null;
		this.layers = null;
		this.layerIndex = -1;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(container:ITimeLineContainerEditable, layers:Array<ITimeLineLayerEditable>, layerIndex:Int):Void
	{
		this.container = container;
		this.layers = layers;
		this.layerIndex = layerIndex;
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerAdd already applied");
		}
		
		for (i in new ReverseIterator(this.layers.length - 1, 0))
		{
			this.container.addLayerAt(this.layers[i], this.layerIndex);
		}
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerAdd already cancelled");
		}
		for (layer in this.layers)
		{
			this.container.removeLayer(layer);
		}
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
package valeditor.editor.action.layer;
import openfl.errors.Error;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectUnselect;
import valeditor.utils.ArraySort;

/**
 * ...
 * @author Matse
 */
class LayerRemove extends ValEditorAction 
{
	static private var _POOL:Array<LayerRemove> = new Array<LayerRemove>();
	
	static public function fromPool():LayerRemove
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new LayerRemove();
	}
	
	public var container:ValEditorContainer;
	public var layers:Array<ValEditorLayer>;
	public var layerIndices:Array<Int> = new Array<Int>();
	
	private var _objectUnselect:ObjectUnselect = new ObjectUnselect();
	
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
		
		this._objectUnselect.clear();
		
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
		
		this._objectUnselect.setup();
		for (layer in this.layers)
		{
			for (object in layer.timeLine.frameCurrent.objects)
			{
				if (ValEditor.selection.hasObject(cast object))
				{
					this._objectUnselect.addObject(cast object);
				}
			}
		}
	}
	
	public function apply():Void
	{
		if (this.status == ValEditorActionStatus.DONE)
		{
			throw new Error("LayerRemove already applied");
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
		
		this._objectUnselect.apply();
		
		this.status = ValEditorActionStatus.DONE;
	}
	
	public function cancel():Void
	{
		if (this.status == ValEditorActionStatus.UNDONE)
		{
			throw new Error("LayerRemove already cancelled");
		}
		
		var count:Int = this.layers.length;
		for (i in 0...count)
		{
			this.container.addLayerAt(this.layers[i], this.layerIndices[i]);
		}
		
		this._objectUnselect.cancel();
		
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
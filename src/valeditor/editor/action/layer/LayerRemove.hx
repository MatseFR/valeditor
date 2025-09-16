package valeditor.editor.action.layer;
import openfl.errors.Error;
import valeditor.container.ITimeLineContainerEditable;
import valeditor.container.ITimeLineLayerEditable;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.object.ObjectRemoveKeyFrame;
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
	
	public var container:ITimeLineContainerEditable;
	public var layers:Array<ITimeLineLayerEditable>;
	public var layerIndices:Array<Int> = new Array<Int>();
	
	private var _action:MultiAction = MultiAction.fromPool();
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
		
		this._action.clear();
		this._objectUnselect.clear();
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function setup(container:ITimeLineContainerEditable, layers:Array<ITimeLineLayerEditable>):Void
	{
		this.container = container;
		this.layers = layers;
		
		// unselect objects
		this._objectUnselect.setup();
		for (layer in this.layers)
		{
			if (layer.timeLine.frameCurrent == null) continue;
			for (object in layer.timeLine.frameCurrent.objects)
			{
				if (ValEditor.selection.hasObject(object))
				{
					this._objectUnselect.addObject(object);
				}
			}
		}
		
		this._action.autoApply = false;
		// remove objects
		var objectRemoveKeyFrame:ObjectRemoveKeyFrame;
		for (layer in this.layers)
		{
			for (keyFrame in layer.timeLine.keyFrames)
			{
				for (object in keyFrame.objects)
				{
					objectRemoveKeyFrame = ObjectRemoveKeyFrame.fromPool();
					objectRemoveKeyFrame.setup(object, keyFrame);
					this._action.add(objectRemoveKeyFrame);
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
		
		this._objectUnselect.apply();
		this._action.apply();
		
		if (this.layerIndices.length == 0)
		{
			for (layer in this.layers)
			{
				this.layerIndices.push(this.container.getLayerIndex(layer));
			}
			#if SWC
			this.layerIndices.sort(integer_reverse);
			#else
			this.layerIndices.sort(ArraySort.integer_reverse);
			#end
			this.layers.resize(0);
			for (index in this.layerIndices)
			{
				this.layers[this.layers.length] = this.container.getLayerAt(index);
			}
		}
		for (index in this.layerIndices)
		{
			this.container.removeLayerAt(index);
		}
		
		this.status = ValEditorActionStatus.DONE;
	}
	
	#if SWC
	private function integer_reverse(a:Int, b:Int):Int
	{
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	#end
	
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
		
		this._action.cancel();
		this._objectUnselect.cancel();
		
		this.status = ValEditorActionStatus.UNDONE;
	}
	
}
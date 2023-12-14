package valeditor.ui.feathers.renderers;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import valeditor.ValEditorLayer;
import valeditor.ui.feathers.variant.CheckVariant;

/**
 * ...
 * @author Matse
 */
@:styleContext
class LayerItemRenderer extends LayoutGroupItemRenderer 
{
	static private var _POOL:Array<LayerItemRenderer> = new Array<LayerItemRenderer>();
	
	static public function fromPool(layer:ValEditorLayer = null):LayerItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(layer);
		return new LayerItemRenderer(layer);
	}
	
	public var layer(get, set):ValEditorLayer;
	
	private var _layer:ValEditorLayer;
	private function get_layer():ValEditorLayer { return this._layer; }
	private function set_layer(value:ValEditorLayer):ValEditorLayer
	{
		if (value != null && this._initialized)
		{
			this._name.text = value.name;
			this._visibleToggle.selected = value.visible;
		}
		return this._layer = value;
	}
	
	private var _name:Label;
	private var _visibleToggle:Check;
	private var _lockToggle:Check;
	
	public function new(layer:ValEditorLayer) 
	{
		super();
		this.layer = layer;
		initializeNow();
		if (this.layer != null)
		{
			this._name.text = layer.name;
			this._visibleToggle.selected = layer.visible;
			this._lockToggle.selected = layer.locked;
		}
	}
	
	public function clear():Void
	{
		this.layer = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.MINIMAL;
		hLayout.paddingRight = Padding.MINIMAL;
		this.layout = hLayout;
		
		this._name = new Label();
		this._name.layoutData = new HorizontalLayoutData(100);
		addChild(this._name);
		
		this._visibleToggle = new Check(null, true);
		this._visibleToggle.variant = CheckVariant.LAYER;
		this._visibleToggle.addEventListener(Event.CHANGE, onVisibleToggle);
		addChild(this._visibleToggle);
		
		this._lockToggle = new Check(null, false);
		this._lockToggle.variant = CheckVariant.LAYER;
		this._lockToggle.addEventListener(Event.CHANGE, onLockToggle);
		addChild(this._lockToggle);
	}
	
	private function setTo(layer:ValEditorLayer):LayerItemRenderer
	{
		this.layer = layer;
		return this;
	}
	
	private function onLockToggle(evt:Event):Void
	{
		if (this._layer == null) return;
		this._layer.locked = this._lockToggle.selected;
	}
	
	private function onVisibleToggle(evt:Event):Void
	{
		if (this._layer == null) return;
		this._layer.visible = this._visibleToggle.selected;
	}
	
}
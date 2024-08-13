package valeditor.ui.feathers.renderers;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import valeditor.ValEditorLayer;
import valeditor.editor.action.layer.LayerLock;
import valeditor.editor.action.layer.LayerVisible;
import valeditor.events.LayerEvent;
import valeditor.ui.feathers.theme.variant.CheckVariant;

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
		if (this._layer != value)
		{
			if (this._layer != null)
			{
				this._layer.removeEventListener(LayerEvent.LOCK_CHANGE, onLayerLockChange);
				this._layer.removeEventListener(LayerEvent.VISIBLE_CHANGE, onLayerVisibilityChange);
			}
			if (value != null)
			{
				value.addEventListener(LayerEvent.LOCK_CHANGE, onLayerLockChange);
				value.addEventListener(LayerEvent.VISIBLE_CHANGE, onLayerVisibilityChange);
			}
		}
		
		if (value != null && this._initialized)
		{
			this._name.text = value.name;
			this._lockToggle.selected = value.locked;
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
		this._visibleToggle.addEventListener(TriggerEvent.TRIGGER, onVisibleToggle);
		addChild(this._visibleToggle);
		
		this._lockToggle = new Check(null, false);
		this._lockToggle.variant = CheckVariant.LAYER;
		this._lockToggle.addEventListener(TriggerEvent.TRIGGER, onLockToggle);
		addChild(this._lockToggle);
	}
	
	private function setTo(layer:ValEditorLayer):LayerItemRenderer
	{
		this.layer = layer;
		return this;
	}
	
	private function onLayerLockChange(evt:LayerEvent):Void
	{
		this._lockToggle.selected = this._layer.locked;
	}
	
	private function onLayerVisibilityChange(evt:LayerEvent):Void
	{
		this._visibleToggle.selected = this._layer.visible;
	}
	
	private function onLockToggle(evt:Event):Void
	{
		if (this._layer == null) return;
		
		var action:LayerLock = LayerLock.fromPool();
		action.addLayer(this._layer, this._lockToggle.selected);
		ValEditor.actionStack.add(action);
	}
	
	private function onVisibleToggle(evt:Event):Void
	{
		if (this._layer == null) return;
		
		var action:LayerVisible = LayerVisible.fromPool();
		action.addLayer(this._layer, this._visibleToggle.selected);
		ValEditor.actionStack.add(action);
	}
	
}
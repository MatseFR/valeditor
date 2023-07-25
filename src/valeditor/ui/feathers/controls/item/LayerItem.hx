package valeditor.ui.feathers.controls.item;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import valeditor.ValEditorLayer;

/**
 * ...
 * @author Matse
 */
@:styleContext
class LayerItem extends LayoutGroup 
{
	static private var _POOL:Array<LayerItem> = new Array<LayerItem>();
	
	static public function fromPool(layer:ValEditorLayer):LayerItem
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(layer);
		return new LayerItem(layer);
	}
	
	public var layer(get, set):ValEditorLayer;
	
	private var _layer:ValEditorLayer;
	private function get_layer():ValEditorLayer { return this._layer; }
	private function set_layer(value:ValEditorLayer):ValEditorLayer
	{
		if (this._layer == value) return value;
		if (value != null && this._initialized)
		{
			this._name.text = value.name;
			this._visibleToggle.selected = value.visible;
		}
		return this._layer = value;
	}
	
	private var _name:Label;
	private var _visibleToggle:Check;
	
	public function new(layer:ValEditorLayer) 
	{
		super();
		this.layer = layer;
		initializeNow();
		this._name.text = layer.name;
		this._visibleToggle.selected = layer.visible;
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
		this.layout = hLayout;
		
		this._name = new Label();
		this._name.layoutData = new HorizontalLayoutData(100);
		addChild(this._name);
		
		this._visibleToggle = new Check(null, true);
		this._visibleToggle.addEventListener(Event.CHANGE, onVisibleToggle);
		addChild(this._visibleToggle);
	}
	
	private function setTo(layer:ValEditorLayer):LayerItem
	{
		this.layer = layer;
		return this;
	}
	
	private function onVisibleToggle(evt:Event):Void
	{
		this._layer.visible = this._visibleToggle.selected;
	}
	
}
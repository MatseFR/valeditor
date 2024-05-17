package valeditor.ui.feathers.renderers;

import feathers.controls.Check;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

/**
 * ...
 * @author Matse
 */
@:styleContext
class CheckItemRenderer extends LayoutGroupItemRenderer 
{
	static private var _POOL:Array<CheckItemRenderer> = new Array<CheckItemRenderer>();
	
	static public function fromPool(propertyName:String):CheckItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(propertyName);
		return new CheckItemRenderer(propertyName);
	}
	
	public var object(get, set):Dynamic;
	public var propertyName:String;
	
	private var _object:Dynamic;
	private function get_object():Dynamic { return this._object; }
	private function set_object(value:Dynamic):Dynamic
	{
		this._object = value;
		if (this._initialized && this._object != null)
		{
			updateCheck();
		}
		return this._object;
	}
	
	private var _check:Check;
	
	public function new(propertyName:String) 
	{
		super();
		this.propertyName = propertyName;
	}
	
	public function clear():Void
	{
		this._object = null;
		this.propertyName = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(propertyName:String):CheckItemRenderer
	{
		this.propertyName = propertyName;
		return this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		this.layout = hLayout;
		
		this._check = new Check();
		this._check.addEventListener(TriggerEvent.TRIGGER, onCheckChange);
		addChild(this._check);
	}
	
	private function updateCheck():Void
	{
		this._check.selected = Reflect.getProperty(this._object, this.propertyName);
	}
	
	private function onCheckChange(evt:TriggerEvent):Void
	{
		if (this._object == null) return;
		Reflect.setProperty(this._object, this.propertyName, this._check.selected);
	}
	
}
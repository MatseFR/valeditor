package ui.feathers.controls;

import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButton;
import feathers.layout.HorizontalAlign;
import feathers.layout.ILayout;
import feathers.layout.ILayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.display.DisplayObject;
import openfl.events.Event;

/**
 * ...
 * @author Matse
 */
@:styleContext
class ToggleLayoutGroup extends LayoutGroup 
{
	public var contentLayout(get, set):ILayout;
	private var _contentLayout:ILayout;
	private function get_contentLayout():ILayout { return this._contentLayout; }
	private function set_contentLayout(value:ILayout):ILayout
	{
		if (this._contentLayout == value) return value;
		
		if (this._initialized)
		{
			this._contentGroup.layout = value;
		}
		
		return this._contentLayout = value;
	}
	
	public var contentLayoutData(get, set):ILayoutData;
	private var _contentLayoutData:ILayoutData;
	private function get_contentLayoutData():ILayoutData { return this._contentLayoutData; }
	private function set_contentLayoutData(value:ILayoutData):ILayoutData
	{
		if (this._contentLayoutData == value) return value;
		
		if (this._initialized)
		{
			this._contentGroup.layoutData = value;
		}
		
		return this._contentLayoutData = value;
	}
	
	public var contentVariant(get, set):String;
	private var _contentVariant:String;
	private function get_contentVariant():String { return this._contentVariant; }
	private function set_contentVariant(value:String):String
	{
		if (this._contentVariant == value) return value;
		
		if (this._initialized)
		{
			this._contentGroup.variant = value;
		}
		
		return this._contentVariant = value;
	}
	
	public var isOpen(get, set):Bool;
	private var _isOpen:Bool;
	private function get_isOpen():Bool { return this._isOpen; }
	private function set_isOpen(value:Bool):Bool
	{
		if (this._isOpen == value) return value;
		
		if (this._initialized)
		{
			this._toggle.selected = value;
		}
		
		return this._isOpen = value;
	}
	
	public var text(get, set):String;
	private var _text:String = "";
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (value == null) value = "";
		if (this._toggle != null) this._toggle.text = value;
		return this._text = value;
	}
	
	public var toggleLayoutData(get, set):ILayoutData;
	private var _toggleLayoutData:ILayoutData;
	private function get_toggleLayoutData():ILayoutData { return this._toggleLayoutData; }
	private function set_toggleLayoutData(value:ILayoutData):ILayoutData
	{
		if (this._toggleLayoutData == value) return value;
		
		if (this._initialized)
		{
			this._toggle.layoutData = value;
		}
		
		return this._toggleLayoutData = value;
	}
	
	public var toggleVariant(get, set):String;
	private var _toggleVariant:String;
	private function get_toggleVariant():String { return this._toggleVariant; }
	private function set_toggleVariant(value:String):String
	{
		if (this._toggle != null) this._toggle.variant = value;
		return this._toggleVariant = value;
	}
	
	private var _toggle(default, null):ToggleButton;
	private var _contentGroup:LayoutGroup;
	
	//@:setter(explicitHeight)
	override function set_explicitHeight(value:Null<Float>):Null<Float> 
	{
		if (this._initialized && value != null)
		{
			this._contentGroup.height = value - this._toggle.height;
		}
		return super.set_explicitHeight(value);
	}
	
	public function new() 
	{
		super();
		this._contentGroup = new LayoutGroup();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout;
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.layout = vLayout;
		
		this._toggle = new ToggleButton(this._text, this._isOpen);
		this._toggle.addEventListener(Event.CHANGE, onToggleChange);
		this._toggle.variant = this._toggleVariant;
		addChild(this._toggle);
		
		this._contentGroup.layout = this._contentLayout;
		this._contentGroup.variant = this._contentVariant;
		if (this._isOpen) addChild(this._contentGroup);
	}
	
	public function addContent(child:DisplayObject):DisplayObject
	{
		return this._contentGroup.addChild(child);
	}
	
	public function addContentAt(child:DisplayObject, index:Int):DisplayObject
	{
		return this._contentGroup.addChildAt(child, index);
	}
	
	public function removeContent(child:DisplayObject):DisplayObject
	{
		return this._contentGroup.removeChild(child);
	}
	
	public function removeContentAt(index:Int):DisplayObject
	{
		return this._contentGroup.removeChildAt(index);
	}
	
	public function removeAllContent(beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void
	{
		this._contentGroup.removeChildren(beginIndex, endIndex);
	}
	
	private function onToggleChange(evt:Event):Void
	{
		if (this._toggle.selected)
		{
			addChild(this._contentGroup);
		}
		else
		{
			removeChild(this._contentGroup);
		}
	}
	
}
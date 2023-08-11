package valeditor.ui.feathers.renderers;

import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import haxe.ds.Map;
import openfl.display.DisplayObject;

/**
 * ...
 * @author Matse
 */
@:styleContext
class FrameItemRenderer extends LayoutGroup 
{
	static private var _POOL:Array<FrameItemRenderer> = new Array<FrameItemRenderer>();
	
	static public function fromPool():FrameItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FrameItemRenderer();
	}
	
	public var state(get, set):#if flash Dynamic #else FrameItemState #end;
	
	private var _state:FrameItemState;
	private function get_state():#if flash Dynamic #else FrameItemState #end { return this._state; }
	private function set_state(value:#if flash Dynamic #else FrameItemState #end):#if flash Dynamic #else FrameItemState #end
	{
		if (this._state == value) return value;
		this._state = value;
		this.setInvalid(STYLES);
		return this._state;
	}
	
	private var _icon:DisplayObject;
	
	private var _stateToIcon:Map<FrameItemState, DisplayObject> = new Map();
	private var _stateToSkin:Map<FrameItemState, DisplayObject> = new Map();

	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.BOTTOM;
		this.layout = vLayout;
	}
	
	override function update():Void 
	{
		super.update();
		
		var stylesInvalid = this.isInvalid(STYLES);
		
		if (stylesInvalid)
		{
			refreshStyles();
		}
	}
	
	private function refreshStyles():Void
	{
		this.backgroundSkin = this._stateToSkin.get(this._state);
		if (this._icon != null)
		{
			removeChild(this._icon);
		}
		this._icon = this._stateToIcon.get(this._state);
		if (this._icon != null)
		{
			addChild(this._icon);
		}
	}
	
	public function getIconForState(state:FrameItemState):DisplayObject
	{
		return this._stateToIcon.get(state);
	}
	
	public function setIconForState(state:FrameItemState, icon:DisplayObject):Void
	{
		if (icon == null)
		{
			this._stateToIcon.remove(state);
		}
		else
		{
			this._stateToIcon.set(state, icon);
		}
	}
	
	public function getSkinForState(state:FrameItemState):DisplayObject
	{
		return this._stateToSkin.get(state);
	}
	
	public function setSkinForState(state:FrameItemState, skin:DisplayObject):Void
	{
		if (skin == null)
		{
			this._stateToSkin.remove(state);
		}
		else
		{
			this._stateToSkin.set(state, skin);
		}
	}
	
}
package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import openfl.display.Bitmap;
import valeditor.ValEditorClass;
import valeditor.utils.ColorUtil;

/**
 * ...
 * @author Matse
 */
@:styleContext
class ClassItemRenderer extends LayoutGroupItemRenderer 
{
	static private var _POOL:Array<ClassItemRenderer> = new Array<ClassItemRenderer>();
	
	static public function fromPool():ClassItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ClassItemRenderer();
	}
	
	public var classColor(get, set):Int;
	public var clss(get, set):ValEditorClass;
	public var packageColor(get, set):Int;
	
	private var _classColor:Int;
	private function get_classColor():Int { return this._classColor; }
	private function set_classColor(value:Int):Int
	{
		this._classColorHex = "#" + ColorUtil.RGBtoHexString(value);
		this.setInvalid(InvalidationFlag.DATA);
		return this._classColor = value;
	}
	
	private var _clss:ValEditorClass;
	private function get_clss():ValEditorClass { return this._clss; }
	private function set_clss(value:ValEditorClass):ValEditorClass
	{
		this.setInvalid(InvalidationFlag.DATA);
		return this._clss = value;
	}
	
	private var _packageColor:Int;
	private function get_packageColor():Int { return this._packageColor; }
	private function set_packageColor(value:Int):Int
	{
		this._packageColorHex = "#" + ColorUtil.RGBtoHexString(value);
		this.setInvalid(InvalidationFlag.DATA);
		return this._packageColor = value;
	}
	
	private var _icon:Bitmap;
	private var _class:Label;
	
	private var _classColorHex:String;
	private var _packageColorHex:String;

	public function new() 
	{
		super();
		initializeNow();
	}
	
	public function clear():Void
	{
		this.clss = null;
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
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		hLayout.paddingTop = hLayout.paddingBottom = Padding.SMALL;
		hLayout.paddingLeft = hLayout.paddingRight = Padding.DEFAULT;
		this.layout = hLayout;
		
		this._icon = new Bitmap();
		addChild(this._icon);
		
		this._class = new Label();
		addChild(this._class);
	}
	
	override function update():Void 
	{
		if (isInvalid(InvalidationFlag.DATA))
		{
			if (this._clss != null)
			{
				this._icon.bitmapData = this._clss.iconBitmapData;
				this._icon.smoothing = true;
				this._class.htmlText = "<font color=\"" + this._packageColorHex + "\">" + this._clss.exportClassPackage + "</font><font color=\"" + this._classColorHex + "\"><b>" + this._clss.exportClassNameShort + "</b></font>";
			}
		}
		
		super.update();
	}
	
}
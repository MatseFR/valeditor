package valeditor.ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valedit.value.base.ExposedValue;
import valedit.value.ExposedNote;
import valeditor.ui.feathers.Padding;

/**
 * ...
 * @author Matse
 */
class NoteUI extends ValueUI 
{
	static private var _POOL:Array<NoteUI> = new Array<NoteUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():NoteUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new NoteUI();
	}
	
	override function set_exposedValue(value:ExposedValue):ExposedValue 
	{
		this._textValue = cast value;
		return super.set_exposedValue(value);
	}
	
	private var _textValue:ExposedNote;
	
	private var _label:Label;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override public function clear():Void 
	{
		super.clear();
		this._textValue = null;
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
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.paddingTop = hLayout.paddingBottom = Padding.DEFAULT;
		hLayout.paddingLeft = hLayout.paddingRight = Padding.DEFAULT * 2;
		this.layout = hLayout;
		
		this._label = new Label();
		this._label.wordWrap = true;
		this._label.layoutData = new HorizontalLayoutData(100);
		this._label.variant = LabelVariant.NOTE;
		addChild(this._label);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._textValue.text;
		cast(this._label.layoutData, HorizontalLayoutData).percentWidth = this._textValue.textPercentWidth;
	}
	
}
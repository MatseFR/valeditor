package valeditor.ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class NameUI extends ValueUI 
{
	static private var _POOL:Array<NameUI> = new Array<NameUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():NameUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new NameUI();
	}
	
	private var _label:Label;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		initializeNow();
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
		hLayout.gap = Spacing.DEFAULT;
		this.layout = hLayout;
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		addChild(this._label);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.toolTip = this._exposedValue.toolTip;
		
		this._label.text = this._exposedValue.name;
	}
	
}
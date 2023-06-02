package valeditor.ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class NameUI extends ValueUI 
{
	private var _label:Label;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		initializeNow();
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
		this._label.text = _exposedValue.name;
	}
	
}
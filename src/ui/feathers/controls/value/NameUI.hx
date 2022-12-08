package ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import ui.feathers.variant.LabelVariant;

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
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
	}
	
}
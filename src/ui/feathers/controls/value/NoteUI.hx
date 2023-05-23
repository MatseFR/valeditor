package ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import ui.feathers.variant.LabelVariant;
import valedit.ExposedValue;
import valedit.value.ExposedNote;

/**
 * ...
 * @author Matse
 */
class NoteUI extends ValueUI 
{
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
		
		this._label.text = this._textValue.text;
		cast(this._label.layoutData, HorizontalLayoutData).percentWidth = this._textValue.textPercentWidth;
	}
	
}
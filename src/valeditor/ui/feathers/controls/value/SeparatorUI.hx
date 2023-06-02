package valeditor.ui.feathers.controls.value;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;

/**
 * ...
 * @author Matse
 */
@:styleContext
class SeparatorUI extends ValueUI 
{
	public var paddingBottom(get, set):Float;
	public var paddingLeft(get, set):Float;
	public var paddingRight(get, set):Float;
	public var paddingTop(get, set):Float;
	
	public var separator:LayoutGroup;
	
	private function get_paddingBottom():Float { return vLayout.paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		return vLayout.paddingBottom = value;
	}
	
	private function get_paddingLeft():Float { return vLayout.paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		return vLayout.paddingLeft = value;
	}
	
	private function get_paddingRight():Float { return vLayout.paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		return vLayout.paddingRight = value;
	}
	
	private function get_paddingTop():Float { return vLayout.paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		return vLayout.paddingTop = value;
	}
	
	private var vLayout:VerticalLayout;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		this.layout = vLayout;
		
		this.separator = new LayoutGroup();
		this.separator.layoutData = VerticalLayoutData.fillVertical();
		addChild(this.separator);
	}
	
}
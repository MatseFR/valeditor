package valeditor.ui.feathers.view;
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valeditor.ui.feathers.controls.ToggleLayoutGroup;
import valeditor.ui.feathers.theme.simple.variants.ScrollContainerVariant;

/**
 * ...
 * @author Matse
 */
class SimpleEditViewToggleGroups extends SimpleEditViewBase 
{
	//public var rightGroup(default, null):LayoutGroup;
	public var rightContainer(default, null):ScrollContainer;
	
	public function new() 
	{
		super();
		
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout;
		
		// right container
		this.rightContainer = new ScrollContainer();
		this.rightContainer.variant = ScrollContainerVariant.WITH_BACKGROUND;
		this.rightContainer.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this.rightContainer.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		this.rightContainer.width = this.rightContainer.minWidth;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.rightContainer.layout = vLayout;
		this.mainBox.addChild(this.rightContainer);
	}
	
	public function addToggleGroup(id:String = "default", title:String = null, isOpen:Bool = false):ToggleLayoutGroup
	{
		var toggleGroup:ToggleLayoutGroup = createEditContainer_toggleGroup(id, title, isOpen);
		this.rightContainer.addChild(toggleGroup);
		return toggleGroup;
	}
	
}
package valeditor.ui.feathers.view;
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
class SimpleEditView extends SimpleEditViewBase
{
	static public inline var ID:String = "simple-edit-view";
	
	public var editContainer(default, null):ScrollContainer;
	public var rightGroup(default, null):LayoutGroup;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		//var vLayout:VerticalLayout;
		
		// right group
		this.rightGroup = new LayoutGroup();
		this.rightGroup.variant = LayoutGroupVariant.CONTENT;
		this.rightGroup.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this.rightGroup.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		this.rightGroup.width = this.rightGroup.minWidth;// + (this._rightBox.maxWidth - this._rightBox.minWidth) / 2.0;
		this.rightGroup.layout = new AnchorLayout();
		this.mainBox.addChild(this.rightGroup);
		
		// edit container
		this.editContainer = createEditContainer_scroll();
		this.editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this.rightGroup.addChild(this.editContainer);
	}
	
	
	
}
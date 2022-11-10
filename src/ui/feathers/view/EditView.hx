package ui.feathers.view;

import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class EditView extends LayoutGroup 
{
	static public inline var ID:String = "edit-view";
	
	public var valEditContainer(default, null):ScrollContainer;
	public var topBar(default, null):LayoutGroup;
	public var stageArea(default, null):LayoutGroup;

	public function new() 
	{
		super();
		
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout;
		
		this.layout = new AnchorLayout();
		
		topBar = new LayoutGroup();
		topBar.layoutData = new AnchorLayoutData(0, 0, null, 0);
		addChild(topBar);
		
		valEditContainer = new ScrollContainer();
		valEditContainer.width = 500;
		valEditContainer.scrollPolicyX = ScrollPolicy.OFF;
		valEditContainer.scrollPolicyY = ScrollPolicy.ON;
		valEditContainer.fixedScrollBars = true;
		valEditContainer.layoutData = new AnchorLayoutData(new Anchor(0, topBar), 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = Spacing.DEFAULT;
		valEditContainer.layout = vLayout;
		addChild(valEditContainer);
		
		stageArea = new LayoutGroup();
		stageArea.layoutData = new AnchorLayoutData(new Anchor(0, topBar), new Anchor(0, valEditContainer), 0, 0);
		addChild(stageArea);
	}
	
}
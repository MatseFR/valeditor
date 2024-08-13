package valeditor.ui.feathers.controls;

import feathers.controls.LayoutGroup;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
class Library extends LayoutGroup 
{
	public var templateLibrary(default, null):TemplateLibrary;
	public var objectLibrary(default, null):ObjectLibrary;
	
	private var _tabNavigator:TabNavigator;
	
	public function new() 
	{
		super();
		this.variant = LayoutGroupVariant.CONTENT;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this.layout = new AnchorLayout();
		
		this.templateLibrary = new TemplateLibrary();
		this.objectLibrary = new ObjectLibrary();
		
		var views:ArrayCollection<TabItem> = new ArrayCollection<TabItem>([
			TabItem.withDisplayObject("Templates", this.templateLibrary),
			TabItem.withDisplayObject("Objects", this.objectLibrary)
		]);
		
		this._tabNavigator = new TabNavigator(views);
		this._tabNavigator.layoutData = new AnchorLayoutData(Padding.MINIMAL, 0, 0, 0);
		addChild(this._tabNavigator);
	}
	
}
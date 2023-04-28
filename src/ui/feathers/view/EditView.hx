package ui.feathers.view;

import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.PopUpListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.feathers.FeathersWindows;
import ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class EditView extends LayoutGroup 
{
	static public inline var ID:String = "edit-view";
	
	private var _box:HDividedBox;
	
	public var valEditContainer(default, null):ScrollContainer;
	public var topBar(default, null):LayoutGroup;
	public var stageArea(default, null):LayoutGroup;
	
	private var _fileMenu:PopUpListView;
	private var _fileMenuCollection:ArrayCollection<Dynamic>;
	
	private var _assetMenu:PopUpListView;
	private var _assetMenuCollection:ArrayCollection<Dynamic>;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this.layout = new AnchorLayout();
		
		topBar = new LayoutGroup();
		//topBar.variant = LayoutGroup.VARIANT_TOOL_BAR;
		topBar.layoutData = new AnchorLayoutData(0, 0, null, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		topBar.layout = hLayout;
		addChild(topBar);
		
		// File menu
		_fileMenuCollection = new ArrayCollection();
		_fileMenuCollection.add({text:"New", id:"new"});
		_fileMenuCollection.add({text:"Save", id:"save"});
		_fileMenuCollection.add({text:"Save As", id:"save as"});
		
		_fileMenu = new PopUpListView(_fileMenuCollection, onFileMenuChange);
		_fileMenu.prompt = "File";
		_fileMenu.selectedIndex = -1;
		_fileMenu.itemToText = function(item:Dynamic):String
		{
			return item.text;
		};
		topBar.addChild(_fileMenu);
		
		// Asset menu
		_assetMenuCollection = new ArrayCollection();
		_assetMenuCollection.add({text:"Browser", id:"browser"});
		
		_assetMenu = new PopUpListView(_assetMenuCollection, onAssetMenuChange);
		_assetMenu.prompt = "Asset";
		_assetMenu.selectedIndex = -1;
		_assetMenu.itemToText = function(item:Dynamic):String
		{
			return item.text;
		}
		topBar.addChild(_assetMenu);
		
		_box = new HDividedBox();
		_box.layoutData = new AnchorLayoutData(new Anchor(0, topBar), 0, 0, 0);
		addChild(_box);
		
		stageArea = new LayoutGroup();
		//stageArea.layoutData = new AnchorLayoutData(new Anchor(0, topBar), new Anchor(0, valEditContainer), 0, 0);
		_box.addChild(stageArea);
		
		valEditContainer = new ScrollContainer();
		//valEditContainer.width = 500;
		//valEditContainer.minWidth = 250;
		valEditContainer.minWidth = UIConfig.VALUE_MIN_WIDTH;
		valEditContainer.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		valEditContainer.width = UIConfig.VALUE_MIN_WIDTH + (UIConfig.VALUE_MAX_WIDTH - UIConfig.VALUE_MIN_WIDTH) / 2;
		valEditContainer.scrollPolicyX = ScrollPolicy.OFF;
		valEditContainer.scrollPolicyY = ScrollPolicy.ON;
		valEditContainer.fixedScrollBars = true;
		//valEditContainer.layoutData = new AnchorLayoutData(new Anchor(0, topBar), 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = Spacing.DEFAULT;
		valEditContainer.layout = vLayout;
		_box.addChild(valEditContainer);
	}
	
	private function onAssetMenuChange(evt:Event):Void
	{
		if (_assetMenu.selectedIndex == -1) return;
		
		var id:String = _assetMenu.selectedItem.id;
		
		switch (id)
		{
			case "browser" :
				FeathersWindows.showAssetBrowser();
		}
		
		_assetMenu.selectedIndex = -1;
	}
	
	private function onFileMenuChange(evt:Event):Void
	{
		if (_fileMenu.selectedIndex == -1) return;
		
		var id:String = _fileMenu.selectedItem.id;
		
		switch (id)
		{
			
		}
		
		_fileMenu.selectedIndex = -1;
	}
	
}
package valeditor.ui.feathers.view;

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
import valeditor.ui.feathers.Spacing;
import valeditor.ui.UIConfig;

/**
 * ...
 * @author Matse
 */
class EditView extends LayoutGroup 
{
	static public inline var ID:String = "edit-view";
	
	public var assetMenuCallback(get, set):String->Void;
	private var _assetMenuCallback:String->Void;
	private function get_assetMenuCallback():String->Void { return this._assetMenuCallback; }
	private function set_assetMenuCallback(value:String->Void):String->Void
	{
		return this._assetMenuCallback = value;
	}
	
	public var fileMenuCallback(get, set):String->Void;
	private var _fileMenuCallback:String->Void;
	private function get_fileMenuCallback():String->Void { return this._fileMenuCallback; }
	private function set_fileMenuCallback(value:String->Void):String->Void
	{
		return this._fileMenuCallback = value;
	}
	
	public var valEditContainer(default, null):ScrollContainer;
	public var topBar(default, null):LayoutGroup;
	public var stageArea(default, null):LayoutGroup;
	
	private var _box:HDividedBox;
	
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
		
		this.topBar = new LayoutGroup();
		//this.topBar.variant = LayoutGroup.VARIANT_TOOL_BAR;
		this.topBar.layoutData = new AnchorLayoutData(0, 0, null, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this.topBar.layout = hLayout;
		addChild(this.topBar);
		
		// File menu
		this._fileMenuCollection = new ArrayCollection();
		this._fileMenuCollection.add({text:"New", id:"new"});
		this._fileMenuCollection.add({text:"Save", id:"save"});
		this._fileMenuCollection.add({text:"Save As", id:"save as"});
		this._fileMenuCollection.add({text:"Load", id:"load"});
		this._fileMenuCollection.add({text:"export simple JSON", id:"export simple json"});
		
		this._fileMenu = new PopUpListView(this._fileMenuCollection, onFileMenuChange);
		this._fileMenu.prompt = "File";
		this._fileMenu.selectedIndex = -1;
		this._fileMenu.itemToText = function(item:Dynamic):String
		{
			return item.text;
		};
		this.topBar.addChild(this._fileMenu);
		
		// Asset menu
		this._assetMenuCollection = new ArrayCollection();
		this._assetMenuCollection.add({text:"Browser", id:"browser"});
		
		this._assetMenu = new PopUpListView(this._assetMenuCollection, onAssetMenuChange);
		this._assetMenu.prompt = "Asset";
		this._assetMenu.selectedIndex = -1;
		this._assetMenu.itemToText = function(item:Dynamic):String
		{
			return item.text;
		}
		this.topBar.addChild(this._assetMenu);
		
		this._box = new HDividedBox();
		this._box.layoutData = new AnchorLayoutData(new Anchor(0, this.topBar), 0, 0, 0);
		addChild(this._box);
		
		this.stageArea = new LayoutGroup();
		this._box.addChild(this.stageArea);
		
		this.valEditContainer = new ScrollContainer();
		this.valEditContainer.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this.valEditContainer.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		this.valEditContainer.width = UIConfig.VALUE_MIN_WIDTH + (UIConfig.VALUE_MAX_WIDTH - UIConfig.VALUE_MIN_WIDTH) / 2;
		this.valEditContainer.scrollPolicyX = ScrollPolicy.OFF;
		this.valEditContainer.scrollPolicyY = ScrollPolicy.ON;
		this.valEditContainer.fixedScrollBars = true;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = Spacing.DEFAULT;
		this.valEditContainer.layout = vLayout;
		this._box.addChild(this.valEditContainer);
	}
	
	private function onAssetMenuChange(evt:Event):Void
	{
		if (this._assetMenu.selectedIndex == -1) return;
		
		var id:String = this._assetMenu.selectedItem.id;
		
		this._assetMenu.selectedIndex = -1;
		
		if (this._assetMenuCallback != null)
		{
			this._assetMenuCallback(id);
		}
	}
	
	private function onFileMenuChange(evt:Event):Void
	{
		if (this._fileMenu.selectedIndex == -1) return;
		
		var id:String = this._fileMenu.selectedItem.id;
		
		this._fileMenu.selectedIndex = -1;
		
		if (this._fileMenuCallback != null)
		{
			this._fileMenuCallback(id);
		}
	}
	
}
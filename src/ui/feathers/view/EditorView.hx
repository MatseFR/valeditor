package ui.feathers.view;

import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.PopUpListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.VDividedBox;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import ui.UIConfig;
import ui.feathers.Spacing;
import ui.feathers.controls.ObjectInfo;
import ui.feathers.controls.ObjectLibrary;
import ui.feathers.controls.ToggleLayoutGroup;
import ui.feathers.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
class EditorView extends LayoutGroup 
{
	static public inline var ID:String = "editor-view";
	
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
	
	public var editContainer(get, never):ScrollContainer;
	private function get_editContainer():ScrollContainer { return this._editContainer; }
	
	private var _menuBar:LayoutGroup;
	private var _fileMenu:PopUpListView;
	private var _fileMenuCollection:ArrayCollection<Dynamic>;
	private var _assetMenu:PopUpListView;
	private var _assetMenuCollection:ArrayCollection<Dynamic>;
	
	private var _mainBox:HDividedBox;
	private var _leftBox:LayoutGroup;
	private var _centerBox:VDividedBox;
	private var _rightBox:LayoutGroup;
	
	// left content
	private var _objectLibGroup:ToggleLayoutGroup;
	private var _objectLib:ObjectLibrary;
	
	// center content
	private var _displayArea:LayoutGroup;
	
	// right content
	private var _objectInfoGroup:ToggleLayoutGroup;
	private var _objectInfo:ObjectInfo;
	private var _propertiesGroup:ToggleLayoutGroup;
	private var _editContainer:ScrollContainer;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this.layout = new AnchorLayout();
		
		// menu bar
		this._menuBar = new LayoutGroup();
		//this._menuBar.variant = LayoutGroupVariant.
		this._menuBar.layoutData = new AnchorLayoutData(0, 0, null, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._menuBar.layout = hLayout;
		addChild(this._menuBar);
		
		// file menu
		this._fileMenuCollection = new ArrayCollection<Dynamic>();
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
		this._menuBar.addChild(this._fileMenu);
		
		// asset menu
		this._assetMenuCollection = new ArrayCollection<Dynamic>();
		this._assetMenuCollection.add({text:"Browser", id:"browser"});
		
		this._assetMenu = new PopUpListView(this._assetMenuCollection, onAssetMenuChange);
		this._assetMenu.prompt = "Asset";
		this._assetMenu.selectedIndex = -1;
		this._assetMenu.itemToText = function(item:Dynamic):String
		{
			return item.text;
		};
		this._menuBar.addChild(this._assetMenu);
		
		this._mainBox = new HDividedBox();
		this._mainBox.layoutData = new AnchorLayoutData(new Anchor(0, this._menuBar), 0, 0, 0);
		addChild(this._mainBox);
		
		this._leftBox = new LayoutGroup();
		this._leftBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._leftBox);
		
		this._centerBox = new VDividedBox();
		this._mainBox.addChild(this._centerBox);
		
		this._rightBox = new LayoutGroup();
		this._rightBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._rightBox);
		
		// left content
		this._objectLibGroup = new ToggleLayoutGroup();
		this._objectLibGroup.text = "Objects";
		this._objectLibGroup.isOpen = true;
		this._objectLibGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._objectLibGroup.contentLayout = new AnchorLayout();
		this._leftBox.addChild(this._objectLibGroup);
		
		this._objectLib = new ObjectLibrary();
		this._objectLib.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._objectLib.minWidth = UIConfig.LEFT_MIN_WIDTH;
		//this._objectLib.maxWidth = UIConfig.LEFT_MAX_WIDTH;
		//this._leftBox.addChild(this._objectLib);
		this._objectLibGroup.addContent(this._objectLib);
		
		// center content
		this._displayArea = new LayoutGroup();
		this._displayArea.minWidth = UIConfig.CENTER_MIN_WIDTH;
		this._centerBox.addChild(this._displayArea);
		
		// right content
		this._objectInfoGroup = new ToggleLayoutGroup();
		this._objectInfoGroup.contentVariant = LayoutGroupVariant.CONTENT;
		this._objectInfoGroup.text = "Info";
		this._objectInfoGroup.isOpen = true;
		this._objectInfoGroup.layoutData = new AnchorLayoutData(0, 0, null, 0);
		this._rightBox.addChild(this._objectInfoGroup);
		
		this._objectInfo = new ObjectInfo();
		this._objectInfoGroup.addContent(this._objectInfo);
		
		this._propertiesGroup = new ToggleLayoutGroup();
		this._propertiesGroup.text = "Properties";
		this._propertiesGroup.isOpen = true;
		this._propertiesGroup.layoutData = new AnchorLayoutData(new Anchor(0, this._objectInfoGroup), 0, 0, 0);
		this._propertiesGroup.contentLayout = new AnchorLayout();
		this._rightBox.addChild(this._propertiesGroup);
		
		this._editContainer = new ScrollContainer();
		//this._editContainer.minWidth = UIConfig.VALUE_MIN_WIDTH;
		//this._editContainer.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		//this._editContainer.width = UIConfig.VALUE_MIN_WIDTH + (UIConfig.VALUE_MAX_WIDTH - UIConfig.VALUE_MIN_WIDTH) / 2;
		this._editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._editContainer.scrollPolicyX = ScrollPolicy.OFF;
		this._editContainer.scrollPolicyY = ScrollPolicy.ON;
		this._editContainer.fixedScrollBars = true;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		this._editContainer.layout = vLayout;
		//this._rightBox.addChild(this._editContainer);
		this._propertiesGroup.addContent(this._editContainer);
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
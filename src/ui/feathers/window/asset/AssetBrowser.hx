package ui.feathers.window.asset;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import ui.feathers.Padding;
#if starling
import ui.feathers.window.asset.starling.StarlingAtlasAssetsWindow;
import ui.feathers.window.asset.starling.StarlingTextureAssetsWindow;
#end
import valedit.asset.AssetType;

/**
 * ...
 * @author Matse
 */
class AssetBrowser extends Panel 
{
	private var _headerGroup:LayoutGroup;
	private var _titleLabel:Label;
	
	//private var _footerGroup:LayoutGroup;
	private var _closeButton:Button;
	
	private var _assetTypeList:ListView;
	private var _assetTypeCollection:ArrayCollection<Dynamic>;
	private var _navigator:StackNavigator;
	
	private var _binaryAssets:BinaryAssetsWindow;
	private var _bitmapAssets:BitmapAssetsWindow;
	private var _soundAssets:SoundAssetsWindow;
	private var _textAssets:TextAssetsWindow;
	#if starling
	private var _starlingAtlasAssets:StarlingAtlasAssetsWindow;
	private var _starlingTextureAssets:StarlingTextureAssetsWindow;
	#end

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		
		_headerGroup = new LayoutGroup();
		_headerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		//hLayout = new HorizontalLayout();
		//hLayout.horizontalAlign = HorizontalAlign.CENTER;
		//hLayout.verticalAlign = VerticalAlign.MIDDLE;
		//hLayout.setPadding(Padding.DEFAULT);
		//_headerGroup.layout = hLayout;
		_headerGroup.layout = new AnchorLayout();
		this.header = _headerGroup;
		
		_titleLabel = new Label("ASSET BROWER");
		_titleLabel.layoutData = AnchorLayoutData.center();
		_headerGroup.addChild(_titleLabel);
		
		//_footerGroup = new LayoutGroup();
		//_footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		//hLayout = new HorizontalLayout();
		//hLayout.horizontalAlign = HorizontalAlign.CENTER;
		//hLayout.verticalAlign = VerticalAlign.MIDDLE;
		//hLayout.setPadding(Padding.DEFAULT);
		//_footerGroup.layout = hLayout;
		//this.footer = _footerGroup;
		
		_closeButton = new Button("Close", onCloseButton);
		_closeButton.layoutData = AnchorLayoutData.middleRight();
		_headerGroup.addChild(_closeButton);
		
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.JUSTIFY;
		this.layout = hLayout;
		
		_assetTypeList = new ListView(null, onAssetTypeChange);
		addChild(_assetTypeList);
		
		_assetTypeCollection = new ArrayCollection<Dynamic>();
		_assetTypeCollection.add({text:AssetType.BINARY, id:AssetType.BINARY});
		_assetTypeCollection.add({text:AssetType.BITMAP, id:AssetType.BITMAP});
		_assetTypeCollection.add({text:AssetType.SOUND, id:AssetType.SOUND});
		_assetTypeCollection.add({text:AssetType.TEXT, id:AssetType.TEXT});
		#if starling
		_assetTypeCollection.add({text:AssetType.STARLING_ATLAS, id:AssetType.STARLING_ATLAS});
		_assetTypeCollection.add({text:AssetType.STARLING_TEXTURE, id:AssetType.STARLING_TEXTURE});
		#end
		_assetTypeList.dataProvider = _assetTypeCollection;
		
		_assetTypeList.itemToText = function(item:Dynamic):String
		{
			return item.text;
		};
		
		_navigator = new StackNavigator();
		_navigator.layoutData = new HorizontalLayoutData(100);
		addChild(_navigator);
		
		var item:StackItem;
		
		_binaryAssets = new BinaryAssetsWindow();
		_binaryAssets.headerEnabled = false;
		_binaryAssets.cancelEnabled = false;
		_binaryAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.BINARY, _binaryAssets);
		_navigator.addItem(item);
		
		_bitmapAssets = new BitmapAssetsWindow();
		_bitmapAssets.headerEnabled = false;
		_bitmapAssets.cancelEnabled = false;
		_bitmapAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.BITMAP, _bitmapAssets);
		_navigator.addItem(item);
		
		_soundAssets = new SoundAssetsWindow();
		_soundAssets.headerEnabled = false;
		_soundAssets.cancelEnabled = false;
		_soundAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.SOUND, _soundAssets);
		_navigator.addItem(item);
		
		_textAssets = new TextAssetsWindow();
		_textAssets.headerEnabled = false;
		_textAssets.cancelEnabled = false;
		_textAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.TEXT, _textAssets);
		_navigator.addItem(item);
		
		#if starling
		_starlingAtlasAssets = new StarlingAtlasAssetsWindow();
		_starlingAtlasAssets.headerEnabled = false;
		_starlingAtlasAssets.cancelEnabled = false;
		_starlingAtlasAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.STARLING_ATLAS, _starlingAtlasAssets);
		_navigator.addItem(item);
		
		_starlingTextureAssets = new StarlingTextureAssetsWindow();
		_starlingTextureAssets.headerEnabled = false;
		_starlingTextureAssets.cancelEnabled = false;
		_starlingTextureAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.STARLING_TEXTURE, _starlingTextureAssets);
		_navigator.addItem(item);
		#end
		
		_assetTypeList.selectedIndex = 0;
	}
	
	private function onAssetTypeChange(evt:Event):Void
	{
		_navigator.rootItemID = _assetTypeList.selectedItem.id;
	}
	
	private function onCloseButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
	}
	
}
package valeditor.ui.feathers.window.asset;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.core.PopUpManager;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import valedit.asset.AssetType;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;
#if starling
import valeditor.ui.feathers.window.asset.starling.StarlingAtlasAssetsWindow;
import valeditor.ui.feathers.window.asset.starling.StarlingTextureAssetsWindow;
#end

/**
 * ...
 * @author Matse
 */
class AssetBrowser extends Panel 
{
	private var _headerGroup:Header;
	
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
		
		this._headerGroup = new Header("Asset Browser");
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = _headerGroup;
		
		this._closeButton = new Button("Close", onCloseButton);
		this._closeButton.layoutData = AnchorLayoutData.middleRight(0, Padding.DEFAULT);
		this._headerGroup.rightView = this._closeButton;
		
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.JUSTIFY;
		this.layout = hLayout;
		
		this._assetTypeList = new ListView(null, onAssetTypeChange);
		addChild(this._assetTypeList);
		
		this._assetTypeCollection = new ArrayCollection<Dynamic>();
		this._assetTypeCollection.add({text:AssetType.BINARY, id:AssetType.BINARY});
		this._assetTypeCollection.add({text:AssetType.BITMAP, id:AssetType.BITMAP});
		this._assetTypeCollection.add({text:AssetType.SOUND, id:AssetType.SOUND});
		this._assetTypeCollection.add({text:AssetType.TEXT, id:AssetType.TEXT});
		#if starling
		this._assetTypeCollection.add({text:AssetType.STARLING_ATLAS, id:AssetType.STARLING_ATLAS});
		this._assetTypeCollection.add({text:AssetType.STARLING_TEXTURE, id:AssetType.STARLING_TEXTURE});
		#end
		this._assetTypeList.dataProvider = _assetTypeCollection;
		
		this._assetTypeList.itemToText = function(item:Dynamic):String
		{
			return item.text;
		};
		
		this._navigator = new StackNavigator();
		this._navigator.layoutData = new HorizontalLayoutData(100);
		addChild(this._navigator);
		
		var item:StackItem;
		
		this._binaryAssets = new BinaryAssetsWindow();
		this._binaryAssets.headerEnabled = false;
		this._binaryAssets.cancelEnabled = false;
		this._binaryAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.BINARY, this._binaryAssets);
		this._navigator.addItem(item);
		
		this._bitmapAssets = new BitmapAssetsWindow();
		this._bitmapAssets.headerEnabled = false;
		this._bitmapAssets.cancelEnabled = false;
		this._bitmapAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.BITMAP, this._bitmapAssets);
		_navigator.addItem(item);
		
		this._soundAssets = new SoundAssetsWindow();
		this._soundAssets.headerEnabled = false;
		this._soundAssets.cancelEnabled = false;
		this._soundAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.SOUND, this._soundAssets);
		this._navigator.addItem(item);
		
		this._textAssets = new TextAssetsWindow();
		this._textAssets.headerEnabled = false;
		this._textAssets.cancelEnabled = false;
		this._textAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.TEXT, this._textAssets);
		this._navigator.addItem(item);
		
		#if starling
		this._starlingAtlasAssets = new StarlingAtlasAssetsWindow();
		this._starlingAtlasAssets.headerEnabled = false;
		this._starlingAtlasAssets.cancelEnabled = false;
		this._starlingAtlasAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.STARLING_ATLAS, this._starlingAtlasAssets);
		this._navigator.addItem(item);
		
		this._starlingTextureAssets = new StarlingTextureAssetsWindow();
		this._starlingTextureAssets.headerEnabled = false;
		this._starlingTextureAssets.cancelEnabled = false;
		this._starlingTextureAssets.removeEnabled = true;
		item = StackItem.withDisplayObject(AssetType.STARLING_TEXTURE, this._starlingTextureAssets);
		this._navigator.addItem(item);
		#end
		
		this._assetTypeList.selectedIndex = 0;
	}
	
	private function onAssetTypeChange(evt:Event):Void
	{
		this._navigator.rootItemID = this._assetTypeList.selectedItem.id;
	}
	
	private function onCloseButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
	}
	
}
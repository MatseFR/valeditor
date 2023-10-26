package valeditor.ui.feathers.window.asset.starling;

import feathers.controls.Button;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import starling.textures.TextureAtlas;
import valeditor.ui.feathers.renderers.starling.StarlingAtlasAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
import valeditor.utils.starling.AtlasLoader;
import valedit.asset.AssetLib;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.asset.starling.StarlingAtlasAsset;
import valeditor.utils.starling.TextureCreationParameters;

/**
 * ...
 * @author Matse
 */
class StarlingAtlasAssetsWindow extends AssetsWindow<StarlingAtlasAsset>
{
	private var _addAtlasButton:Button;
	
	private var _atlasLoader:AtlasLoader = new AtlasLoader();

	public function new() 
	{
		super();
		this._filesEnabled = false;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._addAtlasButton = new Button("add Atlas");
		this._footerGroup.addChildAt(_addAtlasButton, 0);
		this._buttonList.push(_addAtlasButton);
		
		this._assetList.dataProvider = AssetLib.starlingAtlasCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new StarlingAtlasAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:StarlingAtlasAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
	}
	
	override function controlsDisable():Void 
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._addAtlasButton.removeEventListener(TriggerEvent.TRIGGER, onAddAtlasbutton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._addAtlasButton.addEventListener(TriggerEvent.TRIGGER, onAddAtlasbutton);
	}
	
	private function atlasLoadComplete(atlas:TextureAtlas, textureParams:TextureCreationParameters, bitmapAsset:BitmapAsset, textAsset:TextAsset):Void
	{
		AssetLib.createStarlingAtlas(bitmapAsset.path, atlas, textureParams, bitmapAsset, textAsset);
	}
	
	private function onAddAtlasbutton(evt:TriggerEvent):Void
	{
		disableUI();
		this._atlasLoader.start(atlasLoadComplete, enableUI, enableUI);
	}
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			AssetLib.removeStarlingAtlas(item);
		}
	}
}
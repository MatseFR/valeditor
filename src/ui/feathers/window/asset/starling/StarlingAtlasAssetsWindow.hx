package ui.feathers.window.asset.starling;

import feathers.controls.Button;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import starling.textures.TextureAtlas;
import ui.feathers.renderers.starling.StarlingAtlasAssetItemRenderer;
import ui.feathers.window.asset.AssetsWindow;
import utils.starling.AtlasLoader;
import valedit.asset.AssetLib;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.asset.starling.StarlingAtlasAsset;

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
	
	@:access(valedit.asset.AssetLib)
	override function initialize():Void 
	{
		super.initialize();
		
		_addAtlasButton = new Button("add Atlas");
		_footerGroup.addChildAt(_addAtlasButton, 0);
		_buttonList.push(_addAtlasButton);
		
		_assetList.dataProvider = AssetLib._starlingAtlasCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new StarlingAtlasAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:StarlingAtlasAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		_assetList.itemRendererRecycler = recycler;
		_assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		controlsEnable();
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_addAtlasButton.removeEventListener(TriggerEvent.TRIGGER, onAddAtlasbutton);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_addAtlasButton.addEventListener(TriggerEvent.TRIGGER, onAddAtlasbutton);
	}
	
	private function atlasLoadComplete(atlas:TextureAtlas, bitmapAsset:BitmapAsset, textAsset:TextAsset):Void
	{
		AssetLib.createStarlingAtlas(bitmapAsset.path, atlas, bitmapAsset, textAsset);
	}
	
	private function onAddAtlasbutton(evt:TriggerEvent):Void
	{
		disableUI();
		_atlasLoader.start(atlasLoadComplete, enableUI, enableUI);
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
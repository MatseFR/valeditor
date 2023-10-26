package valeditor.ui.feathers.window.asset.starling;
import feathers.controls.Button;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import valeditor.ui.feathers.renderers.starling.StarlingTextureAssetItemRenderer;
import valeditor.utils.starling.AtlasLoader;
import valeditor.utils.starling.TextureCreationParameters;
import valeditor.utils.starling.TextureLoader;
import valedit.asset.AssetLib;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.asset.starling.StarlingTextureAsset;
import valeditor.ui.feathers.window.asset.AssetsWindow;

/**
 * ...
 * @author Matse
 */
class StarlingTextureAssetsWindow extends AssetsWindow<StarlingTextureAsset>
{
	private var _addAtlasButton:Button;
	private var _addTextureButton:Button;
	
	private var _atlasLoader:AtlasLoader = new AtlasLoader();
	private var _textureLoader:TextureLoader = new TextureLoader();
	
	public function new() 
	{
		super();
		this._filesEnabled = false;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._addAtlasButton = new Button("add Atlas");
		this._footerGroup.addChildAt(this._addAtlasButton, 0);
		this._buttonList.push(this._addAtlasButton);
		
		this._addTextureButton = new Button("add Texture");
		this._footerGroup.addChildAt(this._addTextureButton, 1);
		this._buttonList.push(this._addTextureButton);
		
		this._assetList.dataProvider = AssetLib.starlingTextureCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new StarlingTextureAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:StarlingTextureAssetItemRenderer, state:ListViewItemState) -> {
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
		this._addAtlasButton.removeEventListener(TriggerEvent.TRIGGER, onAddAtlasButton);
		this._addTextureButton.removeEventListener(TriggerEvent.TRIGGER, onAddTextureButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._addAtlasButton.addEventListener(TriggerEvent.TRIGGER, onAddAtlasButton);
		this._addTextureButton.addEventListener(TriggerEvent.TRIGGER, onAddTextureButton);
	}
	
	private function atlasLoadComplete(atlas:TextureAtlas, textureParams:TextureCreationParameters, bitmapAsset:BitmapAsset, textAsset:TextAsset):Void
	{
		AssetLib.createStarlingAtlas(bitmapAsset.path, atlas, textureParams, bitmapAsset, textAsset);
	}
	
	private function textureLoadComplete(texture:Texture, textureParams:TextureCreationParameters, bitmapAsset:BitmapAsset):Void
	{
		AssetLib.createStarlingTexture(bitmapAsset.path, texture, textureParams, bitmapAsset);
	}
	
	private function onAddAtlasButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._atlasLoader.start(atlasLoadComplete, enableUI, enableUI);
	}
	
	private function onAddTextureButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._textureLoader.start(textureLoadComplete, enableUI, enableUI);
	}
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			AssetLib.removeStarlingTexture(item);
		}
	}
	
}
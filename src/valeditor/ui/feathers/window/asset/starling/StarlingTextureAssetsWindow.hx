package valeditor.ui.feathers.window.asset.starling;
import feathers.controls.Button;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import valeditor.ui.feathers.renderers.starling.StarlingTextureAssetItemRenderer;
import valeditor.utils.starling.AtlasLoader;
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
	
	@:access(valedit.asset.AssetLib)
	override function initialize():Void 
	{
		super.initialize();
		
		_addAtlasButton = new Button("add Atlas");
		_footerGroup.addChildAt(_addAtlasButton, 0);
		_buttonList.push(_addAtlasButton);
		
		_addTextureButton = new Button("add Texture");
		_footerGroup.addChildAt(_addTextureButton, 1);
		_buttonList.push(_addTextureButton);
		
		_assetList.dataProvider = AssetLib._starlingTextureCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new StarlingTextureAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:StarlingTextureAssetItemRenderer, state:ListViewItemState) -> {
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
		_addAtlasButton.removeEventListener(TriggerEvent.TRIGGER, onAddAtlasButton);
		_addTextureButton.removeEventListener(TriggerEvent.TRIGGER, onAddTextureButton);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_addAtlasButton.addEventListener(TriggerEvent.TRIGGER, onAddAtlasButton);
		_addTextureButton.addEventListener(TriggerEvent.TRIGGER, onAddTextureButton);
	}
	
	private function atlasLoadComplete(atlas:TextureAtlas, bitmapAsset:BitmapAsset, textAsset:TextAsset):Void
	{
		AssetLib.createStarlingAtlas(bitmapAsset.path, atlas, bitmapAsset, textAsset);
	}
	
	private function textureLoadComplete(texture:Texture, bitmapAsset:BitmapAsset):Void
	{
		AssetLib.createStarlingTexture(bitmapAsset.path, texture, bitmapAsset);
	}
	
	private function onAddAtlasButton(evt:TriggerEvent):Void
	{
		disableUI();
		_atlasLoader.start(atlasLoadComplete, enableUI, enableUI);
	}
	
	private function onAddTextureButton(evt:TriggerEvent):Void
	{
		disableUI();
		_textureLoader.start(textureLoadComplete, enableUI, enableUI);
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
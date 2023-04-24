package ui.feathers.window.starling;

import feathers.controls.Button;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import ui.feathers.renderers.starling.StarlingAtlasAssetItemRenderer;
import ui.feathers.window.AssetsWindow;
import valedit.asset.AssetLib;
import valedit.asset.starling.StarlingAtlasAsset;

/**
 * ...
 * @author Matse
 */
class StarlingAtlasAssetsWindow extends AssetsWindow<StarlingAtlasAsset>
{
	private var _addAtlasButton:Button;

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
	
	private function onAddAtlasbutton(evt:TriggerEvent):Void
	{
		
	}
	
}
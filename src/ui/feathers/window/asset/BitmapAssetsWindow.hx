package ui.feathers.window.asset;

import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.BitmapData;
import openfl.net.FileFilter;
import ui.feathers.renderers.BitmapAssetItemRenderer;
import ui.feathers.window.asset.AssetsWindow;
import valedit.asset.AssetLib;
import valedit.asset.BitmapAsset;
#if desktop
import openfl.filesystem.File;
import utils.file.asset.BitmapFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import utils.file.asset.BitmapFilesLoader;
#end

/**
 * ...
 * @author Matse
 */
class BitmapAssetsWindow extends AssetsWindow<BitmapAsset>
{	
	#if desktop
	private var _imageLoader:BitmapFilesLoaderDesktop = new BitmapFilesLoaderDesktop();
	#else
	private var _imageLoader:BitmapFilesLoader = new BitmapFilesLoader();
	#end
	
	public function new() 
	{
		super();
	}
	
	@:access(valedit.asset.AssetLib)
	override function initialize():Void 
	{
		super.initialize();
		
		_extensionList = ["jpg", "jpeg", "png", "gif"];
		_filterList = [new FileFilter("Images (*.jpeg, *.jpg, *.gif, *.png)", "*.jpeg;*.jpg;*.gif;*.png")];
		
		_assetList.dataProvider = AssetLib._bitmapCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new BitmapAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:BitmapAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		_assetList.itemRendererRecycler = recycler;
		_assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		controlsEnable();
	}
	
	private function bitmapDataLoadComplete(path:String, bmd:BitmapData):Void
	{
		AssetLib.createBitmap(path, bmd);
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		_imageLoader.start(files, bitmapDataLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		_imageLoader.start(files, bitmapDataLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void 
	{
		_imageLoader.start(files, bitmapDataLoadComplete, enableUI);
	}
	#end
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			AssetLib.removeBitmap(item);
		}
	}
	
}
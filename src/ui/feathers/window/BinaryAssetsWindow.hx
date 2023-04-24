package ui.feathers.window;
import feathers.data.ListViewItemState;
import feathers.utils.DisplayObjectRecycler;
import openfl.utils.ByteArray;
import ui.feathers.renderers.BinaryAssetItemRenderer;
import valedit.asset.AssetLib;
import valedit.asset.BinaryAsset;
#if desktop
import openfl.filesystem.File;
import utils.file.BinaryFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import utils.file.BinaryFilesLoader;
#end

/**
 * ...
 * @author Matse
 */
class BinaryAssetsWindow extends AssetsWindow<BinaryAsset>
{
	#if desktop
	private var _binaryLoader:BinaryFilesLoaderDesktop = new BinaryFilesLoaderDesktop();
	#else
	private var _binaryLoader:BinaryFilesLoader = new BinaryFilesLoader();
	#end
	
	public function new() 
	{
		super();
	}
	
	@:access(valedit.asset.AssetLib)
	override function initialize():Void 
	{
		super.initialize();
		
		_extensionList = [];
		_filterList = [];
		
		_assetList.dataProvider = AssetLib._binaryCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new BinaryAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:BinaryAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		_assetList.itemRendererRecycler = recycler;
		_assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		controlsEnable();
	}
	
	private function binaryLoadComplete(path:String, bytes:ByteArray):Void
	{
		AssetLib.createBinary(path, bytes);
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		_binaryLoader.start(files, binaryLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		_binaryLoader.start(files, binaryLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		_binaryLoader.start(files, binaryLoadComplete, enableUI);
	}
	#end
	
}
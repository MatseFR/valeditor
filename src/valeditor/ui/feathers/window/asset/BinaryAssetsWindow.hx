package valeditor.ui.feathers.window.asset;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import openfl.utils.ByteArray;
import valeditor.ui.feathers.renderers.BinaryAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
import valedit.asset.AssetLib;
import valedit.asset.BinaryAsset;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.asset.BinaryFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.asset.BinaryFilesLoader;
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
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._extensionList = [];
		this._filterList = [];
		
		this._assetList.dataProvider = AssetLib.binaryCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new BinaryAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:BinaryAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
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
		this._binaryLoader.start(files, binaryLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._binaryLoader.start(files, binaryLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		this._binaryLoader.start(files, binaryLoadComplete, enableUI);
	}
	#end
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			AssetLib.removeBinary(item);
		}
	}
	
}
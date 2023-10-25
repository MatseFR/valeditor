package valeditor.ui.feathers.window.asset;
import feathers.events.TriggerEvent;
import openfl.utils.ByteArray;
import valeditor.ui.feathers.window.asset.AssetsWindow;
import valedit.asset.AssetLib;
import feathers.data.ListViewItemState;
import feathers.utils.DisplayObjectRecycler;
import openfl.media.Sound;
import openfl.net.FileFilter;
import valeditor.ui.feathers.renderers.SoundAssetItemRenderer;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.asset.SoundFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.asset.SoundFilesLoader;
#end
import valedit.asset.SoundAsset;

/**
 * ...
 * @author Matse
 */
class SoundAssetsWindow extends AssetsWindow<SoundAsset>
{
	#if desktop
	private var _soundLoader:SoundFilesLoaderDesktop = new SoundFilesLoaderDesktop();
	#else
	private var _soundLoader:SoundFilesLoader = new SoundFilesLoader();
	#end
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		#if flash
		this._extensionList = ["mp3", "wav"];
		this._filterList = [new FileFilter("Sounds (*.mp3, *.wav)", "*.mp3;*.wav")];
		#else
		this._extensionList = ["ogg", "wav"];
		this._filterList = [new FileFilter("Sounds (*.ogg, *.wav)", "*.ogg;*.wav")];
		#end
		
		this._assetList.dataProvider = AssetLib.soundCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new SoundAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:SoundAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		controlsEnable();
	}
	
	private function soundLoadComplete(path:String, sound:Sound, data:ByteArray):Void
	{
		AssetLib.createSound(path, sound, data);
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		this._soundLoader.start(files, soundLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._soundLoader.start(files, soundLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		this._soundLoader.start(files, soundLoadComplete, enableUI);
	}
	#end
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			AssetLib.removeSound(item);
		}
	}
	
}
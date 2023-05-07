package ui.feathers.window.asset;
import feathers.data.ListViewItemState;
import feathers.utils.DisplayObjectRecycler;
import openfl.net.FileFilter;
import ui.feathers.renderers.TextAssetItemRenderer;
import ui.feathers.window.asset.AssetsWindow;
import valedit.asset.AssetLib;
import valedit.asset.TextAsset;
#if desktop
import openfl.filesystem.File;
import utils.file.asset.TextFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import utils.file.asset.TextFilesLoader;
#end

/**
 * ...
 * @author Matse
 */
class TextAssetsWindow extends AssetsWindow<TextAsset>
{
	#if desktop
	private var _textLoader:TextFilesLoaderDesktop = new TextFilesLoaderDesktop();
	#else
	private var _textLoader:TextFilesLoader = new TextFilesLoader();
	#end
	
	public function new() 
	{
		super();
	}
	
	@:access(valedit.asset.AssetLib)
	override function initialize():Void 
	{
		super.initialize();
		
		_extensionList = ["txt", "xml", "json"];
		_filterList = [new FileFilter("Text", "*.txt;*.xml;*.json")];
		
		_assetList.dataProvider = AssetLib._textCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new TextAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:TextAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		_assetList.itemRendererRecycler = recycler;
		_assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		controlsEnable();
	}
	
	private function textLoadComplete(path:String, text:String):Void
	{
		AssetLib.createText(path, text);
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		_textLoader.start(files, textLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		_textLoader.start(files, textLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		_textLoader.start(files, textLoadComplete, enableUI);
	}
	#end
	
}
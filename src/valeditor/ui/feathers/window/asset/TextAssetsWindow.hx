package valeditor.ui.feathers.window.asset;
import feathers.data.ListViewItemState;
import feathers.events.TriggerEvent;
import feathers.utils.DisplayObjectRecycler;
import openfl.net.FileFilter;
import valeditor.ui.feathers.renderers.TextAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
import valedit.asset.AssetLib;
import valedit.asset.TextAsset;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.asset.TextFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.asset.TextFilesLoader;
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
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._extensionList = ["txt", "xml", "json"];
		this._filterList = [new FileFilter("Text", "*.txt;*.xml;*.json")];
		
		this._assetList.dataProvider = AssetLib.textCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new TextAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:TextAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
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
		this._textLoader.start(files, textLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._textLoader.start(files, textLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		this._textLoader.start(files, textLoadComplete, enableUI);
	}
	#end
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			AssetLib.removeText(item);
		}
	}
	
}
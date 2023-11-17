package valeditor.ui.feathers.window.asset;
import feathers.controls.ListView;
import feathers.controls.popups.CalloutPopUpAdapter;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.net.FileFilter;
import valedit.ValEdit;
import valedit.asset.TextAsset;
import valeditor.ui.feathers.renderers.TextAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.FileOpenerDesktop;
import valeditor.utils.file.asset.TextFilesLoaderDesktop;
import valeditor.utils.file.asset.TextFileUpdaterDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.FileOpener;
import valeditor.utils.file.asset.TextFilesLoader;
import valeditor.utils.file.asset.TextFileUpdater;
#end

/**
 * ...
 * @author Matse
 */
class TextAssetsWindow extends AssetsWindow<TextAsset>
{
	#if desktop
	private var _fileOpener:FileOpenerDesktop = new FileOpenerDesktop();
	private var _textLoader:TextFilesLoaderDesktop = new TextFilesLoaderDesktop();
	private var _textUpdater:TextFileUpdaterDesktop = new TextFileUpdaterDesktop();
	#else
	private var _fileOpener:FileOpener = new FileOpener();
	private var _textLoader:TextFilesLoader = new TextFilesLoader();
	private var _textUpdater:TextFileUpdater = new TextFileUpdater();
	#end
	
	private var _contextMenu:ListView;
	private var _contextMenuAsset:TextAsset;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _dummySprite:Sprite;
	private var _pt:Point = new Point();
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._extensionList = ["txt", "xml", "json"];
		this._filterList = [new FileFilter("Text", "*.txt;*.xml;*.json")];
		
		this._assetList.dataProvider = ValEdit.assetLib.textCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:TextAssetItemRenderer = new TextAssetItemRenderer();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			return renderer;
		});
		
		recycler.update = (itemRenderer:TextAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		var data:ArrayCollection<Dynamic>;
		#if desktop
		data = new ArrayCollection<Dynamic>([{id:"refresh", name:"refresh"}, {id:"import", name:"import"}, {id:"remove", name:"remove"}]);
		#else
		data = new ArrayCollection<Dynamic>([{id:"import", name:"import"}, {id:"remove", name:"remove"}]);
		#end
		this._contextMenu = new ListView(data);
		var listLayout:VerticalListLayout = new VerticalListLayout();
		listLayout.requestedRowCount = data.length;
		this._contextMenu.layout = listLayout;
		
		this._contextMenu.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		this._contextMenu.addEventListener(Event.CHANGE, onContextMenuChange);
		this._contextMenu.addEventListener(ListViewEvent.ITEM_TRIGGER, onContextMenuItemTrigger);
		
		this._dummySprite = new Sprite();
		this._dummySprite.mouseEnabled = false;
		this._dummySprite.graphics.beginFill(0xff0000, 0);
		this._dummySprite.graphics.drawRect(0, 0, 4, 4);
		this._dummySprite.graphics.endFill();
		addChild(this._dummySprite);
	}
	
	private function textLoadComplete(path:String, text:String):Void
	{
		ValEdit.assetLib.createText(path, text);
	}
	
	private function closeContextMenu():Void
	{
		this._popupAdapter.close();
		this._contextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		this._textLoader.addFiles(files);
		this._textLoader.start(textLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._textLoader.addFiles(files);
		this._textLoader.start(textLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		disableUI();
		this._textLoader.addFiles(files);
		this._textLoader.start(textLoadComplete, enableUI);
	}
	#end
	
	private function onContextMenuChange(evt:Event):Void
	{
		if (this._contextMenu.selectedItem == null) return;
		
		switch (this._contextMenu.selectedItem.id)
		{
			case "refresh" :
				#if desktop
				var file:File = new File(this._contextMenuAsset.path);
				if (file.exists)
				{
					this._textUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
				}
				else
				{
					this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
				}
				#end
			
			case "import" :
				this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
			
			case "remove" :
				ValEdit.assetLib.removeText(this._contextMenuAsset);
		}
	}
	
	private function onContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		closeContextMenu();
	}
	
	private function onAssetFileCancelled():Void
	{
		
	}
	
	#if desktop
	private function onAssetFileSelected(file:File):Void
	{
		this._textUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#else
	private function onAssetFileSelected(file:FileReference):Void
	{
		this._textUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#end
	
	private function onAssetUpdateComplete():Void
	{
		
	}
	
	private function onItemRightClick(evt:MouseEvent):Void
	{
		var renderer:TextAssetItemRenderer = cast evt.currentTarget;
		this._contextMenuAsset = renderer.asset;
		var object:DisplayObject = cast evt.target;
		this._pt.x = evt.localX;
		this._pt.y = evt.localY;
		this._pt = object.localToGlobal(this._pt);
		this._pt = globalToLocal(this._pt);
		this._dummySprite.x = this._pt.x;
		this._dummySprite.y = this._pt.y;
		
		if (this._popupAdapter.active)
		{
			closeContextMenu();
		}
		this._contextMenu.selectedIndex = -1;
		this._popupAdapter.open(this._contextMenu, this._dummySprite);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
	}
	
	override function onRemoveButton(evt:TriggerEvent):Void 
	{
		var items:Array<Dynamic> = this._assetList.selectedItems.copy();
		for (item in items)
		{
			ValEdit.assetLib.removeText(item);
		}
	}
	
	private function onStageMouseDown(evt:MouseEvent):Void
	{
		if (this._contextMenu.hitTestPoint(evt.stageX, evt.stageY))
		{
			return;
		}
		
		closeContextMenu();
	}
	
}
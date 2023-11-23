package valeditor.ui.feathers.window.asset;

import feathers.controls.ListView;
import feathers.controls.popups.CalloutPopUpAdapter;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.net.FileFilter;
import valedit.ValEdit;
import valedit.asset.BitmapAsset;
import valeditor.ui.feathers.data.AssetMenuItem;
import valeditor.ui.feathers.renderers.asset.BitmapAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.FileOpenerDesktop;
import valeditor.utils.file.asset.BitmapFilesLoaderDesktop;
import valeditor.utils.file.asset.BitmapFileUpdaterDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.FileOpener;
import valeditor.utils.file.asset.BitmapFilesLoader;
import valeditor.utils.file.asset.BitmapFileUpdater;
#end

/**
 * ...
 * @author Matse
 */
class BitmapAssetsWindow extends AssetsWindow<BitmapAsset>
{	
	#if desktop
	private var _fileOpener:FileOpenerDesktop = new FileOpenerDesktop();
	private var _imageLoader:BitmapFilesLoaderDesktop = new BitmapFilesLoaderDesktop();
	private var _imageUpdater:BitmapFileUpdaterDesktop = new BitmapFileUpdaterDesktop();
	#else
	private var _fileOpener:FileOpener = new FileOpener();
	private var _imageLoader:BitmapFilesLoader = new BitmapFilesLoader();
	private var _imageUpdater:BitmapFileUpdater = new BitmapFileUpdater();
	#end
	
	private var _contextMenu:ListView;
	private var _contextMenuAsset:BitmapAsset;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _dummySprite:Sprite;
	private var _pt:Point = new Point();
	
	private var _contextMenuData:ArrayCollection<AssetMenuItem>;
	#if desktop
	private var _refreshMenuItem:AssetMenuItem;
	#end
	private var _importMenuItem:AssetMenuItem;
	private var _removeMenuItem:AssetMenuItem;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._extensionList = ["jpg", "jpeg", "png", "gif"];
		this._filterList = [new FileFilter("Images (*.jpeg, *.jpg, *.gif, *.png)", "*.jpeg;*.jpg;*.gif;*.png")];
		
		this._assetList.dataProvider = ValEdit.assetLib.bitmapCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:BitmapAssetItemRenderer = new BitmapAssetItemRenderer();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			return renderer;
		});
		
		recycler.update = (itemRenderer:BitmapAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		recycler.reset = (itemRenderer:BitmapAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.clear();
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		#if desktop
		this._refreshMenuItem = new AssetMenuItem("refresh", "refresh");
		#end
		this._importMenuItem = new AssetMenuItem("import", "import");
		this._removeMenuItem = new AssetMenuItem("remove", "remove");
		
		#if desktop
		this._contextMenuData = new ArrayCollection<AssetMenuItem>([this._refreshMenuItem, this._importMenuItem, this._removeMenuItem]);
		#else
		this._contextMenuData = new ArrayCollection<AssetMenuItem>([this._importMenuItem, this._removeMenuItem]);
		#end
		
		this._contextMenu = new ListView(this._contextMenuData);
		var listLayout:VerticalListLayout = new VerticalListLayout();
		listLayout.requestedRowCount = this._contextMenuData.length;
		this._contextMenu.layout = listLayout;
		
		this._contextMenu.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		this._contextMenu.itemToEnabled = function(item:Dynamic):Bool
		{
			return item.enabled;
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
	
	private function bitmapDataLoadComplete(path:String, bmd:BitmapData, data:Bytes):Void
	{
		ValEdit.assetLib.createBitmap(path, bmd, data);
	}
	
	private function closeContextMenu():Void
	{
		this._popupAdapter.close();
		this._contextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
		//this._contextMenuAsset = null;
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		this._imageLoader.addFiles(files);
		this._imageLoader.start(bitmapDataLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._imageLoader.addFiles(files);
		this._imageLoader.start(bitmapDataLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void 
	{
		disableUI();
		this._imageLoader.addFiles(files);
		this._imageLoader.start(bitmapDataLoadComplete, enableUI);
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
					this._imageUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
				}
				else
				{
					this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
				}
				#end
			
			case "import" :
				this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
			
			case "remove" :
				ValEdit.assetLib.removeBitmap(this._contextMenuAsset);
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
		this._imageUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#else
	private function onAssetFileSelected(file:FileReference):Void
	{
		this._imageUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#end
	
	private function onAssetUpdateComplete():Void
	{
		
	}
	
	private function onItemRightClick(evt:MouseEvent):Void
	{
		var renderer:BitmapAssetItemRenderer = cast evt.currentTarget;
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
			ValEdit.assetLib.removeBitmap(item);
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
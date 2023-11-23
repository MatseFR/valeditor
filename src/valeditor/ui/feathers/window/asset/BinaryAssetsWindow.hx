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
import openfl.utils.ByteArray;
import valedit.ValEdit;
import valedit.asset.BinaryAsset;
import valeditor.ui.feathers.data.AssetMenuItem;
import valeditor.ui.feathers.renderers.asset.BinaryAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.FileOpenerDesktop;
import valeditor.utils.file.asset.BinaryFilesLoaderDesktop;
import valeditor.utils.file.asset.BinaryFileUpdaterDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.FileOpener;
import valeditor.utils.file.asset.BinaryFilesLoader;
import valeditor.utils.file.asset.BinaryFileUpdater;
#end

/**
 * ...
 * @author Matse
 */
class BinaryAssetsWindow extends AssetsWindow<BinaryAsset>
{
	#if desktop
	private var _fileOpener:FileOpenerDesktop = new FileOpenerDesktop();
	private var _binaryLoader:BinaryFilesLoaderDesktop = new BinaryFilesLoaderDesktop();
	private var _binaryUpdater:BinaryFileUpdaterDesktop = new BinaryFileUpdaterDesktop();
	#else
	private var _fileOpener:FileOpener = new FileOpener();
	private var _binaryLoader:BinaryFilesLoader = new BinaryFilesLoader();
	private var _binaryUpdater:BinaryFileUpdater = new BinaryFileUpdater();
	#end
	
	private var _contextMenu:ListView;
	private var _contextMenuAsset:BinaryAsset;
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
		
		this._extensionList = [];
		this._filterList = [];
		
		this._assetList.dataProvider = ValEdit.assetLib.binaryCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:BinaryAssetItemRenderer = new BinaryAssetItemRenderer();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			return renderer;
		});
		
		recycler.update = (itemRenderer:BinaryAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		recycler.reset = (itemRenderer:BinaryAssetItemRenderer, state:ListViewItemState) -> {
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
	
	private function binaryLoadComplete(path:String, bytes:ByteArray):Void
	{
		ValEdit.assetLib.createBinary(path, bytes);
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
		this._binaryLoader.addFiles(files);
		this._binaryLoader.start(binaryLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._binaryLoader.addFiles(files);
		this._binaryLoader.start(binaryLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		disableUI();
		this._binaryLoader.addFiles(files);
		this._binaryLoader.start(binaryLoadComplete, enableUI);
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
					this._binaryUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
				}
				else
				{
					this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
				}
				#end
			
			case "import" :
				this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
			
			case "remove" :
				ValEdit.assetLib.removeBinary(this._contextMenuAsset);
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
		this._binaryUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#else
	private function onAssetFileSelected(file:FileReference):Void
	{
		this._binaryUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#end
	
	private function onAssetUpdateComplete():Void
	{
		
	}
	
	private function onItemRightClick(evt:MouseEvent):Void
	{
		var renderer:BinaryAssetItemRenderer = cast evt.currentTarget;
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
			ValEdit.assetLib.removeBinary(item);
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
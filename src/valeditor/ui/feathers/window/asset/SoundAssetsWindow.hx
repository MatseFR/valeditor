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
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.media.Sound;
import openfl.net.FileFilter;
import valedit.ValEdit;
import valedit.asset.SoundAsset;
import valeditor.ui.feathers.data.AssetMenuItem;
import valeditor.ui.feathers.renderers.asset.SoundAssetItemRenderer;
import valeditor.ui.feathers.variant.ListViewVariant;
import valeditor.ui.feathers.window.asset.AssetsWindow;
#if desktop
import openfl.filesystem.File;
import valeditor.utils.file.FileOpenerDesktop;
import valeditor.utils.file.asset.SoundFileUpdaterDesktop;
import valeditor.utils.file.asset.SoundFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.FileOpener;
import valeditor.utils.file.asset.SoundFilesLoader;
import valeditor.utils.file.asset.SoundFileUpdater;
#end

/**
 * ...
 * @author Matse
 */
class SoundAssetsWindow extends AssetsWindow<SoundAsset>
{
	#if desktop
	private var _fileOpener:FileOpenerDesktop = new FileOpenerDesktop();
	private var _soundLoader:SoundFilesLoaderDesktop = new SoundFilesLoaderDesktop();
	private var _soundUpdater:SoundFileUpdaterDesktop = new SoundFileUpdaterDesktop();
	#else
	private var _fileOpener:FileOpener = new FileOpener();
	private var _soundLoader:SoundFilesLoader = new SoundFilesLoader();
	private var _soundUpdater:SoundFileUpdater = new SoundFileUpdater();
	#end
	
	private var _contextMenu:ListView;
	private var _contextMenuAsset:SoundAsset;
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
		
		#if flash
		this._extensionList = ["mp3", "wav"];
		this._filterList = [new FileFilter("Sounds (*.mp3, *.wav)", "*.mp3;*.wav")];
		#else
		this._extensionList = ["ogg", "wav"];
		this._filterList = [new FileFilter("Sounds (*.ogg, *.wav)", "*.ogg;*.wav")];
		#end
		
		this._assetList.dataProvider = ValEdit.assetLib.soundCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:SoundAssetItemRenderer = new SoundAssetItemRenderer();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			return renderer;
		});
		
		recycler.update = (itemRenderer:SoundAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		recycler.reset = (itemRenderer:SoundAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.clear();
		};
		
		recycler.destroy = (itemRenderer:SoundAssetItemRenderer) -> {
			itemRenderer.removeEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			itemRenderer.pool();
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
		this._contextMenu.variant = ListViewVariant.CONTEXT_MENU;
		var listLayout:VerticalListLayout = new VerticalListLayout();
		listLayout.requestedRowCount = this._contextMenuData.length;
		this._contextMenu.layout = listLayout;
		
		this._contextMenu.itemToText = function(item:Dynamic):String
		{
			return item.text;
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
	
	private function soundLoadComplete(path:String, sound:Sound, data:Bytes):Void
	{
		ValEdit.assetLib.createSound(path, sound, data);
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
		this._soundLoader.addFiles(files);
		this._soundLoader.start(soundLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		this._soundLoader.addFiles(files);
		this._soundLoader.start(soundLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		disableUI();
		this._soundLoader.addFiles(files);
		this._soundLoader.start(soundLoadComplete, enableUI);
	}
	#end
	
	private function onContextMenuChange(evt:Event):Void
	{
		if (this._contextMenu.selectedItem == null) return;
		
		if (!this._contextMenu.selectedItem.enabled) return;
		
		switch (this._contextMenu.selectedItem.id)
		{
			case "refresh" :
				#if desktop
				var file:File = new File(this._contextMenuAsset.path);
				if (file.exists)
				{
					this._soundUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
				}
				else
				{
					this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
				}
				#end
			
			case "import" :
				this._fileOpener.start(onAssetFileSelected, onAssetFileCancelled, this._filterList);
			
			case "remove" :
				ValEdit.assetLib.removeSound(this._contextMenuAsset);
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
		this._soundUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#else
	private function onAssetFileSelected(file:FileReference):Void
	{
		this._soundUpdater.start(this._contextMenuAsset, file, onAssetUpdateComplete);
	}
	#end
	
	private function onAssetUpdateComplete():Void
	{
		
	}
	
	private function onItemRightClick(evt:MouseEvent):Void
	{
		var renderer:SoundAssetItemRenderer = cast evt.currentTarget;
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
			ValEdit.assetLib.removeSound(item);
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
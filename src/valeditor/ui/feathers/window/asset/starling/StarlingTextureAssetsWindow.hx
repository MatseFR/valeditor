package valeditor.ui.feathers.window.asset.starling;
import feathers.controls.Button;
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
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import valedit.ValEdit;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.asset.starling.StarlingTextureAsset;
import valeditor.ui.feathers.data.AssetMenuItem;
import valeditor.ui.feathers.renderers.asset.starling.StarlingTextureAssetItemRenderer;
import valeditor.ui.feathers.variant.ListViewVariant;
import valeditor.ui.feathers.window.asset.AssetsWindow;
import valeditor.utils.starling.AtlasLoader;
import valeditor.utils.starling.TextureCreationParameters;
import valeditor.utils.starling.TextureLoader;
import valeditor.utils.starling.TextureSourceUpdater;

/**
 * ...
 * @author Matse
 */
class StarlingTextureAssetsWindow extends AssetsWindow<StarlingTextureAsset>
{
	private var _addAtlasButton:Button;
	private var _addTextureButton:Button;
	
	private var _atlasLoader:AtlasLoader = new AtlasLoader();
	private var _textureLoader:TextureLoader = new TextureLoader();
	private var _textureUpdater:TextureSourceUpdater = new TextureSourceUpdater();
	
	private var _contextMenu:ListView;
	private var _contextMenuAsset:StarlingTextureAsset;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _dummySprite:Sprite;
	private var _pt:Point = new Point();
	
	private var _contextMenuData:ArrayCollection<AssetMenuItem>;
	private var _sourceMenuItem:AssetMenuItem;
	private var _removeMenuItem:AssetMenuItem;
	
	public function new() 
	{
		super();
		this._filesEnabled = false;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._addAtlasButton = new Button("add Atlas");
		this._footerGroup.addChildAt(this._addAtlasButton, 0);
		this._buttonList.push(this._addAtlasButton);
		
		this._addTextureButton = new Button("add Texture");
		this._footerGroup.addChildAt(this._addTextureButton, 1);
		this._buttonList.push(this._addTextureButton);
		
		this._assetList.dataProvider = ValEdit.assetLib.starlingTextureCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:StarlingTextureAssetItemRenderer = new StarlingTextureAssetItemRenderer();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			return renderer;
		});
		
		recycler.update = (itemRenderer:StarlingTextureAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		recycler.reset = (itemRenderer:StarlingTextureAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.clear();
		};
		
		recycler.destroy = (itemRenderer:StarlingTextureAssetItemRenderer) -> {
			itemRenderer.removeEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			itemRenderer.pool();
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		this._sourceMenuItem = new AssetMenuItem("source asset", "source asset");
		this._removeMenuItem = new AssetMenuItem("remove", "remove");
		
		this._contextMenuData = new ArrayCollection<AssetMenuItem>([this._sourceMenuItem, this._removeMenuItem]);
		
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
	
	private function closeContextMenu():Void
	{
		this._popupAdapter.close();
		this._contextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
	}
	
	override function controlsDisable():Void 
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._addAtlasButton.removeEventListener(TriggerEvent.TRIGGER, onAddAtlasButton);
		this._addTextureButton.removeEventListener(TriggerEvent.TRIGGER, onAddTextureButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._addAtlasButton.addEventListener(TriggerEvent.TRIGGER, onAddAtlasButton);
		this._addTextureButton.addEventListener(TriggerEvent.TRIGGER, onAddTextureButton);
	}
	
	private function atlasLoadComplete(atlas:TextureAtlas, textureParams:TextureCreationParameters, bitmapAsset:BitmapAsset, textAsset:TextAsset):Void
	{
		ValEdit.assetLib.createStarlingAtlas(bitmapAsset.path, atlas, textureParams, bitmapAsset, textAsset);
	}
	
	private function textureLoadComplete(texture:Texture, textureParams:TextureCreationParameters, bitmapAsset:BitmapAsset):Void
	{
		ValEdit.assetLib.createStarlingTexture(bitmapAsset.path, texture, textureParams, bitmapAsset);
	}
	
	private function onAddAtlasButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._atlasLoader.start(atlasLoadComplete, enableUI, enableUI);
	}
	
	private function onAddTextureButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._textureLoader.start(textureLoadComplete, enableUI, enableUI);
	}
	
	private function onContextMenuChange(evt:Event):Void
	{
		if (this._contextMenu.selectedItem == null) return;
		
		if (!this._contextMenu.selectedItem.enabled) return;
		
		switch (this._contextMenu.selectedItem.id)
		{
			case "source asset" :
				this._textureUpdater.start(this._contextMenuAsset, null, null);
			
			case "remove" :
				ValEdit.assetLib.removeStarlingTexture(this._contextMenuAsset);
		}
	}
	
	private function onContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		closeContextMenu();
	}
	
	private function onItemRightClick(evt:MouseEvent):Void
	{
		var renderer:StarlingTextureAssetItemRenderer = cast evt.currentTarget;
		this._contextMenuAsset = renderer.asset;
		this._removeMenuItem.enabled = !this._contextMenuAsset.isFromAtlas;
		this._contextMenuData.updateAt(this._contextMenuData.indexOf(this._removeMenuItem));
		
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
			if (item.isFromAtlas) continue;
			ValEdit.assetLib.removeStarlingTexture(item);
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
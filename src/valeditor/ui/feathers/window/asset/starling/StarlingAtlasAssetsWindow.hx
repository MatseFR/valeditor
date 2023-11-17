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
import starling.textures.TextureAtlas;
import valedit.ValEdit;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.asset.starling.StarlingAtlasAsset;
import valeditor.ui.feathers.renderers.starling.StarlingAtlasAssetItemRenderer;
import valeditor.ui.feathers.window.asset.AssetsWindow;
import valeditor.utils.starling.AtlasLoader;
import valeditor.utils.starling.TextureCreationParameters;

/**
 * ...
 * @author Matse
 */
class StarlingAtlasAssetsWindow extends AssetsWindow<StarlingAtlasAsset>
{
	private var _addAtlasButton:Button;
	
	private var _atlasLoader:AtlasLoader = new AtlasLoader();
	
	private var _contextMenu:ListView;
	private var _contextMenuAsset:StarlingAtlasAsset;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _dummySprite:Sprite;
	private var _pt:Point = new Point();

	public function new() 
	{
		super();
		this._filesEnabled = false;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this._addAtlasButton = new Button("add Atlas");
		this._footerGroup.addChildAt(_addAtlasButton, 0);
		this._buttonList.push(_addAtlasButton);
		
		this._assetList.dataProvider = ValEdit.assetLib.starlingAtlasCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:StarlingAtlasAssetItemRenderer = new StarlingAtlasAssetItemRenderer();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onItemRightClick);
			return renderer;
		});
		
		recycler.update = (itemRenderer:StarlingAtlasAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		this._assetList.itemRendererRecycler = recycler;
		this._assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		var data:ArrayCollection<Dynamic>;
		#if desktop
		data = new ArrayCollection<Dynamic>([{id:"remove", name:"remove"}]);
		#else
		data = new ArrayCollection<Dynamic>([{id:"remove", name:"remove"}]);
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
		this._addAtlasButton.removeEventListener(TriggerEvent.TRIGGER, onAddAtlasbutton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
		super.controlsEnable();
		this._addAtlasButton.addEventListener(TriggerEvent.TRIGGER, onAddAtlasbutton);
	}
	
	private function atlasLoadComplete(atlas:TextureAtlas, textureParams:TextureCreationParameters, bitmapAsset:BitmapAsset, textAsset:TextAsset):Void
	{
		ValEdit.assetLib.createStarlingAtlas(bitmapAsset.path, atlas, textureParams, bitmapAsset, textAsset);
	}
	
	private function onAddAtlasbutton(evt:TriggerEvent):Void
	{
		disableUI();
		this._atlasLoader.start(atlasLoadComplete, enableUI, enableUI);
	}
	
	private function onContextMenuChange(evt:Event):Void
	{
		if (this._contextMenu.selectedItem == null) return;
		
		switch (this._contextMenu.selectedItem.id)
		{
			case "remove" :
				ValEdit.assetLib.removeStarlingAtlas(this._contextMenuAsset);
		}
	}
	
	private function onContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		closeContextMenu();
	}
	
	private function onItemRightClick(evt:MouseEvent):Void
	{
		var renderer:StarlingAtlasAssetItemRenderer = cast evt.currentTarget;
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
			ValEdit.assetLib.removeStarlingAtlas(item);
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
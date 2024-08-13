package valeditor.ui.feathers.renderers.asset.starling;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.display.Bitmap;
import valeditor.ui.feathers.renderers.asset.AssetItemRenderer;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;
import valedit.asset.starling.StarlingAtlasAsset;

/**
 * ...
 * @author Matse
 */
class StarlingAtlasAssetItemRenderer extends AssetItemRenderer 
{
	static private var _POOL:Array<StarlingAtlasAssetItemRenderer> = new Array<StarlingAtlasAssetItemRenderer>();
	
	static public function fromPool():StarlingAtlasAssetItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new StarlingAtlasAssetItemRenderer();
	}
	
	public var asset(get, set):StarlingAtlasAsset;
	private var _asset:StarlingAtlasAsset;
	private function get_asset():StarlingAtlasAsset { return this._asset; }
	private function set_asset(value:StarlingAtlasAsset):StarlingAtlasAsset
	{
		if (value != null)
		{
			this._preview.bitmapData = value.preview;
			this._previewGroup.setInvalid();
			
			this._nameLabel.text = value.name;
			this._sizeLabel.text = Std.string(value.content.texture.width) + "x" + Std.string(value.content.texture.height);
		}
		else
		{
			this._preview.bitmapData = null;
			this._nameLabel.text = "";
			this._sizeLabel.text = "";
		}
		
		return this._asset = value;
	}
	
	private var _previewGroup:LayoutGroup;
	private var _preview:Bitmap;
	
	private var _nameLabel:Label;
	private var _sizeLabel:Label;
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		this.asset = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.layout = vLayout;
		
		this._previewGroup = new LayoutGroup();
		this._previewGroup.variant = LayoutGroupVariant.ITEM_PREVIEW;
		addChild(this._previewGroup);
		
		this._preview = new Bitmap();
		this._preview.smoothing = true;
		this._previewGroup.addChild(this._preview);
		
		this._nameLabel = new Label();
		this._nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._nameLabel);
		
		this._sizeLabel = new Label();
		this._sizeLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._sizeLabel);
	}
	
}
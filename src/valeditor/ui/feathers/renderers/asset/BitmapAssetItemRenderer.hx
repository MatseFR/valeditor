package valeditor.ui.feathers.renderers.asset;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.display.Bitmap;
import valeditor.ui.feathers.renderers.asset.AssetItemRenderer;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valedit.asset.BitmapAsset;

/**
 * ...
 * @author Matse
 */
class BitmapAssetItemRenderer extends AssetItemRenderer 
{
	public var asset(get, set):BitmapAsset;
	private var _asset:BitmapAsset;
	private function get_asset():BitmapAsset { return this._asset; }
	private function set_asset(value:BitmapAsset):BitmapAsset
	{
		if (value != null)
		{
			this._preview.bitmapData = value.preview;
			this._previewGroup.setInvalid();
			
			this._nameLabel.text = value.name;
			if (value.content != null)
			{
				this._sizeLabel.text = Std.string(value.content.width) + "x" + Std.string(value.content.height);
			}
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
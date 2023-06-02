package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.display.Bitmap;
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
		if (this._asset == value) return value;
		
		if (value != null)
		{
			_preview.bitmapData = value.preview;
			_previewGroup.setInvalid();
			
			_nameLabel.text = value.name;
			if (value.content != null)
			{
				_sizeLabel.text = Std.string(value.content.width) + "x" + Std.string(value.content.height);
			}
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
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.layout = vLayout;
		
		_previewGroup = new LayoutGroup();
		_previewGroup.variant = LayoutGroupVariant.ITEM_PREVIEW;
		addChild(_previewGroup);
		
		_preview = new Bitmap();
		_previewGroup.addChild(_preview);
		
		_nameLabel = new Label();
		_nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(_nameLabel);
		
		_sizeLabel = new Label();
		_sizeLabel.variant = Label.VARIANT_DETAIL;
		addChild(_sizeLabel);
	}
	
}
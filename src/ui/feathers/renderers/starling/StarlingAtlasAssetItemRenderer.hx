package ui.feathers.renderers.starling;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.utils.ScaleUtil;
import openfl.display.Bitmap;
import ui.feathers.variant.LayoutGroupVariant;
import valedit.asset.starling.StarlingAtlasAsset;

/**
 * ...
 * @author Matse
 */
class StarlingAtlasAssetItemRenderer extends LayoutGroupItemRenderer 
{
	public var asset(get, set):StarlingAtlasAsset;
	private var _asset:StarlingAtlasAsset;
	private function get_asset():StarlingAtlasAsset { return this._asset; }
	private function set_asset(value:StarlingAtlasAsset):StarlingAtlasAsset
	{
		if (this._asset == value) return value;
		
		if (value != null)
		{
			_preview.bitmapData = value.bitmapAsset.content;
			var scale:Float = ScaleUtil.scaleToFit(_preview.bitmapData.width, _preview.bitmapData.height, UIConfig.ASSET_PREVIEW_SIZE, UIConfig.ASSET_PREVIEW_SIZE);
			
			_preview.scaleX = _preview.scaleY = scale;
			_previewGroup.setInvalid();
			
			_nameLabel.text = value.name;
			_sizeLabel.text = Std.string(value.content.texture.width) + "x" + Std.string(value.content.texture.height);
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
		addChild(_nameLabel);
		
		_sizeLabel = new Label();
		addChild(_sizeLabel);
	}
	
}
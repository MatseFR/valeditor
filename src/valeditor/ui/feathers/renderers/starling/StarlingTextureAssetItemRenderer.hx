package valeditor.ui.feathers.renderers.starling;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.display.Bitmap;
import starling.textures.SubTexture;
import valeditor.ui.feathers.renderers.AssetItemRenderer;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valedit.asset.starling.StarlingTextureAsset;

/**
 * ...
 * @author Matse
 */
class StarlingTextureAssetItemRenderer extends AssetItemRenderer 
{
	public var asset(get, set):StarlingTextureAsset;
	private var _asset:StarlingTextureAsset;
	private function get_asset():StarlingTextureAsset { return this._asset; }
	private function set_asset(value:StarlingTextureAsset):StarlingTextureAsset
	{
		if (this._asset == value) return value;
		
		if (value != null)
		{
			//var scale:Float;
			//_preview.bitmapData = value.bitmapAsset.content;
			//if (Std.isOfType(value.content, SubTexture))
			//{
				//var sub:SubTexture = cast value.content;
				//_preview.scrollRect = sub.region;
				//scale = ScaleUtil.scaleToFit(_preview.scrollRect.width, _preview.scrollRect.height, UIConfig.ASSET_PREVIEW_SIZE, UIConfig.ASSET_PREVIEW_SIZE);
			//}
			//else
			//{
				//_preview.scrollRect = null;
				//scale = ScaleUtil.scaleToFit(_preview.bitmapData.width, _preview.bitmapData.height, UIConfig.ASSET_PREVIEW_SIZE, UIConfig.ASSET_PREVIEW_SIZE);
			//}
			//_preview.scaleX = _preview.scaleY = scale;
			_preview.bitmapData = value.preview;
			_previewGroup.setInvalid();
			
			_nameLabel.text = value.name;
			_sizeLabel.text = Std.string(value.content.width) + "x" + Std.string(value.content.height);
			
			if (Std.isOfType(value.content, SubTexture))
			{
				var sub:SubTexture = cast value.content;
				if (sub.rotated)
				{
					_rotatedLabel.text = "rotated";
				}
				else
				{
					_rotatedLabel.text = "";
				}
			}
			else
			{
				_rotatedLabel.text = "";
			}
		}
		
		return this._asset = value;
	}
	
	private var _previewGroup:LayoutGroup;
	private var _preview:Bitmap;
	
	private var _nameLabel:Label;
	private var _sizeLabel:Label;
	private var _rotatedLabel:Label;
	
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
		
		_rotatedLabel = new Label();
		_rotatedLabel.variant = Label.VARIANT_DETAIL;
		addChild(_rotatedLabel);
	}
	
}
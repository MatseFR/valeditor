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
		if (value != null)
		{
			this._preview.bitmapData = value.preview;
			this._previewGroup.setInvalid();
			
			this._nameLabel.text = value.name;
			this._sizeLabel.text = Std.string(value.content.width) + "x" + Std.string(value.content.height);
			
			if (Std.isOfType(value.content, SubTexture))
			{
				var sub:SubTexture = cast value.content;
				if (sub.rotated)
				{
					this._rotatedLabel.text = "rotated";
				}
				else
				{
					this._rotatedLabel.text = "";
				}
			}
			else
			{
				this._rotatedLabel.text = "";
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
		
		this._previewGroup = new LayoutGroup();
		this._previewGroup.variant = LayoutGroupVariant.ITEM_PREVIEW;
		addChild(this._previewGroup);
		
		this._preview = new Bitmap();
		this._previewGroup.addChild(this._preview);
		
		this._nameLabel = new Label();
		this._nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._nameLabel);
		
		this._sizeLabel = new Label();
		this._sizeLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._sizeLabel);
		
		this._rotatedLabel = new Label();
		this._rotatedLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._rotatedLabel);
	}
	
}
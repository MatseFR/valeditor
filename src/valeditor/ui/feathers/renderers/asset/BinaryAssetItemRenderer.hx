package valeditor.ui.feathers.renderers.asset;

import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.asset.BinaryAsset;
import valeditor.ui.feathers.renderers.asset.AssetItemRenderer;

/**
 * ...
 * @author Matse
 */
class BinaryAssetItemRenderer extends AssetItemRenderer 
{
	public var asset(get, set):BinaryAsset;
	private var _asset:BinaryAsset;
	private function get_asset():BinaryAsset { return this._asset; }
	private function set_asset(value:BinaryAsset):BinaryAsset
	{
		if (value != null)
		{
			this._nameLabel.text = value.name;
		}
		else
		{
			this._nameLabel.text = "";
		}
		
		return this._asset = value;
	}
	
	private var _nameLabel:Label;
	
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
		
		this._nameLabel = new Label();
		this._nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._nameLabel);
	}
	
}
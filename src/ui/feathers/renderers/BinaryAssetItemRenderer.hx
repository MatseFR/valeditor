package ui.feathers.renderers;

import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.asset.BinaryAsset;

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
		if (this._asset == value) return value;
		
		if (value != null)
		{
			_nameLabel.text = value.name;
		}
		
		return this._asset = value;
	}
	
	private var _nameLabel:Label;
	
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
		
		_nameLabel = new Label();
		_nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(_nameLabel);
	}
	
}
package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.asset.TextAsset;

/**
 * ...
 * @author Matse
 */
class TextAssetItemRenderer extends AssetItemRenderer
{
	public var asset(get, set):TextAsset;
	private var _asset:TextAsset;
	private function get_asset():TextAsset { return this._asset; }
	private function set_asset(value:TextAsset):TextAsset
	{
		if (value != null)
		{
			this._nameLabel.text = value.name;
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
		
		this._nameLabel = new Label();
		this._nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._nameLabel);
	}

}
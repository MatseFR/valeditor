package valeditor.ui.feathers.renderers.asset;

import feathers.controls.Label;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import valedit.asset.TextAsset;
import valeditor.ui.feathers.renderers.asset.AssetItemRenderer;

/**
 * ...
 * @author Matse
 */
class TextAssetItemRenderer extends AssetItemRenderer
{
	static private var _POOL:Array<TextAssetItemRenderer> = new Array<TextAssetItemRenderer>();
	
	static public function fromPool():TextAssetItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextAssetItemRenderer();
	}
	
	public var asset(get, set):TextAsset;
	private var _asset:TextAsset;
	private function get_asset():TextAsset { return this._asset; }
	private function set_asset(value:TextAsset):TextAsset
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
		
		this._nameLabel = new Label();
		this._nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._nameLabel);
	}

}
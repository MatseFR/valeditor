package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import openfl.text.FontType;
import openfl.text.TextFormatAlign;
import valeditor.ui.feathers.data.FontData;
import valeditor.ui.feathers.theme.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
@:styleContext
class FontDataItemRenderer extends LayoutGroupItemRenderer 
{
	static private var _POOL:Array<FontDataItemRenderer> = new Array<FontDataItemRenderer>();
	
	static public function fromPool():FontDataItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FontDataItemRenderer();
	}
	
	public var fontData(get, set):FontData;
	
	override function set_enabled(value:Bool):Bool 
	{
		if (this._enabled == value) return value;
		if (this._initialized)
		{
			this._label.enabled = value;
			this._sampleLabel.enabled = value;
		}
		return super.set_enabled(value);
	}
	
	private var _fontData:FontData;
	private function get_fontData():FontData { return this._fontData; }
	private function set_fontData(value:FontData):FontData
	{
		if (this._initialized)
		{
			this._label.text = value.displayName;
			this._sampleLabel.textFormat.font = value.fontName;
			this._sampleLabel.disabledTextFormat.font = value.fontName;
			this._sampleLabel.embedFonts = value.fontType == FontType.DEVICE ? false : true;
		}
		return this._fontData = value;
	}
	
	private var _label:Label;
	private var _sampleLabel:Label;

	public function new() 
	{
		super();
		//initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hData:HorizontalLayoutData;
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.paddingTop = hLayout.paddingBottom = Padding.MINIMAL;
		hLayout.paddingLeft = hLayout.paddingRight = Padding.SMALL;
		hLayout.gap = Spacing.BIG;
		this.layout = hLayout;
		
		this._label = new Label();
		if (this._fontData != null) this._label.text = this._fontData.displayName;
		this._label.variant = LabelVariant.FONT_DATA_ITEM_TEXT;
		this._label.enabled = this._enabled;
		addChild(this._label);
		
		this._sampleLabel = new Label("Sample");
		this._sampleLabel.variant = LabelVariant.FONT_DATA_ITEM_SAMPLE;
		this._sampleLabel.textFormat = ValEditor.theme.getTextFormat(TextFormatAlign.RIGHT);
		this._sampleLabel.disabledTextFormat = ValEditor.theme.getTextFormat_disabled(TextFormatAlign.RIGHT);
		if (this._fontData != null)
		{
			this._sampleLabel.textFormat.font = this._fontData.fontName;
			this._sampleLabel.disabledTextFormat.font = this._fontData.fontName;
			this._sampleLabel.embedFonts = this._fontData.fontType == FontType.DEVICE ? false : true;
		}
		this._sampleLabel.enabled = this._enabled;
		hData = new HorizontalLayoutData(100);
		this._sampleLabel.layoutData = hData;
		addChild(this._sampleLabel);
	}
	
}
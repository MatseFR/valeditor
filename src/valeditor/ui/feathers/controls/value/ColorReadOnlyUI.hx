package valeditor.ui.feathers.controls.value;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.graphics.FillStyle;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.skins.RectangleSkin;
import valeditor.ui.feathers.variant.LabelVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valedit.ui.IValueUI;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class ColorReadOnlyUI extends ValueUI 
{
	private var _label:Label;
	private var _preview:LayoutGroup;
	private var _previewColor:LayoutGroup;
	private var _previewSkin:RectangleSkin;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.gap = Spacing.DEFAULT;
		this.layout = hLayout;
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_preview = new LayoutGroup();
		_preview.variant = LayoutGroupVariant.COLOR_PREVIEW_CONTAINER;
		addChild(_preview);
		
		_previewColor = new LayoutGroup();
		_previewColor.variant = LayoutGroupVariant.COLOR_PREVIEW;
		_previewSkin = new RectangleSkin(FillStyle.SolidColor(0xffffff));
		_previewColor.backgroundSkin = _previewSkin;
		_preview.addChild(_previewColor);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		_label.text = _exposedValue.name;
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_exposedValue != null)
		{
			colorUpdate();
		}
	}
	
	private function colorUpdate():Void
	{
		_previewSkin.fill = FillStyle.SolidColor(_exposedValue.value);
	}
	
}
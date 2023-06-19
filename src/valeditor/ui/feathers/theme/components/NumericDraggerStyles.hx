package valeditor.ui.feathers.theme.components;
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.graphics.LineStyle;
import feathers.skins.RectangleSkin;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.BitmapData;
import valeditor.ui.feathers.controls.NumericDragger;
import valeditor.ui.feathers.controls.NumericDraggerState;
import valeditor.ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class NumericDraggerStyles 
{
	static public var LINE_BMD_DRAG:BitmapData;
	static public var LINE_BMD_HOVER:BitmapData;
	static public var LINE_BMD_UP:BitmapData;
	
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		NumericDraggerStyles.theme = theme;
		
		if (LINE_BMD_DRAG == null)
		{
			LINE_BMD_DRAG = new BitmapData(2, 1, true, 0xffffffff);
			LINE_BMD_DRAG.setPixel(0, 0, theme.lightColor);
			LINE_BMD_DRAG.setPixel32(1, 0, 0x00ff0000);
		}
		
		if (LINE_BMD_HOVER == null)
		{
			LINE_BMD_HOVER = new BitmapData(2, 1, true, 0xffffffff);
			LINE_BMD_HOVER.setPixel(0, 0, theme.themeColor);
			LINE_BMD_HOVER.setPixel32(1, 0, 0x00ff0000);
		}
		
		if (LINE_BMD_UP == null)
		{
			LINE_BMD_UP = new BitmapData(2, 1, true, 0xffffffff);
			LINE_BMD_UP.setPixel(0, 0, theme.themeColorDark);
			LINE_BMD_UP.setPixel32(1, 0, 0x00ff0000);
		}
		
		if (styleProvider.getStyleFunction(NumericDragger, null) == null)
		{
			styleProvider.setStyleFunction(NumericDragger, null, default_style);
		}
		
		if (styleProvider.getStyleFunction(TextInput, NumericDragger.CHILD_VARIANT_INPUT) == null)
		{
			styleProvider.setStyleFunction(TextInput, NumericDragger.CHILD_VARIANT_INPUT, default_input_style);
		}
		
		if (styleProvider.getStyleFunction(Label, NumericDragger.CHILD_VARIANT_LABEL) == null)
		{
			styleProvider.setStyleFunction(Label, NumericDragger.CHILD_VARIANT_LABEL, default_dragLabel_style);
		}
	}
	
	static private function default_style(dragger:NumericDragger):Void
	{
		var labelSkin:UnderlineSkin = new UnderlineSkin();
		labelSkin.fill = null;
		labelSkin.border = LineStyle.Bitmap(1, LINE_BMD_UP, null, true);
		dragger.setLabelSkinForState(NumericDraggerState.UP, labelSkin);
		
		labelSkin = new UnderlineSkin();
		labelSkin.fill = null;
		labelSkin.border = LineStyle.Bitmap(1, LINE_BMD_HOVER, null, true);
		dragger.setLabelSkinForState(NumericDraggerState.HOVER, labelSkin);
		
		labelSkin = new UnderlineSkin();
		labelSkin.fill = null;
		labelSkin.border = LineStyle.Bitmap(1, LINE_BMD_DRAG, null, true);
		dragger.setLabelSkinForState(NumericDraggerState.DRAG, labelSkin);
		
		var skin:RectangleSkin = new RectangleSkin();
		skin.fill = theme.getThemeFill();
		dragger.setSkinForState(NumericDraggerState.DRAG, skin);
		
		dragger.setLabelTextFormatForState(NumericDraggerState.UP, theme.getTextFormat(LEFT, theme.themeColorDark));
		dragger.setLabelTextFormatForState(NumericDraggerState.HOVER, theme.getTextFormat(LEFT, theme.themeColor));
		dragger.setLabelTextFormatForState(NumericDraggerState.DRAG, theme.getTextFormat(LEFT, theme.lightColor));
		dragger.setLabelTextFormatForState(NumericDraggerState.DISABLED, theme.getTextFormat_disabled());
		
		dragger.dragGroupPaddingLeft = 2.0;
		dragger.dragGroupPaddingRight = 2.0;
		dragger.dragGroupPaddingBottom = 2.0;
		dragger.dragGroupPaddingTop = 2.0;
	}
	
	static private function default_dragLabel_style(label:Label):Void
	{
		// nothing here : we just don't want the label to be styled as a regular label
	}
	
	static private function default_input_style(input:TextInput):Void
	{
		//valeditor.ui.feathers.theme.simple.components.TextInputStyles.textInput(input);
		
		if (input.backgroundSkin == null) {
			var inputSkin = new RectangleSkin();
			inputSkin.cornerRadius = 3.0;
			inputSkin.width = 120.0;
			inputSkin.fill = theme.getLightFillLight();
			inputSkin.border = theme.getContrastBorderLight();
			inputSkin.disabledFill = theme.getLightFill();
			inputSkin.setBorderForState(TextInputState.FOCUSED, theme.getThemeBorder());
			inputSkin.setBorderForState(TextInputState.ERROR, theme.getDangerBorder());
			input.backgroundSkin = inputSkin;
		}
		
		if (input.textFormat == null) {
			input.textFormat = theme.getTextFormat();
		}
		if (input.disabledTextFormat == null) {
			input.disabledTextFormat = theme.getTextFormat_disabled();
		}
		if (input.promptTextFormat == null) {
			input.promptTextFormat = theme.getTextFormat_note();
		}
		
		input.paddingTop = 2.0;
		input.paddingRight = 2.0;
		input.paddingBottom = 2.0;
		input.paddingLeft = 2.0;
	}
	
}
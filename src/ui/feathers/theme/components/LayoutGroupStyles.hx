package ui.feathers.theme.components;
import feathers.controls.LayoutGroup;
import feathers.graphics.FillStyle;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.skins.HorizontalLineSkin;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.skins.UnderlineSkin;
import feathers.skins.VerticalLineSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.controls.value.SeparatorUI;
import ui.feathers.controls.value.SpacingUI;
import ui.feathers.controls.value.ValueUI;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
class LayoutGroupStyles 
{
	static private var theme:ValEditorTheme;

	/**
	   
	   @param	theme
	**/
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		LayoutGroupStyles.theme = theme;
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_DOWN_GROUP, arrow_down_group);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_DOWN_OBJECT, arrow_down_object);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_RIGHT_GROUP, arrow_right_group);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_RIGHT_OBJECT, arrow_right_object);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.CONTENT, content);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.COLOR_PREVIEW, color_preview);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.COLOR_PREVIEW_CONTAINER, color_preview_container);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ITEM_PREVIEW, item_preview);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.MENU_BAR, menu_bar);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.OBJECT_TRAIL, object_trail);
		
		//styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.SCENE, scene);
		
		styleProvider.setStyleFunction(SeparatorUI, null, separatorUI);
		styleProvider.setStyleFunction(SpacingUI, null, spacingUI);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.TOGGLE_CUSTOM_CONTENT, toggleCustom_content);
		
		styleProvider.setStyleFunction(ValueUI, null, valueUI);
	}
	
	static private function arrow_down_group(group:LayoutGroup):Void
	{
		var skin:TriangleSkin = new TriangleSkin(theme.getContrastFill(), theme.getContrastBorderLight());
		skin.pointPosition = RelativePosition.BOTTOM;
		skin.width = 12;
		skin.height = 12;
		group.backgroundSkin = skin;
	}
	
	static private function arrow_down_object(group:LayoutGroup):Void
	{
		var skin:TriangleSkin = new TriangleSkin(theme.getContrastFill(), theme.getContrastBorderLight());
		skin.pointPosition = RelativePosition.BOTTOM;
		skin.width = 12;
		skin.height = 12;
		group.backgroundSkin = skin;
	}
	
	static private function arrow_right_group(group:LayoutGroup):Void
	{
		var skin:TriangleSkin = new TriangleSkin(theme.getContrastFill(), theme.getContrastBorderLight());
		skin.pointPosition = RelativePosition.RIGHT;
		skin.width = 12;
		skin.height = 12;
		group.backgroundSkin = skin;
	}
	
	static private function arrow_right_object(group:LayoutGroup):Void
	{
		var skin:TriangleSkin = new TriangleSkin(theme.getContrastFill(), theme.getContrastBorderLight());
		skin.pointPosition = RelativePosition.RIGHT;
		skin.width = 12;
		skin.height = 12;
		group.backgroundSkin = skin;
	}
	
	static private function color_preview(group:LayoutGroup):Void
	{
		group.width = group.height = 30;
	}
	
	static private function color_preview_container(group:LayoutGroup):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		skin.border = theme.getContrastBorder();
		skin.width = skin.height = 32;
		group.backgroundSkin = skin;
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		group.layout = hLayout;
	}
	
	static private function content(group:LayoutGroup):Void
	{
		if (group.backgroundSkin == null)
		{
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getLightFill();
			group.backgroundSkin = backgroundSkin;
		}
	}
	
	static private function item_preview(group:LayoutGroup):Void
	{
		group.width = group.height = UIConfig.ASSET_PREVIEW_SIZE;
		
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		group.layout = hLayout;
	}
	
	static private function menu_bar(group:LayoutGroup):Void
	{
		if (group.backgroundSkin == null)
		{
			var backgroundSkin = new UnderlineSkin(theme.getLightFill(), theme.getLightBorderDark());
			group.backgroundSkin = backgroundSkin;
		}
	}
	
	static private function object_trail(group:LayoutGroup):Void
	{
		var skin:VerticalLineSkin = new VerticalLineSkin(null, theme.getThemeBorder(2));
		skin.width = Spacing.DEFAULT * 2;
		group.backgroundSkin = skin;
	}
	
	//static private function scene(group:LayoutGroup):Void
	//{
		//var skin:RectangleSkin = new RectangleSkin();
		//skin.fill = FillStyle.SolidColor(0xff0000, 0.25);
		//group.backgroundSkin = skin;
	//}
	
	static private function separatorUI(separator:SeparatorUI):Void
	{
		var skin:HorizontalLineSkin = new HorizontalLineSkin(null, theme.getContrastBorderLight());
		skin.height = Spacing.DEFAULT * 2;
		separator.separator.backgroundSkin = skin;
		separator.paddingLeft = separator.paddingRight = Spacing.DEFAULT * 4;
	}
	
	static private function spacingUI(spacing:SpacingUI):Void
	{
		spacing.height = 16;
	}
	
	static private function toggleCustom_content(group:LayoutGroup):Void
	{
		//group.width = UIConfig.VALUE_NAME_WIDTH;
		//trace("pouet");
	}
	
	static private function valueUI(value:ValueUI):Void
	{
		value.minWidth = UIConfig.VALUE_MIN_WIDTH;
		value.maxWidth = UIConfig.VALUE_MAX_WIDTH;
	}
	
}
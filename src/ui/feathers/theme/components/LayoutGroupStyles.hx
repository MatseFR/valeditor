package ui.feathers.theme.components;
import feathers.controls.LayoutGroup;
import feathers.layout.RelativePosition;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.skins.VerticalLineSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.variant.LayoutGroupVariant;

/**
 * ...
 * @author Matse
 */
@:access(ui.feathers.theme.ValEditorTheme)
class LayoutGroupStyles 
{
	static private var theme:ValEditorTheme;

	/**
	   
	   @param	theme
	**/
	static public function initialize(theme:ValEditorTheme):Void
	{
		LayoutGroupStyles.theme = theme;
		var styleProvider:ClassVariantStyleProvider = theme.styleProvider;
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_DOWN_GROUP, arrow_down_group);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_DOWN_OBJECT, arrow_down_object);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_RIGHT_GROUP, arrow_right_group);
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.ARROW_RIGHT_OBJECT, arrow_right_object);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.COLOR_PREVIEW, color_preview);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.OBJECT_TRAIL, object_trail);
		
		styleProvider.setStyleFunction(LayoutGroup, LayoutGroupVariant.TOGGLE_GROUP_CONTENT, toggleGroup_content);
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
		group.width = group.height = 32;
	}
	
	static private function object_trail(group:LayoutGroup):Void
	{
		var skin:VerticalLineSkin = new VerticalLineSkin(null, theme.getThemeBorder(2));
		group.backgroundSkin = skin;
		group.width = 16;
	}
	
	static private function toggleGroup_content(group:LayoutGroup):Void
	{
		group.width = UIConfig.VALUE_NAME_WIDTH;
	}
	
	static private function value(group:LayoutGroup):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		group.backgroundSkin = skin;
	}
	
}
package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Header;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.simple.SimpleTheme;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class HeaderStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Header, null) == null)
		{
			styleProvider.setStyleFunction(Header, null, function(header:Header):Void
			{
				if (header.backgroundSkin == null)
				{
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getLightFillDark();
					backgroundSkin.width = 44.0;
					backgroundSkin.height = 44.0;
					backgroundSkin.minHeight = 44.0;
					header.backgroundSkin = backgroundSkin;
				}
				
				if (header.textFormat == null)
				{
					header.textFormat = theme.getTextFormat_big();
				}
				
				if (header.disabledTextFormat == null)
				{
					header.disabledTextFormat = theme.getTextFormat_big_disabled();
				}
				
				header.paddingLeft = header.paddingRight = Padding.DEFAULT;
			});
		}
		
		if (styleProvider.getStyleFunction(Header, HeaderVariant.THEME) == null)
		{
			styleProvider.setStyleFunction(Header, HeaderVariant.THEME, function(header:Header):Void
			{
				if (header.backgroundSkin == null)
				{
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getThemeFill();
					backgroundSkin.width = 44.0;
					backgroundSkin.height = 44.0;
					backgroundSkin.minHeight = 44.0;
					header.backgroundSkin = backgroundSkin;
				}
				
				if (header.textFormat == null)
				{
					header.textFormat = theme.getTextFormat_big();
				}
				
				if (header.disabledTextFormat == null)
				{
					header.disabledTextFormat = theme.getTextFormat_big_disabled();
				}
				
				header.paddingLeft = header.paddingRight = Padding.DEFAULT;
			});
		}
	}
	
}
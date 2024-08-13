package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.VDividedBox;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DisplayObjectFactory;
import valeditor.ui.feathers.theme.simple.SimpleTheme;
import valeditor.ui.feathers.theme.simple.variants.ButtonVariant;

/**
 * ...
 * @author Matse
 */
class DividedBoxStyles 
{
	static private var theme:SimpleTheme;
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		DividedBoxStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(HDividedBox, null) == null)
		{
			styleProvider.setStyleFunction(HDividedBox, null, H_default);
		}
		
		if (styleProvider.getStyleFunction(VDividedBox, null) == null)
		{
			styleProvider.setStyleFunction(VDividedBox, null, V_default);
		}
	}
	
	static private function H_default(box:HDividedBox):Void
	{
		if (box.resizeDraggingSkin == null) {
			var resizeDraggingSkin = new RectangleSkin();
			resizeDraggingSkin.fill = theme.getThemeFill();
			resizeDraggingSkin.border = None;
			resizeDraggingSkin.width = 2.0;
			resizeDraggingSkin.height = 2.0;
			box.resizeDraggingSkin = resizeDraggingSkin;
		}
		
		box.dividerFactory = DisplayObjectFactory.withFunction(() -> {
			var btn:Button = new Button();
			btn.variant = ButtonVariant.DIVIDER_H;
			return btn;
		});
	}
	
	static private function V_default(box:VDividedBox):Void
	{
		if (box.resizeDraggingSkin == null) {
			var resizeDraggingSkin = new RectangleSkin();
			resizeDraggingSkin.fill = theme.getThemeFill();
			resizeDraggingSkin.border = None;
			resizeDraggingSkin.width = 2.0;
			resizeDraggingSkin.height = 2.0;
			box.resizeDraggingSkin = resizeDraggingSkin;
		}
		
		box.dividerFactory = DisplayObjectFactory.withFunction(() -> {
			var btn:Button = new Button();
			btn.variant = ButtonVariant.DIVIDER_V;
			return btn;
		});
	}
	
}
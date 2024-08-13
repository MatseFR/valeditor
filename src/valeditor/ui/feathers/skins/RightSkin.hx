package valeditor.ui.feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.skins.BaseGraphicsPathSkin;

/**
 * ...
 * @author Matse
 */
class RightSkin extends BaseGraphicsPathSkin 
{

	public function new(?fill:FillStyle, ?border:LineStyle) 
	{
		super(fill, border);
	}
	
	override function draw():Void 
	{
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;
		
		var currentFill = this.getCurrentFill();
		if (currentFill != null)
		{
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, Math.max(0.0, this.actualWidth - thickness), Math.max(0.0, this.actualHeight - thickness));
			this.graphics.endFill();
		}
		
		var minLineY = 0.0;
		var maxLineX = this.actualWidth - thicknessOffset;
		var maxLineY = Math.max(minLineY, this.actualHeight - thickness);
		
		this.applyLineStyle(currentBorder);
		// right
		this.graphics.moveTo(maxLineX, minLineY);
		this.graphics.lineTo(maxLineX, maxLineY);
	}
	
}
package valeditor.ui.feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.skins.BaseGraphicsPathSkin;

/**
 * ...
 * @author Matse
 */
class TopBottomAndRightSkin extends BaseGraphicsPathSkin 
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
		
		var minLineX = Math.min(this.actualWidth, thicknessOffset);
		var minLineY = Math.min(this.actualHeight, thicknessOffset);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset);
		
		this.applyLineStyle(currentBorder);
		// right
		this.graphics.moveTo(maxLineX, minLineY);
		this.graphics.lineTo(maxLineX, maxLineY);
		// overline
		this.graphics.moveTo(minLineX, minLineY);
		this.graphics.lineTo(maxLineX, minLineY);
		// underline
		this.graphics.moveTo(minLineX, maxLineY);
		this.graphics.lineTo(maxLineX, maxLineY);
	}
	
}
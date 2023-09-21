package valeditor.ui.feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.skins.VerticalLineSkin;
import openfl.errors.ArgumentError;

/**
 * ...
 * @author Matse
 */
class VerticalLineSkinWithOffset extends VerticalLineSkin 
{
	public var lineOffset(get, set):Float;
	
	private var _lineOffset:Float = 0;
	private function get_lineOffset():Float { return this._lineOffset; }
	private function set_lineOffset(value:Float):Float
	{
		if (this._lineOffset == value) return value;
		this._lineOffset = value;
		setInvalid(STYLES);
		return this._lineOffset;
	}
	
	public function new(?fill:FillStyle, ?border:LineStyle, ?lineOffset:Float) 
	{
		super(fill, border);
		if (lineOffset != null)
		{
			this._lineOffset = lineOffset;
		}
	}
	
	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thicknessOffset = getLineThickness(currentBorder) / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, 0.0, this.actualWidth, this.actualHeight);
			this.graphics.endFill();
		}

		var positionX = switch (this._horizontalAlign) {
			case LEFT: this._lineOffset;
			case CENTER: this.actualWidth / 2.0 + this._lineOffset;
			case RIGHT: this.actualWidth - this.lineOffset;
			default: throw new ArgumentError("Unknown horizontal align: " + this._horizontalAlign);
		}
		var minLineY = Math.min(this.actualHeight, thicknessOffset + this._paddingTop);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset - this._paddingTop - this._paddingBottom);

		this.applyLineStyle(currentBorder);
		this.graphics.moveTo(positionX, minLineY);
		this.graphics.lineTo(positionX, maxLineY);
	}
	
}
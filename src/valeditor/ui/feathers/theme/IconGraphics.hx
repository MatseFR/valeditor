package valeditor.ui.feathers.theme;
import openfl.display.Shape;

/**
 * ...
 * @author Matse
 */
class IconGraphics 
{
	static public function drawAddIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(4.0, 9.0, 12.0, 2.0);
		//icon.graphics.drawRect(9.0, 4.0, 2.0, 12.0);
		icon.graphics.drawRect(9.0, 4.0, 2.0, 5.0);
		icon.graphics.drawRect(9.0, 11.0, 2.0, 5.0);
		icon.graphics.endFill();
	}
	
	static public function drawDisclosureClosedIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 10.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}

	static public function drawDisclosureOpenIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 4.0);
		icon.graphics.lineTo(10.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}
	
	static public function drawDownIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(10.0, 16.0);
		icon.graphics.lineTo(16.0, 4.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}
	
	static public function drawFrameFirstIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(16.0, 4.0);
		icon.graphics.lineTo(8.0, 10.0);
		icon.graphics.lineTo(16.0, 16.0);
		icon.graphics.lineTo(16.0, 4.0);
		icon.graphics.drawRect(4.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static public function drawFrameLastIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(12.0, 10.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.drawRect(14.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static public function drawFrameNextIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(8.0, 4.0);
		icon.graphics.lineTo(16.0, 10.0);
		icon.graphics.lineTo(8.0, 16.0);
		icon.graphics.lineTo(8.0, 4.0);
		icon.graphics.drawRect(4.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static public function drawFramePreviousIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(12.0, 4.0);
		icon.graphics.lineTo(4.0, 10.0);
		icon.graphics.lineTo(12.0, 16.0);
		icon.graphics.lineTo(12.0, 4.0);
		icon.graphics.drawRect(14.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static public function drawOpenIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		// top left
		icon.graphics.drawRect(4.0, 4.0, 4.0, 2.0);
		icon.graphics.drawRect(4.0, 6.0, 2.0, 2.0);
		// top right
		icon.graphics.drawRect(12.0, 4.0, 4.0, 2.0);
		icon.graphics.drawRect(14.0, 6.0, 2.0, 2.0);
		// bottom left
		icon.graphics.drawRect(4.0, 12.0, 2.0, 4.0);
		icon.graphics.drawRect(6.0, 14.0, 2.0, 2.0);
		// bottom right
		icon.graphics.drawRect(14.0, 12.0, 2.0, 4.0);
		icon.graphics.drawRect(12.0, 14.0, 2.0, 2.0);
	}
	
	static public function drawPlayIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 10.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}
	
	static public function drawRemoveIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(4.0, 9.0, 12.0, 2.0);
		icon.graphics.endFill();
	}
	
	static public function drawRenameIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(7.0, 4.0, 6.0, 2.0);
		icon.graphics.drawRect(7.0, 14.0, 6.0, 2.0);
		icon.graphics.drawRect(9.0, 6.0, 2.0, 8.0);
		icon.graphics.endFill();
	}
	
	static public function drawStopIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(4.0, 4.0, 12.0, 12.0);
		icon.graphics.endFill();
	}
	
	static public function drawUpIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 16.0);
		icon.graphics.lineTo(10.0, 4.0);
		icon.graphics.lineTo(16.0, 16.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.endFill();
	}
	
}
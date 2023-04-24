package utils.starling;
import openfl.display3D.Context3DTextureFormat;

/**
 * ...
 * @author Matse
 */
class TextureCreationParameters 
{
	public var generateMipMaps:Bool = true;
	public var optimizeForRenderToTexture:Bool = false;
	public var scale:Float = 1;
	public var format:Context3DTextureFormat = Context3DTextureFormat.BGRA;
	public var forcePotTexture:Bool = false;
	
	public function new() 
	{
		
	}
	
	public function reset():Void
	{
		this.generateMipMaps = true;
		this.optimizeForRenderToTexture = false;
		this.scale = 1;
		this.format = Context3DTextureFormat.BGRA;
		this.forcePotTexture = false;
	}
	
}
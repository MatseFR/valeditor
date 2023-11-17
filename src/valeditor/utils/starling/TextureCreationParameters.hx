package valeditor.utils.starling;
import openfl.display3D.Context3DTextureFormat;

/**
 * ...
 * @author Matse
 */
class TextureCreationParameters 
{
	static private var _POOL:Array<TextureCreationParameters> = new Array<TextureCreationParameters>();
	
	static public function fromPool():TextureCreationParameters
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextureCreationParameters();
	}
	
	public var generateMipMaps:Bool = true;
	public var optimizeForRenderToTexture:Bool = false;
	public var scale:Float = 1;
	public var format:Context3DTextureFormat = Context3DTextureFormat.BGRA;
	public var forcePotTexture:Bool = false;
	
	public function new() 
	{
		
	}
	
	public function pool():Void
	{
		reset();
		_POOL[_POOL.length] = this;
	}
	
	public function clone(toParams:TextureCreationParameters = null):TextureCreationParameters
	{
		if (toParams == null) toParams = fromPool();
		
		toParams.generateMipMaps = this.generateMipMaps;
		toParams.optimizeForRenderToTexture = this.optimizeForRenderToTexture;
		toParams.scale = this.scale;
		toParams.format = this.format;
		toParams.forcePotTexture = this.forcePotTexture;
		
		return toParams;
	}
	
	public function reset():Void
	{
		this.generateMipMaps = true;
		this.optimizeForRenderToTexture = false;
		this.scale = 1;
		this.format = Context3DTextureFormat.BGRA;
		this.forcePotTexture = false;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.generateMipMaps = json.generateMipMaps;
		this.optimizeForRenderToTexture = json.optimizeForRenderToTexture;
		this.scale = json.scale;
		this.format = json.format;
		this.forcePotTexture = json.forcePotTexture;
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.generateMipMaps = this.generateMipMaps;
		json.optimizeForRenderToTexture = this.optimizeForRenderToTexture;
		json.scale = this.scale;
		json.format = this.format;
		json.forcePotTexture = this.forcePotTexture;
		
		return json;
	}
	
}
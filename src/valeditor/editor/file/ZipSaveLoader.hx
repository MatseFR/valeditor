package valeditor.editor.file;
import haxe.Json;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lime.media.AudioBuffer;
import openfl.display.BitmapData;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.media.Sound;
import openfl.utils.ByteArray;
import valedit.ValEdit;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.utils.ZipUtil;
import valeditor.events.DefaultEvent;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.utils.starling.TextureCreationParameters;

#if starling
import starling.textures.Texture;
import starling.textures.TextureAtlas;
#end

/**
 * ...
 * @author Matse
 */
class ZipSaveLoader extends EventDispatcher
{
	private var _assetJson:Dynamic;
	private var _dataJson:Dynamic;
	private var _entryMap:StringMap<Entry> = new StringMap<Entry>();
	
	private var _assetList:Array<Dynamic>;
	private var _assetCount:Int;
	private var _assetIndex:Int;
	
	private var _assetNode:Dynamic;
	private var _entry:Entry;
	private var _ba:ByteArray;

	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		this._assetJson = null;
		this._dataJson = null;
		this._entryMap.clear();
		
		this._assetList = null;
		
		this._assetNode = null;
		this._entry = null;
		this._ba = null;
	}
	
	public function load(bytes:Bytes):Void
	{
		var input:BytesInput = new BytesInput(bytes);
		var zip:Reader = new Reader(input);
		var entries:List<Entry> = zip.read();
		
		for (e in entries)
		{
			if (e.compressed)
			{
				ZipUtil.uncompressEntry(e);
			}
			this._entryMap.set(e.fileName, e);
		}
		
		this._entry = this._entryMap.get("valedit_assets.json");
		if (this._entry == null)
		{
			throw new Error("cannot find assets in specified file");
		}
		this._assetJson = Json.parse(this._entry.data.toString());
		
		loadBinaryAssets();
	}
	
	// BINARY ASSETS
	private function loadBinaryAssets():Void
	{
		this._assetList = this._assetJson.binary;
		if (this._assetList == null)
		{
			loadBitmapAssets();
			return;
		}
		this._assetCount = this._assetList.length;
		
		nextBinaryAsset();
	}
	
	private function nextBinaryAsset():Void
	{
		for (i in 0...this._assetCount)
		{
			this._assetNode = this._assetList[i];
			this._entry = this._entryMap.get(this._assetNode.path);
			this._ba = this._entry.data;
			ValEdit.assetLib.createBinary(this._assetNode.path, this._ba);
		}
		
		loadBitmapAssets();
	}
	//\BINARY ASSETS
	
	// BITMAP ASSETS
	private function loadBitmapAssets():Void
	{
		this._assetList = this._assetJson.bitmap;
		if (this._assetList == null)
		{
			loadSoundAssets();
			return;
		}
		this._assetCount = this._assetList.length;
		this._assetIndex = -1;
		
		nextBitmapAsset();
	}
	
	private function nextBitmapAsset():Void
	{
		this._assetIndex++;
		if (this._assetIndex < this._assetCount)
		{
			this._assetNode = this._assetList[this._assetIndex];
			this._entry = this._entryMap.get(this._assetNode.path);
			this._ba = this._entry.data;
			BitmapData.loadFromBytes(this._ba).onComplete(onBitmapLoadComplete).onError(onBitmapLoadError);
		}
		else
		{
			loadSoundAssets();
		}
	}
	
	private function onBitmapLoadComplete(bmd:BitmapData):Void
	{
		ValEdit.assetLib.createBitmap(this._assetNode.path, bmd, this._ba);
		nextBitmapAsset();
	}
	
	private function onBitmapLoadError(error:Dynamic):Void
	{
		trace("ZipSaveLoader failed to load Bitmap " + this._assetNode.path + " error = " + error);
		nextBitmapAsset();
	}
	//\BITMAP ASSETS
	
	// SOUND ASSETS
	private function loadSoundAssets():Void
	{
		this._assetList = this._assetJson.sound;
		if (this._assetList == null)
		{
			loadTextAssets();
			return;
		}
		this._assetCount = this._assetList.length;
		
		nextSoundAsset();
	}
	
	private function nextSoundAsset():Void
	{
		var buffer:AudioBuffer;
		var sound:Sound;
		for (i in 0...this._assetCount)
		{
			this._assetNode = this._assetList[i];
			this._entry = this._entryMap.get(this._assetNode.path);
			#if air
			sound = new Sound();
			sound.loadCompressedDataFromByteArray(this._entry.data, this._entry.data.length);
			#else
			buffer = AudioBuffer.fromBytes(this._entry.data);
			sound = Sound.fromAudioBuffer(buffer);
			#end
			ValEdit.assetLib.createSound(this._assetNode.path, sound, this._entry.data);
		}
		
		loadTextAssets();
	}
	//\SOUND ASSETS
	
	// TEXT ASSETS
	private function loadTextAssets():Void
	{
		this._assetList = this._assetJson.text;
		if (this._assetList == null)
		{
			#if starling
			loadStarlingAtlasAssets();
			#else
			allAssetsLoaded();
			#end
			return;
		}
		this._assetCount = this._assetList.length;
		
		nextTextAsset();
	}
	
	private function nextTextAsset():Void
	{
		for (i in 0...this._assetCount)
		{
			this._assetNode = this._assetList[i];
			this._entry = this._entryMap.get(this._assetNode.path);
			ValEdit.assetLib.createText(this._assetNode.path, this._entry.data.toString());
		}
		
		#if starling
		loadStarlingAtlasAssets();
		#else
		allAssetsLoaded();
		#end
	}
	//\TEXT ASSETS
	
	#if starling
	// STARLING ATLAS ASSETS
	private function loadStarlingAtlasAssets():Void
	{
		this._assetList = this._assetJson.starling_atlas;
		if (this._assetList == null)
		{
			loadStarlingTextureAssets();
			return;
		}
		this._assetCount = this._assetList.length;
		
		nextStarlingAtlasAsset();
	}
	
	private function nextStarlingAtlasAsset():Void
	{
		var atlas:TextureAtlas;
		var bitmapAsset:BitmapAsset;
		var textAsset:TextAsset;
		var texture:Texture;
		var textureParams:TextureCreationParameters;
		for (i in 0...this._assetCount)
		{
			this._assetNode = this._assetList[i];
			textureParams = TextureCreationParameters.fromPool();
			textureParams.fromJSON(this._assetNode.textureParams);
			bitmapAsset = ValEdit.assetLib.getBitmapFromPath(this._assetNode.bitmapPath);
			textAsset = ValEdit.assetLib.getTextFromPath(this._assetNode.textPath);
			texture = Texture.fromBitmapData(bitmapAsset.content, textureParams.generateMipMaps, textureParams.optimizeForRenderToTexture, textureParams.scale, textureParams.format, textureParams.forcePotTexture);
			atlas = new TextureAtlas(texture, textAsset.content);
			ValEdit.assetLib.createStarlingAtlas(this._assetNode.path, atlas, textureParams, bitmapAsset, textAsset);
		}
		
		loadStarlingTextureAssets();
	}
	//\STARLING ATLAS ASSETS
	
	// STARLING TEXTURE ASSETS
	private function loadStarlingTextureAssets():Void
	{
		this._assetList = this._assetJson.starling_texture;
		if (this._assetList == null)
		{
			allAssetsLoaded();
			return;
		}
		this._assetCount = this._assetList.length;
		
		nextStarlingTextureAsset();
	}
	
	private function nextStarlingTextureAsset():Void
	{
		var bitmapAsset:BitmapAsset;
		var texture:Texture;
		var textureParams:TextureCreationParameters;
		for (i in 0...this._assetCount)
		{
			this._assetNode = this._assetList[i];
			textureParams = TextureCreationParameters.fromPool();
			textureParams.fromJSON(this._assetNode.textureParams);
			bitmapAsset = ValEdit.assetLib.getBitmapFromPath(this._assetNode.bitmapPath);
			texture = Texture.fromBitmapData(bitmapAsset.content, textureParams.generateMipMaps, textureParams.optimizeForRenderToTexture, textureParams.scale, textureParams.format, textureParams.forcePotTexture);
			ValEdit.assetLib.createStarlingTexture(this._assetNode.path, texture, textureParams, bitmapAsset);
		}
		
		allAssetsLoaded();
	}
	//\STARLING TEXTURE ASSETS
	#end
	
	private function allAssetsLoaded():Void
	{
		this._entry = this._entryMap.get("valedit_fileSettings.json");
		if (this._entry != null)
		{
			this._dataJson = Json.parse(this._entry.data.toString());
			ValEditor.fileSettings.fromJSON(this._dataJson);
		}
		
		this._entry = this._entryMap.get("valedit_exportSettings.json");
		if (this._entry != null)
		{
			this._dataJson = Json.parse(this._entry.data.toString());
			ValEditor.exportSettings.fromJSON(this._dataJson);
		}
		
		this._entry = this._entryMap.get("valedit_data.json");
		if (this._entry == null)
		{
			throw new Error("cannot find data in specified file");
		}
		this._dataJson = Json.parse(this._entry.data.toString());
		
		var flash:Bool = false;
		if (this._dataJson.flash != null)
		{
			flash = this._dataJson.flash;
		}
		
		#if flash
		if (!flash)
		{
			FeathersWindows.showMessageConfirmWindow("OpenFL to Flash", "This file was not created with a Flash/Air build of ValEditor. openfl.* class paths are gonna be renamed to flash.* - it should work unless some class has no Flash/Air equivalent.", openFLToFlash);
		}
		else
		{
			completeLoading();
		}
		#else
		if (flash)
		{
			FeathersWindows.showMessageConfirmWindow("Flash to OpenFL", "This file was created with a Flash/Air build of ValEditor. flash.* class paths are gonna be renamed to openfl.* - it should work unless some class has no OpenFL equivalent.", flashToOpenFL);
		}
		else
		{
			completeLoading();
		}
		#end
	}
	
	private function completeLoading():Void
	{
		ValEditor.fromJSONSave(this._dataJson);
		
		DefaultEvent.dispatch(this, Event.COMPLETE);
	}
	
	private function flashToOpenFL():Void
	{
		var name:String;
		var data:Array<Dynamic> = this._dataJson.classes;
		for (node in data)
		{
			name = node.clss;
			if (name.indexOf("flash.") == 0)
			{
				name = StringTools.replace(name, "flash.", "openfl.");
				node.clss = name;
			}
		}
		
		completeLoading();
	}
	
	private function openFLToFlash():Void
	{
		var name:String;
		var data:Array<Dynamic> = this._dataJson.classes;
		for (node in data)
		{
			name = node.clss;
			if (name.indexOf("openfl.") == 0)
			{
				name = StringTools.replace(name, "openfl.", "flash.");
				node.clss = name;
			}
		}
		
		completeLoading();
	}
	
}
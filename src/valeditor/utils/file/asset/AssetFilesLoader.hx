package valeditor.utils.file.asset;
import openfl.errors.Error;
import openfl.net.FileReference;
import valedit.ValEdit;
import valedit.asset.AssetType;

/**
 * ...
 * @author Matse
 */
class AssetFilesLoader 
{
	public var isRunning(default, null):Bool;
	
	private var _binaryLoader:BinaryFilesLoader = new BinaryFilesLoader();
	private var _bitmapLoader:BitmapFilesLoader = new BitmapFilesLoader();
	private var _soundLoader:SoundFilesLoader = new SoundFilesLoader();
	private var _textLoader:TextFilesLoader = new TextFilesLoader();
	
	private var _completeCallback:Void->Void;
	
	private var _delayedFiles:Array<FileReference> = new Array<FileReference>();
	private var _delayedFilesAssetType:Array<String> = new Array<String>();
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.isRunning = false;
		
		this._binaryLoader.clear();
		this._bitmapLoader.clear();
		this._soundLoader.clear();
		this._textLoader.clear();
		
		this._completeCallback = null;
		
		this._delayedFiles.resize(0);
		this._delayedFilesAssetType.resize(0);
	}
	
	public function addFile(file:FileReference, assetType:String):Void
	{
		if (this.isRunning)
		{
			this._delayedFiles.push(file);
			this._delayedFilesAssetType.push(assetType);
		}
		else
		{
			switch (assetType)
			{
				case AssetType.BINARY :
					this._binaryLoader.addFile(file);
				
				case AssetType.BITMAP :
					this._bitmapLoader.addFile(file);
				
				case AssetType.SOUND :
					this._soundLoader.addFile(file);
				
				case AssetType.TEXT :
					this._textLoader.addFile(file);
				
				default :
					throw new Error("unknown assetType : " + assetType);
			}
		}
	}
	
	public function addFiles(files:Array<FileReference>, assetType:String):Void
	{
		if (this.isRunning)
		{
			for (file in files)
			{
				this._delayedFiles.push(file);
				this._delayedFilesAssetType.push(assetType);
			}
		}
		else
		{
			switch (assetType)
			{
				case AssetType.BINARY :
					this._binaryLoader.addFiles(files);
				
				case AssetType.BITMAP :
					this._bitmapLoader.addFiles(files);
				
				case AssetType.SOUND :
					this._soundLoader.addFiles(files);
				
				case AssetType.TEXT :
					this._textLoader.addFiles(files);
				
				default :
					throw new Error("unknown assetType : " + assetType);
			}
		}
	}
	
	public function addFileBinary(file:FileReference):Void
	{
		if (this.isRunning)
		{
			this._delayedFiles.push(file);
			this._delayedFilesAssetType.push(AssetType.BINARY);
		}
		else
		{
			this._binaryLoader.addFile(file);
		}
	}
	
	public function addFilesBinary(files:Array<FileReference>):Void
	{
		if (this.isRunning)
		{
			for (file in files)
			{
				this._delayedFiles.push(file);
				this._delayedFilesAssetType.push(AssetType.BINARY);
			}
		}
		else
		{
			this._binaryLoader.addFiles(files);
		}
	}
	
	public function addFileBitmap(file:FileReference):Void
	{
		if (this.isRunning)
		{
			this._delayedFiles.push(file);
			this._delayedFilesAssetType.push(AssetType.BITMAP);
		}
		else
		{
			this._bitmapLoader.addFile(file);
		}
	}
	
	public function addFilesBitmap(files:Array<FileReference>):Void
	{
		if (this.isRunning)
		{
			for (file in files)
			{
				this._delayedFiles.push(file);
				this._delayedFilesAssetType.push(AssetType.BITMAP);
			}
		}
		else
		{
			this._bitmapLoader.addFiles(files);
		}
	}
	
	public function addFileSound(file:FileReference):Void
	{
		if (this.isRunning)
		{
			this._delayedFiles.push(file);
			this._delayedFilesAssetType.push(AssetType.SOUND);
		}
		else
		{
			this._soundLoader.addFile(file);
		}
	}
	
	public function addFilesSound(files:Array<FileReference>):Void
	{
		if (this.isRunning)
		{
			for (file in files)
			{
				this._delayedFiles.push(file);
				this._delayedFilesAssetType.push(AssetType.SOUND);
			}
		}
		else
		{
			this._soundLoader.addFiles(files);
		}
	}
	
	public function addFileText(file:FileReference):Void
	{
		if (this.isRunning)
		{
			this._delayedFiles.push(file);
			this._delayedFilesAssetType.push(AssetType.TEXT);
		}
		else
		{
			this._textLoader.addFile(file);
		}
	}
	
	public function addFilesText(files:Array<FileReference>):Void
	{
		if (this.isRunning)
		{
			for (file in files)
			{
				this._delayedFiles.push(file);
				this._delayedFilesAssetType.push(AssetType.TEXT);
			}
		}
		else
		{
			this._textLoader.addFiles(files);
		}
	}
	
	public function load(completeCallback:Void->Void):Void
	{
		if (this.isRunning)
		{
			throw new Error("AssetFilesLoader is already running");
		}
		this._completeCallback = completeCallback;
		this.isRunning = true;
		
		this._binaryLoader.start(ValEdit.assetLib.createBinary, binaryLoadComplete);
	}
	
	private function binaryLoadComplete():Void
	{
		this._bitmapLoader.start(ValEdit.assetLib.createBitmap, bitmapLoadComplete);
	}
	
	private function bitmapLoadComplete():Void
	{
		this._soundLoader.start(ValEdit.assetLib.createSound, soundLoadComplete);
	}
	
	private function soundLoadComplete():Void
	{
		this._textLoader.start(ValEdit.assetLib.createText, textLoadComplete);
	}
	
	private function textLoadComplete():Void
	{
		this.isRunning = false;
		if (this._delayedFiles.length == 0)
		{
			if (this._completeCallback != null)
			{
				this._completeCallback();
				this._completeCallback = null;
			}
		}
		else
		{
			var count:Int = this._delayedFiles.length;
			for (i in 0...count)
			{
				addFile(this._delayedFiles[i], this._delayedFilesAssetType[i]);
			}
			this._delayedFiles.resize(0);
			this._delayedFilesAssetType.resize(0);
			load(this._completeCallback);
		}
	}
	
}
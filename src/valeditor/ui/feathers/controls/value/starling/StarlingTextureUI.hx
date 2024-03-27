package valeditor.ui.feathers.controls.value.starling;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.display.Bitmap;
import starling.textures.Texture;
import valedit.ValEdit;
import valedit.asset.starling.StarlingTextureAsset;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valeditor.ui.UIConfig;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
class StarlingTextureUI extends ValueUI 
{
	static private var _POOL:Array<StarlingTextureUI> = new Array<StarlingTextureUI>();
	
	static public function disposePool():Void
	{
		_POOL.resize(0);
	}
	
	static public function fromPool():StarlingTextureUI
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new StarlingTextureUI();
	}
	
	private var _label:Label;
	
	private var _contentGroup:LayoutGroup;
	
	private var _previewGroup:LayoutGroup;
	private var _preview:Bitmap;
	
	private var _nameLabel:Label;
	private var _pathLabel:Label;
	private var _sizeLabel:Label;
	
	private var _buttonGroup:LayoutGroup;
	private var _loadButton:Button;
	private var _clearButton:Button;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.DEFAULT;
		hLayout.paddingRight = Padding.VALUE;
		this.layout = hLayout;
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		addChild(this._label);
		
		this._contentGroup = new LayoutGroup();
		this._contentGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._contentGroup.layout = vLayout;
		addChild(this._contentGroup);
		
		this._previewGroup = new LayoutGroup();
		this._previewGroup.maxWidth = UIConfig.ASSET_PREVIEW_WIDTH;
		this._previewGroup.maxHeight = UIConfig.ASSET_PREVIEW_HEIGHT;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.CENTER;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		this._previewGroup.layout = vLayout;
		this._contentGroup.addChild(this._previewGroup);
		
		this._preview = new Bitmap();
		this._preview.smoothing = true;
		this._previewGroup.addChild(this._preview);
		
		this._nameLabel = new Label();
		this._contentGroup.addChild(this._nameLabel);
		
		this._pathLabel = new Label();
		this._pathLabel.wordWrap = true;
		this._contentGroup.addChild(this._pathLabel);
		
		this._sizeLabel = new Label();
		this._contentGroup.addChild(this._sizeLabel);
		
		this._buttonGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._buttonGroup.layout = hLayout;
		this._contentGroup.addChild(this._buttonGroup);
		
		this._loadButton = new Button("set");
		this._loadButton.layoutData = new HorizontalLayoutData(50);
		this._buttonGroup.addChild(this._loadButton);
		
		this._clearButton = new Button("clear");
		this._clearButton.layoutData = new HorizontalLayoutData(50);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.text = this._exposedValue.name;
		
		if (this._readOnly)
		{
			if (this._buttonGroup.parent != null) this._contentGroup.removeChild(this._buttonGroup);
		}
		else
		{
			if (this._buttonGroup.parent == null) this._contentGroup.addChild(this._buttonGroup);
		}
		
		if (this._clearButton.parent != null) this._buttonGroup.removeChild(this._clearButton);
		if (this._exposedValue.isNullable && !this._readOnly)
		{
			this._buttonGroup.addChild(this._clearButton);
		}
		
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			var controlsEnabled:Bool = this._controlsEnabled;
			if (controlsEnabled) controlsDisable();
			var value:Texture = this._exposedValue.value;
			if (value != null)
			{
				assetUpdate(ValEdit.assetLib.getStarlingTextureAssetFromTexture(value));
			}
			else
			{
				assetUpdate(null);
			}
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function updateEditable():Void
	{
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._nameLabel.enabled = this._exposedValue.isEditable;
		this._pathLabel.enabled = this._exposedValue.isEditable;
		this._loadButton.enabled = !this._readOnly && this._exposedValue.isEditable;
		this._clearButton.enabled = !this._readOnly && this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (this._readOnly) return;
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._loadButton.removeEventListener(TriggerEvent.TRIGGER, onLoadButton);
		this._clearButton.removeEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._readOnly) return;
		if (_controlsEnabled) return;
		super.controlsEnable();
		this._loadButton.addEventListener(TriggerEvent.TRIGGER, onLoadButton);
		this._clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
	{
		this._exposedValue.value = null;
		assetUpdate(null);
	}
	
	private function onLoadButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showStarlingTextureAssetsWindow(assetSelected, null, "Select Texture asset");
	}
	
	private function assetSelected(asset:StarlingTextureAsset):Void
	{
		this._exposedValue.value = asset;
		assetUpdate(asset);
	}
	
	private function assetUpdate(asset:StarlingTextureAsset):Void
	{
		if (asset == null)
		{
			this._nameLabel.text = "";
			this._pathLabel.text = "";
			this._sizeLabel.text = "";
			previewUpdate(null);
		}
		else
		{
			this._nameLabel.text = asset.name;
			this._pathLabel.text = asset.path;
			this._sizeLabel.text = asset.content.width + "x" + asset.content.height;
			previewUpdate(asset);
		}
	}
	
	private function previewUpdate(asset:StarlingTextureAsset):Void
	{
		if (asset == null)
		{
			this._preview.bitmapData = null;
		}
		else
		{
			this._preview.bitmapData = asset.preview;
		}
		this._previewGroup.setInvalid();
	}
	
}
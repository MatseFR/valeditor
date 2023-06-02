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
import starling.textures.TextureAtlas;
import valeditor.ui.feathers.controls.value.ValueUI;
import valeditor.ui.feathers.variant.LabelVariant;
import valedit.asset.AssetLib;
import valedit.asset.starling.StarlingAtlasAsset;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class StarlingAtlasUI extends ValueUI 
{
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
		
		_label = new Label();
		_label.variant = LabelVariant.VALUE_NAME;
		addChild(_label);
		
		_contentGroup = new LayoutGroup();
		_contentGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		_contentGroup.layout = vLayout;
		addChild(_contentGroup);
		
		_previewGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.CENTER;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		_previewGroup.layout = vLayout;
		_contentGroup.addChild(_previewGroup);
		
		_preview = new Bitmap();
		_previewGroup.addChild(_preview);
		
		_nameLabel = new Label();
		_contentGroup.addChild(_nameLabel);
		
		_pathLabel = new Label();
		_pathLabel.wordWrap = true;
		_contentGroup.addChild(_pathLabel);
		
		_sizeLabel = new Label();
		_contentGroup.addChild(_sizeLabel);
		
		_buttonGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		_buttonGroup.layout = hLayout;
		_contentGroup.addChild(_buttonGroup);
		
		_loadButton = new Button("set");
		_loadButton.layoutData = new HorizontalLayoutData(50);
		_buttonGroup.addChild(_loadButton);
		
		_clearButton = new Button("clear");
		_clearButton.layoutData = new HorizontalLayoutData(50);
		_buttonGroup.addChild(_clearButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		_label.text = _exposedValue.name;
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (_initialized && _exposedValue != null)
		{
			var controlsEnabled:Bool = _controlsEnabled;
			if (controlsEnabled) controlsDisable();
			var value:TextureAtlas = _exposedValue.value;
			if (value != null)
			{
				assetUpdate(AssetLib.getStarlingAtlasAssetFromAtlas(value));
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
		this.enabled = _exposedValue.isEditable;
		_label.enabled = _exposedValue.isEditable;
		_nameLabel.enabled = _exposedValue.isEditable;
		_pathLabel.enabled = _exposedValue.isEditable;
		_loadButton.enabled = _exposedValue.isEditable;
		_clearButton.enabled = _exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (!_controlsEnabled) return;
		super.controlsDisable();
		_loadButton.removeEventListener(TriggerEvent.TRIGGER, onLoadButton);
		_clearButton.removeEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_loadButton.addEventListener(TriggerEvent.TRIGGER, onLoadButton);
		_clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
	{
		_exposedValue.value = null;
		assetUpdate(null);
	}
	
	private function onLoadButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showStarlingAtlasAssetsWindow(assetSelected, null, "Select Atlas asset");
	}
	
	private function assetSelected(asset:StarlingAtlasAsset):Void
	{
		_exposedValue.value = asset;
		assetUpdate(asset);
	}
	
	private function assetUpdate(asset:StarlingAtlasAsset):Void
	{
		if (asset == null)
		{
			_nameLabel.text = "";
			_pathLabel.text = "";
			_sizeLabel.text = "";
			previewUpdate(null);
		}
		else
		{
			_nameLabel.text = asset.name;
			_pathLabel.text = asset.path;
			_sizeLabel.text = asset.content.texture.width + "x" + asset.content.texture.height;
			previewUpdate(asset);
		}
	}
	
	private function previewUpdate(asset:StarlingAtlasAsset):Void
	{
		if (asset == null)
		{
			_preview.bitmapData = null;
		}
		else
		{
			_preview.bitmapData = asset.preview;
		}
		_previewGroup.setInvalid();
	}
	
}
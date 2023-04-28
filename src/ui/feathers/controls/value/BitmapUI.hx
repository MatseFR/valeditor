package ui.feathers.controls.value;
import valedit.asset.AssetLib;
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
import openfl.display.BitmapData;
import ui.feathers.FeathersWindows;
import ui.feathers.Padding;
import ui.feathers.Spacing;
import ui.feathers.variant.LabelVariant;
import valedit.asset.BitmapAsset;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class BitmapUI extends ValueUI 
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
		vLayout.paddingRight = Padding.VALUE;
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
			var value:Dynamic = _exposedValue.value;
			if (value != null)
			{
				if (Std.isOfType(value, Bitmap))
				{
					assetUpdate(AssetLib.getBitmapFromBitmapData(cast(value, Bitmap).bitmapData));
				}
				else if (Std.isOfType(value, BitmapData))
				{
					assetUpdate(AssetLib.getBitmapFromBitmapData(cast value));
				}
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
		FeathersWindows.showBitmapAssets(assetSelected, null, "Select Bitmap asset");
	}
	
	private function assetSelected(asset:BitmapAsset):Void
	{
		//trace("assetSelected");
		_exposedValue.value = asset;
		assetUpdate(asset);
	}
	
	private function assetUpdate(asset:BitmapAsset):Void
	{
		if (asset == null)
		{
			_nameLabel.text = "";
			_pathLabel.text = "";
			_sizeLabel.text = "";
			bitmapDataUpdate(null);
		}
		else
		{
			_nameLabel.text = asset.name;
			_pathLabel.text = asset.path;
			_sizeLabel.text = asset.content.width + "x" + asset.content.height;
			bitmapDataUpdate(asset.preview);
		}
	}
	
	private function bitmapDataUpdate(bmd:BitmapData):Void
	{
		_preview.bitmapData = bmd;
		_previewGroup.setInvalid();
	}
	
}
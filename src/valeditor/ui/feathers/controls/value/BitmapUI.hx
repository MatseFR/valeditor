package valeditor.ui.feathers.controls.value;
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
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.variant.LabelVariant;
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
		
		this._label = new Label();
		this._label.variant = LabelVariant.VALUE_NAME;
		addChild(this._label);
		
		this._contentGroup = new LayoutGroup();
		this._contentGroup.layoutData = new HorizontalLayoutData(100);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		this._contentGroup.layout = vLayout;
		addChild(this._contentGroup);
		
		this._previewGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.CENTER;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		this._previewGroup.layout = vLayout;
		this._contentGroup.addChild(this._previewGroup);
		
		this._preview = new Bitmap();
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
		this._buttonGroup.addChild(this._clearButton);
	}
	
	override public function initExposedValue():Void 
	{
		super.initExposedValue();
		
		this._label.text = this._exposedValue.name;
		updateEditable();
	}
	
	override public function updateExposedValue(exceptControl:IValueUI = null):Void 
	{
		super.updateExposedValue(exceptControl);
		
		if (this._initialized && this._exposedValue != null)
		{
			var controlsEnabled:Bool = this._controlsEnabled;
			if (controlsEnabled) controlsDisable();
			var value:Dynamic = this._exposedValue.value;
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
		this.enabled = this._exposedValue.isEditable;
		this._label.enabled = this._exposedValue.isEditable;
		this._nameLabel.enabled = this._exposedValue.isEditable;
		this._pathLabel.enabled = this._exposedValue.isEditable;
		this._loadButton.enabled = this._exposedValue.isEditable;
		this._clearButton.enabled = this._exposedValue.isEditable;
	}
	
	override function onValueEditableChange(evt:ValueEvent):Void 
	{
		super.onValueEditableChange(evt);
		updateEditable();
	}
	
	override function controlsDisable():Void 
	{
		if (!this._controlsEnabled) return;
		super.controlsDisable();
		this._loadButton.removeEventListener(TriggerEvent.TRIGGER, onLoadButton);
		this._clearButton.removeEventListener(TriggerEvent.TRIGGER, onClearButton);
	}
	
	override function controlsEnable():Void 
	{
		if (this._controlsEnabled) return;
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
		FeathersWindows.showBitmapAssets(assetSelected, null, "Select Bitmap asset");
	}
	
	private function assetSelected(asset:BitmapAsset):Void
	{
		this._exposedValue.value = asset;
		assetUpdate(asset);
	}
	
	private function assetUpdate(asset:BitmapAsset):Void
	{
		if (asset == null)
		{
			this._nameLabel.text = "";
			this._pathLabel.text = "";
			this._sizeLabel.text = "";
			bitmapDataUpdate(null);
		}
		else
		{
			this._nameLabel.text = asset.name;
			this._pathLabel.text = asset.path;
			this._sizeLabel.text = asset.content.width + "x" + asset.content.height;
			bitmapDataUpdate(asset.preview);
		}
	}
	
	private function bitmapDataUpdate(bmd:BitmapData):Void
	{
		this._preview.bitmapData = bmd;
		this._previewGroup.setInvalid();
	}
	
}
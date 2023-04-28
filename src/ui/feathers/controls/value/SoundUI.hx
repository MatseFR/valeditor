package ui.feathers.controls.value;
import openfl.media.Sound;
import openfl.media.SoundChannel;
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
import ui.feathers.Padding;
import ui.feathers.Spacing;
import ui.feathers.variant.LabelVariant;
import utils.TimeUtil;
import valedit.asset.SoundAsset;
import valedit.events.ValueEvent;
import valedit.ui.IValueUI;

/**
 * ...
 * @author Matse
 */
class SoundUI extends ValueUI 
{
	private var _label:Label;
	
	private var _contentGroup:LayoutGroup;
	
	private var _nameLabel:Label;
	private var _pathLabel:Label;
	private var _durationLabel:Label;
	
	private var _buttonGroup:LayoutGroup;
	private var _loadButton:Button;
	private var _clearButton:Button;
	
	private var _playButton:Button;
	private var _stopButton:Button;
	
	private var _soundChannel:SoundChannel;

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
		
		_nameLabel = new Label();
		_contentGroup.addChild(_nameLabel);
		
		_pathLabel = new Label();
		_pathLabel.wordWrap = true;
		_contentGroup.addChild(_pathLabel);
		
		_durationLabel = new Label();
		_contentGroup.addChild(_durationLabel);
		
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
		
		_playButton = new Button("play");
		_contentGroup.addChild(_playButton);
		
		_stopButton = new Button("stop");
		_contentGroup.addChild(_stopButton);
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
			if (_controlsEnabled) controlsDisable();
			var value:Dynamic = _exposedValue.value;
			if (value != null)
			{
				assetUpdate(AssetLib.getSoundFromSound(cast value));
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
		_playButton.removeEventListener(TriggerEvent.TRIGGER, onPlayButton);
		_stopButton.removeEventListener(TriggerEvent.TRIGGER, onStopButton);
	}
	
	override function controlsEnable():Void 
	{
		if (_controlsEnabled) return;
		super.controlsEnable();
		_loadButton.addEventListener(TriggerEvent.TRIGGER, onLoadButton);
		_clearButton.addEventListener(TriggerEvent.TRIGGER, onClearButton);
		_playButton.addEventListener(TriggerEvent.TRIGGER, onPlayButton);
		_stopButton.addEventListener(TriggerEvent.TRIGGER, onStopButton);
	}
	
	private function onClearButton(evt:TriggerEvent):Void
	{
		_exposedValue.value = null;
		assetUpdate(null);
	}
	
	private function onLoadButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showSoundAssets(assetSelected, null, "Select sound asset");
	}
	
	private function assetSelected(asset:SoundAsset):Void
	{
		//trace("assetSelected");
		_exposedValue.value = asset;
		assetUpdate(asset);
	}
	
	private function assetUpdate(asset:SoundAsset):Void
	{
		if (asset == null)
		{
			_nameLabel.text = "";
			_pathLabel.text = "";
			_durationLabel.text = "";
		}
		else
		{
			_nameLabel.text = asset.name;
			_pathLabel.text = asset.path;
			_durationLabel.text = TimeUtil.msToString(asset.content.length);
		}
	}
	
	private function onPlayButton(evt:TriggerEvent):Void
	{
		if (_soundChannel != null) 
		{
			_soundChannel.stop();
			_soundChannel = null;
		}
		
		var value:Dynamic = _exposedValue.value;
		if (value != null)
		{
			if (Std.isOfType(value, Sound))
			{
				_soundChannel = cast(value, Sound).play();
			}
			else
			{
				_soundChannel = cast(value, SoundAsset).content.play();
			}
		}
	}
	
	private function onStopButton(evt:TriggerEvent):Void
	{
		if (_soundChannel != null)
		{
			_soundChannel.stop();
			_soundChannel = null;
		}
	}
	
}
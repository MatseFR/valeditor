package valeditor.ui.feathers.renderers;

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.media.SoundChannel;
import valeditor.utils.TimeUtil;
import valedit.asset.SoundAsset;

/**
 * ...
 * @author Matse
 */
class SoundAssetItemRenderer extends AssetItemRenderer 
{
	public var asset(get, set):SoundAsset;
	private var _asset:SoundAsset;
	private function get_asset():SoundAsset { return this._asset; }
	private function set_asset(value:SoundAsset):SoundAsset
	{
		if (value != null)
		{
			this._nameLabel.text = value.name;
			if (value.content != null)
			{
				this._durationLabel.text = TimeUtil.msToString(value.content.length);
			}
		}
		
		return this._asset = value;
	}
	
	private var _nameLabel:Label;
	private var _durationLabel:Label;
	
	private var _playButton:Button;
	private var _stopButton:Button;
	
	private var _soundChannel:SoundChannel;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this.layout = vLayout;
		
		this._nameLabel = new Label();
		this._nameLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._nameLabel);
		
		this._durationLabel = new Label();
		this._durationLabel.variant = Label.VARIANT_DETAIL;
		addChild(this._durationLabel);
		
		this._playButton = new Button("play", onPlayButton);
		// prevent item selection when button is clicked
		this._playButton.addEventListener(MouseEvent.CLICK, onClick);
		addChild(this._playButton);
		
		this._stopButton = new Button("stop", onStopButton);
		// prevent item selection when button is clicked
		this._stopButton.addEventListener(MouseEvent.CLICK, onClick);
		addChild(this._stopButton);
	}
	
	private function onPlayButton(evt:TriggerEvent):Void
	{
		if (this._soundChannel != null) this._soundChannel.stop();
		this._soundChannel = this._asset.content.play();
		this._soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
	}
	
	private function onStopButton(evt:TriggerEvent):Void
	{
		if (this._soundChannel != null) 
		{
			this._soundChannel.stop();
			this._soundChannel = null;
		}
	}
	
	private function onSoundComplete(evt:Event):Void
	{
		this._soundChannel = null;
	}
	
	private function onClick(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
}
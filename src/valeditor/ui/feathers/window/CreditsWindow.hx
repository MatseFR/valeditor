package valeditor.ui.feathers.window;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.net.URLRequest;
import openfl.utils.Assets;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class CreditsWindow extends Panel 
{
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _closeButton:Button;
	
	private var _container:ScrollContainer;
	
	private var _authorGroup:LayoutGroup;
	private var _authorText:Label;
	private var _authorButtonsGroup:LayoutGroup;
	private var _authorWebsiteButton:Button;
	private var _authorGithubButton:Button;
	
	private var _haxeGroup:LayoutGroup;
	private var _haxeLogo:Bitmap;
	private var _haxeText:Label;
	private var _haxeButtonsGroup:LayoutGroup;
	private var _haxeWebsiteButton:Button;
	private var _haxeGithubButton:Button;
	
	private var _openflGroup:LayoutGroup;
	private var _openflLogo:Bitmap;
	private var _openflText:Label;
	private var _openflButtonsGroup:LayoutGroup;
	private var _openflWebsiteButton:Button;
	private var _openflGithubButton:Button;
	
	#if starling
	private var _starlingGroup:LayoutGroup;
	private var _starlingLogo:Bitmap;
	private var _starlingText:Label;
	private var _starlingButtonsGroup:LayoutGroup;
	private var _starlingWebsiteButton:Button;
	private var _starlingGithubButton:Button;
	#end
	
	private var _feathersGroup:LayoutGroup;
	private var _feathersLogo:Bitmap;
	private var _feathersText:Label;
	private var _feathersButtonsGroup:LayoutGroup;
	private var _feathersWebsiteButton:Button;
	private var _feathersGithubButton:Button;
	
	private var _thanksGroup:LayoutGroup;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		this._headerGroup = new Header("Credits");
		this._headerGroup.variant = HeaderVariant.THEME;
		this.header = this._headerGroup;
		
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._closeButton = new Button("close", onCloseButton);
		this._footerGroup.addChild(this._closeButton);
		
		this.layout = new AnchorLayout();
		
		this._container = new ScrollContainer();
		this._container.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.MIDDLE;
		vLayout.setPadding(Padding.DEFAULT);
		vLayout.paddingTop = Padding.DEFAULT * 4;
		vLayout.paddingBottom = Padding.DEFAULT * 4;
		vLayout.gap = Spacing.BIG * 2;
		this._container.layout = vLayout;
		addChild(this._container);
		
		// Author
		this._authorGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		this._authorGroup.layout = vLayout;
		this._container.addChild(this._authorGroup);
		
		this._authorText = new Label();
		this._authorText.text = "created by Mathieu Sénidre aka Matse";
		this._authorGroup.addChild(this._authorText);
		
		this._authorButtonsGroup = new LayoutGroup();
		this._authorButtonsGroup.layoutData = new VerticalLayoutData(100);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._authorButtonsGroup.layout = hLayout;
		this._authorGroup.addChild(this._authorButtonsGroup);
		
		this._authorWebsiteButton = new Button("Website", onAuthorWebsiteButton);
		this._authorWebsiteButton.layoutData = new HorizontalLayoutData(50);
		this._authorWebsiteButton.enabled = false;
		this._authorButtonsGroup.addChild(this._authorWebsiteButton);
		
		this._authorGithubButton = new Button("Github", onAuthorGithubButton);
		this._authorGithubButton.layoutData = new HorizontalLayoutData(50);
		this._authorButtonsGroup.addChild(this._authorGithubButton);
		
		// Haxe
		this._haxeGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		this._haxeGroup.layout = vLayout;
		this._container.addChild(this._haxeGroup);
		
		this._haxeLogo = new Bitmap(Assets.getBitmapData("valeditor/credits/haxe_logo.png"));
		this._haxeLogo.smoothing = true;
		this._haxeGroup.addChild(this._haxeLogo);
		
		this._haxeText = new Label("Open source high-level strictly-typed programming language with a fast optimizing cross-compiler.");
		this._haxeText.wordWrap = true;
		this._haxeGroup.addChild(this._haxeText);
		
		this._haxeButtonsGroup = new LayoutGroup();
		this._haxeButtonsGroup.layoutData = new VerticalLayoutData(100);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._haxeButtonsGroup.layout = hLayout;
		this._haxeGroup.addChild(this._haxeButtonsGroup);
		
		this._haxeWebsiteButton = new Button("Website", onHaxeWebsiteButton);
		this._haxeWebsiteButton.layoutData = new HorizontalLayoutData(50);
		this._haxeButtonsGroup.addChild(this._haxeWebsiteButton);
		
		this._haxeGithubButton = new Button("Github", onHaxeGithubButton);
		this._haxeGithubButton.layoutData = new HorizontalLayoutData(50);
		this._haxeButtonsGroup.addChild(this._haxeGithubButton);
		
		// OpenFL
		this._openflGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		this._openflGroup.layout = vLayout;
		this._container.addChild(this._openflGroup);
		
		this._openflLogo = new Bitmap(Assets.getBitmapData("valeditor/credits/openfl_logo.png"));
		this._openflLogo.smoothing = true;
		this._openflGroup.addChild(this._openflLogo);
		
		this._openflText = new Label("The Open Flash Library for creative expression on the web, desktop, mobile and consoles.");
		this._openflText.wordWrap = true;
		this._openflGroup.addChild(this._openflText);
		
		this._openflButtonsGroup = new LayoutGroup();
		this._openflButtonsGroup.layoutData = new VerticalLayoutData(100);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._openflButtonsGroup.layout = hLayout;
		this._openflGroup.addChild(this._openflButtonsGroup);
		
		this._openflWebsiteButton = new Button("Website", onOpenflWebsiteButton);
		this._openflWebsiteButton.layoutData = new HorizontalLayoutData(50);
		this._openflButtonsGroup.addChild(this._openflWebsiteButton);
		
		this._openflGithubButton = new Button("Github", onOpenflGithubButton);
		this._openflGithubButton.layoutData = new HorizontalLayoutData(50);
		this._openflButtonsGroup.addChild(this._openflGithubButton);
		
		#if starling
		// Starling
		this._starlingGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		this._starlingGroup.layout = vLayout;
		this._container.addChild(this._starlingGroup);
		
		this._starlingLogo = new Bitmap(Assets.getBitmapData("valeditor/credits/starling_logo.png"));
		this._starlingLogo.smoothing = true;
		this._starlingGroup.addChild(this._starlingLogo);
		
		this._starlingText = new Label("Display list on the GPU.");
		this._starlingText.wordWrap = true;
		this._starlingGroup.addChild(this._starlingText);
		
		this._starlingButtonsGroup = new LayoutGroup();
		this._starlingButtonsGroup.layoutData = new VerticalLayoutData(100);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._starlingButtonsGroup.layout = hLayout;
		this._starlingGroup.addChild(this._starlingButtonsGroup);
		
		this._starlingWebsiteButton = new Button("Website", onStarlingWebsiteButton);
		this._starlingWebsiteButton.layoutData = new HorizontalLayoutData(50);
		this._starlingButtonsGroup.addChild(this._starlingWebsiteButton);
		
		this._starlingGithubButton = new Button("Github", onStarlingGithubButton);
		this._starlingGithubButton.layoutData = new HorizontalLayoutData(50);
		this._starlingButtonsGroup.addChild(this._starlingGithubButton);
		#end
		
		// Feathers
		this._feathersGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.LEFT;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.DEFAULT;
		this._feathersGroup.layout = vLayout;
		this._container.addChild(this._feathersGroup);
		
		this._feathersLogo = new Bitmap(Assets.getBitmapData("valeditor/credits/feathers_logo.png"));
		this._feathersLogo.smoothing = true;
		this._feathersGroup.addChild(this._feathersLogo);
		
		this._feathersText = new Label("Cross-platform user interface components for creative frontend projects.");
		this._feathersText.wordWrap = true;
		this._feathersGroup.addChild(this._feathersText);
		
		this._feathersButtonsGroup = new LayoutGroup();
		this._feathersButtonsGroup.layoutData = new VerticalLayoutData(100);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		this._feathersButtonsGroup.layout = hLayout;
		this._feathersGroup.addChild(this._feathersButtonsGroup);
		
		this._feathersWebsiteButton = new Button("Website", onFeathersWebsiteButton);
		this._feathersWebsiteButton.layoutData = new HorizontalLayoutData(50);
		this._feathersButtonsGroup.addChild(this._feathersWebsiteButton);
		
		this._feathersGithubButton = new Button("Github", onFeathersGithubButton);
		this._feathersGithubButton.layoutData = new HorizontalLayoutData(50);
		this._feathersButtonsGroup.addChild(this._feathersGithubButton);
	}
	
	private function onCloseButton(evt:TriggerEvent):Void
	{
		FeathersWindows.closeWindow(this);
	}
	
	private function onAuthorGithubButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://github.com/MatseFR");
		Lib.navigateToURL(req, "_blank");
	}
	
	private function onAuthorWebsiteButton(evt:TriggerEvent):Void
	{
		
	}
	
	private function onHaxeGithubButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://github.com/HaxeFoundation/haxe");
		Lib.navigateToURL(req, "_blank");
	}
	
	private function onHaxeWebsiteButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://haxe.org/");
		Lib.navigateToURL(req, "_blank");
	}
	
	private function onOpenflGithubButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://github.com/openfl/openfl");
		Lib.navigateToURL(req, "_blank");
	}
	
	private function onOpenflWebsiteButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://www.openfl.org/");
		Lib.navigateToURL(req, "_blank");
	}
	
	#if starling
	private function onStarlingGithubButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://github.com/openfl/starling");
		Lib.navigateToURL(req, "_blank");
	}
	
	private function onStarlingWebsiteButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://gamua.com/starling/");
		Lib.navigateToURL(req, "_blank");
	}
	#end
	
	private function onFeathersGithubButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://github.com/feathersui/feathersui-openfl");
		Lib.navigateToURL(req, "_blank");
	}
	
	private function onFeathersWebsiteButton(evt:TriggerEvent):Void
	{
		var req:URLRequest = new URLRequest("https://feathersui.com/");
		Lib.navigateToURL(req, "_blank");
	}
	
}
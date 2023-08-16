package valeditor.ui.feathers.window.asset;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.core.PopUpManager;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.TiledRowsListLayout;
import feathers.layout.VerticalAlign;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.net.FileFilter;
#if desktop
import valeditor.utils.file.FilesOpenerDesktop;
import valeditor.utils.file.FolderOpenerDesktop;
import openfl.filesystem.File;
#else
import valeditor.utils.file.FilesOpener;
import openfl.net.FileReference;
#end
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.theme.simple.variants.HeaderVariant;

/**
 * ...
 * @author Matse
 */
class AssetsWindow<T> extends Panel 
{
	public var cancelCallback(get, set):Void->Void;
	private var _cancelCallback:Void->Void;
	private function get_cancelCallback():Void->Void { return this._cancelCallback; }
	private function set_cancelCallback(value:Void->Void):Void->Void
	{
		return this._cancelCallback = value;
	}
	
	public var cancelEnabled(get, set):Bool;
	private var _cancelEnabled:Bool = true;
	private function get_cancelEnabled():Bool { return this._cancelEnabled; }
	private function set_cancelEnabled(value:Bool):Bool
	{
		return this._cancelEnabled = value;
	}
	
	public var closeOnSelection(get, set):Bool;
	private var _closeOnSelection:Bool = false;
	private function get_closeOnSelection():Bool { return this._closeOnSelection; }
	private function set_closeOnSelection(value:Bool):Bool
	{
		return this._closeOnSelection = value;
	}
	
	public var filesEnabled(get, set):Bool;
	private var _filesEnabled:Bool = true;
	private function get_filesEnabled():Bool { return this._filesEnabled; }
	private function set_filesEnabled(value:Bool):Bool
	{
		return this._filesEnabled = value;
	}
	
	public var headerEnabled(get, set):Bool;
	private var _headerEnabled:Bool = true;
	private function get_headerEnabled():Bool { return this._headerEnabled; }
	private function set_headerEnabled(value:Bool):Bool
	{
		return this._headerEnabled = value;
	}
	
	public var removeEnabled(get, set):Bool;
	private var _removeEnabled:Bool = false;
	private function get_removeEnabled():Bool { return this._removeEnabled; }
	private function set_removeEnabled(value:Bool):Bool
	{
		return this._removeEnabled = value;
	}
	
	public var selectionCallback(get, set):T->Void;
	private var _selectionCallback:T->Void;
	private function get_selectionCallback():T->Void { return this._selectionCallback; }
	private function set_selectionCallback(value:T->Void):T->Void
	{
		return this._selectionCallback = value;
	}
	
	public var title(get, set):String;
	private var _title:String = "";
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (value == null) value = "";
		if (this._initialized)
		{
			this._headerGroup.text = value;
		}
		return this._title = value;
	}
	
	private var _headerGroup:Header;
	
	private var _footerGroup:LayoutGroup;
	private var _assetList:ListView;
	
	private var _addFilesButton:Button;
	#if desktop
	private var _addFolderButton:Button;
	#end
	private var _cancelButton:Button;
	private var _removeButton:Button;
	
	private var _buttonList:Array<Button> = new Array<Button>();
	
	private var _extensionList:Array<String>;
	private var _filterList:Array<FileFilter>;
	
	#if desktop
	private var _fileOpener:FilesOpenerDesktop = new FilesOpenerDesktop();
	private var _fileDialogTitle:String = "Select file(s)";
	private var _folderOpener:FolderOpenerDesktop = new FolderOpenerDesktop();
	private var _folderDialogTitle:String = "Select folder";
	#else
	private var _fileOpener:FilesOpener = new FilesOpener();
	#end
	
	private var _controlsEnabled:Bool;
	
	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var listLayout:TiledRowsListLayout;
		
		this.layout = new AnchorLayout();
		
		if (this._headerEnabled)
		{
			this._headerGroup = new Header(this._title);
			this._headerGroup.variant = HeaderVariant.THEME;
			this.header = this._headerGroup;
		}
		
		this._footerGroup = new LayoutGroup();
		this._footerGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.CENTER;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		this._footerGroup.layout = hLayout;
		this.footer = this._footerGroup;
		
		this._addFilesButton = new Button("add file(s)");
		if (this._filesEnabled)
		{
			this._footerGroup.addChild(this._addFilesButton);
		}
		this._buttonList.push(this._addFilesButton);
		
		#if desktop
		this._addFolderButton = new Button("add folder");
		if (this._filesEnabled)
		{
			this._footerGroup.addChild(this._addFolderButton);
		}
		this._buttonList.push(this._addFolderButton);
		#end
		
		this._cancelButton = new Button("cancel");
		if (this._cancelEnabled)
		{
			this._footerGroup.addChild(this._cancelButton);
		}
		this._buttonList.push(this._cancelButton);
		
		if (this._removeEnabled)
		{
			this._removeButton = new Button("remove selected");
			this._removeButton.enabled = false;
			this._footerGroup.addChild(this._removeButton);
		}
		
		this._assetList = new ListView();
		this._assetList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		listLayout = new TiledRowsListLayout();
		listLayout.setPadding(Padding.DEFAULT);
		listLayout.setGap(Spacing.DEFAULT);
		this._assetList.layout = listLayout;
		this._assetList.allowMultipleSelection = this._removeEnabled;
		addChild(this._assetList);
		
		//controlsEnable();
	}
	
	public function reset():Void
	{
		if (this._assetList != null) 
		{
			var controlsEnabled:Bool = this._controlsEnabled;
			if (controlsEnabled) controlsDisable();
			this._assetList.selectedIndex = -1;
			if (controlsEnabled) controlsEnable();
		}
	}
	
	private function controlsDisable():Void
	{
		if (!this._controlsEnabled) return;
		this._assetList.removeEventListener(Event.CHANGE, onSelectionChange);
		this._assetList.removeEventListener(MouseEvent.CLICK, onAssetListBackgroundClick);
		this._addFilesButton.removeEventListener(TriggerEvent.TRIGGER, onAddFilesButton);
		#if desktop
		this._addFolderButton.removeEventListener(TriggerEvent.TRIGGER, onAddFolderButton);
		#end
		if (this._cancelButton != null) this._cancelButton.removeEventListener(TriggerEvent.TRIGGER, onCancelButton);
		if (this._removeButton != null) this._removeButton.removeEventListener(TriggerEvent.TRIGGER, onRemoveButton);
		this._controlsEnabled = false;
	}
	
	private function controlsEnable():Void
	{
		if (this._controlsEnabled) return;
		this._assetList.addEventListener(Event.CHANGE, onSelectionChange);
		this._assetList.addEventListener(MouseEvent.CLICK, onAssetListBackgroundClick);
		this._addFilesButton.addEventListener(TriggerEvent.TRIGGER, onAddFilesButton);
		#if desktop
		this._addFolderButton.addEventListener(TriggerEvent.TRIGGER, onAddFolderButton);
		#end
		if (this._cancelButton != null) this._cancelButton.addEventListener(TriggerEvent.TRIGGER, onCancelButton);
		if (this._removeButton != null) this._removeButton.addEventListener(TriggerEvent.TRIGGER, onRemoveButton);
		this._controlsEnabled = true;
	}
	
	private function disableUI():Void
	{
		this._assetList.selectable = false;
		for (btn in this._buttonList)
		{
			btn.enabled = false;
		}
		if (this._removeButton != null) this._removeButton.enabled = false;
	}
	
	private function enableUI():Void
	{
		this._assetList.selectable = true;
		for (btn in this._buttonList)
		{
			btn.enabled = true;
		}
		if (this._removeButton != null) this._removeButton.enabled = this._assetList.selectedIndices.length != 0;
	}
	
	private function onSelectionChange(evt:Event):Void
	{
		if (this._selectionCallback != null)
		{
			this._selectionCallback(this._assetList.selectedItem);
		}
		if (this._closeOnSelection)
		{
			PopUpManager.removePopUp(this);
		}
		if (this._removeButton != null)
		{
			this._removeButton.enabled = this._assetList.selectedIndices.length != 0;
		}
	}
	
	#if desktop
	private function onAddFilesButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._fileOpener.start(onAddFilesComplete, onAddFilesCancel, this._filterList, null, this._fileDialogTitle);
	}
	
	private function onAddFilesCancel():Void
	{
		enableUI();
	}
	
	private function onAddFilesComplete(files:Array<File>):Void
	{
		throw new Error("override onAddFilesComplete function");
	}
	
	private function onAddFolderButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._folderOpener.start(onAddFolderComplete, onAddFolderCancel, this._extensionList, this._folderDialogTitle);
	}
	
	private function onAddFolderCancel():Void
	{
		enableUI();
	}
	
	private function onAddFolderComplete(files:Array<File>):Void
	{
		throw new Error("override onAddFolderComplete function");
	}
	#else
	private function onAddFilesButton(evt:TriggerEvent):Void
	{
		disableUI();
		this._fileOpener.start(onAddFilesComplete, onAddFilesCancel, this._filterList);
	}
	
	private function onAddFilesCancel():Void
	{
		enableUI();
	}
	
	private function onAddFilesComplete(files:Array<FileReference>):Void
	{
		throw new Error("override onAddFilesComplete function");
	}
	#end
	
	private function onAssetListBackgroundClick(evt:MouseEvent):Void
	{
		this._assetList.selectedIndex = -1;
	}
	
	private function onCancelButton(evt:TriggerEvent):Void
	{
		PopUpManager.removePopUp(this);
		if (this._cancelCallback != null) this._cancelCallback();
	}
	
	private function onRemoveButton(evt:TriggerEvent):Void
	{
		
	}
	
}
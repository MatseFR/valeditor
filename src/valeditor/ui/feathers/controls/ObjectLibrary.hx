package valeditor.ui.feathers.controls;

import feathers.controls.LayoutGroup;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import valeditor.ValEditor;
import valeditor.events.EditorEvent;
import valeditor.ui.feathers.theme.variant.TabBarVariant;

/**
 * ...
 * @author Matse
 */
class ObjectLibrary extends LayoutGroup 
{
	private var _tabNavigator:TabNavigator;
	private var _allObjects:ObjectList;
	private var _activeObjects:ObjectList;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		this.layout = new AnchorLayout();
		
		this._allObjects = new ObjectList();
		this._allObjects.isGlobal = true;
		this._activeObjects = new ObjectList();
		
		var views:ArrayCollection<TabItem> = new ArrayCollection<TabItem>([
			TabItem.withDisplayObject("All", this._allObjects),
			TabItem.withDisplayObject("Active", this._activeObjects)
		]);
		
		this._tabNavigator = new TabNavigator(views);
		this._tabNavigator.customTabBarVariant = TabBarVariant.TOP_SPACING;
		this._tabNavigator.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(this._tabNavigator);
		
		ValEditor.addEventListener(EditorEvent.CONTAINER_CURRENT, onEditorContainerCurrent);
		
		if (ValEditor.currentContainer != null)
		{
			onEditorContainerCurrent(null);
		}
	}
	
	private function onEditorContainerCurrent(evt:EditorEvent):Void
	{
		if (ValEditor.currentContainer != null)
		{
			this._allObjects.collection = ValEditor.currentContainer.allObjectsCollection;
			this._activeObjects.collection = ValEditor.currentContainer.activeObjectsCollection;
		}
		else
		{
			this._allObjects.collection = null;
			this._activeObjects.collection = null;
		}
	}
	
}
package editor.base;

import feathers.controls.Application;
import feathers.controls.navigators.StackItem;
import feathers.controls.navigators.StackNavigator;
import feathers.style.Theme;
import openfl.display.StageScaleMode;
import valedit.helpers.DisplayHelper;
import valedit.helpers.GeomHelper;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import ui.feathers.FeathersFactories;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.view.EditView;
import valedit.value.ExposedGroup;
import valedit.ValEdit;
import valedit.value.ExposedBool;
import valedit.value.ExposedColor;
import valedit.value.ExposedFloat;
import valedit.value.ExposedFloatRange;
import valedit.value.ExposedInt;
import valedit.value.ExposedIntRange;
import valedit.value.ExposedObject;
import valedit.value.ExposedSelect;
import valedit.value.ExposedString;

/**
 * ...
 * @author Matse
 */
class ValEditorBaseFeathers extends Application 
{
	public var scene(default, null):Sprite;
	public var screenNavigator(default, null):StackNavigator;
	public var theme(default, null):ValEditorTheme;
	public var editView(default, null):EditView;
	
	/**
	   
	**/
	public function new() 
	{
		super();
		
		var item:StackItem;
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.stageFocusRect = false;
		
		scene = new Sprite();
		addChild(scene);
		
		theme = new ValEditorTheme();
		Theme.setTheme(theme);
		
		screenNavigator = new StackNavigator();
		addChild(screenNavigator);
		
		editView = new EditView();
		editView.initializeNow();
		ValEdit.uiContainerDefault = editView.valEditContainer;
		
		item = StackItem.withDisplayObject(EditView.ID, editView);
		screenNavigator.addItem(item);
		
		screenNavigator.pushItem(EditView.ID);
	}
	
}
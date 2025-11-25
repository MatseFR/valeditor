package valeditor.data;
import openfl.Assets;
import openfl.utils.AssetType;
#if massive
import valedit.data.massive.data.MassiveData;
import valedit.data.massive.display.MassiveDisplayData;
import valedit.data.massive.particle.MassiveParticleData;
#end
import valedit.data.openfl.display.OpenFLDisplayData;
import valedit.data.openfl.display3D.OpenFLDisplay3DData;
import valedit.data.openfl.filesystem.OpenFLFileSystemData;
import valedit.data.openfl.filters.OpenFLFiltersData;
import valedit.data.openfl.geom.OpenFLGeomData;
import valedit.data.openfl.media.OpenFLMediaData;
import valedit.data.openfl.net.OpenFLNetData;
import valedit.data.openfl.text.OpenFLTextData;
import valedit.data.openfl.ui.OpenFLUiData;
import valedit.data.valedit.ShapeData;
import valeditor.ValEditor;
import valeditor.ValEditorClassSettings;
import valeditor.editor.CategoryID;
import valeditor.ui.InteractiveFactories;
#if starling
import valedit.data.starling.animation.StarlingAnimationData;
import valedit.data.starling.core.StarlingCoreData;
import valedit.data.starling.display.StarlingDisplayData;
import valedit.data.starling.events.StarlingEventsData;
import valedit.data.starling.extensions.StarlingColorArgbData;
import valedit.data.starling.filters.StarlingFilterData;
import valedit.data.starling.geom.StarlingGeomData;
import valedit.data.starling.rendering.StarlingRenderingData;
import valedit.data.starling.styles.StarlingStylesData;
import valedit.data.starling.text.StarlingTextData;
import valedit.data.starling.texture.StarlingTextureData;
import valedit.data.starling.utils.StarlingUtilsData;
#end

/**
 * ...
 * @author Matse
 */
class Data 
{
	
	static public function exposeAll():Void
	{
		#if massive
		exposeMassive();
		#end
		exposeOpenFL();
		#if starling
		exposeStarling();
		#end
	}
	
	//################################################################################
	// Massive
	//################################################################################
	#if massive
	static public function exposeMassive():Void
	{
		exposeMassive_data();
		exposeMassive_display();
		exposeMassive_particle();
	}
	
	static public function exposeMassive_data():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Frame
		settings.canBeCreated = false;
		settings.collection = MassiveData.exposeFrame();
		ValEditor.registerClass(massive.data.Frame, settings);
		settings.clear();
		
		// ImageData
		settings.canBeCreated = false;
		settings.collection = MassiveData.exposeImageData();
		ValEditor.registerClass(massive.data.ImageData, settings);
		settings.clear();
		
		// QuadData
		settings.canBeCreated = false;
		settings.collection = MassiveData.exposeQuadData();
		ValEditor.registerClass(massive.data.QuadData, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeMassive_display():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// MassiveDisplay
		settings.canBeCreated = false;
		settings.collection = MassiveDisplayData.exposeMassiveDisplay();
		ValEditor.registerClass(massive.display.MassiveDisplay, settings);
		settings.clear();
		
		// MassiveImageLayer
		settings.canBeCreated = false;
		settings.collection = MassiveDisplayData.exposeMassiveImageLayer();
		ValEditor.registerClass(massive.display.MassiveImageLayer, settings);
		settings.clear();
		
		// MassiveQuadLayer
		settings.canBeCreated = false;
		settings.collection = MassiveDisplayData.exposeMassiveQuadLayer();
		ValEditor.registerClass(massive.display.MassiveQuadLayer, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeMassive_particle():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Particle
		
		// ParticleEmitter
		
		// ParticleSystem
		settings.canBeCreated = false;
		settings.collection = MassiveParticleData.exposeParticleSystem();
		ValEditor.registerClass(massive.particle.ParticleSystem, settings);
		settings.clear();
		
		// ParticleSystemOptions
		settings.canBeCreated = false;
		settings.collection = MassiveParticleData.exposeParticleSystemOptions();
		ValEditor.registerClass(massive.particle.ParticleSystemOptions, settings);
		settings.clear();
		
		settings.pool();
	}
	#end
	//################################################################################
	//\Massive
	//################################################################################
	
	//################################################################################
	// OpenFL
	//################################################################################
	static public function exposeOpenFL():Void
	{
		exposeOpenFL_display();
		exposeOpenFL_display_shapes();
		exposeOpenFL_display3D();
		exposeOpenFL_filters();
		#if desktop
		exposeOpenFL_filesystem();
		#end
		exposeOpenFL_geom();
		exposeOpenFL_media();
		exposeOpenFL_net();
		exposeOpenFL_text();
		exposeOpenFL_ui();
	}
	
	static public function exposeOpenFL_display():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Bitmap
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeBitmap();
		settings.visibilityCollection = OpenFLDisplayData.getBitmapVisibility();
		settings.constructorCollection = OpenFLDisplayData.exposeBitmapConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(openfl.display.Bitmap, settings);
		settings.clear();
		
		// BitmapData
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeBitmapData();
		settings.constructorCollection = OpenFLDisplayData.exposeBitmapDataConstructor();
		ValEditor.registerClass(openfl.display.BitmapData, settings);
		settings.clear();
		
		// DisplayObject
		settings.canBeCreated = false;
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeDisplayObject();
		ValEditor.registerClass(openfl.display.DisplayObject, settings);
		settings.clear();
		
		// DisplayObjectContainer
		settings.canBeCreated = false;
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeDisplayObjectContainer();
		ValEditor.registerClass(openfl.display.DisplayObjectContainer, settings);
		settings.clear();
		
		// FPS
		settings.canBeCreated = true;
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeFPS();
		settings.constructorCollection = OpenFLDisplayData.exposeFPSConstructor();
		ValEditor.registerClass(openfl.display.FPS, settings);
		settings.clear();
		
		// InteractiveObject
		settings.canBeCreated = false;
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeInteractiveObject();
		ValEditor.registerClass(openfl.display.InteractiveObject, settings);
		settings.clear();
		
		// MovieClip
		settings.canBeCreated = false;
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeMovieClip();
		ValEditor.registerClass(openfl.display.MovieClip, settings);
		settings.clear();
		
		// NativeWindow
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeNativeWindow();
		settings.constructorCollection = OpenFLDisplayData.exposeNativeWindowConstructor();
		ValEditor.registerClass(openfl.display.NativeWindow, settings);
		settings.clear();
		
		// NativeWindowInitOptions
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeNativeWindowInitOptions();
		ValEditor.registerClass(openfl.display.NativeWindowInitOptions, settings);
		settings.clear();
		
		// Screen
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeScreen();
		ValEditor.registerClass(openfl.display.Screen, settings);
		settings.clear();
		
		#if (!air || air >= 31)
		// ScreenMode
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeScreenMode();
		ValEditor.registerClass(openfl.display.ScreenMode, settings);
		settings.clear();
		#end
		
		// Shape
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeShape();
		ValEditor.registerClass(openfl.display.Shape, settings);
		settings.clear();
		
		// SimpleButton
		settings.canBeCreated = true;
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeSimpleButton();
		settings.constructorCollection = OpenFLDisplayData.exposeSimpleButtonConstructor();
		ValEditor.registerClass(openfl.display.SimpleButton, settings);
		settings.clear();
		
		// Sprite
		settings.canBeCreated = false;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLDisplayData.exposeSprite();
		settings.visibilityCollection = OpenFLDisplayData.getSpriteVisibility();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		ValEditor.registerClass(openfl.display.Sprite, settings);
		settings.clear();
		
		// Stage
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeStage();
		ValEditor.registerClass(openfl.display.Stage, settings);
		settings.clear();
		
		// Stage3D
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeStage3D();
		ValEditor.registerClass(openfl.display.Stage3D, settings);
		settings.clear();
		
		// Tile
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeTile();
		settings.constructorCollection = OpenFLDisplayData.exposeTileConstructor();
		ValEditor.registerClass(openfl.display.Tile, settings);
		settings.clear();
		
		// TileContainer
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeTileContainer();
		settings.constructorCollection = OpenFLDisplayData.exposeTileContainerConstructor();
		ValEditor.registerClass(openfl.display.TileContainer, settings);
		settings.clear();
		
		// TileMap
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeTileMap();
		settings.constructorCollection = OpenFLDisplayData.exposeTileMapConstructor();
		ValEditor.registerClass(openfl.display.Tilemap, settings);
		settings.clear();
		
		// Tileset
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplayData.exposeTileSet();
		settings.constructorCollection = OpenFLDisplayData.exposeTileSetConstructor();
		ValEditor.registerClass(openfl.display.Tileset, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_display_shapes():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// ArcShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeArcShape();
		settings.visibilityCollection = ShapeData.getArcShapeVisibility();
		settings.constructorCollection = ShapeData.exposeArcShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.ArcShape, settings);
		settings.clear();
		
		// ArrowShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeArrowShape();
		settings.visibilityCollection = ShapeData.getArrowShapeVisibility();
		settings.constructorCollection = ShapeData.exposeArrowShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.ArrowShape, settings);
		settings.clear();
		
		// BurstShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeBurstShape();
		settings.visibilityCollection = ShapeData.getBurstShapeVisibility();
		settings.constructorCollection = ShapeData.exposeBurstShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.BurstShape, settings);
		settings.clear();
		
		// CircleShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeCircleShape();
		settings.visibilityCollection = ShapeData.getCircleShapeVisibility();
		settings.constructorCollection = ShapeData.exposeCircleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.CircleShape, settings);
		settings.clear();
		
		// DonutShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeDonutShape();
		settings.visibilityCollection = ShapeData.getDonutShapeVisibility();
		settings.constructorCollection = ShapeData.exposeDonutShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.DonutShape, settings);
		settings.clear();
		
		// EllipseShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeEllipseShape();
		settings.visibilityCollection = ShapeData.getEllipseShapeVisibility();
		settings.constructorCollection = ShapeData.exposeEllipseShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.EllipseShape, settings);
		settings.clear();
		
		// FlowerShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeFlowerShape();
		settings.visibilityCollection = ShapeData.getFlowerShapeVisibility();
		settings.constructorCollection = ShapeData.exposeFlowerShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.FlowerShape, settings);
		settings.clear();
		
		// GearShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeGearShape();
		settings.visibilityCollection = ShapeData.getGearShapeVisibility();
		settings.constructorCollection = ShapeData.exposeGearShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.GearShape, settings);
		settings.clear();
		
		// PolygonShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposePolygonShape();
		settings.visibilityCollection = ShapeData.getPolygonShapeVisibility();
		settings.constructorCollection = ShapeData.exposePolygonShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.PolygonShape, settings);
		settings.clear();
		
		// RectangleShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeRectangleShape();
		settings.visibilityCollection = ShapeData.getRectangleShapeVisibility();
		settings.constructorCollection = ShapeData.exposeRectangleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.RectangleShape, settings);
		settings.clear();
		
		// RoundRectangleShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeRoundRectangleShape();
		settings.visibilityCollection = ShapeData.getRoundRectangleShapeVisibility();
		settings.constructorCollection = ShapeData.exposeRoundRectangleShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.RoundRectangleShape, settings);
		settings.clear();
		
		// StarShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeStarShape();
		settings.visibilityCollection = ShapeData.getStarShapeVisibility();
		settings.constructorCollection = ShapeData.exposeStarShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.StarShape, settings);
		settings.clear();
		
		// WedgeShape
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_DISPLAY);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = ShapeData.exposeWedgeShape();
		settings.visibilityCollection = ShapeData.getWedgeShapeVisibility();
		settings.constructorCollection = ShapeData.exposeWedgeShapeConstructor();
		settings.interactiveFactory = InteractiveFactories.openFL_default;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(valedit.object.openfl.display.WedgeShape, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_display3D():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Context3D
		settings.canBeCreated = false;
		settings.collection = OpenFLDisplay3DData.exposeContext3D();
		ValEditor.registerClass(openfl.display3D.Context3D, settings);
		settings.clear();
		
		settings.pool();
	}
	
	#if desktop
	static public function exposeOpenFL_filesystem():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		settings.canBeCreated = false;
		settings.collection = OpenFLFileSystemData.exposeFile();
		settings.constructorCollection = OpenFLFileSystemData.exposeFileConstructor();
		ValEditor.registerClass(openfl.filesystem.File, settings);
		
		settings.pool();
	}
	#end
	
	static public function exposeOpenFL_filters():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// BevelFilter
		settings.canBeCreated = false;
		settings.collection = OpenFLFiltersData.exposeBevelFilter();
		settings.constructorCollection = OpenFLFiltersData.exposeBevelFilterConstructor();
		ValEditor.registerClass(openfl.filters.BevelFilter, settings);
		settings.clear();
		
		// BlurFilter
		settings.canBeCreated = false;
		settings.collection = OpenFLFiltersData.exposeBlurFilter();
		settings.constructorCollection = OpenFLFiltersData.exposeBlurFilterConstructor();
		ValEditor.registerClass(openfl.filters.BlurFilter, settings);
		settings.clear();
		
		// DisplacementMapFilter
		settings.canBeCreated = false;
		settings.collection = OpenFLFiltersData.exposeDisplacementMapFilter();
		settings.constructorCollection = OpenFLFiltersData.exposeDisplacementMapFilterConstructor();
		ValEditor.registerClass(openfl.filters.DisplacementMapFilter, settings);
		settings.clear();
		
		// DropShadowFilter
		settings.canBeCreated = false;
		settings.collection = OpenFLFiltersData.exposeDropShadowFilter();
		settings.constructorCollection = OpenFLFiltersData.exposeDropShadowFilterConstructor();
		ValEditor.registerClass(openfl.filters.DropShadowFilter, settings);
		settings.clear();
		
		// GlowFilter
		settings.canBeCreated = false;
		settings.collection = OpenFLFiltersData.exposeGlowFilter();
		settings.constructorCollection = OpenFLFiltersData.exposeGlowFilterConstructor();
		ValEditor.registerClass(openfl.filters.GlowFilter, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_geom():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// ColorTransform
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposeColorTransform();
		ValEditor.registerClass(openfl.geom.ColorTransform, settings);
		settings.clear();
		
		// Matrix
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposeMatrix();
		settings.constructorCollection = OpenFLGeomData.exposeMatrixConstructor();
		ValEditor.registerClass(openfl.geom.Matrix, settings);
		settings.clear();
		
		// Matrix3D
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposeMatrix3D();
		ValEditor.registerClass(openfl.geom.Matrix3D, settings);
		settings.clear();
		
		// PerspectiveProjection
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposePerspectiveProjection();
		settings.constructorCollection = OpenFLGeomData.exposePerspectiveProjectionConstructor();
		ValEditor.registerClass(openfl.geom.PerspectiveProjection, settings);
		settings.clear();
		
		// Point
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposePoint();
		settings.constructorCollection = OpenFLGeomData.exposePointConstructor();
		ValEditor.registerClass(openfl.geom.Point, settings);
		settings.clear();
		
		// Rectangle
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposeRectangle();
		settings.constructorCollection = OpenFLGeomData.exposeRectangleConstructor();
		ValEditor.registerClass(openfl.geom.Rectangle, settings);
		settings.clear();
		
		// Transform
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposeTransform();
		ValEditor.registerClass(openfl.geom.Transform, settings);
		settings.clear();
		
		// Vector3D
		settings.canBeCreated = false;
		settings.collection = OpenFLGeomData.exposeVector3D();
		settings.constructorCollection = OpenFLGeomData.exposeVector3DConstructor();
		ValEditor.registerClass(openfl.geom.Vector3D, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_media():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// ID3Info
		settings.canBeCreated = false;
		settings.collection = OpenFLMediaData.exposeID3Info();
		ValEditor.registerClass(openfl.media.ID3Info, settings);
		settings.clear();
		
		// Sound
		settings.canBeCreated = false;
		settings.collection = OpenFLMediaData.exposeSound();
		ValEditor.registerClass(openfl.media.Sound, settings);
		settings.clear();
		
		// SoundChannel
		settings.canBeCreated = false;
		settings.collection = OpenFLMediaData.exposeSoundChannel();
		ValEditor.registerClass(openfl.media.SoundChannel, settings);
		settings.clear();
		
		// SoundLoaderContext
		settings.canBeCreated = false;
		settings.collection = OpenFLMediaData.exposeSoundLoaderContext();
		settings.constructorCollection = OpenFLMediaData.exposeSoundLoaderContextConstructor();
		ValEditor.registerClass(openfl.media.SoundLoaderContext, settings);
		settings.clear();
		
		// SoundTransform
		settings.canBeCreated = false;
		settings.collection = OpenFLMediaData.exposeSoundTransform();
		settings.constructorCollection = OpenFLMediaData.exposeSoundTransformConstructor();
		ValEditor.registerClass(openfl.media.SoundTransform, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_net():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// FileReference
		settings.canBeCreated = false;
		settings.collection = OpenFLNetData.exposeFileReference();
		ValEditor.registerClass(openfl.net.FileReference, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_text():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Font
		settings.canBeCreated = false;
		settings.collection = OpenFLTextData.exposeFont();
		settings.constructorCollection = OpenFLTextData.exposeFontConstructor();
		ValEditor.registerClass(openfl.text.Font, settings);
		settings.clear();
		
		// TextField
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_TEXT);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectOpenFL = true;
		settings.collection = OpenFLTextData.exposeTextField();
		settings.visibilityCollection = OpenFLTextData.getTextFieldVisibility();
		settings.interactiveFactory = InteractiveFactories.openFL_visible;
		settings.useBounds = true;
		ValEditor.registerClass(openfl.text.TextField, settings);
		settings.clear();
		
		// TextFormat
		settings.canBeCreated = false;
		settings.addCategory(CategoryID.OPENFL);
		settings.addCategory(CategoryID.OPENFL_TEXT);
		if (Assets.exists("valeditor/icon/openfl.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/openfl.png");
		}
		settings.collection = OpenFLTextData.exposeTextFormat();
		settings.constructorCollection = OpenFLTextData.exposeTextFormatConstructor();
		ValEditor.registerClass(openfl.text.TextFormat, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeOpenFL_ui():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// GameInputControl
		settings.canBeCreated = false;
		settings.collection = OpenFLUiData.exposeGameInputControl();
		ValEditor.registerClass(openfl.ui.GameInputControl, settings);
		settings.clear();
		
		// GameInputDevice
		settings.canBeCreated = false;
		settings.collection = OpenFLUiData.exposeGameInputDevice();
		ValEditor.registerClass(openfl.ui.GameInputDevice, settings);
		settings.clear();
		
		settings.pool();
	}
	//################################################################################
	//\OpenFL
	//################################################################################
	
	//################################################################################
	// Starling
	//################################################################################
	#if starling
	static public function exposeStarling():Void
	{
		exposeStarling_animation();
		exposeStarling_core();
		exposeStarling_display();
		exposeStarling_events();
		exposeStarling_extensions_colorArgb();
		exposeStarling_filters();
		exposeStarling_rendering();
		exposeStarling_text();
		exposeStarling_texture();
		exposeStarling_utils();
	}
	
	static public function exposeStarling_animation():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// DelayedCall
		settings.canBeCreated = false;
		settings.collection = StarlingAnimationData.exposeDelayedCall();
		ValEditor.registerClass(starling.animation.DelayedCall, settings);
		settings.clear();
		
		// Juggler
		settings.collection = StarlingAnimationData.exposeJuggler();
		ValEditor.registerClass(starling.animation.Juggler, settings);
		settings.clear();
		
		// Tween
		settings.canBeCreated = false;
		settings.collection = StarlingAnimationData.exposeTween();
		ValEditor.registerClass(starling.animation.Tween, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_core():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Starling
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.collection = StarlingCoreData.exposeStarling();
		ValEditor.registerClass(starling.core.Starling, settings);
		
		settings.pool();
	}
	
	static public function exposeStarling_display():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Button
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeButton();
		settings.constructorCollection = StarlingDisplayData.exposeButtonConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Button, settings);
		settings.clear();
		
		// Canvas
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeCanvas();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Canvas, settings);
		settings.clear();
		
		// DisplayObject
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeDisplayObject();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.DisplayObject, settings);
		settings.clear();
		
		// DisplayObjectContainer
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeDisplayObject();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.DisplayObjectContainer, settings);
		settings.clear();
		
		// Image
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeImage();
		settings.visibilityCollection = StarlingDisplayData.getImageVisibility();
		settings.constructorCollection = StarlingDisplayData.exposeImageConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Image, settings);
		settings.clear();
		
		// Mesh
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeMesh();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Mesh, settings);
		settings.clear();
		
		// MeshBatch
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeMeshBatch();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.MeshBatch, settings);
		settings.clear();
		
		// MovieClip
		settings.canBeCreated = false; // TODO : set this to true once Array and Vector are implemented in ValEdit(or)
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeMovieClip();
		settings.constructorCollection = StarlingDisplayData.exposeMovieClipConstructor();
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.MovieClip, settings);
		settings.clear();
		
		// Quad
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_DISPLAY);
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeQuad();
		settings.visibilityCollection = StarlingDisplayData.getQuadVisibility();
		settings.constructorCollection = StarlingDisplayData.exposeQuadConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Quad, settings);
		settings.clear();
		
		// Sprite
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeSprite();
		settings.visibilityCollection = StarlingDisplayData.getSpriteVisibility();
		settings.interactiveFactory = InteractiveFactories.starling_default;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Sprite, settings);
		settings.clear();
		
		// Sprite3D
		settings.canBeCreated = false;
		settings.disposeFunctionName = "dispose";
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingDisplayData.exposeSprite3D();
		settings.visibilityCollection = StarlingDisplayData.getSprite3DVisibility();
		settings.interactiveFactory = InteractiveFactories.starling_3D;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.display.Sprite3D, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_events():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Touch
		settings.canBeCreated = false;
		settings.collection = StarlingEventsData.exposeTouch();
		ValEditor.registerClass(starling.events.Touch, settings);
		settings.clear();
		
		// TouchData
		settings.canBeCreated = false;
		settings.collection = StarlingEventsData.exposeTouchData();
		ValEditor.registerClass(starling.events.TouchData, settings);
		settings.clear();
		
		// TouchProcessor
		settings.canBeCreated = false;
		settings.collection = StarlingEventsData.exposeTouchProcessor();
		ValEditor.registerClass(starling.events.TouchProcessor, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_extensions_colorArgb():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// ColorArgb
		settings.collection = StarlingColorArgbData.exposeColorArgb();
		ValEditor.registerClass(starling.extensions.ColorArgb, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_filters():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// BlurFilter
		settings.collection = StarlingFilterData.exposeBlurFilter();
		settings.constructorCollection = StarlingFilterData.exposeBlurFilterConstructor();
		ValEditor.registerClass(starling.filters.BlurFilter, settings);
		settings.clear();
		
		// ColorMatrixFilter
		settings.collection = StarlingFilterData.exposeColorMatrixFilter();
		settings.constructorCollection = StarlingFilterData.exposeColorMatrixFilterConstructor();
		ValEditor.registerClass(starling.filters.ColorMatrixFilter, settings);
		settings.clear();
		
		// DisplacementMapFilter
		settings.collection = StarlingFilterData.exposeDisplacementMapFilter();
		settings.constructorCollection = StarlingFilterData.exposeDisplacementMapFilterConstructor();
		ValEditor.registerClass(starling.filters.DisplacementMapFilter, settings);
		settings.clear();
		
		// DropShadowFilter
		settings.collection = StarlingFilterData.exposeDropShadowFilter();
		settings.constructorCollection = StarlingFilterData.exposeDropShadowFilterConstructor();
		ValEditor.registerClass(starling.filters.DropShadowFilter, settings);
		settings.clear();
		
		// FilterChain
		settings.collection = StarlingFilterData.exposeFilterChain();
		settings.constructorCollection = StarlingFilterData.exposeFilterChainConstructor();
		ValEditor.registerClass(starling.filters.FilterChain, settings);
		settings.clear();
		
		// FragmentFilter
		settings.collection = StarlingFilterData.exposeFragmentFilter();
		ValEditor.registerClass(starling.filters.FragmentFilter, settings);
		settings.clear();
		
		// GlowFilter
		settings.collection = StarlingFilterData.exposeGlowFilter();
		ValEditor.registerClass(starling.filters.GlowFilter, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_geom():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// Polygon
		settings.canBeCreated = false;
		settings.collection = StarlingGeomData.exposePolygon();
		ValEditor.registerClass(starling.geom.Polygon, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_rendering():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// BatchToken
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeBatchToken();
		ValEditor.registerClass(starling.rendering.BatchToken, settings);
		settings.clear();
		
		// Effect
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeEffect();
		ValEditor.registerClass(starling.rendering.Effect, settings);
		settings.clear();
		
		// FilterEffect
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeFilterEffect();
		ValEditor.registerClass(starling.rendering.FilterEffect, settings);
		settings.clear();
		
		// IndexData
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeIndexData();
		ValEditor.registerClass(starling.rendering.IndexData, settings);
		settings.clear();
		
		// MeshEffect
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeMeshEffect();
		ValEditor.registerClass(starling.rendering.MeshEffect, settings);
		settings.clear();
		
		// Painter
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposePainter();
		ValEditor.registerClass(starling.rendering.Painter, settings);
		settings.clear();
		
		// RenderState
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeRenderState();
		ValEditor.registerClass(starling.rendering.RenderState, settings);
		settings.clear();
		
		// VertexData
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeVertexData();
		ValEditor.registerClass(starling.rendering.VertexData, settings);
		settings.clear();
		
		// VertexDataFormat
		settings.canBeCreated = false;
		settings.collection = StarlingRenderingData.exposeVertexDataFormat();
		ValEditor.registerClass(starling.rendering.VertexDataFormat, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_styles():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// DistanceFieldStyle
		settings.canBeCreated = false;
		settings.collection = StarlingStylesData.exposeDistanceFieldStyle();
		settings.constructorCollection = StarlingStylesData.exposeDistanceFieldStyleConstructor();
		ValEditor.registerClass(starling.styles.DistanceFieldStyle, settings);
		settings.clear();
		
		// MeshStyle
		settings.canBeCreated = false;
		settings.collection = StarlingStylesData.exposeMeshStyle();
		ValEditor.registerClass(starling.styles.MeshStyle, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_text():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// TextField
		settings.canBeCreated = true;
		settings.disposeFunctionName = "dispose";
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_TEXT);
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.isDisplayObject = true;
		settings.isDisplayObjectStarling = true;
		settings.collection = StarlingTextData.exposeTextField();
		settings.visibilityCollection = StarlingTextData.getTextFieldVisibility();
		settings.constructorCollection = StarlingTextData.exposeTextFieldConstructor();
		settings.interactiveFactory = InteractiveFactories.starling_visible;
		settings.hasRadianRotation = true;
		settings.useBounds = true;
		settings.usePivotScaling = true;
		ValEditor.registerClass(starling.text.TextField, settings);
		settings.clear();
		
		// TextFormat
		settings.canBeCreated = true;
		settings.addCategory(CategoryID.STARLING);
		settings.addCategory(CategoryID.STARLING_TEXT);
		if (Assets.exists("valeditor/icon/starling.png", AssetType.IMAGE))
		{
			settings.iconBitmapData = Assets.getBitmapData("valeditor/icon/starling.png");
		}
		settings.collection = StarlingTextData.exposeTextFormat();
		//settings.visibilityCollection = StarlingTextData
		settings.constructorCollection = StarlingTextData.exposeTextFormatConstructor();
		ValEditor.registerClass(starling.text.TextFormat, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_texture():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// AtfData
		settings.collection = StarlingTextureData.exposeAtfData();
		ValEditor.registerClass(starling.textures.AtfData, settings);
		settings.clear();
		
		// ConcreteTexture
		settings.collection = StarlingTextureData.exposeConcreteTexture();
		ValEditor.registerClass(starling.textures.ConcreteTexture, settings);
		settings.clear();
		
		// RenderTexture
		settings.collection = StarlingTextureData.exposeRenderTexture();
		ValEditor.registerClass(starling.textures.RenderTexture, settings);
		settings.clear();
		
		// TextureOptions
		settings.collection = StarlingTextureData.exposeTextureOptions();
		settings.constructorCollection = StarlingTextureData.exposeTextureOptionsConstructor();
		ValEditor.registerClass(starling.textures.TextureOptions, settings);
		settings.clear();
		
		settings.pool();
	}
	
	static public function exposeStarling_utils():Void
	{
		var settings:ValEditorClassSettings = ValEditorClassSettings.fromPool();
		
		// MeshSubSet
		settings.canBeCreated = false;
		settings.collection = StarlingUtilsData.exposeMeshSubSet();
		ValEditor.registerClass(starling.utils.MeshSubset, settings);
		settings.clear();
		
		// Padding
		settings.canBeCreated = false;
		settings.collection = StarlingUtilsData.exposePadding();
		ValEditor.registerClass(starling.utils.Padding, settings);
		settings.clear();
		
		settings.pool();
	}
	#end
	//################################################################################
	//\Starling
	//################################################################################
	
}
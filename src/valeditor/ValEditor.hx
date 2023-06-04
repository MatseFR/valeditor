package valeditor;
import feathers.data.ArrayCollection;
import openfl.errors.Error;
import valedit.ExposedCollection;
import valedit.ObjectType;
import valedit.ValEdit;
import valedit.ValEditClass;
import valedit.ValEditObject;
import valedit.ValEditTemplate;
import valedit.util.RegularPropertyName;
import valeditor.editor.Selection;
import valeditor.ui.InteractiveFactories;

/**
 * ...
 * @author Matse
 */
@:access(valedit.ValEdit)
class ValEditor 
{
	static public var selection(default, null):Selection = new Selection();
	
	static public var currentContainer(get, set):ValEditorContainer;
	static private var _currentContainer:ValEditorContainer;
	static private function get_currentContainer():ValEditorContainer { return _currentContainer; }
	static private function set_currentContainer(value:ValEditorContainer):ValEditorContainer
	{
		if (value == _currentContainer) return value;
		if (_currentContainer != null)
		{
			_currentContainer.close();
		}
		_currentContainer = value;
		if (_currentContainer != null)
		{
			_currentContainer.open();
		}
		return _currentContainer;
	}
	
	static public var categoryCollection(default, null):ArrayCollection<String> = new ArrayCollection<String>();
	static public var classCollection(default, null):ArrayCollection<String> = new ArrayCollection<String>();
	static public var objectCollection(default, null):ArrayCollection<ValEditorObject> = new ArrayCollection<ValEditorObject>();
	static public var templateCollection(default, null):ArrayCollection<ValEditorTemplate> = new ArrayCollection<ValEditorTemplate>();
	
	static public var isMouseOverUI:Bool;
	
	static private var _categoryToClassCollection:Map<String, ArrayCollection<String>> = new Map<String, ArrayCollection<String>>();
	static private var _categoryToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _categoryToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	static private var _classToObjectCollection:Map<String, ArrayCollection<ValEditorObject>> = new Map<String, ArrayCollection<ValEditorObject>>();
	static private var _classToTemplateCollection:Map<String, ArrayCollection<ValEditorTemplate>> = new Map<String, ArrayCollection<ValEditorTemplate>>();
	
	static private var _classMap:Map<String, ValEditorClass> = new Map<String, ValEditorClass>();
	
	static public function registerClass(type:Class<Dynamic>, collection:ExposedCollection, canBeCreated:Bool = true, objectType:Int = -1, ?constructorCollection:ExposedCollection, ?settings:ValEditorClassSettings, ?categoryList:Array<String>):ValEditorClass
	{
		var className:String = Type.getClassName(type);
		if (_classMap.exists(className))
		{
			trace("ValEditor.registerClass ::: Class " + className + " already registered");
			return null;
		}
		
		var v:ValEditorClass = new ValEditorClass();
		
		var result:ValEditClass = ValEdit.registerClass(type, collection, canBeCreated, objectType, constructorCollection, settings, categoryList, v);
		if (result == null) return null;
		
		_classMap.set(className, v);
		
		if (settings != null)
		{
			v.interactiveFactory = settings.interactiveFactory;
			v.hasRadianRotation = settings.hasRadianRotation;
		}
		else
		{
			v.hasRadianRotation = objectType == ObjectType.DISPLAY_STARLING;
		}
		
		if (v.interactiveFactory == null)
		{
			switch (v.objectType)
			{
				case ObjectType.DISPLAY_OPENFL :
					v.interactiveFactory = InteractiveFactories.openFL_default;
				
				#if starling
				case ObjectType.DISPLAY_STARLING :
					v.interactiveFactory = InteractiveFactories.starling_default;
				#end
				
				case ObjectType.OTHER :
					// nothing here
				
				default :
					throw new Error("ValEdit.registerClass");
			}
		}
		
		if (collection.hasValue(RegularPropertyName.PIVOT_X))
		{
			v.hasPivotProperties = true;
		}
		else
		{
			if (v.proxyPropertyMap != null)
			{
				v.hasPivotProperties = v.proxyPropertyMap.hasPropertyRegular(RegularPropertyName.PIVOT_X);
			}
			else
			{
				v.hasPivotProperties = v.propertyMap.hasPropertyRegular(RegularPropertyName.PIVOT_X);
			}
		}
		
		if (collection.hasValue(RegularPropertyName.TRANSFORM))
		{
			v.hasTransformProperty = true;
		}
		else
		{
			if (v.proxyPropertyMap != null)
			{
				v.hasTransformProperty = v.proxyPropertyMap.hasPropertyRegular(RegularPropertyName.TRANSFORM);
			}
			else
			{
				v.hasTransformProperty = v.propertyMap.hasPropertyRegular(RegularPropertyName.TRANSFORM);
			}
		}
		
		if (collection.hasValue(RegularPropertyName.TRANSFORMATION_MATRIX))
		{
			v.hasTransformationMatrixProperty = true;
		}
		else
		{
			if (v.proxyPropertyMap != null)
			{
				v.hasTransformationMatrixProperty = v.proxyPropertyMap.hasPropertyRegular(RegularPropertyName.TRANSFORMATION_MATRIX);
			}
			else
			{
				v.hasTransformationMatrixProperty = v.propertyMap.hasPropertyRegular(RegularPropertyName.TRANSFORMATION_MATRIX);
			}
		}
		
		if (categoryList != null)
		{
			var strCollection:ArrayCollection<String>;
			for (category in categoryList)
			{
				if (!_categoryToClassCollection.exists(category))
				{
					categoryCollection.add(category);
					_categoryToClassCollection.set(category, new ArrayCollection<String>());
					_categoryToObjectCollection.set(category, new ArrayCollection<ValEditorObject>());
					_categoryToTemplateCollection.set(category, new ArrayCollection<ValEditorTemplate>());
				}
				strCollection = _categoryToClassCollection.get(category);
				strCollection.add(className);
			}
		}
		
		var objCollection:ArrayCollection<ValEditorObject>;
		if (!_classToObjectCollection.exists(className))
		{
			objCollection = new ArrayCollection<ValEditorObject>();
			_classToObjectCollection.set(className, objCollection);
		}
		
		var templateCollection:ArrayCollection<ValEditorTemplate>;
		if (!_classToTemplateCollection.exists(className))
		{
			templateCollection = new ArrayCollection<ValEditorTemplate>();
			_classToTemplateCollection.set(className, templateCollection);
		}
		
		for (superName in v.superClassNames)
		{
			if (!_classToObjectCollection.exists(superName))
			{
				objCollection = new ArrayCollection<ValEditorObject>();
				_classToObjectCollection.set(superName, objCollection);
			}
			
			if (!_classToTemplateCollection.exists(superName))
			{
				templateCollection = new ArrayCollection<ValEditorTemplate>();
				_classToTemplateCollection.set(superName, templateCollection);
			}
		}
		
		if (canBeCreated)
		{
			classCollection.add(className);
		}
		
		return v;
	}
	
	static public function unregisterClass(type:Class<Dynamic>):Void
	{
		var className:String = Type.getClassName(type);
		if (!_classMap.exists(className))
		{
			trace("ValEditor.unregisterClass ::: Class " + className + " not registered");
			return;
		}
		
		var valClass:ValEditorClass = _classMap.get(className);
		_classMap.remove(className);
		
		var strCollection:ArrayCollection<String>;
		for (category in valClass.categories)
		{
			strCollection = _categoryToClassCollection.get(category);
			strCollection.remove(className);
			if (strCollection.length == 0)
			{
				// no more class associated with this category : remove category
				categoryCollection.remove(category);
				_categoryToClassCollection.remove(category);
				_categoryToObjectCollection.remove(category);
				_categoryToTemplateCollection.remove(category);
			}
		}
		
		var objectList:Array<ValEditObject> = valClass.getObjectList();
		
		if (valClass.canBeCreated)
		{
			for (obj in objectList)
			{
				destroyObjectInternal(cast obj);
			}
			
			classCollection.remove(className);
			_classToObjectCollection.remove(className);
		}
		else
		{
			for (obj in objectList)
			{
				unregisterObjectInternal(cast obj);
			}
		}
	}
	
	static public function createObjectWithClass(clss:Class<Dynamic>, ?id:String, ?params:Array<Dynamic>):ValEditorObject
	{
		return createObjectWithClassName(Type.getClassName(clss), id, params);
	}
	
	static public function createObjectWithClassName(className:String, ?id:String, ?params:Array<Dynamic>):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var valObject:ValEditorObject = new ValEditorObject(valClass, id);
		
		ValEdit.createObjectWithClassName(className, id, params, valObject);
		
		valObject.interactiveObject = valClass.interactiveFactory(valObject);
		valObject.hasPivotProperties = valClass.hasPivotProperties;
		valObject.hasTransformProperty = valClass.hasTransformProperty;
		valObject.hasTransformationMatrixProperty = valClass.hasTransformationMatrixProperty;
		valObject.hasRadianRotation = valClass.hasRadianRotation;
		
		registerObjectInternal(valObject);
		
		return valObject;
	}
	
	static public function createTemplateWithClass(clss:Class<Dynamic>, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		return createTemplateWithClassName(Type.getClassName(clss), id, constructorCollection);
	}
	
	static public function createTemplateWithClassName(className:String, ?id:String, ?constructorCollection:ExposedCollection):ValEditorTemplate
	{
		var valClass:ValEditorClass = _classMap.get(className);
		var template:ValEditorTemplate = new ValEditorTemplate(valClass, id);
		
		ValEdit.createTemplateWithClassName(className, id, constructorCollection, template);
		
		registerTemplateInternal(template);
		
		return template;
	}
	
	static public function createObjectWithTemplate(template:ValEditorTemplate, ?id:String):ValEditorObject
	{
		var valClass:ValEditorClass = _classMap.get(template.className);
		var valObject:ValEditorObject = new ValEditorObject(valClass, id);
		
		ValEdit.createObjectWithTemplate(template, id, valObject);
		
		valObject.interactiveObject = valClass.interactiveFactory(valObject);
		
		registerObjectInternal(valObject);
		
		return valObject;
	}
	
	static private function registerObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.registerObjectInternal(valObject);
		
		objectCollection.add(valObject);
		
		var objCollection:ArrayCollection<ValEditorObject> = _classToObjectCollection.get(valObject.className);
		objCollection.add(valObject);
		
		for (className in valObject.clss.superClassNames)
		{
			objCollection = _classToObjectCollection.get(className);
			objCollection.add(valObject);
		}
		
		for (category in valObject.clss.categories)
		{
			objCollection = _categoryToObjectCollection.get(category);
			objCollection.add(valObject);
		}
		
		if (_currentContainer != null)
		{
			_currentContainer.add(valObject);
		}
	}
	
	static private function registerTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.registerTemplateInternal(template);
		
		templateCollection.add(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.className);
		collection.add(template);
		
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.add(template);
		}
		
		for (category in template.clss.categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			collection.add(template);
		}
	}
	
	static public function destroyObject(valObject:ValEditorObject):Void
	{
		destroyObjectInternal(valObject);
	}
	
	static private function destroyObjectInternal(valObject:ValEditorObject):Void
	{
		unregisterObjectInternal(valObject);
	}
	
	static private function unregisterObjectInternal(valObject:ValEditorObject):Void
	{
		ValEdit.unregisterObjectInternal(valObject);
		
		objectCollection.remove(valObject);
		
		var objCollection:ArrayCollection<ValEditorObject> = _classToObjectCollection.get(valObject.className);
		objCollection.remove(valObject);
		
		for (className in valObject.clss.superClassNames)
		{
			objCollection = _classToObjectCollection.get(className);
			objCollection.remove(valObject);
		}
		
		for (category in valObject.clss.categories)
		{
			objCollection = _categoryToObjectCollection.get(category);
			objCollection.remove(valObject);
		}
	}
	
	static public function destroyTemplate(template:ValEditorTemplate):Void
	{
		destroyTemplateInternal(template);
	}
	
	static private function destroyTemplateInternal(template:ValEditorTemplate):Void
	{
		unregisterTemplateInternal(template);
	}
	
	static private function unregisterTemplateInternal(template:ValEditorTemplate):Void
	{
		ValEdit.unregisterTemplateInternal(template);
		
		templateCollection.remove(template);
		
		var collection:ArrayCollection<ValEditorTemplate> = _classToTemplateCollection.get(template.className);
		collection.remove(template);
		
		for (className in template.clss.superClassNames)
		{
			collection = _classToTemplateCollection.get(className);
			collection.remove(template);
		}
		
		for (category in template.clss.categories)
		{
			collection = _categoryToTemplateCollection.get(category);
			collection.remove(template);
		}
	}
	
	static public function getClassCollectionForCategory(category:String):ArrayCollection<String>
	{
		return _categoryToClassCollection.get(category);
	}
	
	static public function getValEditClassByClass(clss:Class<Dynamic>):ValEditorClass
	{
		return _classMap.get(Type.getClassName(clss));
	}
	
	static public function getValEditClassByClassName(className:String):ValEditorClass
	{
		return _classMap.get(className);
	}
	
	static public function getObjectCollectionForClass(clss:Class<Dynamic>):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(Type.getClassName(clss));
	}
	
	static public function getObjectCollectionForClassName(className:String):ArrayCollection<ValEditorObject>
	{
		return _classToObjectCollection.get(className);
	}
	
	static public function getTemplateCollectionForClassName(className:String):ArrayCollection<ValEditorTemplate>
	{
		return _classToTemplateCollection.get(className);
	}
	
	static public function getTemplateCollectionForCategory(category:String):ArrayCollection<ValEditorTemplate>
	{
		return _categoryToTemplateCollection.get(category);
	}
	
}
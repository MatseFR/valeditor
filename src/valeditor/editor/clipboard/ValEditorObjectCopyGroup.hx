package valeditor.editor.clipboard;
import haxe.iterators.ArrayIterator;

/**
 * ...
 * @author Matse
 */
class ValEditorObjectCopyGroup 
{
	public var isRealClipboard:Bool = false;
	public var numCopies(get, never):Int;
	
	private function get_numCopies():Int { return this._copies.length; }
	
	private var _copies:Array<ValEditorObjectCopy> = new Array<ValEditorObjectCopy>();
	private var _objectToCopy:Map<ValEditorObject, ValEditorObjectCopy> = new Map<ValEditorObject, ValEditorObjectCopy>();
	
	public function new() 
	{
		
	}
	
	public function iterator():ArrayIterator<ValEditorObjectCopy>
	{
		return this._copies.iterator();
	}
	
	public function clear():Void
	{
		for (copy in this._copies)
		{
			if (this.isRealClipboard)
			{
				copy.object.isInClipboard = false;
				if (copy.object.canBeDestroyed())
				{
					ValEditor.destroyObject(copy.object);
				}
			}
			copy.pool();
		}
		this._copies.resize(0);
		this._objectToCopy.clear();
	}
	
	public function copyFrom(group:ValEditorObjectCopyGroup):Void
	{
		for (copy in group._copies)
		{
			addCopy(copy.clone());
		}
	}
	
	public function addCopy(copy:ValEditorObjectCopy):Void
	{
		if (this._copies.indexOf(copy) != -1) return;
		if (this.isRealClipboard) copy.object.isInClipboard = true;
		this._copies.push(copy);
		this._objectToCopy.set(copy.object, copy);
	}
	
	public function getCopyAt(index:Int):ValEditorObjectCopy
	{
		return this._copies[index];
	}
	
	public function getCopyForObject(object:ValEditorObject):ValEditorObjectCopy
	{
		return this._objectToCopy.get(object);
	}
	
	public function hasCopy(copy:ValEditorObjectCopy):Bool
	{
		return this._copies.indexOf(copy) != -1;
	}
	
	public function hasCopyForObject(object:ValEditorObject):Bool
	{
		return this._objectToCopy.exists(object);
	}
	
	public function removeCopy(copy:ValEditorObjectCopy):Bool
	{
		var result:Bool = this._copies.remove(copy);
		if (result)
		{
			this._objectToCopy.remove(copy.object);
			if (this.isRealClipboard)
			{
				copy.object.isInClipboard = false;
				if (copy.object.canBeDestroyed())
				{
					ValEditor.destroyObject(copy.object);
				}
			}
			copy.pool();
		}
		return result;
	}
	
	public function removeCopyForObject(object:ValEditorObject):Bool
	{
		var copy:ValEditorObjectCopy = getCopyForObject(object);
		if (copy == null) return false;
		return removeCopy(copy);
	}
	
}
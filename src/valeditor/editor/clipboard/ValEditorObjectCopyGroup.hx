package valeditor.editor.clipboard;
import haxe.iterators.ArrayIterator;

/**
 * ...
 * @author Matse
 */
class ValEditorObjectCopyGroup 
{
	public var numCopies(get, never):Int;
	
	private function get_numCopies():Int { return this._copies.length; }
	
	private var _copies:Array<ValEditorObjectCopy> = new Array<ValEditorObjectCopy>();
	
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
			copy.object.isInClipboard = false;
			if (copy.object.canBeDestroyed())
			{
				ValEditor.destroyObject(copy.object);
			}
			copy.pool();
		}
		this._copies.resize(0);
	}
	
	public function addCopy(copy:ValEditorObjectCopy):Void
	{
		if (this._copies.indexOf(copy) != -1) return;
		copy.object.isInClipboard = true;
		this._copies.push(copy);
	}
	
	public function getCopyAt(index:Int):ValEditorObjectCopy
	{
		return this._copies[index];
	}
	
	public function hasCopy(copy:ValEditorObjectCopy):Bool
	{
		return this._copies.indexOf(copy) != -1;
	}
	
	public function removeCopy(copy:ValEditorObjectCopy):Bool
	{
		var result:Bool = this._copies.remove(copy);
		if (result)
		{
			copy.object.isInClipboard = false;
			if (copy.object.canBeDestroyed())
			{
				ValEditor.destroyObject(copy.object);
			}
			copy.pool();
		}
		return result;
	}
	
}
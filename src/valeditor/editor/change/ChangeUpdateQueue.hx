package valeditor.editor.change;

import juggler.animation.IAnimatable;

/**
 * ...
 * @author Matse
 */
class ChangeUpdateQueue implements IAnimatable 
{
	private var _queue:Array<IChangeUpdate> = new Array<IChangeUpdate>();
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._queue.resize(0);
	}
	
	public function add(object:IChangeUpdate):Void
	{
		if (this._queue.indexOf(object) != -1) return;
		this._queue[this._queue.length] = object;
	}
	
	public function advanceTime(time:Float):Void 
	{
		for (object in this._queue)
		{
			object.changeUpdate();
		}
		this._queue.resize(0);
	}
	
}
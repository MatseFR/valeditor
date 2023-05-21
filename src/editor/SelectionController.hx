package editor;
import events.SelectionEvent;
import openfl.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
class SelectionController extends EventDispatcher
{
	public var object(get, set):Dynamic;
	private var _object:Dynamic;
	private function get_object():Dynamic { return this._object; }
	private function set_object(value:Dynamic):Dynamic
	{
		if (this._object == value) return value;
		this._object = value;
		SelectionEvent.dispatch(this, SelectionEvent.CHANGE, this._object);
		return this._object;
	}

	public function new() 
	{
		super();
	}
	
}
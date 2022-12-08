package ui.feathers.theme.flatcolor.settings;

import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
class BaseSettings extends EventDispatcher 
{

	public function new() 
	{
		super();
		
	}
	
	private function dispatchChange():Void
	{
		dispatchEvent(new Event(Event.CHANGE));
	}
	
}
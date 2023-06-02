package editors;

import haxe.DynamicAccess;
import haxe.Constraints.Function;
#if LUA_ALLOWED
import hxlua.Lua;
import hxlua.LuaL;
import hxlua.Types;
#end
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
#if sys
#end
import Type.ValueType;
#if DISCORD_ALLOWED
import Discord;
#end

using StringTools;

class EditorLua
{
	public static var Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
	public static var Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
	public static var Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";
	public static var callbacks:Map<String, Function> = [];

	public var closed:Bool = false;

	#if LUA_ALLOWED
	public var lua:cpp.RawPointer<Lua_State> = null;
	#end

	public function new(script:String)
	{
		#if LUA_ALLOWED
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		// Lua.init_callbacks(lua);

		// trace('Lua version: ' + Lua.version());
		// trace("LuaJIT version: " + Lua.versionJIT());

		var result:Dynamic = LuaL.dofile(lua, script);
		var resultStr:String = Lua.tostring(lua, result);
		if (resultStr != null && result != 0)
		{
			lime.app.Application.current.window.alert(resultStr, 'Error on .LUA script!');
			trace('Error on .LUA script! ' + resultStr);
			lua = null;
			return;
		}
		trace('Lua file loaded succesfully:' + script);

		// Lua variables
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('inChartEditor', true);

		set('curBpm', Conductor.bpm);
		set('bpm', PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet', Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength', FlxG.sound.music.length);
		set('songName', PlayState.SONG.song);

		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		for (i in 0...4)
		{
			set('defaultPlayerStrumX' + i, 0);
			set('defaultPlayerStrumY' + i, 0);
			set('defaultOpponentStrumX' + i, 0);
			set('defaultOpponentStrumY' + i, 0);
		}

		set('downscroll', ClientPrefs.downScroll);
		set('middlescroll', ClientPrefs.middleScroll);

		// stuff 4 noobz like you B)
		addCallback("getProperty", function(variable:String)
		{
			var killMe:Array<String> = variable.split('.');
			if (killMe.length > 1)
			{
				var coverMeInPiss:Dynamic = Reflect.getProperty(EditorPlayState.instance, killMe[0]);

				for (i in 1...killMe.length - 1)
				{
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length - 1]);
			}
			return Reflect.getProperty(EditorPlayState.instance, variable);
		});
		addCallback("setProperty", function(variable:String, value:Dynamic)
		{
			var killMe:Array<String> = variable.split('.');
			if (killMe.length > 1)
			{
				var coverMeInPiss:Dynamic = Reflect.getProperty(EditorPlayState.instance, killMe[0]);

				for (i in 1...killMe.length - 1)
				{
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length - 1], value);
			}
			return Reflect.setProperty(EditorPlayState.instance, variable, value);
		});
		addCallback("getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic)
		{
			if (Std.isOfType(Reflect.getProperty(EditorPlayState.instance, obj), FlxTypedGroup))
			{
				return Reflect.getProperty(Reflect.getProperty(EditorPlayState.instance, obj).members[index], variable);
			}

			var leArray:Dynamic = Reflect.getProperty(EditorPlayState.instance, obj)[index];
			if (leArray != null)
			{
				if (Type.typeof(variable) == ValueType.TInt)
				{
					return leArray[variable];
				}
				return Reflect.getProperty(leArray, variable);
			}
			return null;
		});
		addCallback("setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic)
		{
			if (Std.isOfType(Reflect.getProperty(EditorPlayState.instance, obj), FlxTypedGroup))
			{
				return Reflect.setProperty(Reflect.getProperty(EditorPlayState.instance, obj).members[index], variable, value);
			}

			var leArray:Dynamic = Reflect.getProperty(EditorPlayState.instance, obj)[index];
			if (leArray != null)
			{
				if (Type.typeof(variable) == ValueType.TInt)
				{
					return leArray[variable] = value;
				}
				return Reflect.setProperty(leArray, variable, value);
			}
		});
		addCallback("removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false)
		{
			if (Std.isOfType(Reflect.getProperty(EditorPlayState.instance, obj), FlxTypedGroup))
			{
				var sex = Reflect.getProperty(EditorPlayState.instance, obj).members[index];
				if (!dontDestroy)
					sex.kill();
				Reflect.getProperty(EditorPlayState.instance, obj).remove(sex, true);
				if (!dontDestroy)
					sex.destroy();
				return;
			}
			Reflect.getProperty(EditorPlayState.instance, obj).remove(Reflect.getProperty(EditorPlayState.instance, obj)[index]);
		});

		addCallback("getColorFromHex", function(color:String)
		{
			if (!color.startsWith('0x'))
				color = '0xff' + color;
			return Std.parseInt(color);
		});

		addCallback("setGraphicSize", function(obj:String, x:Int, y:Int = 0)
		{
			var poop:FlxSprite = Reflect.getProperty(EditorPlayState.instance, obj);
			if (poop != null)
			{
				poop.setGraphicSize(x, y);
				poop.updateHitbox();
				return;
			}
		});
		addCallback("scaleObject", function(obj:String, x:Float, y:Float)
		{
			var poop:FlxSprite = Reflect.getProperty(EditorPlayState.instance, obj);
			if (poop != null)
			{
				poop.scale.set(x, y);
				poop.updateHitbox();
				return;
			}
		});
		addCallback("updateHitbox", function(obj:String)
		{
			var poop:FlxSprite = Reflect.getProperty(EditorPlayState.instance, obj);
			if (poop != null)
			{
				poop.updateHitbox();
				return;
			}
		});
		addCallback("changePresence", function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
		{
			#if DISCORD_ALLOWED
			DiscordClient.changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			#end
		});
		addCallback("close", function()
		{
			closed = true;
			return closed;
		});

		call('onCreate', []);
		#end
	}

	#if LUA_ALLOWED
	public function addCallback(name:String, callback:Function):Void
	{
		if (lua == null || (lua != null && (callback != null && !Reflect.isFunction(callback))))
			return;

		callbacks.set(name, callback);

		Lua.pushstring(lua, name);
		Lua.pushcclosure(lua, cpp.Function.fromStaticFunction(callbackHandler), 1);
		Lua.setglobal(lua, name);
	}

	public function removeCallback(name:String):Void
	{
		if (lua == null)
			return;

		callbacks.remove(name);

		Lua.pushnil(lua);
		Lua.setglobal(lua, name);
	}

	private static function callbackHandler(L:cpp.RawPointer<Lua_State>):Int
	{
		/* callback name */
		var name:String = Lua.tostring(L, Lua.upvalueindex(1));

		var n:Int = Lua.gettop(L);

		var args:Array<Any> = [];
		for (i in 0...n)
			args[i] = fromLua(L, i + 1);

		/* clear the stack */
		Lua.pop(L, n);

		if (callbacks.exists(name))
		{
			var ret:Dynamic = Reflect.callMethod(null, callbacks.get(name), args);
			if (ret != null)
			{
				toLua(L, ret);
				return 1;
			}
		}

		return 0;
	}

	public static function toLua(L:cpp.RawPointer<Lua_State>, object:Any):Bool
	{
		switch (Type.typeof(object))
		{
			case TNull:
				Lua.pushnil(L);
			case TBool:
				Lua.pushboolean(L, object ? 1 : 0);
			case TInt:
				Lua.pushinteger(L, cast(object, Int));
			case TFloat:
				Lua.pushnumber(L, cast(object, Float));
			case TClass(String):
				Lua.pushstring(L, cast(object, String));
			case TClass(Array):
				var tArray:Array<Any> = cast object;

				Lua.createtable(L, tArray.length, 0);

				for (i in 0...tArray.length)
				{
					Lua.pushnumber(L, i + 1);
					toLua(L, tArray[i]);
					Lua.settable(L, -3);
				}
			case TClass(haxe.ds.StringMap) | TClass(haxe.ds.ObjectMap):
				var tLen:Int = 0;
				for (n => val in object)
					tLen++;

				Lua.createtable(L, tLen, 0);

				for (n => val in object)
				{
					Lua.pushstring(L, Std.string(n));
					toLua(L, val);
					Lua.settable(L, -3);
				}
			case TObject:
				var tLen:Int = 0;
				for (n in Reflect.fields(object))
					tLen++;

				Lua.createtable(L, tLen, 0);

				for (n in Reflect.fields(object))
				{
					Lua.pushstring(L, n);
					toLua(L, Reflect.field(object, n));
					Lua.settable(L, -3);
				}
			default:
				trace('Cannot convert ${Type.typeof(object)} to Lua');
				return false;
		}

		return true;
	}

	public static function fromLua(L:cpp.RawPointer<Lua_State>, v:Int):Any
	{
		var ret:Any = null;

		switch (Lua.type(L, v))
		{
			case t if (t == Lua.TNIL):
				ret = null;
			case t if (t == Lua.TBOOLEAN):
				ret = Lua.toboolean(L, v) == 1 ? true : false;
			case t if (t == Lua.TNUMBER):
				ret = Lua.tonumber(L, v);
			case t if (t == Lua.TSTRING):
				ret = cast(Lua.tostring(L, v), String);
			case t if (t == Lua.TTABLE):
				var count:Int = 0;
				var array:Bool = true;

				Lua.pushnil(L);

				while (Lua.next(L, v < 0 ? v - 1 : v) != 0)
				{
					if (array)
					{
						if (Lua.type(L, -2) != Lua.TNUMBER)
							array = false;
						else
						{
							var index:Float = Lua.tonumber(L, -2);
							if (index < 0 || Std.int(index) != index)
								array = false;
						}
					}

					count++;
					Lua.pop(L, 1);
				}

				if (count == 0)
					ret = {};
				else if (array)
				{
					var vArray:Array<Any> = [];

					Lua.pushnil(L);

					while (Lua.next(L, v < 0 ? v - 1 : v) != 0)
					{
						vArray[Std.int(Lua.tonumber(L, -2)) - 1] = fromLua(L, -1);
						Lua.pop(L, 1);
					}

					ret = cast vArray;
				}
				else
				{
					var vAccess:DynamicAccess<Any> = {};

					Lua.pushnil(L);

					while (Lua.next(L, v < 0 ? v - 1 : v) != 0)
					{
						switch (Lua.type(L, -2))
						{
							case t if (t == Lua.TSTRING):
								vAccess.set(cast(Lua.tostring(L, -2), String), fromLua(L, -1));
							case t if (t == Lua.TNUMBER):
								vAccess.set(Std.string(Lua.tonumber(L, -2)), fromLua(L, -1));
						}

						Lua.pop(L, 1);
					}

					ret = cast vAccess;
				}
			default:
				trace('Cannot return ${Lua.typename(L, v)} in Haxe');
				ret = null;
		}

		return ret;
	}
	#end

	function typeToString(type:Int):String
	{
		#if LUA_ALLOWED
		switch (type)
		{
			case t if (t == Lua.TBOOLEAN):
				return "boolean";
			case t if (t == Lua.TNUMBER):
				return "number";
			case t if (t == Lua.TSTRING):
				return "string";
			case t if (t == Lua.TTABLE):
				return "table";
			case t if (t == Lua.TFUNCTION):
				return "function";
		}

		if (type <= Lua.TNIL)
			return "nil";
		#end
		return "unknown";
	}

	function getErrorMessage(status:Int):String
	{
		#if LUA_ALLOWED
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null)
			v = v.trim();

		if (v == null || v == "")
		{
			switch (status)
			{
				case e if (e == Lua.ERRRUN):
					return "Runtime Error";
				case e if (e == Lua.ERRMEM):
					return "Memory Allocation Error";
				case e if (e == Lua.ERRERR):
					return "Critical Error";
			}

			return "Unknown Error";
		}

		return v;
		#end
		return null;
	}

	var lastCalledFunction:String = '';

	public function call(func:String, args:Array<Dynamic>):Dynamic
	{
		#if LUA_ALLOWED
		if (closed)
			return Function_Continue;

		lastCalledFunction = func;
		try
		{
			if (lua == null)
				return Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.TFUNCTION)
			{
				if (type > Lua.TNIL)
					trace("ERROR (" + func + "): attempt to call a " + typeToString(type) + " value");

				Lua.pop(lua, 1);
				return Function_Continue;
			}

			for (arg in args)
				toLua(lua, arg);

			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.OK)
			{
				var error:String = getErrorMessage(status);
				trace("ERROR (" + func + "): " + error);
				return Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast fromLua(lua, -1);
			if (result == null)
				result = Function_Continue;

			Lua.pop(lua, 1);
			return result;
		}
		catch (e:Dynamic)
		{
			trace(e);
		}
		#end
		return Function_Continue;
	}

	public function set(variable:String, data:Dynamic)
	{
		#if LUA_ALLOWED
		if (lua == null)
		{
			return;
		}

		toLua(lua, data);
		Lua.setglobal(lua, variable);
		#end
	}

	#if LUA_ALLOWED
	public function getBool(variable:String)
	{
		var result:String = null;
		Lua.getglobal(lua, variable);
		result = fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return false;
		}

		// YES! FINALLY IT WORKS
		// trace('variable: ' + variable + ', ' + result);
		return (result == 'true');
	}
	#end

	public function stop()
	{
		#if LUA_ALLOWED
		if (lua == null)
		{
			return;
		}

		Lua.close(lua);
		lua = null;
		#end
	}
}

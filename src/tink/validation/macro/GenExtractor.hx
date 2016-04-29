package tink.validation.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.FieldInfo;

using haxe.macro.Tools;
using tink.MacroApi;

class GenExtractor {
	static public function args()
		return ['value'];
		
	static public function nullable(e)
		return macro if(value != null) $e else null;
		
	static public function string()
		return macro if(!Std.is(value, String)) throw 'The value `' + value + '` should be String' else value;
		
	static public function int()
		return macro if(!Std.is(value, Int)) throw 'The value `' + value + '` should be Int' else value;
		
	static public function float()
		return macro if(!Std.is(value, Float)) throw 'The value `' + value + '` should be Float' else value;
		
	static public function bool()
		return macro if(!Std.is(value, Bool)) throw 'The value `' + value + '` should be Bool' else value;
		
	static public function date()
		return macro if(!Std.is(value, Date)) throw 'The value `' + value + '` should be Date' else value;
		// TODO: should make a copy? i.e. `Date.fromTime(value.getTime())`
		
	static public function bytes()
		return macro if(!Std.is(value, Bytes)) throw 'The value `' + value + '` should be Bytes' else value;
		
	static public function map(k, v)
		return macro if(!Std.is(value, Map)) throw 'The value `' + value + '` should be Map' else value;
		
	static public function anon(fields:Array<FieldInfo>, ct)
		return (macro function (value:$ct) {
			var __ret:Dynamic = {};
			$b{[for(f in fields) {
				var name = f.name;
				var assert = f.optional ? macro null : macro if(!Reflect.hasField(value, $v{name})) throw $v{'Field `${f.name}` should not be null'};
				macro {
					$assert;
					var value = value.$name;
					__ret.$name = ${f.expr};
				}
			}]}
			return __ret;
		}).getFunction().sure();
		
	static public function array(e:Expr)
	{
		return macro {
			if(!Std.is(value, Array)) throw 'The value `' + value + '` should be Array';
			[for(value in (value:Array<Dynamic>)) $e];
		}
	}
		
	static public function enm(_, ct, _, _) {
		var name = switch ct {
			case TPath({pack: pack, name: name, sub: sub}):
				var ret = pack.copy();
				ret.push(name);
				if(sub != null) ret.push(sub);
				ret;
			default: throw 'assert';
		}
		return macro if(!Std.is(value, $p{name})) throw 'The value `' + value + '` should be an EnumValue' else value;
	}
		
	static public function dyn(_, _)
		return macro value;
		
	static public function dynAccess(_)
		return macro value;
		
	static public function reject(t:Type)
		return 'Cannot extract ${t.toString()}';
		
	static public function rescue(t:Type, _, _)
		return switch t {
			case TDynamic(t) if (t == null):
				Some(dyn(null, null));
			default: 
				None;
		}
}
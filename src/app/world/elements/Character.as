package app.world.elements
{
	import com.piterwilson.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	public class Character extends Sprite
	{
		// Storage
		public var outfit:MovieClip;
		public var animatePose:Boolean;

		private var _itemDataMap:Object;

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		// pData = { x:Number, y:Number, [various "__Data"s], ?params:URLVariables }
		public function Character(pData:Object) {
			super();
			animatePose = false;

			this.x = pData.x;
			this.y = pData.y;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function () { startDrag(); });
			this.addEventListener(MouseEvent.MOUSE_UP, function () { stopDrag(); });

			/****************************
			* Store Data
			*****************************/
			_itemDataMap = {};
			_itemDataMap[ITEM.SKIN] = pData.skin;
			_itemDataMap[ITEM.HAT] = pData.hat;
			_itemDataMap[ITEM.HAIR] = pData.hair;
			_itemDataMap[ITEM.EARS] = pData.ears;
			_itemDataMap[ITEM.EYES] = pData.eyes;
			_itemDataMap[ITEM.MOUTH] = pData.mouth;
			_itemDataMap[ITEM.NECK] = pData.neck;
			_itemDataMap[ITEM.TAIL] = pData.tail;
			_itemDataMap[ITEM.CONTACTS] = pData.contacts;
			_itemDataMap[ITEM.POSE] = pData.pose;

			_itemDataMap[ITEM.PAW] = pData.paw;
			_itemDataMap[ITEM.BACK] = pData.back;
			_itemDataMap[ITEM.PAW_BACK] = pData.pawback;
			
			if(pData.params) _parseParams(pData.params);

			updatePose();
		}

		public function updatePose() {
			var tScale = 3;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new Pose(getItemData(ITEM.POSE)));
			outfit.scaleX = outfit.scaleY = tScale;

			outfit.apply({
				items:[
					getItemData(ITEM.SKIN),
					getItemData(ITEM.HAT),
					getItemData(ITEM.HAIR),
					getItemData(ITEM.EARS),
					getItemData(ITEM.EYES),
					getItemData(ITEM.MOUTH),
					getItemData(ITEM.NECK),
					getItemData(ITEM.TAIL),
					getItemData(ITEM.CONTACTS),

					getItemData(ITEM.PAW),
					getItemData(ITEM.BACK),
					getItemData(ITEM.PAW_BACK)
				]
			});
			if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}

		private function _parseParams(pParams:URLVariables) : void {
			trace(pParams.toString());

			_setParamToType(pParams, ITEM.SKIN, "s", false);
			_setParamToType(pParams, ITEM.HAIR, "d");
			_setParamToType(pParams, ITEM.HAT, "h");
			_setParamToType(pParams, ITEM.EARS, "e");
			_setParamToType(pParams, ITEM.EYES, "y");
			_setParamToType(pParams, ITEM.MOUTH, "m");
			_setParamToType(pParams, ITEM.NECK, "n");
			_setParamToType(pParams, ITEM.TAIL, "t");
			_setParamToType(pParams, ITEM.CONTACTS, "c");
			_setParamToType(pParams, ITEM.POSE, "p", false);
			
			if(pParams.paw == "y") { _itemDataMap[ITEM.PAW] = Costumes.instance.hand; }
			if(pParams.back == "y") { _itemDataMap[ITEM.BACK] = Costumes.instance.fromage; }
			if(pParams.pawb == "y") { _itemDataMap[ITEM.PAW_BACK] = Costumes.instance.backHand; }
			
			if(pParams["sh"] && pParams["sh"] != "") {
				var tColor = pParams["sh"].split(",");
				Costumes.instance.shamanMode = parseInt(tColor.splice(0, 1)[0]);
				if(tColor.length > 0) {
					Costumes.instance.shamanColor = _hexToInt(tColor[0]);
				}
			}
		}
		private function _setParamToType(pParams:URLVariables, pType:String, pParam:String, pAllowNull:Boolean=true) {
			try {
				var tData:ItemData = null, tID = pParams[pParam], tColors;
				if(tID != null && tID != "") {
					tColors = tID.split(","); // Get a list of all the colors (ID is first); ex: 5,ffffff,abcdef,169742
					tID = tColors.splice(0, 1)[0]; // Remove first item and store it as the ID.
					tData = Costumes.instance.getItemFromTypeID(pType, tID);
					if(tColors.length > 0) { tData.colors = _hexArrayToIntArray(tColors, tData.defaultColors); }
				}
				_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );
			} catch (error:Error) { };
		}
		private function _hexArrayToIntArray(pColors:Array, pDefaults:Array) : Array {
			pColors = pColors.concat(); // Shallow Copy
			for(var i = 0; i < pDefaults.length; i++) {
				pColors[i] = pColors[i] ? _hexToInt(pColors[i]) : pDefaults[i];
			}
			return pColors;
		}
		private function _hexToInt(pVal:String) : int {
			return parseInt(pVal, 16);
		}

		public function getParams() : String {
			var tParms = new URLVariables();

			_addParamToVariables(tParms, "s", ITEM.SKIN);
			_addParamToVariables(tParms, "d", ITEM.HAIR);
			_addParamToVariables(tParms, "h", ITEM.HAT);
			_addParamToVariables(tParms, "e", ITEM.EARS);
			_addParamToVariables(tParms, "y", ITEM.EYES);
			_addParamToVariables(tParms, "m", ITEM.MOUTH);
			_addParamToVariables(tParms, "n", ITEM.NECK);
			_addParamToVariables(tParms, "t", ITEM.TAIL);
			_addParamToVariables(tParms, "c", ITEM.CONTACTS);
			_addParamToVariables(tParms, "p", ITEM.POSE);
			
			if(getItemData(ITEM.PAW)) { tParms.paw = "y"; }
			if(getItemData(ITEM.BACK)) { tParms.back = "y"; }
			if(getItemData(ITEM.PAW_BACK)) { tParms.pawb = "y"; }
			
			if(Costumes.instance.shamanMode != SHAMAN_MODE.OFF) {
				tParms["sh"] = Costumes.instance.shamanMode+","+_intToHex(Costumes.instance.shamanColor);
			}

			return tParms.toString().replace(/%2C/g, ",");
		}
		private function _addParamToVariables(pParams:URLVariables, pParam:String, pType:String) {
			var tData:ItemData = getItemData(pType);
			if(tData) {
				pParams[pParam] = tData.id;
				var tColors = getColors(pType);
				if(String(tColors) != String(tData.defaultColors)) { // Quick way to compare two arrays with primitive types
					pParams[pParam] += ","+_intArrayToHexArray(tColors).join(",");
				}
			}
			/*else { pParams[pParam] = ''; }*/
		}
		private function _intArrayToHexArray(pColors:Array) : Array {
			pColors = pColors.concat(); // Shallow Copy
			for(var i = 0; i < pColors.length; i++) {
				pColors[i] = _intToHex(pColors[i]);
			}
			return pColors;
		}
		private function _intToHex(pVal:int) : String {
			return pVal.toString(16).toUpperCase();
		}

		/****************************
		* Color
		*****************************/
		public function getColors(pType:String) : Array {
			return _itemDataMap[pType].colors;
		}

		public function colorItem(pType:String, arg2:int, pColor:String) : Array {
			_itemDataMap[pType].colors[arg2] = Costumes.instance.convertColorToNumber(pColor);
			updatePose();
		}

		/****************************
		* Update Data
		*****************************/
		public function getItemData(pType:String) : ItemData {
			return _itemDataMap[pType];
		}

		public function setItemData(pItem:ItemData) : void {
			var tType = pItem.type == ITEM.SKIN_COLOR ? ITEM.SKIN : pItem.type;
			_itemDataMap[tType] = pItem;
			updatePose();
		}

		public function removeItem(pType:String) : void {
			_itemDataMap[pType] = null;
			updatePose();
		}
	}
}

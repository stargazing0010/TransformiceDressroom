package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import fl.containers.*;
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	
	public class OtherTabPane extends TabPane
	{
		// Storage
		public var character:Character;
		
		public var button_hand		: PushButton;
		public var button_back		: PushButton;
		public var button_backHand	: PushButton;
		
		public var shamanButtons	: Array;
		public var shamanColorPickerButton	: ScaleButton;
		public var shamanColorBlueButton	: GameButton;
		public var shamanColorPinkButton	: GameButton;
		
		public var characterHead	: Character;
		
		// Constructor
		public function OtherTabPane(pCharacter:Character) {
			super();
			character = pCharacter;
			
			var i:int = 0, xx:Number = 15, yy:Number = 15, tButton:GameButton, sizex:Number, sizey:Number, spacingx:Number;
			
			// Shaman options
			sizex = 80; sizey = 50; spacingx = sizex + 10; xx = 5 - spacingx;
			
			shamanButtons = [];
			var icon = addItem(new $ShamFeather()); icon.x = (xx += spacingx) + sizex*0.5; icon.y = yy + sizey*0.5; icon.scaleX = icon.scaleY = 2;
			icon.addEventListener(MouseEvent.CLICK, _onNoShamanButtonClicked);
			xx -= 5;
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"btn_normal_mode", text:"Normal" }), id:SHAMAN_MODE.NORMAL })) as PushButton);
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"btn_hard_mode", text:"Hard" }), id:SHAMAN_MODE.HARD })) as PushButton);
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"btn_divine_mode", text:"Divine" }), id:SHAMAN_MODE.DIVINE })) as PushButton);
			if(GameAssets.shamanMode != SHAMAN_MODE.OFF) {
				shamanButtons[GameAssets.shamanMode-2].toggleOn();
			}
			_registerClickHandler(shamanButtons, _onShamanButtonClicked);
			
			addItem( shamanColorPickerButton = new ScaleButton({ x:xx += spacingx + 30, y:yy + sizey*0.5 - 10, obj:new $ColorWheel() }) );
			
			sizex = 26; sizey = 18;
			
			addItem( shamanColorBlueButton = new GameButton({ x:xx - (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey, origin:0.5 }) );
			shamanColorBlueButton.addChild(_colorSpriteBox({ color:0x95D9D6, size:12, x:-12*0.5, y:-12*0.5 }));
			
			addItem( shamanColorPinkButton = new GameButton({ x:xx + (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey, origin:0.5 }) );
			shamanColorPinkButton.addChild(_colorSpriteBox({ color:0xFCA6F1, size:12, x:-12*0.5, y:-12*0.5 }));
			
			// Line
			yy += 50 + 10;
			_drawLine(this, 5, yy, ConstantsApp.PANE_WIDTH);
			
			// Grid
			yy += 15; xx = 15;
			var grid:Grid = this.addItem( new Grid({ x:xx, y:yy, width:385, columns:5, margin:5 }) ) as Grid;

			this.button_hand = new PushButton({ width:grid.radius, height:grid.radius, obj:new GameAssets.extraObjectWand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_hand);
			if(character.getItemData(ITEM.OBJECT)) { this.button_hand.toggleOn(); }
			
			this.button_back = new PushButton({ width:grid.radius, height:grid.radius, obj:new GameAssets.extraFromage.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_back);
			if(character.getItemData(ITEM.BACK)) { this.button_back.toggleOn(); }
			
			this.button_backHand = new PushButton({ width:grid.radius, height:grid.radius, obj:new GameAssets.extraBackHand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_backHand);
			if(character.getItemData(ITEM.PAW_BACK)) { this.button_backHand.toggleOn(); }
			
			yy += grid.Height + 10;
			
			characterHead = new Character({ skin:GameAssets.skins[GameAssets.defaultSkinIndex], pose:GameAssets.poses[GameAssets.defaultPoseIndex] });
			var saveHeadButton = addItem(new GameButton({ x:348, y:310, width:70, height:70 }));
			saveHeadButton.addChild(characterHead);
			saveHeadButton.addEventListener(MouseEvent.CLICK, _onSaveMouseHeadClicked);
			
			UpdatePane();
		}
		
		/****************************
		* Public
		*****************************/
		
		public override function open() : void {
			super.open();
			
			_updateHead();
		}
		
		/****************************
		* Private
		*****************************/
		private function _drawLine(pParent:MovieClip, pX:Number, pY:Number, pWidth:Number) : void {
			var tLine:Shape = new Shape();
			tLine.x = pX;
			tLine.y = pY;
			pParent.addChild(tLine);
			
			tLine.graphics.lineStyle(1, 0x11181c, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth - 10, 0);
			
			tLine.graphics.lineStyle(1, 0x608599, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth - 10, 1);
		}
		
		// pData = { color:int, box:Sprite[optional], size:Number=20, x:Number[optional], y:Number[optional] }
		private function _colorSpriteBox(pData:Object) : Sprite {
			var tBox:Sprite = pData.box ? pData.box : new Sprite();
			var tSize:Number = pData.size ? pData.size : 20;
			tBox.graphics.beginFill(pData.color, 1);
			tBox.graphics.drawRect(0, 0, tSize, tSize);
			tBox.graphics.endFill();
			if(pData.x) tBox.x = pData.x;
			if(pData.y) tBox.y = pData.y;
			return tBox;
		}
		
		private function _updateHead() {
			// copy character data onto our copy
			for each(var tItemType in ITEM.LAYERING) {
				if(tItemType == ITEM.SKIN_COLOR) continue;
				var data = character.getItemData(tItemType);
				if(data) characterHead.setItemData( data ); else characterHead.removeItem( tItemType );
			}
			characterHead.setItemData( character.getItemData(ITEM.POSE) );
			characterHead.scale = 1;
			
			// Cut the head off the poor mouse ;_;
			var pose = characterHead.outfit.pose;
			var partsToKeep = ["Tete_", "Oeil_", "OeilVide_", "Oeil2_", "Oeil3_", "Oeil4_", "OreilleD_", "OreilleG_"];
			var tChild:DisplayObject = null;
			for(var i:int = pose.numChildren-1; i >= 0; i--) {
				tChild = pose.getChildAt(i);
				
				if(tChild.name && !partsToKeep.some(function(partName){ return tChild.name.indexOf(partName) == 0 })) {
					pose.removeChildAt(i);
				}
			}
			
			var btnSize = 70, size = 60;
			var tBounds = characterHead.getBounds(characterHead);
			var tOffset = tBounds.topLeft;
			FewfDisplayUtils.fitWithinBounds(characterHead, size, size, size, size);
			characterHead.x = btnSize / 2 - (tBounds.width / 2 + tOffset.x) * characterHead.scaleX;
			characterHead.y = btnSize / 2 - (tBounds.height / 2 + tOffset.y) * characterHead.scaleY;
		
		}
		
		/****************************
		* Events
		*****************************/
		private function _registerClickHandler(pArray:Array, pCallback:Function) : void {
			for(var i:int = 0; i < pArray.length; i++) {
				pArray[i].addEventListener(PushButton.STATE_CHANGED_BEFORE, pCallback);
			}
		}
		
		private function _onShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons, pEvent.target as PushButton);
			GameAssets.shamanMode = pEvent.target.id;
			if(pEvent.target.pushed) {
				GameAssets.shamanMode = SHAMAN_MODE.OFF;
			}
			character.updatePose();
			_updateHead();
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons);
			GameAssets.shamanMode = SHAMAN_MODE.OFF;
			character.updatePose();
			_updateHead();
		}

		private function _untoggle(pList:Array, pButton:PushButton=null) : void {
			/*if (pButton != null && pButton.pushed) { return; }*/

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
			_updateHead();
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			for(var i:int = 0; i < shamanButtons.length; i++) {
				shamanButtons[i].toggleOff();
			}
			if(GameAssets.shamanMode >= 2) {
				shamanButtons[GameAssets.shamanMode-2].toggleOn(false);
			}
			
			button_hand.toggle(!!character.getItemData(ITEM.OBJECT), false);
			button_back.toggle(!!character.getItemData(ITEM.BACK), false);
			button_backHand.toggle(!!character.getItemData(ITEM.PAW_BACK), false);
			_updateHead();
		}
		
		private function _onSaveMouseHeadClicked(pEvent:Event) {
			FewfDisplayUtils.saveAsPNG(characterHead, 'mouse_head', character.outfit.scaleX);
		}
	}
}

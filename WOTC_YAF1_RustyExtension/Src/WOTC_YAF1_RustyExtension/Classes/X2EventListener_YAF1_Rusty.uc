//*******************************************************************************************
//  FILE:   YAF1 event listener templates - rusty                              
//  
//	File created	19/01/21	20:00
//	LAST UPDATED    05/02/21	16:30
//
//  This listener uses a Tuple event to adjust YAF1 settings
//
//*******************************************************************************************
class X2EventListener_YAF1_Rusty extends X2EventListener config (Game);

var localized string m_strDestructible, m_strGotLoot;

var config array<name> PsionicValidClasses;
var config bool SHOW_LOOT_MESSAGE, REQUIRES_SCANNING;

//register the event listeners
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_YAF1_Rusty_Style());
	Templates.AddItem(CreateListenerTemplate_YAF1_Rusty_Desc());
	Templates.AddItem(CreateListenerTemplate_YAF1_Rusty_Info());

	return Templates; 
}

//create the actual listeners
static function CHEventListenerTemplate CreateListenerTemplate_YAF1_Rusty_Style()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'YAF1_Rusty_Style');

	Template.RegisterInStrategy = false;
	Template.RegisterInTactical = true;

	Template.AddCHEvent('YAF1_OverrideUnitStyle', On_YAF1_Rusty_Style, ELD_Immediate);

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_YAF1_Rusty_Desc()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'YAF1_Rusty_Desc');

	Template.RegisterInStrategy = false;
	Template.RegisterInTactical = true;

	Template.AddCHEvent('YAF1_OverrideUnitDesc', On_YAF1_Rusty_Desc, ELD_Immediate);

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_YAF1_Rusty_Info()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'YAF1_Rusty_Info');

	Template.RegisterInStrategy = false;
	Template.RegisterInTactical = true;

	Template.AddCHEvent('YAF1_OverrideShowInfo', On_YAF1_Rusty_Info, ELD_Immediate);

	return Template;
}

//create the ELR functions

/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; allow mods to change the style		 SENT FROM YAF1_DEFAULTSCREENSTYLES.UC
;
;	Tuple = new class'LWTuple';
;	Tuple.Id = 'YAF1_OverrideUnitStyle';
;
;	Value = EmptyValue;
;	Value.kind = LWTVObject;
;	Value.o = TargetState;
;	Tuple.Data.AddItem(Value);
;
;	// yes, this is the object and not a name
;	// modders can just get it as a X2StrategyElementTemplate and not cast it
;	Value = EmptyValue;
;	Value.kind = LWTVObject;
;	Value.o = BestTemplate;
;	Tuple.Data.AddItem(Value);
;
;`XEVENTMGR.TriggerEvent('YAF1_OverrideUnitStyle', Tuple);
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/
static function EventListenerReturn On_YAF1_Rusty_Style(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local LWTuple							Tuple;
    local XComGameState_Unit				UnitState;

	local X2StrategyElementTemplateManager	StratMgr;

    Tuple = LWTuple(EventData);

	//bailout if we don't have the minimum things
	if (Tuple == none )
	{
		return ELR_NoInterrupt;
	}

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	UnitState = XComGameState_Unit(Tuple.Data[0].o);

	if (UnitState != none)
	{
		if (UnitState.GetMyTemplate().CharacterGroupName == 'Chryssalid' && UnitState.GetTeam() == eTeam_One
			&& UnitState.GetMyTemplateName() != 'CXQueen')
		{
			//THIS SHOULD BE A HIVE CHRYSSALID, BUT NOT THE QUEEN, SET THE UNIQUE SCREEN
			//set the style based on the conditions
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_HIVE');
			return ELR_NoInterrupt;
		}

		if (UnitState.GetMyTemplate().CharacterGroupName == 'Chryssalid' && UnitState.GetTeam() == eTeam_One
			&& UnitState.GetMyTemplateName() == 'CXQueen')
		{
			//THIS SHOULD BE THE HIVE QUEEN, SET THE UNIQUE SCREEN
			//set the style based on the conditions
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_RULERCXHIVE');
			return ELR_NoInterrupt;
		}

		if ( (UnitState.GetMyTemplateName()	 == 'ViperPrincess'
			|| UnitState.GetMyTemplateName() == 'ViperPrince3'
			|| UnitState.GetMyTemplateName() == 'ViperPrince2'
			|| UnitState.GetMyTemplateName() == 'ViperPrince1')
			&& IsDLCLoaded('ChildrenOfTheKingNew')
			)
		{
			//THIS SHOULD BE THE CHILREN OF THE KING 2.0, SET THE UNIQUE SCREEN
			//HAD TO INCLUDE THE DLC CHECK AS THE 1.0 NON-RULERS ARE CALLED THE SAME TEMPLATE NAME
			//set the style based on the conditions
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_RULERCXCOTK');
			return ELR_NoInterrupt;
		}

		if (UnitState.GetTeam() == eTeam_One)
		{
			//OTHER FACTION 1 TEAMS
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_FAC1');
			return ELR_NoInterrupt;
		}

		if (UnitState.GetTeam() == eTeam_Two)
		{
			//OTHER FACTION 2 TEAMS
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_FAC2');
			return ELR_NoInterrupt;
		}

		if (default.PsionicValidClasses.find(UnitState.GetSoldierClassTemplateName()) != INDEX_NONE)
		{
			//THIS IS ANY CONFIGURED PSI CLASS
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_Templar');
			return ELR_NoInterrupt;
		}

		if (UnitState.GetMyTemplate().CharacterGroupName == 'DarkXComSoldier' || UnitState.GetMyTemplateName() == 'AdvMEC_MOCX' )
		{
			//THIS SHOULD BE ANY MOCX SET THE UNIQUE SCREEN
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_MOCX');
			return ELR_NoInterrupt;
		}

		if (UnitState.GetMyTemplate().CharacterGroupName == 'FactionAnchor')
		{
			//THIS SHOULD BE ANY MOCX SET THE UNIQUE SCREEN
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_FactionAnchor');
			return ELR_NoInterrupt;
		}

		// ADD MORE UNIT CONDITION OVERRIDES HERE
	}
	else 	//.. so this is what shows when tabbing to a relay/psi transmitter/detructable
	{
			Tuple.Data[1].o = StratMgr.FindStrategyElementTemplate('RustyStyle_Destructable');
			return ELR_NoInterrupt;
	}

	//NO MATCHES RETURN
	return ELR_NoInterrupt;
}

/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; allow mods to change the description		SENT FROM YAF1_UIUNITINFO.UC
;	Tuple = new class'LWTuple';
;	Tuple.Id = 'YAF1_OverrideUnitDesc';
;
;	Value = EmptyValue;
;	Value.kind = LWTVObject;
;	Value.o = UnitState;
;	Tuple.Data.AddItem(Value);
;
;	Value = EmptyValue;
;	Value.kind = LWTVString;
;	Value.s = DescText;
;	Tuple.Data.AddItem(Value);
;
;	`XEVENTMGR.TriggerEvent('YAF1_OverrideUnitDesc', Tuple, self);
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/
static function EventListenerReturn On_YAF1_Rusty_Desc(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local LWTuple				Tuple;
    local XComGameState_Unit	UnitState;
	//local UIScreen				UIUnitInfo;

    Tuple = LWTuple(EventData);
	//UIUnitInfo = UIScreen(EventSource);

	//bailout if we don't have the minimum things
	if (Tuple == none)
	{
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(Tuple.Data[0].o);

	if (UnitState != none)
	{
		//set the description string to something
		//Tuple.Data[1].s = UnitState.IsFriendlyToLocalPlayer() ? m_strSoldierInfo : m_strEnemyInfo;

		if	( default.SHOW_LOOT_MESSAGE &&
				( !default.REQUIRES_SCANNING || UnitState.IsUnitAffectedByEffectName('ScanningProtocol') || UnitState.IsUnitAffectedByEffectName('TargetDefinition') )
			)
		{
			if (UnitState.PendingLoot.LootToBeCreated.Length > 0 )
			{
				Tuple.Data[1].s = default.m_strGotLoot @":" @Tuple.Data[1].s;
			}
		}

	}

	return ELR_NoInterrupt;
}

/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; allow mods to change the show/hide behavior	SENT FROM YAF1_UIUNITINFO.UC
;	Tuple = new class'LWTuple';
;	Tuple.Id = 'YAF1_OverrideShowInfo';
;	Tuple.Data.Add(4);
;
;	// The targeted unit.
;	Tuple.Data[0].kind = LWTVObject;
;	Tuple.Data[0].o = Target;
;	// Whether the info should be available.
;	Tuple.Data[1].kind = LWTVBool;
;	Tuple.Data[1].b = XComGameState_Unit(Target) != none;
;	// What to show as a title description
;	Tuple.Data[2].kind = LWTVString;
;	Tuple.Data[2].s = XComGameState_Unit(Target) != none ? XComGameState_Unit(Target).GetName(eNameType_FullNick) : m_strNotAUnit;
;	// What to show as a reason
;	Tuple.Data[3].kind = LWTVString;
;	Tuple.Data[3].s = m_strNoInfoAvailable;
;
;	`XEVENTMGR.TriggerEvent('YAF1_OverrideShowInfo', Tuple);
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/
static function EventListenerReturn On_YAF1_Rusty_Info(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local LWTuple				Tuple;
    local XComGameState_Unit	UnitState;

    Tuple = LWTuple(EventData);

	//bailout if we don't have the minimum things
	if (Tuple == none)
	{
		return ELR_NoInterrupt;
	}

	UnitState = XComGameState_Unit(Tuple.Data[0].o);

	if (UnitState != none )
	{
		//bailout for friendly units ... we know our own abilities ... this includes mind controlled units!
		if (UnitState.IsFriendlyToLocalPlayer())
		{
			return ELR_NoInterrupt;
		}

		// Whether the info should be available.
		//Tuple.Data[1].b = boolshow;

		// What to show as a title description string (or name?)
		//Tuple.Data[2].s = UnitState != none ? UnitState.GetName(eNameType_FullNick) : m_strNotAUnit;

		// What to show as a reason string
		//Tuple.Data[3].s = m_strNoInfoAvailable;

		//	!! THIS GOT SO BIG IT BECAME ITS OWN MOD !!
	}
	else 	//.. so this is what shows when tabbing to a relay/psi transmitter/detructable
	{
		// What to show as a reason string
		Tuple.Data[3].s = default.m_strDestructible;
		return ELR_NoInterrupt;
	}


	return ELR_NoInterrupt;
}

//HELPER FUNC TO CHECK FOR DLC LOADED
static private function bool IsDLCLoaded(name DLCName)
{
	local XComOnlineEventMgr	EventManager;
	local int					Index;

	EventManager = `ONLINEEVENTMGR;

	for(Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--)	
	{
		if(EventManager.GetDLCNames(Index) == DLCName)	
		{
			return true;
		}
	}
	return false;
}

Robot Quest

Robot Quest is a very high level brawler meant to have an increasing skill ceiling

A fighter has up to 4 lite attacks:
	On landing a blow, the fighter creates stagger for follow up attacks

A lite melee attack can be countered in the following ways:
	I. Timing.  The nature of all melees in robot quest are sweeps.  That is
	They are defensive positions with offensive movements.  Each attack will
	wind you back and forth on the center line.
	II.  Block.
		Blocking loses health but is the quickest option to stop damage

The fighter steps off the centerline slightly on every move.  The odd move weaves up,
then attacks down.  The even move weaves down and attacks up.  The collision shapes
reward moving to the outside of an attack and punish moving to the inside.

Enemy Algorithm:
	Enemies are meant to be one of a limited style per entity.  Their strategies
	will differ.
	
	Every enemy has a detect radius that will trigger the seek state if one of the
	entities is a player.  This can really and should really just be accomplished 
	with a mask.
	Because the intention is to have multiple players, the detect function should
	account for multiple players.  There can be at max 4 players so running the
	detect radius constantly for enemies shouldn't be too costly.
	
	The counterbubble determines if the enemy is in attack range and can begin a combination
	or if they should return to seek
	
Layer Key:
	[row, column]
	Kinematic_Body: [1, 1]
	Body_Collider: [1, 2]
	Player: [1, 3]
	Enemy: [1, 4]
	
	HitBox_Player: [2, 1]
	HitBox_Enemy: [2, 2]
	HitCollider_Player: [2, 3]
	HitCollider_enemy: [2, 4]
	CounterBubble_player: [2,5]
	CounterBubble_enemy: [2,6]
	DetectRadius_player: [2,7]
	DetectRaduis_enemy: [2, 8]

Mask Key:
	[row, column]
	Kinematic_Body: [[1,1], [1,2]]
	Body_Collider: [[1,2]]
	HitBox_Player: [[2, 4]]
	HitBox_Enemy: [[2, 3]]
	CounterBubble_Player: [[2,4]]
	CounterBubble_Enemy: [[2,1],[2,3]]
	DetectRadius_Player: [[1,1]]
	DetectRadius_Enemy: [[1,1]]

z-index:
	level = 0
	sprite_overlay = 1
	fighter = 2
	overlapping_object = 3

state_tree

The first layer is just solid bodies. 1,1 will be reserved for any solid thing that can't go
through another solid thing, like characters.
The second layer is a body collider. 1,2 can interact with bodies and bodies can interact with them.
The third layer is a kinematic body of type player.  1, 3 is for player parent nodes.
The fourth layer is the same but for enemies. 1,4 is for enemy parent nodes.

The hitboxes and hitcolliders will be able to affect each other if not self.type.

The attack loop needs simplification and a grab first approach.
I will do another analysis of which states have the fewest transition options
Clinch state should be very binding and although controls are enabled, you
cannot move.  The clinched opponent can only time clinch reverse with pummel.

Timers

Fighter
1. SlipTimer - 0.2
2. DodgeTimer - 0.4
3. ThrowTimer - 0.8
4. KnockdownTimer - 1.2
5. RecoverTimer - 1.2
6. ClinchTimer - 2.4

Player
1. ComboTimer - 0.4

Timer combinations:
	What timers definitely won't go off at the same time?
	The knockdown timer should never overlap with other timers and should timeout preceding timers
	The RecoverTimer should never overlap with other timers
	The throwtimer will overlap the clinchtimer and possibly the slip timer
	The Clinchtimer will overlap the combo timer (pummel) and throw timer
	It may overlap the knockdown and recover timers
	The throwtimer should end the clinch timer
